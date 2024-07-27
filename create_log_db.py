import sqlite3

conn = sqlite3.connect('log.db')

cursor = conn.cursor()

cursor.execute('''
    CREATE TABLE IF NOT EXISTS queries_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT,
        sql_query TEXT,
        path TEXT,
        model_name TEXT,
        feedback TEXT,
        rating TEXT
    )
''')

conn.commit()
conn.close()

import sqlite3

def get_all_queries():
    conn = sqlite3.connect('log.db')
    cursor = conn.cursor()
    
    cursor.execute("SELECT * FROM queries_log")
    rows = cursor.fetchall()
    
    conn.close()
    return rows

# Exemplo de uso
all_queries = get_all_queries()
for query in all_queries:
    print(query)
