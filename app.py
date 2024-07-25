import gradio as gr
import sqlite3
import pandas as pd
import time
from llm import LLM, Gemini

schema_path = "schemas/schema_en.sql"
schema = open(schema_path, "r").read()


db_path = "/home/paulo/D/ufv/mestrado/pesquisa/cnpj/db_en.sqlite"
model = "models/phi_Q8_0.gguf"

llm = LLM(model, db_path)
gemini = Gemini()


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
        sql_query = gemini(messages)
    else:
        sql_query = llm(messages)

    conn = sqlite3.connect(db_path)
    try:
        df = pd.read_sql_query(sql_query, conn)
    except Exception as e:
        print(e)
        df = pd.DataFrame()
    
    conn.close()
    
    return sql_query, df



def submit_question(question, model_name, progress=gr.Progress()):
    progress((0, 2), "Gerando SQL...")
    time.sleep(1)  # Simular tempo de processamento

    sql_query, df = text_to_sql(question, model_name)

    progress((1, 2), "Executando Query...")
    time.sleep(2)  # Simular tempo de processamento

    progress((2, 2), "Concluído")

    return sql_query, gr.Dataframe(df, visible=True)

# Função para gerar gráfico com as colunas selecionadas


def generate_plot(df, x_col, y_col, plot_type):
    line_plot = gr.LinePlot(None, None, None, visible=False)
    bar_plot = gr.LinePlot(None, None, None, visible=False)
    scatter_plot = gr.LinePlot(None, None, None, visible=False)

    if plot_type == "Linha":
        line_plot = gr.LinePlot(value=df, x=x_col, y=y_col, visible=True)
    elif plot_type == "Barra":
        bar_plot = gr.BarPlot(value=df, x=x_col, y=y_col, visible=True)
    elif plot_type == "Dispersão":
        scatter_plot = gr.ScatterPlot(value=df, x=x_col, y=y_col, visible=True)

    return line_plot, bar_plot, scatter_plot

def update_columns(df):
            columns = df.columns.tolist()

            v1 = columns[0] if len(columns) > 0 else None
            v2 = columns[1] if len(columns) > 1 else v1

            x_col, y_col = gr.Dropdown(choices=columns, value=v1), gr.Dropdown(
                choices=columns, value=v2)

            return x_col, y_col

# Interface Gradio


def create_interface():
    with gr.Blocks(css="""
        body { 
            font-family: Arial, sans-serif; 
            background-color: #f4f4f9;
            color: #333;
            margin: 0;
            padding: 20px;
        }
        .gr-blocks { 
            max-width: 800px; 
            margin: auto; 
            padding: 20px;
            background: white;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
            border-radius: 10px;
        }
        .gr-textbox, .gr-button, .gr-dataframe, .gr-markdown, .gr-progress { 
            margin-bottom: 20px;
        }
        .gr-row {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
        }
        .gr-center {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
        }
    """) as demo:
        gr.Markdown("# Aplicação Text-to-SQL")  
        
        with gr.Row():
            with gr.Column():
                question = gr.Textbox(
                    label="Pergunta", placeholder="Digite sua pergunta aqui...")
            with gr.Column():
                model_name = gr.Radio(label="Modelo", choices=[
                                    "Gemini", "Modelo Menor"], value="Gemini")

        with gr.Row():
            submit_button = gr.Button("Submeter")

        with gr.Row():
            sql_output = gr.Textbox(label="SQL Gerado", interactive=False)

        with gr.Row():
            result_table = gr.Dataframe(
                label="Resultados da Consulta", interactive=False, height=300, visible=True)


        with gr.Row():
            x_col = gr.Dropdown(label="Coluna X", choices=[], interactive=True)
            y_col = gr.Dropdown(label="Coluna Y", choices=[], interactive=True)
            plot_type = gr.Radio(label="Tipo de Gráfico", choices=[
                                 "Linha", "Barra", "Dispersão"], value="Linha")
            generate_button = gr.Button("Gerar Gráfico")

        with gr.Row():
            line_plot = gr.LinePlot(label="Gráfico de Linha", visible=False)
            bar_plot = gr.BarPlot(label="Gráfico de Barra", visible=False)
            scatter_plot = gr.ScatterPlot(
                label="Gráfico de Dispersão", visible=False)

        submit_button.click(submit_question, inputs=[question, model_name], outputs=[
                            sql_output, result_table])

        result_table.change(update_columns, inputs=[
                            result_table], outputs=[x_col, y_col])

        generate_button.click(generate_plot, inputs=[
                              result_table, x_col, y_col, plot_type], outputs=[line_plot, bar_plot, scatter_plot])
    
        

    return demo


# Cria e lança a interface
demo = create_interface()
demo.launch()
