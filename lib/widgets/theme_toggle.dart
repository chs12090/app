import 'package:flutter/material.dart';

class ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Theme.of(context).brightness == Brightness.light ? Icons.dark_mode : Icons.light_mode,
      ),
      onPressed: () {
        // Toggle theme logic (requires provider or similar state management)
        // This is a placeholder; implement with a state management solution
      },
    );
  }
}