from flask import Flask, request, jsonify
from flask_cors import CORS
from langchain_community.chat_models import ChatOpenAI
from langchain.chains import LLMChain
from langchain.memory import ConversationBufferWindowMemory
from langchain.prompts import PromptTemplate
from dotenv import load_dotenv
import os
import json

app = Flask(__name__)
CORS(app)

load_dotenv()
api_key = os.environ.get("OPENAI_API_KEY")

llm = ChatOpenAI(
    model_name="gpt-4o",
    temperature=0.7,  # 웹과 유사한 응답을 위해 조정된 파라미터  
    max_tokens=1500,
    frequency_penalty=0.0,
    presence_penalty=0.0
)

template = """넌 모바일 게임 속에서 키워지는 고양이를 연기해야 해. 
현재 상태:
배고픔: {hunger}
피로도: {fatigue}
행복도: {happiness}
체중: {weight}

이전 대화:
{history}

사용자: {input}
고양이:

응답의 마지막 부분에는 반드시 다음 형식으로 상태 변화량(델타)을 포함해야 해:
상태 변화: {{
    "hunger": <변화량>,
    "fatigue": <변화량>,
    "happiness": <변화량>,
    "weight": <변화량>
}}
"""




prompt = PromptTemplate(
    input_variables=["hunger", "fatigue", "happiness", "weight", "history", "input"],
    template=template
)

memory = ConversationBufferWindowMemory(
    memory_key="history",
    input_key="input",  # Specify the input key
    return_messages=True,
    k=10
)

conversation = LLMChain(
    llm=llm,
    prompt=prompt,
    memory=memory,
    verbose=True
)

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    user_input = data.get('message', '')
    current_status = data.get('status', {})

    if not user_input:
        return jsonify({'error': 'No input provided'}), 400

    try:
        # Create a single dictionary with all input variables
        input_dict = {
            'hunger': current_status.get('hunger', 100),
            'fatigue': current_status.get('fatigue', 0),
            'happiness': current_status.get('happiness', 50),
            'weight': current_status.get('weight', 50),
            'input': user_input
        }

        # Pass the dictionary to the conversation
        response = conversation(input_dict)
        bot_response = response['text']  # Access the response text

        print("AI Full Response:", bot_response)

        # Parse status changes if present
        status_dict = {}
        if "상태 변화:" in bot_response:
            try:
                bot_message, status_changes = bot_response.split("상태 변화:")
                # + 기호 제거
                status_changes = status_changes.replace("+", "")
                status_dict = json.loads(status_changes.strip())
                bot_response = bot_message.strip()
            except json.JSONDecodeError as e:
                print(f"Failed to parse status changes JSON: {e}")
                print(f"Raw status changes: {status_changes.strip()}")
                status_dict = {}
        else:
            status_dict = {}



        return jsonify({
        'response': bot_response,
        'status_changes': status_dict,
})

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)