from llm_helper import llm
from few_shot import FewShotPosts

few_shot = FewShotPosts()


def get_length_str(length):
    if length == "Short":
        return "1 to 5 lines"
    if length == "Medium":
        return "6 to 10 lines"
    if length == "Long":
        return "11 to 15 lines"
    if length == "Extended":
        return "20 to 25 lines"


def generate_post(length, language, tag):
    prompt = get_prompt(length, language, tag)
    response = llm.invoke(prompt)
    generated_post_text = response.content
    return generated_post_text


def get_prompt(length, language, tag):
    length_str = get_length_str(length)

    length_notes = {
        "Short": "Make it concise and attention-grabbing. Use 1-2 impactful sentences.",
        "Medium": "Include 1 key point with a brief explanation or example.",
        "Long": "Structure with: 1)Attention-grabbing hook 2) Main point\n 3) Supporting details including 2023-24 data",
        "Extended": (
            "Include:\n"
            "- Detailed real-world examples\n"
            "- Multiple paragraphs with clear transitions\n"
            "- Data/statistics where applicable\n"
            "- 3-5 key points with explanations"
        )
    }

    # Language note
    language_note = ""
    if language == "Hinglish":
        language_note = "Use Hinglish (Hindi+English mix with Roman script)."

    prompt = f"""
    Generate a LinkedIn post with these specifications:

    1) TOPIC: {tag}
    2) LENGTH: {length_str}
    {length_notes[length]}
    3) LANGUAGE: {language}
    {language_note}

    TONE: Professional but conversational
    FORMAT: 
    - No hashtags
    - Skip greetings/signatures
    - Focus on value-driven content
    """

    # prompt = prompt.format(post_topic=tag, post_length=length_str, post_language=language)

    examples = few_shot.get_filtered_posts(length, language, tag)

    if len(examples) > 0:
        prompt += "4) Use the writing style as per the following examples."

    for i, post in enumerate(examples):
        post_text = post['text']
        prompt += f'\n\n Example {i+1}: \n\n {post_text}'

        if i == 1: # Use max two samples
            break

    return prompt


if __name__ == "__main__":
    print("Generating post for Medium length, English, Mental Health...")

    generated_content = generate_post("Medium", "English", "Mental Health")

    print("\n--- Generated Post Text ---")
    print(generated_content)