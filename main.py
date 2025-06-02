import streamlit as st
from post_generator import generate_post
from few_shot import FewShotPosts

# Initialize
fs = FewShotPosts()

def main():
# UI Layout
    st.title("LinkedIn Post Generator")

    col1, col2, col3 = st.columns(3)
    with col1:
        selected_tag = st.selectbox("Topic", options=fs.get_tags())
    with col2:
        selected_length = st.selectbox("Length", ["Short", "Medium", "Long", "Extended"])
    with col3:
    #         # Dropdown for Language
        selected_language = st.selectbox("Language", options=["English", "Hinglish"])


    if st.button("Generate Post"):
        result = generate_post(selected_length, selected_language, selected_tag)
        st.subheader("Generated Prompt")
        st.write(result)

if __name__ == "__main__":
    main()

