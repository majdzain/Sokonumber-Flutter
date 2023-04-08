import 'package:flutter/material.dart';

class EmptyCell extends StatelessWidget {
  const EmptyCell({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xB1B2B7),
          border: Border.all(color: Colors.grey, width: 1)),
    );
  }
}
