# Task 7: Basic Sales Summary from SQLite Database using Python

## 📝 Project Overview

This project demonstrates how to use SQL inside Python to analyze sales data from a SQLite database. It includes connecting to a database, running SQL queries, displaying results with print statements, and creating visualizations with matplotlib.

## 🎯 Objective

Use SQL inside Python to pull simple sales info (like total quantity sold, total revenue), and display it using basic print statements and a simple bar chart.

## 🛠️ Tools Used

- **Python** (sqlite3, pandas, matplotlib, seaborn)
- **SQLite** (built into Python — no setup needed!)
- **Jupyter Notebook**

## 📂 Project Structure

```
project/
├── create_sales_db.py          # Script to create sample sales database
├── sales_analysis.ipynb        # Main Jupyter notebook for analysis
├── sales_data.db              # SQLite database file (generated)
├── sales_chart.png            # Generated bar chart
├── sales_analysis_dashboard.png # Generated dashboard
├── requirements.txt           # Python dependencies
└── README.md                  # This file
```

## 🚀 Getting Started

### Prerequisites

- Python 3.7 or higher
- pip (Python package installer)

### Installation

1. **Clone or download this repository**

2. **Install required packages:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Create the sales database:**
   ```bash
   python create_sales_db.py
   ```

4. **Run the sales analysis using Jupyter notebook:**
   ```bash
   jupyter notebook sales_analysis.ipynb
   ```

## 📊 Dataset

The project uses a sample SQLite database (`sales_data.db`) with realistic sales data including:

- **Products**: Coffee, Tea, Sandwich, Muffin, Salad, Soup, Smoothie, Bagel, Croissant, Juice
- **Sales Records**: 200 transactions over 30 days
- **Fields**: product, quantity, price, sale_date, customer_id

### Database Schema

```sql
CREATE TABLE sales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    price REAL NOT NULL,
    sale_date DATE NOT NULL,
    customer_id INTEGER
);
```

## 🔍 Key SQL Queries

### Main Sales Summary Query
```sql
SELECT 
    product,
    SUM(quantity) AS total_qty,
    SUM(quantity * price) AS revenue
FROM sales 
GROUP BY product
ORDER BY revenue DESC
```

### Daily Sales Trend Query
```sql
SELECT 
    sale_date,
    SUM(quantity * price) AS daily_revenue,
    SUM(quantity) AS daily_quantity
FROM sales 
GROUP BY sale_date
ORDER BY sale_date
```

## 📈 Sample Output

```
📊 SALES SUMMARY RESULTS:
==================================================
  product  total_qty  revenue
    Salad         66   783.24
 Sandwich         64   563.64
 Smoothie         79   470.02
     Soup         55   344.80
   Coffee         62   280.61
    Juice         73   273.57
   Muffin         63   219.81
    Bagel         62   185.19
      Tea         46   148.75
Croissant         28   119.19

📈 KEY METRICS:
💰 Total Revenue: $3388.82
📦 Total Quantity Sold: 598
🛍️  Number of Products: 10
🥇 Top Product by Revenue: Salad ($783.24)
```

## 📊 Visualizations

The project generates several visualizations:

1. **Simple Bar Chart** (`sales_chart.png`) - Revenue by product
2. **Comprehensive Dashboard** (`sales_analysis_dashboard.png`) - Multiple charts including:
   - Revenue by product
   - Quantity sold by product
   - Average price by product
   - Daily revenue trend

## 🎓 Learning Outcomes

By completing this task, you will learn:

- ✅ How to write basic SQL queries
- ✅ Practice importing SQL data into Python
- ✅ Perform simple data summaries
- ✅ Create your first sales chart
- ✅ Use pandas for data manipulation
- ✅ Integrate SQLite with Python applications

## ❓ Interview Questions & Answers

### **Q: How did you connect Python to a database?**
**A:** I used the `sqlite3` library (built into Python) with `sqlite3.connect("sales_data.db")`

### **Q: What SQL query did you run?**
**A:** I ran a GROUP BY query: `SELECT product, SUM(quantity) AS total_qty, SUM(quantity * price) AS revenue FROM sales GROUP BY product ORDER BY revenue DESC`

### **Q: What does GROUP BY do?**
**A:** GROUP BY aggregates rows with the same values in specified columns into groups, allowing aggregate functions like SUM() to be applied to each group separately.

### **Q: How did you calculate revenue?**
**A:** Revenue = SUM(quantity * price) - I multiplied quantity by price for each sale and summed the results for each product group.

### **Q: How did you visualize the result?**
**A:** I used matplotlib to create bar charts showing revenue by product with `df.plot(kind='bar', x='product', y='revenue')`

### **Q: What does pandas do in your code?**
**A:** Pandas loads SQL query results into a DataFrame using `pd.read_sql_query()`, providing easy data manipulation and integration with matplotlib for plotting.

### **Q: What's the benefit of using SQL inside Python?**
**A:** Combines SQL's powerful querying capabilities with Python's data analysis tools, allowing efficient data extraction and seamless integration with visualization libraries.

### **Q: Could you run the same SQL query directly in DB Browser for SQLite?**
**A:** Yes, the exact same SQL query can be run in DB Browser for SQLite or any SQLite client to get the same results.

## 🔧 Technical Implementation

### Database Connection
```python
import sqlite3
conn = sqlite3.connect("sales_data.db")
```

### Running SQL Queries
```python
import pandas as pd
query = "SELECT product, SUM(quantity) AS total_qty, SUM(quantity * price) AS revenue FROM sales GROUP BY product"
df = pd.read_sql_query(query, conn)
```

### Creating Visualizations
```python
import matplotlib.pyplot as plt
df.plot(kind='bar', x='product', y='revenue')
plt.savefig("sales_chart.png")
plt.show()
```

## 📝 Additional Features

The solution includes several enhancements beyond the basic requirements:

- **Error handling** for database connections
- **Multiple visualization types** (bar charts, line charts, dashboard)
- **Comprehensive data analysis** with key metrics
- **Professional code structure** with functions and documentation
- **Interactive Jupyter notebook** with step-by-step explanations

## 🤝 Contributing

This is a learning project for Task 7. Feel free to explore and modify the code to enhance your understanding of SQL and Python integration.

## 📄 License

This project is for educational purposes as part of Task 7 completion.

---

**Task Completion Date:** 2025  
**Author:** Task 7 Solution  
**Tools:** Python, SQLite, pandas, matplotlib, Jupyter Notebook
