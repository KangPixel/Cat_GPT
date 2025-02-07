import 'package:flutter/material.dart';
import '../models/cat.dart';

class CatCard extends StatelessWidget {
  final Cat cat;
  final double imageSize; // 필수 named parameter
  final VoidCallback onSelected;

  const CatCard({
    Key? key,
    required this.cat,
    required this.imageSize,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              cat.imagePath,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Text(
              cat.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              cat.description,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
