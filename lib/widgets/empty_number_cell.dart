// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class EmptyNumberCell extends StatelessWidget {
  int number;
  double fontSize;
  EmptyNumberCell({
    Key? key,
    required this.number,
    this.fontSize = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 1)),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(fontSize: fontSize, color: Colors.grey),
        ),
      ),
    );
  }
}
