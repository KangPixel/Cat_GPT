import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'status.dart';

const backendUrl = 'https://85e3-121-129-161-110.ngrok-free.app/chat';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

void sendMessage() async {
  String prompt = _controller.text.trim();
  if (prompt.isNotEmpty) {
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
            'fatigue': catStatus.fatigue.value,
            'happiness': catStatus.happiness.value,
            'weight': catStatus.weight.value,
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final botResponse = jsonResponse['response'];
        final statusChanges = jsonResponse['status_changes'];

        // 상태 변화량(Delta) 적용
        if (statusChanges != null) {
          catStatus.updateStatus(
            hungerDelta: statusChanges['hunger'] ?? 0,
            fatigueDelta: statusChanges['fatigue'] ?? 0,
            happinessDelta: statusChanges['happiness'] ?? 0,
            weightDelta: statusChanges['weight'] ?? 0,
          );
        }

        setState(() {
          messages.add({'role': 'assistant', 'content': botResponse});
          isLoading = false;
        });
      } else {
        setState(() {
          messages.add({'role': 'assistant', 'content': 'Error: Unable to process.'});
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        messages.add({'role': 'assistant', 'content': 'Error: $e'});
        isLoading = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chatbot"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration.collapsed(
                          hintText: "메시지를 입력하세요"),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}