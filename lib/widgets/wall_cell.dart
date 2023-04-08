import 'package:flutter/material.dart';

class WallCell extends StatelessWidget {
  const WallCell({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xFFFF77A8),
          border: Border.all(color: Colors.grey, width: 1)),
    );
  }
}
