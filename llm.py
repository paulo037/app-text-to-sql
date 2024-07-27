from langchain_core.runnables import RunnableLambda
from llama_cpp import Llama
from langgraph.graph import END, StateGraph
from typing import List
from typing_extensions import TypedDict
from langchain_community.utilities.sql_database import SQLDatabase
import re
import sqlite3
import google.generativeai as genai
import os
from dotenv import load_dotenv
from  pprint import pprint
load_dotenv()
import os

script_dir = os.path.dirname(os.path.abspath(__file__))

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
    path: List[dict]


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

    sql = llm(messages)
    
    state["sql"] = sql

    messages.append({"role": "assistant", "content": sql})
    state["messages"] = messages

    # print(llm.tokenizer.apply_chat_template(messages, tokenize=False))

    if state["attempts"] == None:
        state["attempts"] = 1
    else:
        state["attempts"] += 1

    state['path'].append({'node': 'generate_sql', 'output': sql})
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

        state['path'].append({'node': 'run_sql', 'output': 'ok'})
    except Exception as e:
        state["error"] = str(e.args[0]) if e.args else str(e)
        state['path'].append({'node': 'run_sql', 'output': state["error"]})
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
        state['path'].append(
            {'node': 'stop_or_retry', 'output': 'generate_sql'})
        return "generate_sql"

    if state["error"] and state["attempts"] >= max_attempts:
        state["sql"] = ";"

    state['path'].append({'node': 'stop_or_retry', 'output': 'stop'})
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


def build_app():
    workflow = StateGraph(GraphState)

    # Define the nodes
    workflow.add_node("generate_sql", generate_sql)
    workflow.add_node("run_sql", run_sql)

    # Build graph
    workflow.set_entry_point("generate_sql")
    workflow.add_edge("generate_sql", "run_sql")
    workflow.add_conditional_edges(
        "run_sql",
        stop_or_retry,
        {
            "generate_sql": "generate_sql",
            "stop": END,
        },
    )
    
    return workflow.compile()


class SQLGenerator():
    def __init__(self, model, _call):
        self.model = model
        self._call = _call

    def __call__(self, messages):
        return self._call(self.model, messages)


class LLM():
    def __init__(self, model_path, db_path):
        self.model = Llama(model_path=model_path, n_ctx=4096)
        self.db = Sqlite(db_path)
        self.app = build_app()

    def __call__(self, messages):

        def _call(model: Llama, messages):
            args = {
                "temperature": 0.2,
                "top_p": 0.95,
                "max_tokens": 300,
                "stop": ["[/SQL]", "<|end|>"],
                "top_k": 10,
            }

            sql = model.create_chat_completion(
                messages, **args)['choices'][0]['message']['content']

            pattern = r"SELECT(.*?)\;"

            matches = re.findall(pattern, sql, re.DOTALL)
            if matches:
                sql = "SELECT " + matches[-1] + ";"
            else:
                sql = ";"
            return sql

        state = {
            "llm": SQLGenerator(self.model, _call),
            "db": self.db,
            "messages": messages,
            "output": [],
            "error": None,
            "sql": None,
            "attempts": 0,
            "path": []
        }

        state = self.app.invoke(state)
        
        pprint(state['path'])
        
        return state['path'], state.get('sql', ';')


class Gemini():
    def __init__(self, db_path):
        genai.configure(api_key=os.getenv("GOOGLE_API"))
        self.model = genai.GenerativeModel(model_name="gemini-1.5-flash-latest")
        self.gen_template = open(os.path.join(script_dir,"templates/gemini_gen_template.txt"), "r").read()
        self.fix_template = open(os.path.join(script_dir,"templates/gemini_fix_template.txt"), "r").read()
        
        self.db = Sqlite(db_path)
        self.app = build_app()

    def __call__(self, messages):
        def _call(model, messages):
            question, schema, error, assistant = "", "", "", ""

            for message in messages:
                if message["role"] == "user":
                    question = message["content"]
                elif message["role"] == "schema":
                    schema = message["content"]
                elif message["role"] == "assistant":
                    assistant = message["content"]
                elif message["role"] == "sqlite":
                    error = message["content"]

            if not error:
                prompt = self.gen_template.format(
                    schema=schema, question=question)
            else:
                prompt = self.fix_template.format(
                    schema=schema, question=question, predicted=assistant, error=error)

            try:
                response = model.generate_content(prompt)
                sql_blocks = re.findall(
                    r'```sql(.*?)```', response.text, re.DOTALL)

                return sql_blocks[-1].strip() if sql_blocks else ""

            except Exception as e:
                return str(e)

        state = {
            "llm": SQLGenerator(self.model, _call),
            "db": self.db,
            "messages": messages,
            "output": [],
            "error": None,
            "sql": None,
            "attempts": 0,
            "path": []
        }

        state = self.app.invoke(state)
        
        pprint(state['path'])
        
        return state['path'], state.get('sql', ';')
