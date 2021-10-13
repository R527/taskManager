import 'package:flutter/material.dart';
import 'home.dart';


int taskNum = 0;//タスクの数を保存

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(''),
    );
  }
}

