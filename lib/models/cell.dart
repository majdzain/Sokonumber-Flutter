// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Cell extends Equatable {
  int index;
  List<Offset>? offsets;
  int type;
  bool isSwipeable;
  int? n;
  bool isMatch;
  Cell? instead;
  Cell? previous;
  Cell({
    required this.index,
    this.offsets,
    required this.type,
    required this.isSwipeable,
    this.isMatch = false,
    this.instead,
    this.n,
    this.previous,
  });

  @override
  List<Object> get props {
    return [index];
  }

  // @override
  // String toString() {
  //   return '{index:$index,offsets:$offsets,type:$type,isSwipeable:$isSwipeable,n:$n,isMatch:$isMatch,instead:$instead,previous:$previous}';
  // }
}
