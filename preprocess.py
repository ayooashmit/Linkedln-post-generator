import json
import mysql.connector
from mysql.connector import Error
from llm_helper import llm
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import JsonOutputParser
from langchain_core.exceptions import OutputParserException
from typing import List, Dict, Any


class DatabaseProcessor:
    def __init__(self):
        self.connection = None
        self.connect()

    def connect(self):
        try:
            self.connection = mysql.connector.connect(
                host="localhost",
                user="root",
                password="ashmit3108",
                database="linkedin_posts"
            )
            if self.connection.is_connected():
                print("DatabaseProcessor: Successfully connected to the database.")
            else:
                print("DatabaseProcessor: Failed to establish database connection.")
        except Error as e:
            print(f"DatabaseProcessor: Database connection failed: {e}")
            self.connection = None

    def close(self):
        if self.connection and self.connection.is_connected():
            self.connection.close()
            print("DatabaseProcessor: Database connection closed.")

    def fetch_all_posts(self) -> List[Dict]:
        """Fetches all posts from the 'posts' table."""
        if not self.connection or not self.connection.is_connected():
            print("DatabaseProcessor: No active connection to fetch posts. Attempting to reconnect...")
            self.connect()
            if not self.connection or not self.connection.is_connected():
                print("DatabaseProcessor: Failed to reconnect, returning empty list.")
                return []

        query = "SELECT id, text, engagement, line_count, language, tags, creator_id FROM posts"
        cursor = None
        try:
            cursor = self.connection.cursor(dictionary=True)
            cursor.execute(query)
            rows = cursor.fetchall()

            processed_rows = []
            for row in rows:
                if 'tags' in row and isinstance(row['tags'], str):
                    try:
                        row['tags'] = json.loads(row['tags'])
                    except json.JSONDecodeError:
                        row['tags'] = []
                elif 'tags' not in row or row['tags'] is None:
                    row['tags'] = []

                processed_rows.append(row)
            return processed_rows
        except Error as e:
            print(f"DatabaseProcessor: Error fetching posts: {e}")
            return []
        finally:
            if cursor:
                cursor.close()

    def update_post_metadata(self, post_id: int, line_count: int, language: str, tags: List[str]):
        """Updates metadata for a single post in the 'posts' table."""
        if not self.connection or not self.connection.is_connected():
            print("DatabaseProcessor: No active connection to update post. Attempting to reconnect...")
            self.connect()
            if not self.connection or not self.connection.is_connected():
                print("DatabaseProcessor: Failed to reconnect, skipping update.")
                return

        query = """
        UPDATE posts
        SET line_count = %s, language = %s, tags = %s
        WHERE id = %s
        """
        cursor = None
        try:
            cursor = self.connection.cursor()

            tags_json = json.dumps(tags)
            cursor.execute(query, (line_count, language, tags_json, post_id))
            self.connection.commit()

        except Error as e:
            print(f"DatabaseProcessor: Error updating post ID {post_id}: {e}")
        finally:
            if cursor:
                cursor.close()

    def __del__(self):
        self.close()



def extract_metadata(post_text: str) -> Dict:
    """Extracts line_count, language, and tags from a post using LLM."""
    template = '''
    You are given a LinkedIn post. You need to extract number of lines, language of the post and tags.
    1. Return a valid JSON. No preamble.
    2. JSON object should have exactly three keys: line_count, language and tags.
    3. tags is an array of text tags. Extract maximum two tags.
    4. Language should be English or Hinglish (Hinglish means hindi + english)

    Here is the actual post on which you need to perform this task:
    {post_text}
    '''

    pt = PromptTemplate.from_template(template)
    chain = pt | llm
    response = chain.invoke(input={"post_text": post_text})

    try:
        json_parser = JsonOutputParser()
        res = json_parser.parse(response.content)

        if not isinstance(res.get('tags'), list):
            res['tags'] = [str(res['tags'])] if res.get('tags') is not None else []

        if isinstance(res.get('line_count'), str) and res['line_count'].isdigit():
             res['line_count'] = int(res['line_count'])
        elif not isinstance(res.get('line_count'), int):
             res['line_count'] = 0
        return res
    except OutputParserException:
        print(f"Warning: OutputParserException for post: {post_text[:50]}...")
        return {"line_count": 0, "language": "Unknown", "tags": []}
    except Exception as e:
        print(f"Warning: General error parsing metadata for post: {post_text[:50]}... Error: {e}")
        return {"line_count": 0, "language": "Unknown", "tags": []}


def get_unified_tags(all_current_tags: List[str]) -> Dict[str, str]:
    """Unifies a list of tags using LLM, returning a mapping."""
    unique_tags_list = ','.join(all_current_tags)

    template = '''I will give you a list of tags. You need to unify tags with the following requirements,
    1. Tags are unified and merged to create a shorter list.
       Example 1: "Jobseekers", "Job Hunting" can be all merged into a single tag "Job Search".
       Example 2: "Motivation", "Inspiration", "Drive" can be mapped to "Motivation"
       Example 3: "Personal Growth", "Personal Development", "Self Improvement" can be mapped to "Self Improvement"
       Example 4: "Scam Alert", "Job Scam" etc. can be mapped to "Scams"
    2. Each tag should be follow title case convention. example: "Motivation", "Job Search"
    3. Output should be a JSON object, No preamble
    4. Output should have mapping of original tag and the unified tag.
       For example: {{"Jobseekers": "Job Search",  "Job Hunting": "Job Search", "Motivation": "Motivation"}}

    Here is the list of tags:
    {tags}
    '''
    pt = PromptTemplate.from_template(template)
    chain = pt | llm
    response = chain.invoke(input={"tags": unique_tags_list})

    try:
        json_parser = JsonOutputParser()
        res = json_parser.parse(response.content)
        return res
    except OutputParserException:
        print(f"Warning: OutputParserException for unifying tags: {unique_tags_list[:100]}...")
        return {}
    except Exception as e:
        print(f"Warning: General error unifying tags: {unique_tags_list[:100]}... Error: {e}")
        return {}

def preprocess_database_posts():
    """
    Main function to preprocess posts directly in the database.
    Fetches, enriches, unifies tags, and updates the database.
    """
    db_processor = DatabaseProcessor()
    if not db_processor.connection or not db_processor.connection.is_connected():
        print("Preprocessing aborted: Could not connect to database.")
        return

    print("Fetching all posts from the database...")
    all_db_posts = db_processor.fetch_all_posts()
    if not all_db_posts:
        print("No posts found in the database to preprocess.")
        db_processor.close()
        return

    print(f"Fetched {len(all_db_posts)} posts.")

    all_extracted_tags = set()
    posts_to_update = []

    for post in all_db_posts:
        print(f"Processing post ID: {post.get('id', 'N/A')}")
        metadata = extract_metadata(post['text'])
        post_id = post.get('id')
        current_text = post.get('text')

        extracted_line_count = metadata.get('line_count', 0)
        extracted_language = metadata.get('language', 'Unknown')
        extracted_tags_from_llm = metadata.get('tags', [])


        all_extracted_tags.update(extracted_tags_from_llm)

        posts_to_update.append({
            'id': post_id,
            'text': current_text,
            'line_count': extracted_line_count,
            'language': extracted_language,
            'raw_extracted_tags': extracted_tags_from_llm
        })

    if not all_extracted_tags:
        print("No tags extracted from any posts. Skipping tag unification.")

        for post_data in posts_to_update:
            db_processor.update_post_metadata(
                post_data['id'],
                post_data['line_count'],
                post_data['language'],
                []
            )
        db_processor.close()
        return



    print(f"Unifying {len(all_extracted_tags)} unique tags...")
    unified_tags_map = get_unified_tags(list(all_extracted_tags))
    if not unified_tags_map:
        print("Tag unification failed or returned empty map. Skipping unified tag application.")
        for post_data in posts_to_update:
             db_processor.update_post_metadata(
                post_data['id'],
                post_data['line_count'],
                post_data['language'],
                []
            )
        db_processor.close()
        return

    print("Applying unified tags and updating database...")
    for post_data in posts_to_update:
        original_tags = post_data.get('raw_extracted_tags', [])
        final_unified_tags = []
        for tag in original_tags:

            unified_tag = unified_tags_map.get(tag, tag)
            if unified_tag:
                final_unified_tags.append(unified_tag)


        final_unified_tags = list(set(final_unified_tags))


        db_processor.update_post_metadata(
            post_data['id'],
            post_data['line_count'],
            post_data['language'],
            final_unified_tags
        )
    print("Database preprocessing complete.")
    db_processor.close()


if __name__ == "__main__":
    preprocess_database_posts()