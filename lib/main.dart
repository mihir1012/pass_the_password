import 'package:flutter/material.dart';
import 'package:pass_the_password/home.dart';

void main() {
  runApp(const AppHome());
}

class AppHome extends StatelessWidget {
  const AppHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SharedPreferences Demo',
      home: HomePage(),
      themeMode: ThemeMode.system,
    );
  }
}
