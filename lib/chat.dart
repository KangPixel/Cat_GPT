import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'status.dart';

const backendUrl = 'http://34.22.100.160:8000/chat';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  Future<void> sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'content': prompt});
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
            'hunger': catStatus.hunger.value,
            'intimacy': catStatus.intimacy.value, // 친밀도 전달
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final botResponse = jsonResponse['response']; // 고양이의 대화 메시지
        final statusChanges = jsonResponse['status_changes'];

        if (statusChanges != null) {
          catStatus.updateStatus(
            intimacyDelta: statusChanges['intimacy'] ?? 0,
          );
        }

        setState(() {
          messages.add({'role': 'assistant', 'content': botResponse});
        });
        _scrollToBottom(); // 새 메시지 추가 후 자동 스크롤
      } else {
        setState(() {
          messages.add(
              {'role': 'assistant', 'content': 'Error: Unable to process.'});
        });
        _scrollToBottom(); // 에러 메시지 표시 후 자동 스크롤
      }
    } catch (e) {
      setState(() {
        messages.add({'role': 'assistant', 'content': 'Error: $e'});
      });
      _scrollToBottom(); // 에러 메시지 표시 후 자동 스크롤
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
              controller: _scrollController, // 스크롤 컨트롤러 연결
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final message = messages[index];
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
                    onSubmitted: (_) => sendMessage(), // 엔터키 처리
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
    _scrollController.dispose(); // 컨트롤러 해제
    super.dispose();
  }
}
