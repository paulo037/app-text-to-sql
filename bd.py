import sqlite3
from faker import Faker
import random

# Cria uma instância do Faker
fake = Faker()

# Conecta ao banco de dados SQLite (ou cria se não existir)
conn = sqlite3.connect('ecommerce.db')
cursor = conn.cursor()

# Cria tabelas para o banco de dados de e-commerce
cursor.execute('''
    CREATE TABLE IF NOT EXISTS users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        address TEXT,
        phone TEXT
    )
''')

cursor.execute('''
    CREATE TABLE IF NOT EXISTS products (
        product_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        price REAL,
        stock INTEGER
    )
''')

cursor.execute('''
    CREATE TABLE IF NOT EXISTS orders (
        order_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        order_date TEXT,
        status TEXT,
        total REAL,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
    )
''')

cursor.execute('''
    CREATE TABLE IF NOT EXISTS order_items (
        order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER,
        product_id INTEGER,
        quantity INTEGER,
        price REAL,
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
        FOREIGN KEY (product_id) REFERENCES products(product_id)
    )
''')

# Função para gerar dados falsos para a tabela users
def generate_users(n):
    users = []
    for _ in range(n):
        name = fake.name()
        email = fake.email()
        address = fake.address()
        phone = fake.phone_number()
        users.append((name, email, address, phone))
    return users

# Função para gerar dados falsos para a tabela products
def generate_products(n):
    products = []
    for _ in range(n):
        name = fake.word()
        description = fake.text()
        price = round(random.uniform(10.0, 1000.0), 2)
        stock = random.randint(1, 100)
        products.append((name, description, price, stock))
    return products

# Função para gerar dados falsos para a tabela orders
def generate_orders(n, user_ids):
    orders = []
    for _ in range(n):
        user_id = random.choice(user_ids)
        order_date = fake.date_this_year()
        status = random.choice(['pending', 'completed', 'shipped', 'cancelled'])
        total = round(random.uniform(20.0, 2000.0), 2)
        orders.append((user_id, order_date, status, total))
    return orders

# Função para gerar dados falsos para a tabela order_items
def generate_order_items(n, order_ids, product_ids):
    order_items = []
    for _ in range(n):
        order_id = random.choice(order_ids)
        product_id = random.choice(product_ids)
        quantity = random.randint(1, 10)
        price = round(random.uniform(10.0, 1000.0), 2)
        order_items.append((order_id, product_id, quantity, price))
    return order_items

# Insere dados falsos nas tabelas
users = generate_users(100)
cursor.executemany('INSERT INTO users (name, email, address, phone) VALUES (?, ?, ?, ?)', users)

products = generate_products(50)
cursor.executemany('INSERT INTO products (name, description, price, stock) VALUES (?, ?, ?, ?)', products)

# Pega os IDs gerados para as tabelas users e products
cursor.execute('SELECT user_id FROM users')
user_ids = [row[0] for row in cursor.fetchall()]

orders = generate_orders(200, user_ids)
cursor.executemany('INSERT INTO orders (user_id, order_date, status, total) VALUES (?, ?, ?, ?)', orders)

# Pega os IDs gerados para as tabelas orders e products
cursor.execute('SELECT order_id FROM orders')
order_ids = [row[0] for row in cursor.fetchall()]

cursor.execute('SELECT product_id FROM products')
product_ids = [row[0] for row in cursor.fetchall()]

order_items = generate_order_items(500, order_ids, product_ids)
cursor.executemany('INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)', order_items)

# Salva (commit) as mudanças e fecha a conexão com o banco de dados
conn.commit()
conn.close()

print("Banco de dados de e-commerce criado com dados falsos.")
