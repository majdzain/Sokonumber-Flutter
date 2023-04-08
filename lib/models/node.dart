// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:sokonumber_flutter/models/cell.dart';
import 'package:sokonumber_flutter/utils/constants/levels.dart';

class Node extends Equatable {
  List<Cell> currentCells;
  int level;
  List<int> _currentIndexes = [];
  int? x;
  int? y;
  Node({required this.level, required this.currentCells, this.x, this.y});

  List<Node> getNextStates() {
    List<Node> nodes = [];
    List<Offset> directions = getAvalibleDirections();
    for (Offset offset in directions) {
      nodes.add(move(offset));
    }
    return nodes;
  }

  List<Cell> checkMatch(int index, List<Cell> cells) {
    if (levels[level]![index].type == 4 ||
        (levels[level]![index].instead != null &&
            levels[level]![index].instead!.type == 4)) {
      // print ("$index" + 'true');
      if ((cells[index].type == 1) &&
          (cells[index].n == levels[level]![index].n ||
              (levels[level]![index].instead != null &&
                  levels[level]![index].instead!.type == 4 &&
                  levels[level]![index].instead!.n == cells[index].n))) {
        cells[index].isMatch = true;
      } else {
        cells[index].isMatch = false;
      }
    } else {
      // print ("$index" + 'false');
      cells[index].isMatch = false;
    }
    return cells;
  }

  List<Offset> getAvalibleDirections() {
    List<Offset> directions = [];
    for (Cell cell in currentCells) {
      if (cell.type == 1 && cell.offsets!.isNotEmpty) {
        for (Offset offset in cell.offsets!) {
          if (!directions.contains(offset)) {
            directions.add(offset);
          }
        }
      }
    }
    return directions;
  }

  bool isFinal() {
    bool isWin = true;
    for (int i = 0; i < currentCells.length; i++) {
      if (levels[level]![i].type == 4 ||
          (levels[level]![i].instead != null &&
              levels[level]![i].instead!.type == 4)) {
        if (!(currentCells[i].type == 1 &&
            (currentCells[i].n == levels[level]![i].n ||
                (levels[level]![i].instead != null &&
                    levels[level]![i].instead!.type == 4 &&
                    levels[level]![i].instead!.n == currentCells[i].n)))) {
          isWin = false;
          break;
        }
      }
    }
    return isWin;
  }

  Node move(Offset offset) {
    addCurrentIndexes(offset);
    List<int> newIndexes = [];
    List<Cell> cells = List.from(currentCells);
    for (int index in _currentIndexes) {
      int? newIndex = getNextPosition(index, offset);

      if (newIndex != null) {
        cells = swipe(index, newIndex, cells);

        newIndexes.add(newIndex);
        cells = checkMatch(newIndex, cells);
      }
    }
    for (int newIndex in newIndexes) {
      cells = changeDirections(newIndex, cells);
    }
    _currentIndexes = [];
    return Node(level: level, currentCells: cells);
  }

  List<Cell> swipe(int i1, int i2, List<Cell> cells) {
    Cell temp = cells[i1];
    if (levels[level]![i1].type == 1) {
      cells[i1] = levels[level]![i1].instead ??
          Cell(index: i1, type: 2, isSwipeable: false);
    } else {
      cells[i1] = levels[level]![i1];
    }
    cells[i2] = temp;

    return cells;
  }

  int? getNextPosition(int index, Offset d) {
    if (d.dy == 1.0) {
      return index + sqrt(currentCells.length).floor();
    } else if (d.dy == -1.0) {
      return index - sqrt(currentCells.length).floor();
    } else if (d.dx == 1.0) {
      return index + 1;
    } else if (d.dx == -1.0) {
      return index - 1;
    }

    return null;
  }

  List<Cell> changeDirections(int index, List<Cell> cells) {
    cells[index].offsets = [];

    /// Up Direction
    if (index - sqrt(cells.length) >= 0 &&
        (cells[index - sqrt(cells.length).floor()].type == 2 ||
            cells[index - sqrt(cells.length).floor()].type == 4)) {
      cells[index].offsets!.add(Offset(0.0, -1.0));
    }

    /// Down Direction
    if (index + sqrt(cells.length) < cells.length &&
        (cells[index + sqrt(cells.length).floor()].type == 2 ||
            cells[index + sqrt(cells.length).floor()].type == 4)) {
      cells[index].offsets!.add(Offset(0.0, 1.0));
    }

    /// Right Direction
    if ((index + 1) % sqrt(cells.length).floor() != 0 &&
        (cells[index + 1].type == 2 || cells[index + 1].type == 4)) {
      cells[index].offsets!.add(Offset(1.0, 0.0));
    }

    /// Left Direction
    if ((index) % sqrt(cells.length).floor() != 0 &&
        (cells[index - 1].type == 2 || cells[index - 1].type == 4)) {
      cells[index].offsets!.add(Offset(-1.0, 0.0));
    }
    return cells;
    // Cell cell = a[index];
    // setState(() {
    //   a = List.from(a);
    // });
    // return cell;
  }

  void addCurrentIndexes(Offset o) {
    for (int i = 0; i < currentCells.length; i++) {
      if (currentCells[i].type == 1 && checkMove(o, i)) {
        _currentIndexes.add(i);
      }
    }
  }

  bool checkMove(Offset d, int index) {
    if (d.dy == 1.0) {
      return checkDownMove(index);
    } else if (d.dy == -1.0) {
      return checkUpMove(index);
    } else if (d.dx == 1.0) {
      return checkRightMove(index);
    } else if (d.dx == -1.0) {
      return checkLeftMove(index);
    }
    return true;
  }

  bool checkRightMove(int index) {
    return ((index + 1) % sqrt(currentCells.length).floor() != 0 &&
            (currentCells[index + 1].type == 2 ||
                currentCells[index + 1].type == 4)) &&
        (currentCells[index + 1].type != 1);
  }

  bool checkLeftMove(int index) {
    return ((index) % sqrt(currentCells.length).floor() != 0 &&
            (currentCells[index - 1].type == 2 ||
                currentCells[index - 1].type == 4)) &&
        (currentCells[index - 1].type != 1);
  }

  // bool checkInRange(index) {
  //   return (index >= 0 && index < a.length);
  // }

  bool checkUpMove(int index) {
    return (index - sqrt(currentCells.length) >= 0 &&
            (currentCells[index - sqrt(currentCells.length).floor()].type ==
                    2 ||
                currentCells[index - sqrt(currentCells.length).floor()].type ==
                    4)) &&
        (currentCells[index - sqrt(currentCells.length).floor()].type != 1);
  }

  bool checkDownMove(int index) {
    return (index + sqrt(currentCells.length) < currentCells.length &&
            (currentCells[index + sqrt(currentCells.length).floor()].type ==
                    2 ||
                currentCells[index + sqrt(currentCells.length).floor()].type ==
                    4)) &&
        (currentCells[index + sqrt(currentCells.length).floor()].type != 1);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [currentCells, level, x, y];
}
