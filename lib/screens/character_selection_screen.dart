import 'package:flutter/material.dart';
import '../models/cat.dart';
import '../widgets/cat_card.dart';
import '../screens/game_screen.dart';

final List<Cat> cats = [
  Cat(
    name: 'Player',
    imagePath: 'assets/images/cat1.png',
    description: '나의 고양이',
    color: 'one',
  ),
  Cat(
    name: '흰냥이',
    imagePath: 'assets/images/cat2.png',
    description: '지구력이 뛰어난 고양이',
    color: 'two',
  ),
  Cat(
    name: '갈냥이',
    imagePath: 'assets/images/cat3.png',
    description: '힘이 좋은 고양이',
    color: 'three',
  ),
  Cat(
    name: '아이보리냥이',
    imagePath: 'assets/images/cat4.png',
    description: '똑똑한 고양이',
    color: 'four',
  ),
];

class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cardImageSize = size.width * 0.35;

    return Scaffold(
      appBar: AppBar(
        title: const Text('캐릭터 선택'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popAndPushNamed(context, '/'); // GameScreen으로 이동
          },
        ),
      ),
      backgroundColor: Colors.cyan[50],
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4 / 5,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          bool isSelectable = cats[index].name == 'Player';

          return Opacity(
            opacity: isSelectable ? 1.0 : 0.5, // 선택 불가능한 카드 투명도 낮춤
            child: GestureDetector(
              onTap: isSelectable
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GameScreen(selectedCat: cats[index]),
                        ),
                      );
                      print('선택된 고양이: ${cats[index].name}');
                    }
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${cats[index].name}은(는) 선택할 수 없습니다!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
              child: CatCard(
                cat: cats[index],
                imageSize: cardImageSize,
                onSelected: isSelectable
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GameScreen(selectedCat: cats[index]),
                          ),
                        );
                        print('선택된 고양이: ${cats[index].name}');
                      }
                    : () {}, // 선택 불가능한 경우 onSelected를 null로 설정
              ),
            ),
          );
        },
      ),
    );
  }
}
