import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MemoryGamePage extends StatefulWidget {
  @override
  _MemoryGamePageState createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  List<String> items = [
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
    '🐨', '🐯',
  ];

  List<String> cards = [];

  List<bool> cardVisibility = [];

  int? firstCardIndex;
  int? secondCardIndex;

  int pairsFound = 0;

  bool isGameLocked = false;

  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    cards = List<String>.from(items)..addAll(items);
    cardVisibility = List<bool>.filled(cards.length, true);
    pairsFound = 0;
    _elapsedSeconds = 0;
    isGameLocked = false;
    cards.shuffle();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _onCardTap(int index) {
    if (isGameLocked || !cardVisibility[index]) {
      return;
    }

    setState(() {
      if (firstCardIndex == null) {
        firstCardIndex = index;
      } else if (secondCardIndex == null) {
        secondCardIndex = index;
        isGameLocked = true;

        Future.delayed(Duration(seconds: 1), () {
          if (cards[firstCardIndex!] == cards[secondCardIndex!]) {
            cardVisibility[firstCardIndex!] = false;
            cardVisibility[secondCardIndex!] = false;

            pairsFound++;

            if (pairsFound == items.length) {
              _stopTimer();
              _showGameCompleteDialog();
            }
          }

          firstCardIndex = null;
          secondCardIndex = null;
          isGameLocked = false;
        });
      }
    });
  }

  void _showGameCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You completed the game in $_elapsedSeconds seconds.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startNewGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Game'),
        backgroundColor: Colors.teal, // Set the app bar background color
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Elapsed Time: $_elapsedSeconds seconds',
              style: TextStyle(fontSize: 18),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _onCardTap(index),
                child: Container(
                  color: cardVisibility[index] ? Colors.teal : Colors.transparent, // Set the card color
                  child: Center(
                    child: Text(
                      cardVisibility[index] ? cards[index] : '',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Memory Game',
    home: MemoryGamePage(),
  ));
}
