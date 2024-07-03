from langchain_community.llms import Ollama
from langchain_core.prompts import PromptTemplate

template= """# <|system|>
You are a chatbot tasked with responding to questions about an SQLite database.
Your responses must always consist of valid SQL code, and only that.
If you are unable to generate SQL for a question, respond with 'I do not know'.

# <|ddl|>
The query will run on a database with the following schema:
{schema}

# <|user|>
{question}

# <|assistant|>
[SQL]"""

# Initialize the Ollama model
llm = Ollama(model="paulo037/stablecodespiderfp16", keep_alive=-1, stop=["[/SQL]", "<|im_end|>"], temperature=-1)

prompt = PromptTemplate.from_template(template)
chain = (prompt | llm)

