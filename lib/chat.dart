//채팅ui
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'status.dart';
import 'chat_log.dart';

const backendUrl = 'http://34.22.100.160:8000/chat';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;
  String _catFileName = 'gray_cat';
  String _catName = '고양이';

  @override
  void initState() {
    super.initState();
    _loadCatData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _loadCatData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _catFileName = prefs.getString('selectedCat') ?? 'gray_cat';
      _catName = prefs.getString('catName') ?? '고양이';
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
            'catName': catStatus.catName.value,
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final botResponse = jsonDecode(jsonResponse['response']);
        final statusChanges = jsonResponse['status_changes'];
        if (statusChanges != null) {
          catStatus.updateStatus(
            intimacyDelta: statusChanges['intimacy'] ?? 0,
          );
        }

        setState(() {
          chatLog.addMessage('assistant', botResponse['response']);
        });
      } else {
        setState(() {
          chatLog.addMessage('assistant', 'Error: Unable to process.');
        });
      }
    } catch (e) {
      setState(() {
        chatLog.addMessage('assistant', 'Error: $e');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      _scrollToBottom();
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
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFF6AE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(_catName, style: const TextStyle(color: Colors.black)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white.withOpacity(0.8),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 4),
              child: const Text(
                '대화를 통해 친밀도를 높여 보세요!\n'
                '친밀도가 높아지면 고양이가 주인을 더 잘 따릅니다!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment: const Alignment(0, 0.3),
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/images/cat/$_catFileName.png',
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  ListView.builder(
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
                      final isUser = (message['role'] == 'user');
                      final isCat = (message['role'] == 'assistant');

                      // 말풍선 색상
                      final bubbleColor = isCat
                          ? const Color(0xFF693435) 
                          : Colors.white; 
                      // 텍스트 색 (고양이 -> 전체 흰색, user -> 검정)
                      final textColor = isCat ? Colors.white : Colors.black;

                      return _buildMessageRow(
                        context,
                        content: message['content'] ?? '',
                        isUser: isUser,
                        isCat: isCat,
                        bubbleColor: bubbleColor,
                        textColor: textColor,
                      );
                    },
                  ),
                ],
              ),
            ),

            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "여기에 입력하라 냥!",
                        ),
                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),
                    InkWell(
                      onTap: sendMessage,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.asset(
                          'assets/images/paw_icon.png',
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Parse 함수: *...* = 이탤릭 + 연한 색
  List<TextSpan> parseMessageWithAsterisks(String message, {required bool isCat}) {
    final RegExp regex = RegExp(r'\*(.*?)\*');
    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    // 고양이 메시지: 일반은 white, 이탤릭은 white70
    // 사용자 메시지: 일반은 black, 이탤릭은 black54
    final Color normalColor = isCat ? Colors.white : Colors.black;
    final Color italicColor = isCat ? Colors.white70 : Colors.black54;

    final matches = regex.allMatches(message);
    for (final match in matches) {
      // 일반 텍스트
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: message.substring(lastMatchEnd, match.start),
            style: TextStyle(color: normalColor),
          ),
        );
      }

      // *...* 구간
      final groupText = match.group(1) ?? '';
      spans.add(
        TextSpan(
          text: groupText,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: italicColor,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    // 마지막 남은 부분
    if (lastMatchEnd < message.length) {
      spans.add(
        TextSpan(
          text: message.substring(lastMatchEnd),
          style: TextStyle(color: normalColor),
        ),
      );
    }

    return spans;
  }

  Widget _buildMessageRow(
    BuildContext context, {
    required String content,
    required bool isUser,
    required bool isCat,
    required Color bubbleColor,
    required Color textColor,
  }) {
    final mainAxisAlign = isUser ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: mainAxisAlign,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isCat) ...[
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/cat/$_catFileName.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 말풍선
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(12.0),
            // RichText로 parse
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: textColor, // base text color
                  fontSize: 15,
                  fontFamily: 'Pretendard',
                ),
                // parseMessageWithAsterisks에 isCat 전달
                children: parseMessageWithAsterisks(content, isCat: isCat),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
