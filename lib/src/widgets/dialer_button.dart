import 'package:flutter/material.dart';

class DialerButton extends StatelessWidget {
  final String digit;
  final String letters;
  final Function() onPressed;

  const DialerButton({
    super.key,
    required this.digit,
    required this.letters,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: letters.isEmpty
                  ? const EdgeInsets.all(12.0)
                  : const EdgeInsets.all(0),
              child: Text(
                digit,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            if (letters.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 2.0),
                child: Text(
                  letters,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
