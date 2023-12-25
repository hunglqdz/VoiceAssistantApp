import 'package:flutter/material.dart';

class FeatureBox extends StatelessWidget {
  final Color color;
  final String header;
  final String description;
  const FeatureBox({
    super.key,
    required this.color,
    required this.header,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20).copyWith(
          left: 15,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                header,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(description),
            ),
          ],
        ),
      ),
    );
  }
}
