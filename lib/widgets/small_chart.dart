import 'package:flutter/material.dart';
import 'dart:math';

class SmallChart extends StatelessWidget {
  const SmallChart({super.key});

  @override
  Widget build(BuildContext context) {
    final rnd = Random();
    final data = List<int>.generate(8, (_) => 40 + rnd.nextInt(120));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((v) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              height: (v.toDouble()),
              decoration: BoxDecoration(
                color: Colors.indigo.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
