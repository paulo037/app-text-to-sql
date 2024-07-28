import streamlit as st
from streamlit_option_menu import option_menu 
import sqlite3
import pandas as pd
from llm import LLM, Gemini
import os

script_dir = os.path.dirname(os.path.abspath(__file__))



schema_path = os.path.join(script_dir, "schemas/schema_en_with_examples.sql")
schema = open(schema_path, "r").read()
log_db_path =  os.path.join(script_dir,"log.db")
db_path =  os.path.join(script_dir, "...")
model =  os.path.join(script_dir, "models/phi_Q8_0.gguf")

llm = LLM(model, db_path)
gemini = Gemini(db_path)

import json

def log_query_to_db(question, sql_query, path, model_name):
    conn = sqlite3.connect(log_db_path)
    cursor = conn.cursor()

    cursor.execute("INSERT INTO queries_log (question, sql_query, path, model_name) VALUES (?, ?, ?, ?)",
                   (question, sql_query, json.dumps(path), model_name))
    conn.commit()
    conn.close()

def update_feedback_in_db(question, feedback, rating):
    conn = sqlite3.connect(log_db_path)
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE queries_log
        SET feedback = ?, rating = ?
        WHERE question = ?
    """, (feedback, rating, question))
    conn.commit()
    conn.close()


def text_to_sql(question, model_name):
    messages = [
        {
            "role": "schema",
            "content": schema
        },
        {
            "role": "user",
            "content": question
        }]

    if model_name == "Gemini":
        path, sql_query = gemini(messages)
    else:
        path, sql_query = llm(messages)

    conn = sqlite3.connect(db_path)
    try:
        df = pd.read_sql_query(sql_query, conn)
    except Exception as e:
        print(e)
        df = pd.DataFrame()

    conn.close()

    return sql_query, df, path

def main():
    st.set_page_config(page_title="LLM App", layout="wide")

    # Initialize session state to hold the DataFrame and SQL query
    if 'df' not in st.session_state:
        st.session_state.df = pd.DataFrame()
    if 'sql_query' not in st.session_state:
        st.session_state.sql_query = ""
    if 'path' not in st.session_state:
        st.session_state.path = []
    if 'question' not in st.session_state:
        st.session_state.question = ""

    with st.sidebar:
        selected = option_menu("Menu", ["Chat", "Gráficos", "Ver Schema"],
                               icons=["chat", "bar-chart", "database"],
                               menu_icon="menu-hamburger", default_index=0,
                               styles={
                                   "container": {"padding": "0!important", "background-color": "rgb(38 39 48)"},
                                   "icon": {"color": "#FFFFFF"},
                                   "nav-link": {"font-size": "16px", "text-align": "left", "margin": "0px", "--hover-color": "#08c"},
                                   "nav-link-selected": {"background-color": "#08c"}
                               })

    if selected == "Chat":
        st.header("Chat")
        question = st.text_input("Pergunta", placeholder="Digite sua pergunta aqui...")

        model_name = st.radio("Modelo", ["Gemini", "Modelo Menor"], index=0, key="model_name", horizontal=True)

        if st.button("Submeter"):
            with st.spinner('Gerando SQL...'):
                sql_query, df, path = text_to_sql(question, model_name)
                st.session_state.sql_query = sql_query  # Save the SQL query to session state
                st.session_state.df = df  # Save the dataframe to session state
                st.session_state.path = path  # Save the path to session state
                st.session_state.question = question  # Save the question to session state
                st.success('Concluído')

                # Log the query to the database
                log_query_to_db(question, sql_query, path, model_name)

        # Display the SQL query and DataFrame if they exist in session state
        if st.session_state.sql_query:
            st.subheader("SQL Gerado")
            st.code(st.session_state.sql_query, language='sql')
        if not st.session_state.df.empty:
            st.subheader("Resultados da Consulta")
            st.dataframe(st.session_state.df.head(100))

        feedback = st.text_input("Feedback", placeholder="Digite seu feedback aqui...")
        rating = st.radio("Avaliação", ["👍", "👎"], index=0, horizontal=True)
        if st.button("Enviar feedback"):
            update_feedback_in_db(st.session_state.question, feedback, rating == "👍")
            st.write("Feedback enviado! Obrigado.")

    elif selected == "Gráficos":
        st.header("Gráficos")

        if not st.session_state.df.empty:
            st.write("Selecione as colunas e o tipo de gráfico")

            c1, c2 = st.columns(2)

            with c1:
                x_col = st.selectbox("Coluna X", st.session_state.df.columns)
            with c2:
                y_col = st.selectbox("Coluna Y", st.session_state.df.columns)

            plot_type = st.radio("Tipo de Gráfico", ["Linha", "Barra", "Dispersão"], horizontal=True)

            if st.button("Gerar Gráfico"):
                if plot_type == "Linha":
                    st.line_chart(st.session_state.df, x=x_col, y=y_col)
                elif plot_type == "Barra":
                    st.bar_chart(st.session_state.df, x=x_col, y=y_col)
                elif plot_type == "Dispersão":
                    st.scatter_chart(st.session_state.df, x=x_col, y=y_col)
        else:
            st.write("Por favor, faça uma consulta na aba 'Chat' para carregar os dados.")

    elif selected == "Ver Schema":
        st.header("Schema do Banco de Dados")
        st.markdown(f"```\n{schema}\n```")

if __name__ == "__main__":
    main()


