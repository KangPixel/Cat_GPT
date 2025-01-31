//채팅ui
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'status.dart';
import 'chat_log.dart';

const backendUrl = 'http://34.22.100.160:8000/chat';
//const backendUrl = 'https://2b18-112-187-152-186.ngrok-free.app/chat';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  void initState() {
    super.initState();
    // 화면이 처음 로드될 때 스크롤을 맨 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      chatLog.addMessage('user', prompt);
      _controller.clear();
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': prompt,
          'status': {
            'intimacy': catStatus.intimacy.value,
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final botResponse = jsonResponse['response'];
        final statusChanges = jsonResponse['status_changes'];

        if (statusChanges != null) {
          catStatus.updateStatus(
            intimacyDelta: statusChanges['intimacy'] ?? 0,
          );
        }

        setState(() {
          chatLog.addMessage('assistant', botResponse);
        });
        _scrollToBottom();
      } else {
        setState(() {
          chatLog.addMessage('assistant', 'Error: Unable to process.');
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        chatLog.addMessage('assistant', 'Error: $e');
      });
      _scrollToBottom();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatLog.messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= chatLog.messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final message = chatLog.messages[index];
                final isUser = message['role'] == 'user';
                return Container(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Text(message['content'] ?? ''),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration.collapsed(
                      hintText: "메시지를 입력하세요",
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
