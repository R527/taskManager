import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:admob_flutter/admob_flutter.dart';
import 'package:taskpagetest/services/admob.dart';

import 'home.dart';
import 'main.dart';

class LockPage extends StatefulWidget{
  @override
  _LockPage createState() => _LockPage();
}
//Task管理メインクラス
class _LockPage extends State<LockPage> with WidgetsBindingObserver{

  String taskText = '';
  void init() async{
    taskText = await loadStringPrefs('','setTask',0);
    print(taskText);
    if(taskText == ''){
      print('未入力');
      taskText = 'タスク未入力です。';
    }
  }
  @override
  void initState() {
    super.initState();
    init();
    // WidgetsFlutterBinding.ensureInitialized();
    // Admob.initialize();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: FutureBuilder(
              future: _getFutureValue(),
              builder: (BuildContext context,AsyncSnapshot<void> snapshot) {
                // 通信中はスピナーを表示
                if (snapshot.connectionState != ConnectionState.done) return CircularProgressIndicator();
                // エラー発生時はエラーメッセージを表示
                if (snapshot.hasError) return Text(snapshot.error.toString());
                // データがnullでないかチェック
                if (snapshot.hasData) {
                  return _viewLockPage();
                } else {
                  return Text("データが存在しません");
                }
              }
          )

      ),
    );
  }
  Future<String> _getFutureValue() async {
    // 擬似的に通信中を表現するために１秒遅らせる
    await Future.delayed(
      Duration(seconds: 1),
    );
    return Future.value("データの取得に成功しました");
  }

  Widget _viewLockPage(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(taskText,style: TextStyle(fontSize: 24)),
          _successButtonWidget(),
          _failTaskButtonWidget(),
        ],
      ),
    );
  }
  //タスク達成時用
  Widget _successButtonWidget(){
    return Container(
      margin: EdgeInsets.only(top: 20,bottom: 5),
      child:ElevatedButton(
          onPressed: (){
            //todo スマホのホーム画面へ
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: Text('    達成！  ',style: TextStyle(fontSize: 20))),
    );
  }

  //タスク達成時用
  Widget _failTaskButtonWidget(){
    return Container(
      margin: EdgeInsets.only(bottom: 40),
      child:ElevatedButton(
        onPressed: (){
          //todo 広告表示
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        child: Text('    失敗。  ',style: TextStyle(fontSize: 20))),
    );
  }

  Future<String> loadStringPrefs(String def,String saveName,int buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(saveName + '$buildNum') ?? def;
  }
}