import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Comon/DebugManager.dart';
import 'home.dart';

int taskNum = 0;//タスクの数を保存

void main() async{

  //Prefs 全削除 Debug用
  if(isPrefsClear){
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }

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

