// chat.dart (채팅 UI)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'status.dart';
import 'chat_log.dart';

// 서버 주소
const backendUrl = 'http://34.22.100.160:8000/chat';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // 텍스트 입력 제어 / 스크롤 제어
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false; // 전송 로딩 상태
  String _catFileName = 'gray_cat'; // 고양이 이미지 파일명 (기본)
  String _catName = '고양이'; // 고양이 이름 (기본)

  @override
  void initState() {
    super.initState();
    // 온보딩에서 저장한 고양이 정보 불러오기
    _loadCatData();

    // 화면 초기 로드 후, 자동 스크롤 아래로
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  /// SharedPreferences에서 'selectedCat'(고양이 파일명),
  /// 'catName'(고양이 이름) 가져와 설정
  Future<void> _loadCatData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _catFileName = prefs.getString('selectedCat') ?? 'gray_cat';
      _catName = prefs.getString('catName') ?? '고양이';
    });
  }

  /// 메시지 전송 로직
  Future<void> sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return; // 빈 문자열은 무시

    setState(() {
      // chatLog에 사용자 메시지 추가
      chatLog.addMessage('user', prompt);
      _controller.clear();
      isLoading = true;
    });

    try {
      // 서버로 POST
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': prompt,
          // 고양이의 친밀도 상태
          'status': {
            'intimacy': catStatus.intimacy.value,
            'catName': catStatus.catName.value,
          },
        }),
      );

      if (response.statusCode == 200) {
        // 응답 파싱
        final jsonResponse = jsonDecode(response.body);
        // GPT 응답 (JSON 문자열) 파싱
        final botResponse = jsonDecode(jsonResponse['response']);

        // 친밀도 변화가 있는지 체크
        final statusChanges = jsonResponse['status_changes'];
        if (statusChanges != null) {
          final delta = statusChanges['intimacy'] ?? 0;
          // 실제 catStatus 업데이트
          catStatus.updateStatus(intimacyDelta: delta);

          // delta != 0 → system 메시지로 안내
          if (delta != 0) {
            final sign = (delta > 0) ? '+' : '';
            final sysMsg =
                '친밀도가 $sign$delta만큼 ${(delta > 0) ? '올랐어요:)' : '내려갔어요:('}';

            // 채팅 목록에 system 메시지 추가
            chatLog.addMessage('system', sysMsg);
          }
        }

        // 고양이(assistant) 메시지 추가
        setState(() {
          chatLog.addMessage('assistant', botResponse['response']);
        });
      } else {
        // 실패 응답 → 에러 메시지
        setState(() {
          chatLog.addMessage('assistant', 'Error: Unable to process.');
        });
      }
    } catch (e) {
      // 예외 발생 → 에러 메시지
      setState(() {
        chatLog.addMessage('assistant', 'Error: $e');
      });
    } finally {
      // 로딩 해제 후 스크롤 아래로
      setState(() {
        isLoading = false;
      });
      _scrollToBottom();
    }
  }

  /// 메시지 추가 시점에 스크롤을 맨 아래로 이동
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
      // 키보드 열릴 때 입력창 영역 확보
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFF6AE),

      // 상단 AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        // 고양이 이름을 타이틀로
        title: Text(_catName, style: const TextStyle(color: Colors.black)),
        elevation: 0,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // 상단 안내 문구
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

            // 채팅 메시지 리스트
            Expanded(
              child: Stack(
                children: [
                  // 고양이 이미지를 중앙 아래쪽에 반투명하게
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

                  // 메시지 표시용 ListView
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: chatLog.messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // 로딩 표시
                      if (index >= chatLog.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final message = chatLog.messages[index];
                      final role = message['role'] ?? 'user';
                      final content = message['content'] ?? '';

                      // system → 중앙 정렬 안내 메시지
                      if (role == 'system') {
                        return _buildSystemMessage(content);
                      }

                      // user / assistant
                      final isUser = (role == 'user');
                      final isCat = (role == 'assistant');

                      // 고양이 말풍선=갈색, 사용자=흰색
                      final bubbleColor =
                          isCat ? const Color(0xFF693435) : Colors.white;
                      // 고양이 텍스트=흰색, 사용자=검정
                      final textColor = isCat ? Colors.white : Colors.black;

                      return _buildMessageRow(
                        context,
                        content: content,
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

            // 입력창
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(8),
              child: Container(
                // 둥근 흰색 배경
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // 텍스트 입력 필드
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
                    // 발바닥 아이콘(전송 버튼)
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

  /// system 메시지 → 중앙 정렬 안내 (회색 박스)
  Widget _buildSystemMessage(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ),
    );
  }

  /// 고양이(assistant) / 사용자(user) 말풍선
  ///   - 고양이: 왼쪽 프로필 + 갈색 말풍선
  ///   - 사용자: 오른쪽 말풍선
  ///   - 고양이만 *...* 이탤릭 처리
  Widget _buildMessageRow(
    BuildContext context, {
    required String content,
    required bool isUser,
    required bool isCat,
    required Color bubbleColor,
    required Color textColor,
  }) {
    // 오른쪽(사용자) / 왼쪽(고양이) 정렬
    final mainAxisAlign =
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: mainAxisAlign,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 고양이면 왼쪽 프로필
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
              borderRadius: BorderRadius.circular(15.0),
            ),
            padding: const EdgeInsets.all(12.0),

            // 고양이만 *...* 이탤릭 처리 → _buildCatRichText()
            child: isCat
                ? _buildCatRichText(content)
                : Text(
                    content,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontFamily: 'OwnglyphPDH',
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// 고양이 메시지에서만 *...* 이탤릭 처리
  Widget _buildCatRichText(String content) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white, // 기본 텍스트=흰색
          fontSize: 18,
          fontFamily: 'OwnglyphPDH',
        ),
        children: _parseAsterisksForCat(content),
      ),
    );
  }

  /// _parseAsterisksForCat: *...* 구간 → 이탤릭+white70, 나머지는 white
  List<TextSpan> _parseAsterisksForCat(String message) {
    final regex = RegExp(r'\*(.*?)\*');
    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    const Color normalColor = Colors.white; // 일반 텍스트 색
    const Color italicColor = Colors.white70; // 이탤릭 부분 색

    final matches = regex.allMatches(message);
    for (final match in matches) {
      // match.start 이전 -> 일반 텍스트
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: message.substring(lastMatchEnd, match.start),
            style: const TextStyle(color: normalColor),
          ),
        );
      }

      // *...* 구간 -> 이탤릭, white70
      final groupText = match.group(1) ?? '';
      spans.add(
        TextSpan(
          text: groupText,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: italicColor,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    // 마지막 남은 구간
    if (lastMatchEnd < message.length) {
      spans.add(
        TextSpan(
          text: message.substring(lastMatchEnd),
          style: const TextStyle(color: normalColor),
        ),
      );
    }

    return spans;
  }
}
