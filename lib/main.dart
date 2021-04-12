import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'constant.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

void main() {
  timeDilation = 5.0;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<int>> snake = [
    [0, 0],
    [1, 0]
  ];
  int prevscore = 0;
  List<int> apple = [5, 5];
  int direction = 1;
  bool value = false;
  Random _random = Random();
  int previosMove = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(new Duration(milliseconds: 300), (timer) {
      move();
      setState(() {});
    });
  }

  void move() {
    if(direction==0)return;
    List<int> head = [
      snake.last[0] + direction * (direction % 2),
      snake.last[1] + (direction / 3).round()
    ];
    previosMove = direction;
    head[0] = head[0] == items_in_a_row ? 0 : head[0];
    head[1] = head[1] == items_in_a_column ? 0 : head[1];
    head[0] = head[0] < 0 ? items_in_a_row - 1 : head[0];
    head[1] = head[1] < 0 ? items_in_a_column - 1 : head[1];

    if (direction != 0 &&
        snake
            .firstWhere((element) => listEquals(element, head),
                orElse: () => List.of([]))
            .isNotEmpty) {
      direction = 0;
      prevscore = snake.length;
      restart();
      return;
    }
    if (listEquals(head, apple)) {
      apple = [
        _random.nextInt(items_in_a_row),
        _random.nextInt(items_in_a_column)
      ];
    } else
      snake.removeAt(0);

    snake.add(head);
  }

  void restart() {
    previosMove = 1;
    snake = [
      [0, 0],
      [1, 0]
    ];
    apple = [
      _random.nextInt(items_in_a_row),
      _random.nextInt(items_in_a_column)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: items_in_a_row,
              crossAxisSpacing: 0.0,
              mainAxisSpacing: 0.0,
            ),
            shrinkWrap: true,
            itemCount: items_in_a_row * items_in_a_column,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              int row = index % items_in_a_row;
              int col = items_in_a_column -
                  1 -
                  ((index * 1) / items_in_a_row).floor();
              var pair = [row, col];
              bool checked = snake
                  .firstWhere((element) => listEquals(element, pair),
                      orElse: () => List.of([]))
                  .isNotEmpty;
              checked = checked || listEquals(apple, pair);
              return CupertinoSwitch(
                value: checked,
                onChanged: (bool value) {},
              );
            }),
        Text('Prev score $prevscore'),
        GestureDetector(
            onPanUpdate: (something) {
              Offset position = something.localPosition - Offset(100, 100);
              int mayDirection = direction;
              if (position.distance < 30) return;
              if (position.dx.abs() > position.dy.abs()) {
                mayDirection = position.dx.sign.toInt();
              } else {
                mayDirection = -2 * position.dy.sign.toInt();
              }
              direction =
                  mayDirection != -previosMove ? mayDirection : direction;
            },
            child: Container(
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
              height: 200,
              width: 200,
            )),
      ]),
    );
  }
}
