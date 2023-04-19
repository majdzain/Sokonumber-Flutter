import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sokonumber_flutter/pages/player.dart';
import 'package:sokonumber_flutter/utils/constants/play_type.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sokonumber",
          style: TextStyle(fontSize: 28),
        ),
        backgroundColor: Color(0xFFFF77A8),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Welcome to Sokonumber Game',
                      style: TextStyle(fontSize: 40)),
                  SizedBox(height: 25),
                  Text('You can play normally and follow these instractions:',
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  SizedBox(
                    width: Platform.isAndroid || Platform.isIOS
                        ? null
                        : MediaQuery.of(context).size.width / 2,
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio:
                          Platform.isAndroid || Platform.isIOS ? 7 : 8,
                      shrinkWrap: true,
                      children: [
                        Container(),
                        Text('KEYBOARD',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('TOUCH/MOUSE',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('MOVE',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('WASD/ARROWS', style: TextStyle(fontSize: 16)),
                        Text('SWIPE UP, DOWN, LEFT, RIGHT',
                            style: TextStyle(fontSize: 16)),
                        Text('RESTART',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('R', style: TextStyle(fontSize: 16)),
                        Text('\u{21BB}',
                            style: TextStyle(fontSize: 16, color: Colors.red)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (c) {
                          return PlayerPage(
                              playType: PlayType.User, level: 1, title: '');
                        }));
                      },
                      child:
                          Text('User Player', style: TextStyle(fontSize: 18))),
                  SizedBox(
                    height: 15,
                  ),
                  Divider(),
                  Text(
                      'Or you can see the search algorithims how can play the game',
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (c) {
                          return PlayerPage(
                              playType: PlayType.DFS, level: 3, title: '');
                        }));
                      },
                      child:
                          Text('DFS Player', style: TextStyle(fontSize: 18))),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (c) {
                          return PlayerPage(
                              playType: PlayType.BFS, level: 3, title: '');
                        }));
                      },
                      child:
                          Text('BFS Player', style: TextStyle(fontSize: 18))),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (c) {
                          return PlayerPage(
                              playType: PlayType.UCS, level: 3, title: '');
                        }));
                      },
                      child:
                          Text('UCS Player', style: TextStyle(fontSize: 18))),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Not implemented yet!')));
                        // Navigator.of(context).push(MaterialPageRoute(builder: (c) {
                        //   return PlayerPage(
                        //       playType: PlayType.A_STAR, level: 3, title: '');
                        // }));
                      },
                      child:
                          Text('A_STAR Player', style: TextStyle(fontSize: 18)))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
