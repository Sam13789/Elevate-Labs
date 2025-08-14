#!/usr/bin/env python3
"""
Script to create a sample sales database with realistic sales data.
This creates the sales_data.db SQLite database required for Task 7.
"""

import sqlite3
import random
from datetime import datetime, timedelta

def create_sales_database():
    """Create a SQLite database with sample sales data."""
    
    # Connect to SQLite database (creates file if it doesn't exist)
    conn = sqlite3.connect('sales_data.db')
    cursor = conn.cursor()
    
    # Drop table if it exists (for clean start)
    cursor.execute('DROP TABLE IF EXISTS sales')
    
    # Create sales table
    cursor.execute('''
        CREATE TABLE sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            sale_date DATE NOT NULL,
            customer_id INTEGER
        )
    ''')
    
    # Sample products with their base prices
    products = [
        ('Coffee', 4.50),
        ('Tea', 3.25),
        ('Sandwich', 8.75),
        ('Muffin', 3.50),
        ('Salad', 12.00),
        ('Soup', 6.25),
        ('Smoothie', 5.75),
        ('Bagel', 2.95),
        ('Croissant', 4.25),
        ('Juice', 3.80)
    ]
    
    # Generate sample sales data for the last 30 days
    start_date = datetime.now() - timedelta(days=30)
    sales_data = []
    
    for i in range(200):  # Generate 200 sales records
        product_name, base_price = random.choice(products)
        quantity = random.randint(1, 5)
        # Add some price variation (±10%)
        price = round(base_price * random.uniform(0.9, 1.1), 2)
        sale_date = start_date + timedelta(days=random.randint(0, 30))
        customer_id = random.randint(1001, 1050)  # 50 different customers
        
        sales_data.append((product_name, quantity, price, sale_date.strftime('%Y-%m-%d'), customer_id))
    
    # Insert sample data
    cursor.executemany('''
        INSERT INTO sales (product, quantity, price, sale_date, customer_id)
        VALUES (?, ?, ?, ?, ?)
    ''', sales_data)
    
    # Commit changes and close connection
    conn.commit()
    
    # Display some basic info about the created database
    cursor.execute('SELECT COUNT(*) FROM sales')
    total_records = cursor.fetchone()[0]
    
    cursor.execute('SELECT COUNT(DISTINCT product) FROM sales')
    unique_products = cursor.fetchone()[0]
    
    print(f"✅ Sales database created successfully!")
    print(f"📊 Total records: {total_records}")
    print(f"🛍️  Unique products: {unique_products}")
    print(f"💾 Database file: sales_data.db")
    
    # Show sample data
    print("\n📋 Sample records:")
    cursor.execute('SELECT * FROM sales LIMIT 5')
    for row in cursor.fetchall():
        print(f"   {row}")
    
    conn.close()

if __name__ == "__main__":
    create_sales_database()
