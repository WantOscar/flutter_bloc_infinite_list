import 'package:flutter/material.dart';
import 'package:flutter_bloc_infinite_list/src/app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: App(),
      debugShowCheckedModeBanner: false,
    );
  }
}
