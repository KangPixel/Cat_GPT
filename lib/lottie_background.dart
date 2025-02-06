import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// ✅ Lottie 배경을 Flutter의 Overlay로 렌더링할 수 있도록 설정
class LottieBackgroundWidget extends StatelessWidget {
  final String lottieFile;
  final bool isMirrored; // 좌우 반전 여부 추가

  const LottieBackgroundWidget({Key? key, required this.lottieFile, this.isMirrored = true}) : super(key: key); //기본값: 반전 안 함

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black, // 🔹 검은 화면 방지
        child: Transform.scale(
          scaleX: isMirrored ? -1 : 1, //x축 반전 적용
          child: Lottie.asset(
          lottieFile,
          fit: BoxFit.cover,
          repeat: true,
        ),
      ),
    ),  
  );
}
}