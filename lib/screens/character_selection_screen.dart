import 'package:flutter/material.dart';
import '../models/cat.dart';
import '../widgets/cat_card.dart';
import '../screens/game_screen.dart';

final List<Cat> cats = [
  Cat(
    name: 'Player',
    imagePath: 'assets/images/cat1.png',
    description: '빠르고 날렵한 고양이',
    color: 'one', // 지정
  ),
  Cat(
    name: '고양이 2',
    imagePath: 'assets/images/cat2.png',
    description: '지구력이 뛰어난 고양이',
    color: 'two', // 지정
  ),
  Cat(
    name: '고양이 3',
    imagePath: 'assets/images/cat3.png',
    description: '힘이 좋은 고양이',
    color: 'three', // 지정
  ),
  Cat(
    name: '고양이 4',
    imagePath: 'assets/images/cat4.png',
    description: '똑똑한 고양이',
    color: 'four', // 지정
  ),
];

class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cardImageSize = size.width * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('캐릭터 선택'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          return CatCard(
            cat: cats[index],
            imageSize: cardImageSize,
            onSelected: () {
              // 선택된 고양이를 경주 화면으로 전달
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(selectedCat: cats[index]),
                ),
              );
              print('선택된 고양이: ${cats[index].name}');
            },
          );
        },
      ),
    );
  }
}
