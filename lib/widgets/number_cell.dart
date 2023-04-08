import 'package:flutter/material.dart';

class NumberCell extends StatelessWidget {
  int number;
  bool isMatch;
  double fontSize;
  NumberCell({
    Key? key,
    required this.isMatch,
    required this.number,
    this.fontSize = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('number_container_$number$isMatch'),
      color: isMatch ? Colors.red : Colors.white,
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
              fontSize: fontSize, color: isMatch ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
