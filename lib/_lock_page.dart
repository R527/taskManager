import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskpagetest/services/admob.dart';
import 'home.dart';


String loadString = '';
class LockPage extends StatefulWidget{
  @override
  _LockPage createState() => _LockPage();
}
//Task管理メインクラス
class _LockPage extends State<LockPage> with WidgetsBindingObserver{

  String taskText = '';
  int achievementTask = 0;

  bool isLoading = true;

  //初期化ロード処理
  void init() async{
    //タスク内容をロード
    taskText = await loadStringPrefs('','setTask',0);
    print(taskText);
    if(taskText == ''){
      print('未入力');
      taskText = 'タスク未入力です。';
    }
    //タスク達成数をロード
    var now = DateTime.now();
    String day = DateFormat('yyyy/MM/dd').format(now);
    achievementTask = await loadIntPrefs('achievementTask' + day);
    loadString = 'achievementTask' + day;
    print('achievementTask' + day);


    isLoading = false;
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
    init();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading ? CircularProgressIndicator():Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(taskText,style: TextStyle(fontSize: 24)),
              _successButtonWidget(),
              _failTaskButtonWidget(),
            ],
          ),
        )
          // child: FutureBuilder(
          //     future: _getFutureValue(),
          //     builder: (BuildContext context,AsyncSnapshot<void> snapshot) {
          //       // 通信中はスピナーを表示
          //       if (snapshot.connectionState != ConnectionState.done) return CircularProgressIndicator();
          //       // エラー発生時はエラーメッセージを表示
          //       if (snapshot.hasError) return Text(snapshot.error.toString());
          //       // データがnullでないかチェック
          //       if (snapshot.hasData) {
          //         return _viewLockPage();
          //       } else {
          //         return Text("データが存在しません");
          //       }
          //     }
          // )

      ),
    );
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
          onPressed: () async{
            //スマホのホーム画面へ
            var now = DateTime.now();
            String day = DateFormat('yyyy/MM/dd').format(now);

            await saveIntPrefs(achievementTask++,'achievementTask' + day);
            if(loadString == 'achievementTask' + day){
              print('同じ');
            }
            print('achievementTask' + day);

            print(await loadIntPrefs('achievementTask' + day));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage('')),
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
        onPressed: () async{
          //広告表示
          var now = DateTime.now();
          String day = DateFormat('yyyy/MM/dd').format(now);
          await saveIntPrefs(achievementTask--,'achievementTask' + day);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage('')),
          );
        },
        child: Text('    失敗。  ',style: TextStyle(fontSize: 20))),
    );
  }

  Future<String> loadStringPrefs(String def,String saveName,int buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(saveName + '$buildNum') ?? def;
  }

  Future<void> saveIntPrefs(int setInt,String saveName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(saveName, setInt);
  }

  Future<int> loadIntPrefs(String saveName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(saveName) ?? 0;
  }
}