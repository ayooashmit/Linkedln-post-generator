import mysql.connector
from mysql.connector import Error
from typing import List, Dict


class FewShotPosts:
    def __init__(self):
        self.connection = None
        try:
            self.connection = self._create_connection()
            if self.connection and self.connection.is_connected():
                self.unique_tags = self._load_unique_tags()
            else:
                self.unique_tags = []
        except Exception as e:
            print(f"Initialization error: {e}")
            self.unique_tags = []

    def _create_connection(self):
        try:
            conn = mysql.connector.connect(
                host="localhost",  # Replace with your credentials
                user="root",
                password="ashmit3108",
                database="linkedin_posts"
            )
            if conn.is_connected():
                print("Successfully connected to the database.")
                return conn
            else:
                print("Failed to establish database connection.")
                return None
        except Error as e:
            print(f"Database connection failed during creation: {e}")
            return None

    def _load_unique_tags(self) -> List[str]:
        """
        Load all unique tags from the database.
        Corrected query to handle JSON arrays.
        """
        if not self.connection or not self.connection.is_connected():
            print("No active database connection to load tags. Attempting to reconnect...")
            self.connection = self._create_connection() # Try to reconnect
            if not self.connection or not self.connection.is_connected():
                print("Failed to reconnect, returning empty tags list.")
                return [] # Return empty if reconnection also fails

        query = """
        SELECT DISTINCT JSON_UNQUOTE(tag_value) AS tag
        FROM posts,
             JSON_TABLE(
                 tags,
                 '$[*]' COLUMNS (tag_value VARCHAR(255) PATH '$')
             ) AS jt;
        """
        cursor = None
        try:
            cursor = self.connection.cursor()
            cursor.execute(query)
            # Fetch all results and extract the tag string
            unique_tags = [row[0] for row in cursor.fetchall()]
            return unique_tags
        except Error as e:
            print(f"Error fetching unique tags: {e}")
            return []
        finally:
            if cursor:
                cursor.close()

    def get_filtered_posts(self, length: str, language: str, tag: str) -> List[Dict]:
        """Get posts filtered by length, language and tag"""
        length_ranges = {
            "Short": (1, 5),
            "Medium": (6, 10),
            "Long": (11, 15),
            "Extended": (16, 25)
        }
        min_len, max_len = length_ranges.get(length, (1, 25))

        query = """
                SELECT
                    text,
                    engagement,
                    line_count,
                    language,
                    tags
                FROM posts
                WHERE language = %s
                AND line_count BETWEEN %s AND %s
                AND JSON_CONTAINS(tags, JSON_QUOTE(%s), '$')
                """

        cursor = None
        try:
            cursor = self.connection.cursor(dictionary=True)
            cursor.execute(query, (language, min_len, max_len, tag))
            return cursor.fetchall()
        except Error as e:
            print(f"Error fetching filtered posts: {e}")
            return []
        finally:
            if cursor:
                cursor.close()

    def categorize_length(self, line_count: int) -> str:
        if line_count <= 5:
            return "Short"
        elif 6 <= line_count <= 10:
            return "Medium"
        elif 11 <= line_count <= 15:
            return "Long"
        else:
            return "Extended"

    def get_tags(self) -> List[str]:
        return self.unique_tags

    def __del__(self):
        if hasattr(self, 'connection') and self.connection.is_connected():
            self.connection.close()


if __name__ == "__main__":
    try:
        fs = FewShotPosts()
        print("Available tags:", fs.get_tags())
        posts = fs.get_filtered_posts("Medium", "English", "Job Search")
        for post in posts:
            print(f"\nPost (Engagement: {post['engagement']}):\n{post['text']}\n")
    except Exception as e:
        print(f"Error: {e}")
# import pandas as pd
# from database import get_connection
#
#
# class FewShotPosts:
#     def __init__(self, file_path="data/processed_posts.json"):
#         self.df = None
#         self.unique_tags = None
#         self.load_posts(file_path)
#
#     def load_posts(self, file_path):
#         with open(file_path, encoding="utf-8") as f:
#             posts = json.load(f)
#             self.df = pd.json_normalize(posts)
#             self.df['length'] = self.df['line_count'].apply(self.categorize_length)
#             # collect unique tags
#             all_tags = self.df['tags'].apply(lambda x: x).sum()
#             self.unique_tags = list(set(all_tags))
#
#     def get_filtered_posts(self, length, language, tag):
#         df_filtered = self.df[
#             (self.df['tags'].apply(lambda tags: tag in tags)) &  # Tags contain 'Influencer'
#             (self.df['language'] == language) &  # Language is 'English'
#             (self.df['length'] == length)  # Line count is less than 5
#         ]
#         return df_filtered.to_dict(orient='records')
#
#     def categorize_length(self, line_count):
#         if line_count <= 5:
#             return "Short"
#         elif 5 < line_count <= 10:
#             return "Medium"
#         elif 10 < line_count <= 15:
#             return "Long"
#         else:
#             return "Extended"
#
#     def get_tags(self):
#         return self.unique_tags
#
#
# if __name__ == "__main__":
#     fs = FewShotPosts()
#     # print(fs.get_tags())
#     posts = fs.get_filtered_posts("Medium","Hinglish","Job Search")
#     print(posts)