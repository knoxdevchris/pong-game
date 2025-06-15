import 'dart:math';
import 'package:flutter/material.dart';
import './ball.dart';
import './bat.dart';

enum Direction { up, down, left, right }

class Pong extends StatefulWidget {
  @override
  _PongState createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  double posX = 0, posY = 0;
  double batPosition = 0;
  late double width, height, batWidth, batHeight;
  double increment = 5;
  double randX = 1, randY = 1;
  int score = 0;

  late Animation<double> animation;
  late AnimationController controller;

  Direction hDir = Direction.right;
  Direction vDir = Direction.down;


  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(minutes: 10000), vsync: this);

    animation = Tween<double>(begin: 0, end: 100).animate(controller)
      ..addListener(() {
        safeSetState(() {
          (hDir == Direction.right) ? posX += increment * randX : posX -= increment * randX;
          (vDir == Direction.down) ? posY += increment * randY : posY -= increment * randY;
        });
        checkBorders();
      });

    controller.forward();
  }

  void safeSetState(Function fn) {
    if (mounted && controller.isAnimating) {
      setState(() => fn());
    }
  }

  void moveBat(DragUpdateDetails update) {
    safeSetState(() {
      batPosition += update.delta.dx;
    });
  }

  void checkBorders() {
    double diameter = 50;
    if (posX <= 0 && hDir == Direction.left) {
      hDir = Direction.right;
      randX = randomNumber();
    }
    if (posX >= width - diameter && hDir == Direction.right) {
      hDir = Direction.left;
      randX = randomNumber();
    }
    if (posY >= height - diameter - batHeight && vDir == Direction.down) {
      if (posX >= (batPosition - diameter) && posX <= (batPosition + batWidth + diameter)) {
        vDir = Direction.up;
        randY = randomNumber();
        safeSetState(() => score++);
      } else {
        controller.stop();
        showMessage(context);
      }
    }
    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
      randY = randomNumber();
    }
  }

  double randomNumber() {
    var ran = Random();
    return (50 + ran.nextInt(101)) / 100;
  }

  void showMessage(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Game Over"),
            content: Text("Would you like to play again?"),
            actions: [
              ElevatedButton(
                child: Text("Yes"),
                onPressed: () {
                  setState(() {
                    posX = 0;
                    posY = 0;
                    score = 0;
                  });
                  Navigator.of(context).pop();
                  controller.repeat();
                },
              ),
              ElevatedButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                  dispose();
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      batWidth = width / 5;
      batHeight = height / 20;

      return Stack(children: [
        Positioned(top: posY, left: posX, child: Ball()),
        Positioned(
            bottom: 0,
            left: batPosition,
            child: GestureDetector(
                onHorizontalDragUpdate: moveBat,
                child: Bat(batWidth, batHeight))),
        Positioned(top: 0, right: 24, child: Text("Score: $score")),
      ]);
    });
  }
}
