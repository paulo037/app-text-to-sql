from langchain_core.runnables import RunnableLambda
from llama_cpp import Llama
from langgraph.graph import END, StateGraph
from typing import List
from typing_extensions import TypedDict
from langchain_community.utilities.sql_database import SQLDatabase
import re
import sqlite3


class GraphState(TypedDict):
    """
    Represents the state of a graph during query generation and execution.

    Attributes:
        llm: The pipeline used to generate the SQL query.
        db: The database instance that the query will run on.
        messages: A history of messages sent to the pipeline during query generation.
        output: A list of dictionaries containing the results of the executed query.
        error: Any error message encountered during query execution.
        attempts: The number of attempts made to generate a valid SQL query.
    """
    llm: Llama
    db: SQLDatabase
    messages: List[dict]
    output: List[dict]
    error: str
    sql: str
    attempts: int


def generate_sql(state):
    """
    Generate answer

    Args:
        state (dict): The current graph state

    Returns:
        state (dict): New messages added to state, that contains LLM generation
    """

    messages = []
    roles = []

    for i in range(len(state["messages"]) - 1, -1, -1):
        message = state["messages"][i]
        if message["role"] not in roles:
            roles.append(message["role"])
            messages.append(message)

    messages.reverse()

    llm = state["llm"]

    args = {
        "temperature": 0.2,
        "top_p": 0.95,
        "max_tokens": 300,
        "stop": ["[/SQL]", "<|end|>"],
        "top_k": 10,
    }


    sql = llm.create_chat_completion(messages, **args)['choices'][0]['message']['content']

    messages.append({"role": "assistant", "content": sql})
    state["messages"] = messages

    # print(llm.tokenizer.apply_chat_template(messages, tokenize=False))

    if state["attempts"] == None:
        state["attempts"] = 1
    else:
        state["attempts"] += 1
    return state


def sanatize_sql(state):
    """
    Sanitizes the SQL query.

    Args:
        state (dict): The current graph state.

    Returns:
        state (dict): Now with a sanitized SQL query.
    """

    pattern = r"\[SQL\](.*?)\[/SQL\]"

    messages = state["messages"]

    sql = messages[-1]['content']

    matches = re.findall(pattern, sql, re.DOTALL)
    if matches:
        sql = matches[-1]
    else:
        sql = ";"

    if sql == ";":
        pattern = r"SELECT(.*?)\;"

        messages = state["messages"]

        sql = messages[-1]['content']

        matches = re.findall(pattern, sql, re.DOTALL)
        if matches:
            sql = "SELECT " + matches[-1] + ";"
        else:
            sql = ";"

    state["sql"] = sql

    return state

def run_sql(state):
    """
    Runs a SQL query and verifies the answer.

    Args:
        state (dict): The current graph state.

    Returns:
        dict: The updated state with verification result added.
    """
    sql = state["sql"]
    db = state["db"]
    state["error"] = None

    try:
        out = db.run(sql, include_columns=True)
        if out:
            state["output"] = out
        else:
            state["output"] = [{}]
    except Exception as e:
        state["error"] = str(e.args[0]) if e.args else str(e)
        state["messages"].append({"role": "sqlite", "content": state["error"]})

    return state

# Edges

def stop_or_retry(state):
    """
    Determines whether to re-generate an answer, or return the answer.

    Args:
        state (dict): The current graph state

    Returns:
        str: Binary decision for next node to call
    """

    max_attempts = 3

    if state["error"] and state["attempts"] < max_attempts:
        return "generate_sql"

    if state["error"] and state["attempts"] >= max_attempts:
        state["sql"] = ";"
    return "stop"


class Sqlite():
    def __init__(self, db_path):
        self.db_path = db_path

    def run(self, sql, include_columns=True):

        try:
          conn = sqlite3.connect(self.db_path)
          cursor = conn.cursor()

        except:
          cursor.execute("PRAGMA foreign_keys = OFF;")
        cursor.execute("EXPLAIN " + sql)
        cursor.close()
        conn.close()


workflow = StateGraph(GraphState)

# Define the nodes
workflow.add_node("generate_sql", generate_sql)
workflow.add_node("sanatize_sql", sanatize_sql)
workflow.add_node("run_sql", run_sql)

# Build graph
workflow.set_entry_point("generate_sql")
workflow.add_edge("generate_sql", "sanatize_sql")
workflow.add_edge("sanatize_sql", "run_sql")
workflow.add_conditional_edges(
    "run_sql",
    stop_or_retry,
    {
        "generate_sql": "generate_sql",
        "stop": END,
    },
)


class LLM():
    def __init__(self, model_path, db_path):
        self.model = Llama(model_path=model_path, n_ctx=4096)
        self.db = Sqlite(db_path)
        self.app = workflow.compile()

    def __call__(self, messages):
        state = {
            "llm": self.model,
            "db": self.db,
            "messages": messages,
            "output": [],
            "error": None,
            "sql": None,
            "attempts": 0
        }

        if True:
            for output in self.app.stream(state):
                for key, value in output.items():
                    print("=" * 30)
                    print(key)
                    print("-" * 30)
                    if key == "generate_sql":
                        print(value["messages"][-1]["content"])
                    elif key == "sanatize_sql":
                        print(value["sql"])
                    elif key == "run_sql":
                        print(
                            value["output"] if not value["error"] else value["error"])
                    print("=" * 30)

            sql = value.get('sql', ';')

        else:
            sql = self.app.invoke(state).get('sql', ';')
        return sql

