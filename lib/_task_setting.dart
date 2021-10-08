import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskpagetest/taskControllerPage.dart';

import 'main.dart';

//タスクsettingpage
class TaskSettingPage extends StatefulWidget{
  TaskSettingPage(this.buildNum,this.newTask);
  final int buildNum;
  final bool newTask;//StatefulWidgeとStatelessWidget　finalをつける　不変にするため

  @override
  _TaskSettingPage createState() => _TaskSettingPage();
}
class _TaskSettingPage extends State<TaskSettingPage>{

  //textField用
  final setTaskController = TextEditingController();
  //優先度保存
  List<bool> _isRankingSelected = [true, false, false];

  //初期設定
  Future<void> init() async{
    setTaskController.text = await loadStringPrefs('', 'setTask', widget.buildNum);
    for(int i = 0;i < 3; i++){
      //優先度１のみtrueそれ以外はfalse
      _isRankingSelected[i] = await loadBoolPrefs(i == 0 ? true:false,'setTaskRanking',widget.buildNum,i);
    }


  }
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('タスク設定'),
        actions: [
          ElevatedButton(
              onPressed: (){
                //未入力などDiaLogで表示
                if(setTaskController.text == ''){
                  _showDialog();
                }else{
                  //Save処理
                  saveStringPrefs(setTaskController.text,'setTask',widget.buildNum);
                  for(int i = 0;i < 3; i++) saveBoolPrefs(_isRankingSelected[i],'setTaskRanking',widget.buildNum,i);
                  if(widget.newTask) saveIntPrefs(widget.buildNum + 1,'taskDataListLength');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskControllerPage()),
                  );
                }
              },
              child: Container(
                child: Text(
                    '適応',
                  style: TextStyle(fontSize: 20),
                ),
              )
          )
        ],
      ),
      body: Center(
        child:Column(
          children: <Widget>[
            _setTaskTextFild(),
            _rankingTask(),
          ],
        )
      ),
    );
  }

  //タスク内容を記入し保存する
  Widget _setTaskTextFild(){
    return Container(
      margin: EdgeInsets.only(left: 10,right: 10,top: 30,bottom: 40),
      child: TextField(
        controller: setTaskController,
        autofocus: true,
        onChanged: (text){
          setTaskController.text = text;
        },
        decoration: InputDecoration(
          hintText: 'タスク入力欄（例：筋トレ）',
        ),
      ),
    );
  }
  //優先順位決定
  Widget _rankingTask(){
    return Container(
      margin: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text('優先度',style: TextStyle(fontSize: 20))),
          ToggleButtons(
            children: <Widget>[
              Container(child: Text('1',style: TextStyle(fontSize: 20))),
              Container(child: Text('2',style: TextStyle(fontSize: 20))),
              Container(child: Text('3',style: TextStyle(fontSize: 20))),
            ],

            //優先度の決定処理
            onPressed: (int index) {
              setState(() {
                for(int i = 0;i < 3; i++){
                  _isRankingSelected[i] = false;
                }
                _isRankingSelected[index] = !_isRankingSelected[index];

              });
            },
            isSelected: _isRankingSelected,
          ),
        ],
      ),
    );
  }

  //タスク未記入の場合
  Future _showDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) =>
        AlertDialog(
          content: Text('タスク内容を入力してください。'),
        ),
    );
  }


  //以下Prefs処理
  void saveStringPrefs(String setStr,String saveName,int buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(saveName + '$buildNum', setStr);
  }

  Future<String> loadStringPrefs(String def,String saveName,int buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(saveName + '$buildNum') ?? def;
  }

  void saveIntPrefs(int setInt,String saveName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(saveName, setInt);
  }

  Future<int> loadIntPrefs(int def,String saveName,int buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(saveName) ?? def;
  }

  void saveBoolPrefs(bool setBool,String saveName,int buildNum,[int? rankingNum]) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(saveName + '$buildNum' + '$rankingNum!', setBool);
  }

  Future<bool> loadBoolPrefs(bool def, String saveName,int buildNum,[int? rankingNum]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(saveName + '$buildNum' + '$rankingNum!') ?? def;
  }
}

