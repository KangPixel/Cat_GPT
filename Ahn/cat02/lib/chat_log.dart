//채팅 로그 저장
class ChatLog {
  List<Map<String, String>> messages = [];

  void addMessage(String role, String content) {
    messages.add({'role': role, 'content': content});
  }

  void clearMessages() {
    messages.clear();
  }
}

final chatLog = ChatLog();
