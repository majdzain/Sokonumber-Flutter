import 'dart:collection';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sokonumber_flutter/models/node.dart';
import 'package:sokonumber_flutter/models/node_pair.dart';
import 'package:sokonumber_flutter/utils/constants/levels.dart';
import 'package:sokonumber_flutter/utils/constants/play_type.dart';

import '../widgets/empty_cell.dart';
import '../widgets/empty_number_cell.dart';
import '../widgets/number_cell.dart';
import '../widgets/wall_cell.dart';
import '../models/cell.dart';
import 'package:collection/collection.dart';

const MAX_COST = 100000000;

class PlayerPage extends StatefulWidget {
  final PlayType playType;
  final int? level;
  const PlayerPage(
      {Key? key,
      required this.playType,
      required this.level,
      required this.title})
      : super(key: key);

  final String title;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  int level = 1;
  List<Cell> a = [];
  late AudioPlayer winAudioPlayer,
      swipeAudioPlayer,
      wrongSwipeAudioPlayer,
      nextLevelAudioPlayer;

  // List<Cell> b = [];

  late AnimationController leftController,
      rightController,
      upController,
      downController,
      zeroController;

  late Animation<Offset> leftOffset,
      rightOffset,
      upOffset,
      downOffset,
      zeroOffset;

  final FocusNode _focusNode = FocusNode();

  void _handleKeyEvent(RawKeyEvent event) {
    if (!isWinner &&
        rightController.status != AnimationStatus.forward &&
        leftController.status != AnimationStatus.forward &&
        upController.status != AnimationStatus.forward &&
        downController.status != AnimationStatus.forward) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        addCurrentIndexes(Offset(0.0, -1.0));
        upController.forward();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.keyS) {
        addCurrentIndexes(Offset(0.0, 1.0));
        downController.forward();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        addCurrentIndexes(Offset(1.0, 0.0));
        rightController.forward();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        addCurrentIndexes(Offset(-1.0, 0.0));
        leftController.forward();
      }
    }
    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      setState(() {
        isWinner = false;
        a = List.from(levels[level]!);
        nodes = [];
      });
      start(widget.playType);
    } else if (isWinner) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        nextLevelAudioPlayer.play();
        a = levels[level + 1]!;
        setState(() {
          level = level + 1;
          a = List.from(a);
        });
        setState(() {
          isWinner = false;
          nodes = [];
          solveDepth = '0';
          visitedLength = '0';
        });
        start(widget.playType);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    winAudioPlayer = AudioPlayer();
    swipeAudioPlayer = AudioPlayer();
    wrongSwipeAudioPlayer = AudioPlayer();
    nextLevelAudioPlayer = AudioPlayer();
    leftController = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: widget.playType == PlayType.User ? 200 : 200));
    rightController = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: widget.playType == PlayType.User ? 200 : 200));
    upController = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: widget.playType == PlayType.User ? 200 : 200));
    downController = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: widget.playType == PlayType.User ? 200 : 200));
    zeroController = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: widget.playType == PlayType.User ? 200 : 200));

    leftOffset = Tween<Offset>(begin: Offset.zero, end: Offset(-1.0, 0.0))
        .animate(leftController);

    rightOffset = Tween<Offset>(begin: Offset.zero, end: Offset(1.0, 0.0))
        .animate(rightController);

    upOffset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -1.0))
        .animate(upController);

    downOffset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
        .animate(downController);

    zeroOffset = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(zeroController);

    rightController.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          widget.playType == PlayType.User) {
        List<int> newIndexes = [];
        for (int index in currentIndexes) {
          // if (checkRightOffset(index)) {
          int? newIndex = getNextPosition(index, Offset(1.0, 0.0));
          if (newIndex != null) {
            move(index, newIndex);
            newIndexes.add(newIndex);

            checkMatch(newIndex);
          }
        }
        for (int newIndex in newIndexes) {
          changeDirections(newIndex);
        }
        rightController.reset();
        setState(() {
          currentIndexes = [];
        });
        checkWin();
        // }
      }
    });

    leftController.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          widget.playType == PlayType.User) {
        List<int> newIndexes = [];
        for (int index in currentIndexes) {
          // if (checkLeftOffset(index)) {
          int? newIndex = getNextPosition(index, Offset(-1.0, 0.0));
          if (newIndex != null) {
            move(index, newIndex);
            newIndexes.add(newIndex);

            checkMatch(newIndex);
          }
        }
        for (int newIndex in newIndexes) {
          changeDirections(newIndex);
        }
        leftController.reset();
        setState(() {
          currentIndexes = [];
        });
        checkWin();
        // }
      }
    });

    upController.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          widget.playType == PlayType.User) {
        List<int> newIndexes = [];
        for (int index in currentIndexes) {
          int? newIndex = getNextPosition(index, Offset(0.0, -1.0));
          if (newIndex != null) {
            move(index, newIndex);

            newIndexes.add(newIndex);

            checkMatch(newIndex);
          }
        }
        for (int newIndex in newIndexes) {
          changeDirections(newIndex);
        }
        upController.reset();
        setState(() {
          currentIndexes = [];
        });
        checkWin();
      }
    });

    downController.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          widget.playType == PlayType.User) {
        List<int> newIndexes = [];
        for (int index in currentIndexes) {
          int? newIndex = getNextPosition(index, Offset(0.0, 1.0));

          if (newIndex != null) {
            move(index, newIndex);

            newIndexes.add(newIndex);
            checkMatch(newIndex);
          }
        }
        for (int newIndex in newIndexes) {
          changeDirections(newIndex);
        }
        downController.reset();
        setState(() {
          currentIndexes = [];
        });
        checkWin();
      }
    });

    level = widget.level ?? 1;
    _controllerCenter =
        ConfettiController(duration: const Duration(microseconds: 500));
    a = List.from(levels[level]!);

    start(widget.playType);
    Future.delayed(Duration.zero, () async {
      await nextLevelAudioPlayer.setAsset('assets/audio/next_level.wav');
      await winAudioPlayer.setAsset('assets/audio/win.wav');
      await swipeAudioPlayer.setAsset('assets/audio/swipe.wav');
      await wrongSwipeAudioPlayer.setAsset('assets/audio/wrong_swipe.wav');
      nextLevelAudioPlayer.play();
    });
  }

  Cell? moveTo(Offset o, int ind) {
    Cell? cell;
    List<int> newIndexes = [];
    int newInd = ind;
    for (int index in currentIndexes) {
      int? newIndex = getNextPosition(index, o);
      if (newIndex != null) {
        move(index, newIndex);
        newIndexes.add(newIndex);
        checkMatch(newIndex);
        if (index == ind) {
          newInd = newIndex;
        }
      }
    }
    for (int newIndex in newIndexes) {
      Cell c = changeDirections(newIndex);
      if (newIndex == newInd) {
        cell = c;
      }
    }
    if (o.dy == 1.0) {
      downController.reset();
    } else if (o.dy == -1.0) {
      upController.reset();
    } else if (o.dx == 1.0) {
      rightController.reset();
    } else if (o.dx == -1.0) {
      leftController.reset();
    }

    setState(() {
      currentIndexes = [];
    });
    if (checkWin())
      return null;
    else
      return cell;
  }

  List<int> currentIndexes = [];

  Future<void> start(PlayType playType) async {
    await Future.delayed(Duration(milliseconds: 300));

    switch (playType) {
      case PlayType.DFS:

        // int number = 0;
        Node primaryNode = Node(level: level, currentCells: a);
        primaryNode.x = 0;
        primaryNode.y = 0;
        // print(printTree(primaryNode, [],[]));
        setState(() {
          solveDepth = '0';
          visitedLength = '0';
          nodes.add(primaryNode);
        });
        bool r = await playDFS(primaryNode);
        setState(() {
          isWinner = true;
        });

        break;
      case PlayType.BFS:
        Node primaryNode = Node(level: level, currentCells: a);
        setState(() {
          solveDepth = '0';
          visitedLength = '0';
        });
        await playBFS(primaryNode);
        setState(() {
          isWinner = true;
        });
        break;
      case PlayType.UCS:
        Node primaryNode = Node(level: level, currentCells: a);
        setState(() {
          solveDepth = '0';
          visitedLength = '0';
          nodes.add(primaryNode);
        });
        await playUCS(primaryNode);
        setState(() {
          isWinner = true;
        });
        break;
    }
  }

  // Cell? getCellByNumber(int n) {
  //   for (int i = 0; i < a.length; i++) {
  //     if (a[i].type == 1 && a[i].n == (n)) {
  //       return a[i];
  //     }
  //   }
  //   return null;
  // }

  String solvePath = '';
  String solveDepth = '';
  String visitedLength = '';
  String movedNode = '';

// DFS Algorithm
  Future<bool> playDFS(Node node, [List<Node>? visited]) async {
    List<Node> visited1 = List.from(visited ?? []);
    if (node.isFinal()) return Future.value(true);
    if (!visited1.contains(node)) {
      setState(() {
        visitedLength = '${visited1.length + 1}';
      });
      visited1.add(node);
    }
    List<Node> nextNodes = node.getNextStates();

    for (int i = 0; i < nextNodes.length; i++) {
      // print(nextNodes[i]);
      if (!visited1.contains(nextNodes[i])) {
        setState(() {
          nodes.add(nextNodes[i]);
        });
        //await Future.delayed(Duration(milliseconds: 0));
        if (i == nextNodes.length - 1) {
          setState(() {
            solveDepth = (int.parse(solveDepth) + 1).toString();
            print('Solve Depth is :${solveDepth}');
          });
        }
        if (await playDFS(nextNodes[i], visited1)) return Future.value(true);
      }
    }
    return Future.value(false);
  }

// BFS Algorithm
  int level_size = 0;
  int level_bfs = 0;

  Future<void> playBFS(Node node) async {
    Queue<Node> queue = Queue<Node>.from(<Node>[]);
    List<Node> visited = [];
    queue.add(node);
    while (queue.isNotEmpty) {
      level_size = queue.length;
      while (level_size-- != 0) {
        Node n = queue.removeFirst();

        if (n.isFinal()) return;
        visited.add(n);
        setState(() {
          visitedLength = '${visited.length}';
        });
        List<Node> nextNodes = n.getNextStates();

        for (int i = 0; i < nextNodes.length; i++) {
          // print(nextNodes[i]);
          if (!visited.contains(nextNodes[i])) {
            setState(() {
              solveDepth = (int.parse(solveDepth) + 1).toString();

              nodes.add(nextNodes[i]);
            });
            //await Future.delayed(Duration(milliseconds: 20));
            // if (i == nextNodes.length - 1) {
            //   setState(() {
            //     solveDepth = (int.parse(solveDepth) +1).toString();
            //   });
            // }
            queue.add(nextNodes[i]);
            // if(await playDFS(nextNodes[i],visited)) return Future.value(true);
          }
        }
        //dep++;
      }
      level_bfs++;
      setState(() {
        print(level_bfs);
      });
      solveDepth = level_bfs.toString();
    }
  }

  List<List<Node>> printTree(
      Node node, List<List<Node>> nodes, List<Node> visited) {
    if (!visited.contains(node)) {
      visited.add(node);
    }
    if (node.isFinal()) {
      return nodes;
    }
    ;
    List<Node> nextNodes = node.getNextStates();
    List<Node> addedNodes = [];
    for (int i = 0; i < nextNodes.length; i++) {
      if (!visited.contains(nextNodes[i])) {
        nextNodes[i].x = node.x! + 1;
        nextNodes[i].y = i;
        addedNodes.add(nextNodes[i]);
        printTree(nextNodes[i], nodes, visited);
      }
    }
    nodes.add(addedNodes);
    return nodes;
  }

// UCS Algorithm

  int lev_size = 0;
  int level_ucs = 0;
  Future<void> playUCS(Node node) async {
    Map<Node, int> costs = {};

    PriorityQueue<NodePair> queue = PriorityQueue<NodePair>(((a, b) {
      return a.cost.compareTo(b.cost);
    }));
    costs[node] = 0;
    queue.add(NodePair(cost: 0, node: node));
    while (queue.isNotEmpty) {
      lev_size = queue.length;
      while (lev_size-- != 0) {
        // await Future.delayed(Duration(milliseconds: 20));
        NodePair nodePair = queue.removeFirst();
        setState(() {
          nodes.add(nodePair.node);

          visitedLength = (int.parse(visitedLength) + 1).toString();
        });
        int previousCost = costs[nodePair.node] ?? MAX_COST;
        if (previousCost < nodePair.cost) continue;
        if (nodePair.node.isFinal()) return;
        List<Node> nextNodes = nodePair.node.getNextStates();
        for (int i = 0; i < nextNodes.length; i++) {
          int previousChildCost = costs[nextNodes[i]] ?? MAX_COST;
          int childCost = nodePair.cost + 1;
          if (previousChildCost > childCost) {
            costs[nextNodes[i]] = childCost;
            queue.add(NodePair(cost: childCost, node: nextNodes[i]));
            //   if (i == nextNodes.length - 1) {
            //   setState(() {
            //     solveDepth = (int.parse(solveDepth) + 1).toString();
            //   });
            // }
          }
        }
      }
      level_ucs++;
      setState(() {
        print(level_ucs);
      });
      solveDepth = level_ucs.toString();
    }
  }

// change old position in new position
  void move(int i1, int i2) {
    Cell temp = a[i1];
    if (levels[level]![i1].type == 1) {
      a[i1] = levels[level]![i1].instead ??
          Cell(index: i1, type: 2, isSwipeable: false);
    } else {
      a[i1] = levels[level]![i1];
    }
    temp.index = i2;
    a[i2] = temp;
    setState(() {
      a = List.from(a);
    });
    //  printlist();
  }

// check if number match with node
  void checkMatch(int index) {
    if (levels[level]![index].type == 4 ||
        (levels[level]![index].instead != null &&
            levels[level]![index].instead!.type == 4)) {
      // print ("$index" + 'true');
      if ((a[index].type == 1) &&
          (a[index].n == levels[level]![index].n ||
              (levels[level]![index].instead != null &&
                  levels[level]![index].instead!.type == 4 &&
                  levels[level]![index].instead!.n == a[index].n))) {
        a[index].isMatch = true;
      } else {
        a[index].isMatch = false;
      }
    } else {
      // print ("$index" + 'false');
      a[index].isMatch = false;
    }
    setState(() {
      a = List.from(a);
    });
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    _focusNode.dispose();
    leftController.dispose();
    rightController.dispose();
    upController.dispose();
    downController.dispose();
    winAudioPlayer.dispose();
    swipeAudioPlayer.dispose();
    wrongSwipeAudioPlayer.dispose();
    nextLevelAudioPlayer.dispose();
    super.dispose();
  }

// Get next state (offsets can be moved to it)
  Cell changeDirections(int index) {
    a[index].offsets = [];

    /// Up Direction
    if (index - sqrt(a.length) >= 0 &&
        (a[index - sqrt(a.length).floor()].type == 2 ||
            a[index - sqrt(a.length).floor()].type == 4)) {
      a[index].offsets!.add(Offset(0.0, -1.0));
    }

    /// Down Direction
    if (index + sqrt(a.length) < a.length) {
      print((a[index + sqrt(a.length).floor()].type));
    }

    /// Right Direction
    if ((index + 1) % sqrt(a.length).floor() != 0 &&
        (a[index + 1].type == 2 || a[index + 1].type == 4)) {
      a[index].offsets!.add(Offset(1.0, 0.0));
    }

    /// Left Direction
    if ((index) % sqrt(a.length).floor() != 0 &&
        (a[index - 1].type == 2 || a[index - 1].type == 4)) {
      a[index].offsets!.add(Offset(-1.0, 0.0));
    }

    if (index + sqrt(a.length) < a.length &&
        (a[index + sqrt(a.length).floor()].type == 2 ||
            a[index + sqrt(a.length).floor()].type == 4)) {
      a[index].offsets!.add(Offset(0.0, 1.0));
    }

    Cell cell = a[index];
    setState(() {
      a = List.from(a);
    });
    return cell;
  }

// return new index is available
  int? getNextPosition(int index, Offset d) {
    if (d.dy == 1.0 && checkDownOffset(index)) {
      return index + sqrt(a.length).floor();
    } else if (d.dy == -1.0 && checkUpOffset(index)) {
      return index - sqrt(a.length).floor();
    } else if (d.dx == 1.0 && checkRightOffset(index)) {
      return index + 1;
    } else if (d.dx == -1.0 && checkLeftOffset(index)) {
      return index - 1;
    }

    return null;
  }

  bool checkRightOffset(int index) {
    return ((index + 1) % sqrt(a.length).floor() != 0 &&
            (a[index + 1].type == 2 || a[index + 1].type == 4)) &&
        (a[index + 1].type != 1);
  }

  bool checkLeftOffset(int index) {
    return ((index) % sqrt(a.length).floor() != 0 &&
            (a[index - 1].type == 2 || a[index - 1].type == 4)) &&
        (a[index - 1].type != 1);
  }

  // bool checkInRange(index) {
  //   return (index >= 0 && index < a.length);
  // }

  bool checkUpOffset(int index) {
    return (index - sqrt(a.length) >= 0 &&
            (a[index - sqrt(a.length).floor()].type == 2 ||
                a[index - sqrt(a.length).floor()].type == 4)) &&
        (a[index - sqrt(a.length).floor()].type != 1);
  }

  bool checkDownOffset(int index) {
    return (index + sqrt(a.length) < a.length &&
            (a[index + sqrt(a.length).floor()].type == 2 ||
                a[index + sqrt(a.length).floor()].type == 4)) &&
        (a[index + sqrt(a.length).floor()].type != 1);
  }

// check if node can be moved return true
  bool checkMove(Offset d, int index) {
    if (d.dy == 1.0) {
      return checkDownOffset(index);
    } else if (d.dy == -1.0) {
      return checkUpOffset(index);
    } else if (d.dx == 1.0) {
      return checkRightOffset(index);
    } else if (d.dx == -1.0) {
      return checkLeftOffset(index);
    }
    return true;
  }

// list of nodes can be moved together
  void addCurrentIndexes(Offset o) {
    bool isWillMove = false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].type == 1 && checkMove(o, i)) {
        currentIndexes.add(i);
        isWillMove = true;
      }
    }
    if (isWillMove) {
      swipeAudioPlayer.play();
    } else {
      wrongSwipeAudioPlayer.play();
    }
    setState(() {
      currentIndexes = List.from(currentIndexes);
    });
  }

  bool isWinner = false;
  late ConfettiController _controllerCenter;

  bool checkWin() {
    bool isWin = true;
    for (int i = 0; i < a.length; i++) {
      if (levels[level]![i].type == 4 ||
          (levels[level]![i].instead != null &&
              levels[level]![i].instead!.type == 4)) {
        if (!(a[i].type == 1 &&
            (a[i].n == levels[level]![i].n ||
                (levels[level]![i].instead != null &&
                    levels[level]![i].instead!.type == 4 &&
                    levels[level]![i].instead!.n == a[i].n)))) {
          isWin = false;
          break;
        }
      }
    }
    if (isWin) {
      winAudioPlayer.play();
      _controllerCenter.play();
      setState(() {
        isWinner = true;
      });
    }
    return isWin;
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  List<Node> nodes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        autofocus: true,
        focusNode: _focusNode,
        onKey: _handleKeyEvent,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Level Number : $level',
                      style: TextStyle(
                          fontSize: 50,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    isWinner || widget.playType != PlayType.User
                        ? Text(
                            widget.playType != PlayType.User
                                ? getPlayTypeDisplay(widget.playType)
                                : 'Congratulations, You Win!',
                            style: TextStyle(fontSize: 40, color: Colors.blue),
                          )
                        : Container(),
                    isWinner ? SizedBox(height: 15) : Container(),
                    widget.playType != PlayType.User
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'The Node With Number : $movedNode Is Moved Now',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Solve Depth : $solveDepth',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Visited Nodes : $visitedLength',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Solve Path : $solvePath',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                              SizedBox(height: 5),
                            ],
                          )
                        : Container(),
                    SizedBox(height: 20),
                    widget.playType == PlayType.User
                        ? Container(
                            width: 100 * sqrt(a.length),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xFFFF77A8), width: 3)),
                            height: 100 * sqrt(a.length),
                            child: GridView.count(
                              key: Key('grid_view'),
                              crossAxisCount: sqrt(a.length).floor(),
                              shrinkWrap: true,
                              children: List.generate(
                                  a.length,
                                  (index) => a[index].isSwipeable
                                      ? SlideTransition(
                                          position: checkLeftOffset(index)
                                              ? leftOffset
                                              : zeroOffset,
                                          child: SlideTransition(
                                            position: checkRightOffset(index)
                                                ? rightOffset
                                                : zeroOffset,
                                            child: SlideTransition(
                                              position: checkUpOffset(index)
                                                  ? upOffset
                                                  : zeroOffset,
                                              child: SlideTransition(
                                                position: checkDownOffset(index)
                                                    ? downOffset
                                                    : zeroOffset,
                                                child: GestureDetector(
                                                  onHorizontalDragUpdate: (d) {
                                                    if (!isWinner) {
                                                      if (d.delta.dx >= 3 ||
                                                          d.delta.dx <= -3) {
                                                        if (d.delta.direction ==
                                                                0 ||
                                                            d.delta.direction ==
                                                                pi) {
                                                          if (d.delta.dx > 0 &&
                                                              rightController
                                                                      .status !=
                                                                  AnimationStatus
                                                                      .forward) {
                                                            if (checkRightOffset(
                                                                index)) {
                                                              addCurrentIndexes(
                                                                  Offset(1.0,
                                                                      0.0));
                                                              rightController
                                                                  .forward();
                                                            }
                                                          } else if (d.delta
                                                                      .dx <
                                                                  0 &&
                                                              leftController
                                                                      .status !=
                                                                  AnimationStatus
                                                                      .forward) {
                                                            if (checkLeftOffset(
                                                                index)) {
                                                              addCurrentIndexes(
                                                                  Offset(-1.0,
                                                                      0.0));
                                                              leftController
                                                                  .forward();
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  },
                                                  onVerticalDragUpdate: (d) {
                                                    if (!isWinner) {
                                                      if (d.delta.dy >= 3 ||
                                                          d.delta.dy <= -3) {
                                                        if (d.delta.direction ==
                                                                (pi / 2) ||
                                                            d.delta.direction ==
                                                                -(pi / 2)) {
                                                          if (d.delta.dy < 0 &&
                                                              upController
                                                                      .status !=
                                                                  AnimationStatus
                                                                      .forward) {
                                                            if (checkUpOffset(
                                                                index)) {
                                                              addCurrentIndexes(
                                                                  Offset(0.0,
                                                                      -1.0));
                                                              upController
                                                                  .forward();
                                                            }
                                                          } else if (d.delta
                                                                      .dy >
                                                                  0 &&
                                                              downController
                                                                      .status !=
                                                                  AnimationStatus
                                                                      .forward) {
                                                            if (checkDownOffset(
                                                                index)) {
                                                              addCurrentIndexes(
                                                                  Offset(0.0,
                                                                      1.0));
                                                              downController
                                                                  .forward();
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.8),
                                                              spreadRadius: 5,
                                                              blurRadius: 5,
                                                              offset: Offset(1,
                                                                  1), // changes position of shadow
                                                            ),
                                                          ],
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                              width: 2)),
                                                      child: Center(
                                                          child: NumberCell(
                                                        key: Key(
                                                            'number_${index}_${a[index].isMatch}'),
                                                        number: a[index].n!,
                                                        isMatch:
                                                            a[index].isMatch,
                                                      ))),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : a[index].type == 2
                                          ? EmptyCell(
                                              key: Key('empty_$index'),
                                            )
                                          : a[index].type == 3
                                              ? WallCell(
                                                  key: Key('wall_$index'),
                                                )
                                              : EmptyNumberCell(
                                                  key: Key(
                                                      'empty_number_$index'),
                                                  number: a[index].n!)),
                            ),
                          )
                        : a.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : GridView.builder(
                                itemCount: nodes.length,
                                shrinkWrap: true,
                                itemBuilder: (_, ind) {
                                  List<Cell> a = nodes[ind].currentCells;
                                  return Padding(
                                    key: Key('padding_$ind'),
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      width: 60 * sqrt(a.length),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0xFFFF77A8),
                                              width: 3)),
                                      height: 60 * sqrt(a.length),
                                      child: GridView.count(
                                        key: Key('grid_view_$ind'),
                                        crossAxisCount: sqrt(a.length).floor(),
                                        shrinkWrap: true,
                                        children: List.generate(
                                          a.length,
                                          (index) => a[index].isSwipeable
                                              ? SlideTransition(
                                                  position:
                                                      checkLeftOffset(index)
                                                          ? leftOffset
                                                          : zeroOffset,
                                                  child: SlideTransition(
                                                    position:
                                                        checkRightOffset(index)
                                                            ? rightOffset
                                                            : zeroOffset,
                                                    child: SlideTransition(
                                                      position:
                                                          checkUpOffset(index)
                                                              ? upOffset
                                                              : zeroOffset,
                                                      child: SlideTransition(
                                                        position:
                                                            checkDownOffset(
                                                                    index)
                                                                ? downOffset
                                                                : zeroOffset,
                                                        child: GestureDetector(
                                                          onHorizontalDragUpdate:
                                                              (d) {
                                                            if (!isWinner) {
                                                              if (d.delta.dx >=
                                                                      3 ||
                                                                  d.delta.dx <=
                                                                      -3) {
                                                                if (d.delta.direction ==
                                                                        0 ||
                                                                    d.delta.direction ==
                                                                        pi) {
                                                                  if (d.delta.dx >
                                                                          0 &&
                                                                      rightController
                                                                              .status !=
                                                                          AnimationStatus
                                                                              .forward) {
                                                                    if (checkRightOffset(
                                                                        index)) {
                                                                      addCurrentIndexes(Offset(
                                                                          1.0,
                                                                          0.0));
                                                                      rightController
                                                                          .forward();
                                                                    }
                                                                  } else if (d.delta
                                                                              .dx <
                                                                          0 &&
                                                                      leftController
                                                                              .status !=
                                                                          AnimationStatus
                                                                              .forward) {
                                                                    if (checkLeftOffset(
                                                                        index)) {
                                                                      addCurrentIndexes(Offset(
                                                                          -1.0,
                                                                          0.0));
                                                                      leftController
                                                                          .forward();
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          },
                                                          onVerticalDragUpdate:
                                                              (d) {
                                                            if (!isWinner) {
                                                              if (d.delta.dy >=
                                                                      3 ||
                                                                  d.delta.dy <=
                                                                      -3) {
                                                                if (d.delta.direction ==
                                                                        (pi /
                                                                            2) ||
                                                                    d.delta.direction ==
                                                                        -(pi /
                                                                            2)) {
                                                                  if (d.delta.dy <
                                                                          0 &&
                                                                      upController
                                                                              .status !=
                                                                          AnimationStatus
                                                                              .forward) {
                                                                    if (checkUpOffset(
                                                                        index)) {
                                                                      addCurrentIndexes(Offset(
                                                                          0.0,
                                                                          -1.0));
                                                                      upController
                                                                          .forward();
                                                                    }
                                                                  } else if (d.delta
                                                                              .dy >
                                                                          0 &&
                                                                      downController
                                                                              .status !=
                                                                          AnimationStatus
                                                                              .forward) {
                                                                    if (checkDownOffset(
                                                                        index)) {
                                                                      addCurrentIndexes(Offset(
                                                                          0.0,
                                                                          1.0));
                                                                      downController
                                                                          .forward();
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          },
                                                          child: Container(
                                                              width: 100,
                                                              height: 100,
                                                              decoration: BoxDecoration(
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.8),
                                                                      spreadRadius:
                                                                          5,
                                                                      blurRadius:
                                                                          5,
                                                                      offset: Offset(
                                                                          1,
                                                                          1), // changes position of shadow
                                                                    ),
                                                                  ],
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width:
                                                                          2)),
                                                              child: Center(
                                                                  child:
                                                                      NumberCell(
                                                                key: Key(
                                                                    'number_${ind}_$index'),
                                                                fontSize: 18,
                                                                number:
                                                                    a[index].n!,
                                                                isMatch: a[
                                                                        index]
                                                                    .isMatch,
                                                              ))),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : a[index].type == 2
                                                  ? EmptyCell(
                                                      key: Key(
                                                          'empty_${ind}_$index'),
                                                    )
                                                  : a[index].type == 3
                                                      ? WallCell(
                                                          key: Key(
                                                              'wall_${ind}_$index'),
                                                        )
                                                      : EmptyNumberCell(
                                                          key: Key(
                                                              'empty_number_${ind}_$index'),
                                                          fontSize: 18,
                                                          number: a[index].n!),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 8),
                              ),
                    isWinner ? SizedBox(height: 15) : Container(),
                    isWinner
                        ? ElevatedButton(
                            onPressed: () {
                              nextLevelAudioPlayer.play();
                              a = levels[level + 1]!;
                              setState(() {
                                level = level + 1;
                                a = List.from(a);
                              });
                              setState(() {
                                isWinner = false;
                                nodes = [];
                                solveDepth = '0';
                                visitedLength = '0';
                              });
                              start(widget.playType);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Next',
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward,
                                    size: 30, color: Colors.white),
                              ],
                            ),
                            style:
                                ElevatedButton.styleFrom(primary: Colors.blue),
                          )
                        : Container(),
                    SizedBox(height: 15),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                  confettiController: _controllerCenter,
                  blastDirectionality: BlastDirectionality
                      .explosive, // don't specify a direction, blast randomly
                  // start again as soon as the animation is finished
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ],
                  numberOfParticles:
                      300, // manually specify the colors to be used
                  createParticlePath: drawStar, // define a custom shape/path.
                ),
              ),
              Positioned(
                  top: 0,
                  left: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Center(
                              child: Icon(Icons.home_rounded,
                                  color: Colors.black, size: 40),
                            )),
                        SizedBox(
                          width: 20,
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                isWinner = false;
                                a = List.from(levels[level]!);
                                nodes = [];
                              });
                              start(widget.playType);
                            },
                            icon: Center(
                              child: Icon(Icons.refresh,
                                  color: Colors.red, size: 40),
                            )),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

/*/{
 bool dfs (List <Cell> b , List<bool> visited, List<Cell> current-node)
 {
  if (b.checkWin)return true
  visited.add(b)
  





  isVisited [current-node]=true
  for(node in b[current-node])
  if (isVisited[node])
  continue
  dfs(b,isVisited,node)
 }

*/
