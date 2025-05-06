import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_infinite_list/src/app.dart';
import 'package:flutter_bloc_infinite_list/src/core/post_observer.dart';

void main() {
  runApp(const MyApp());
  Bloc.observer = const PostObserver();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: App(),
      debugShowCheckedModeBanner: false,
    );
  }
}
