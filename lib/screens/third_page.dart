import 'package:flutter/material.dart';
import 'dart:async';

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  List<String> items = ['🎮', '🎲', '🎯', '🎨', '🎭', '🎪', '🎰', '🎳'];
  List<String> cards = [];
  List<bool> cardFlips = [];
  List<int> selectedCards = [];
  int pairs = 0;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    initGame();
  }

  void initGame() {
    cards = [...items, ...items];
    cards.shuffle();
    cardFlips = List.filled(16, false);
    selectedCards = [];
    pairs = 0;
  }

  void resetGame() {
    setState(() {
      initGame();
    });
  }

  void onCardTap(int index) {
    if (isProcessing || cardFlips[index] || selectedCards.length == 2) return;

    setState(() {
      cardFlips[index] = true;
      selectedCards.add(index);
    });

    if (selectedCards.length == 2) {
      isProcessing = true;
      Timer(const Duration(milliseconds: 500), () {
        checkMatch();
        isProcessing = false;
      });
    }
  }

  void checkMatch() {
    if (cards[selectedCards[0]] == cards[selectedCards[1]]) {
      pairs++;
      if (pairs == 8) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Congratulations! 🎉'),
            content: const Text('You won! Want to play again?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  resetGame();
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
        );
      }
    } else {
      setState(() {
        cardFlips[selectedCards[0]] = false;
        cardFlips[selectedCards[1]] = false;
      });
    }
    selectedCards.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          'Memory Game',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(221, 0, 0, 0),
              Color.fromARGB(221, 71, 71, 71),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Pairs Found: $pairs/8',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 16,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => onCardTap(index),
                  child: Card(
                    color: cardFlips[index] ? Colors.white : Colors.deepPurple,
                    child: Center(
                      child: Text(
                        cardFlips[index] ? cards[index] : '?',
                        style: TextStyle(
                          fontSize: 32,
                          color: cardFlips[index] ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: resetGame,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
