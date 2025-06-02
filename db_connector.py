import mysql.connector

def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="ashmit3108",
        database="linkedin_posts",
        port=3306  # Default MySQL port
    )

# Test connection
if __name__ == "__main__":
    try:
        conn = get_connection()
        print(" Connection successful")
        conn.close()
    except Exception as e:
        print(f"Connection failed: {e}")