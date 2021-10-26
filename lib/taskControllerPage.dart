import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '_task_setting.dart';
import '_time_controller_page.dart';
import 'home.dart';
import 'main.dart';


//Task管理
class TaskControllerPage extends StatefulWidget{
  @override
  _TaskControllerPage createState() => _TaskControllerPage();
}
//Task管理メインクラス
class _TaskControllerPage extends State<TaskControllerPage>{

  //Drawer用のKey
  final GlobalKey<ScaffoldState> _openDrawerkey = GlobalKey<ScaffoldState>();

  //List宣言
  int taskLen = 0;//taskの数を保存
  List<TaskDataList> taskDataList = [];

  //Initを待つためのフラグ
  bool isLoading = true;

  //Listをロードして初期化
  Future<void> init() async{

    List<TaskDataList> taskList = [];
    taskLen = await loadIntPrefs('taskDataListLength');
    //Listの数が１以上ならロードする
    if(taskLen != 0){
      for(int i = 0;i < taskLen; i++){
        List<bool> list = [];
        String task = '';

        task = await loadStringPrefs('','setTask',i);
        for(int x = 0;x < 3; x++) list.add(await loadBoolPrefs(false,'setTaskRanking',i,x));
        taskList.add(TaskDataList(task,list,false));
      }
      //優先度反映
      for(int x = 0;x < 3; x++){
        for(int i = 0;i < taskLen; i++){
          if(taskList[i].taskRankingList[x]){
            taskDataList.add(taskList[i]);
          }
        }
      }
    }



   isLoading = false;
    setState(() {});
  }

  //初期化処理
  @override
  void initState() {
    super.initState();
    init();
  }

  //画面表示
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _openDrawerkey,
      appBar: AppBar(
        title: Text('タスク管理'),

        //Drawerを開く
        leading: IconButton(
          icon:Icon(Icons.menu),
          onPressed: (){
            _openDrawerkey.currentState!.openDrawer();
          },
        ),

        actions: [
          //いらないタスクを捨てるボタン
          IconButton(
              onPressed: () async{
                //todo いらないタスク捨てる

                int len = taskDataList.length;
                if(len == 0) return;

                //既に設定されているtask設定を削除する
                for(int i = 0;i < taskDataList.length; i++){
                  if(taskDataList[i].checkBox) {
                    taskDataList.removeAt(i);
                    i--;
                  }
                }

                //一旦Prefs全削除
                for(int i = 0;i < len + 3; i++){
                  await removePrefs('setTask',i);
                  for(int x = 0;x < 3; x++){
                    await removePrefs('setTaskRanking',i,x);
                  }
                }

                //セーブしなおし
                for(int i = 0;i < taskDataList.length; i++){

                  await saveStringPrefs(taskDataList[i].task,'setTask',i);

                  for(int x = 0;x < 3; x++){
                    await saveBoolPrefs(taskDataList[i].taskRankingList[x],'setTaskRanking',i,x);
                  }
                }
                //List数セーブ
                await saveIntPrefs(taskDataList.length,'taskDataListLength');
                setState(() {});
              },
              icon: Icon(Icons.delete)
          ),

          //タスクを追加するボタン
          IconButton(
              onPressed: (){
                //タスクを追加する
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskSettingPage(taskDataList.length,true)),
                );
              },
              icon: Icon(Icons.add)
          ),
        ],
      ),

      //Drawerを開く
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              height: 60,
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ), child: null,
              ),
            ),
            _homeControllerPage('ホーム'),
            _timeControllerPage('ロック管理'),
            _taskControllerPage('タスク管理'),
          ],
        ),
      ),

      body:Center(
        child: isLoading ? CircularProgressIndicator() :  Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                itemBuilder: (context,index){
                  return _taskListViewTile(index);
                },
                itemCount: taskDataList.length,
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeControllerPage(String text){
    return Container(
      child: ListTile(
          title: Text(text),
          trailing: Icon(Icons.arrow_forward),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage('')),
            );
          }
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0,color:Colors.grey)),
      ),
    );
  }
  //Drawer用
  Widget _timeControllerPage(String text){
    return Container(
      child: ListTile(
          title: Text(text),
          trailing: Icon(Icons.arrow_forward),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TimeControllerPage()),
            );
          }
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0,color:Colors.grey)),
      ),
    );
  }

  //Drawer用
  Widget _taskControllerPage(String text){
    return Container(
      child: ListTile(
          title: Text(text),
          trailing: Icon(Icons.arrow_forward),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskControllerPage()),
            );
          }
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0,color:Colors.grey)),
      ),
    );
  }

  //タスク一覧表示
  Widget _taskListViewTile(int index){
    return Container(
      //height: 5,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1,color: Colors.grey))
      ),
      child: ListTile(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskSettingPage(index,false)),
          );
        },
        title: Row(
          children: [
            //checkBox
            Checkbox(value: taskDataList[index].checkBox,
                onChanged: (e){
                  setState(() => taskDataList[index].checkBox = e!);
                }
            ),
            //タスク
            Text(taskDataList[index].task),
            //優先度
            Text(createRanking(taskDataList[index].taskRankingList)),
          ],
        ),
      ),
    );
  }

  //優先度表示用メソッド
  String createRanking(List<bool> list){
    String str = '';
      for(int i = 0;i < 3;i++){
        if(list[i] == true){
          int rank = i + 1;
          str = '優先度' + '$rank';
        }
      }
    return str;
  }

  //下記Prefs処理
  Future<void> saveStringPrefs(String setStr,String saveName,int buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(saveName + '$buildNum', setStr);
  }

  Future<String> loadStringPrefs(String def,String saveName,int buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(saveName + '$buildNum') ?? def;
  }

  Future<void> saveBoolPrefs(bool setBool,String saveName,int buildNum,[int? rankingNum]) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(rankingNum == null){
      await prefs.setBool(saveName + '$buildNum', setBool);
    }else{
      await prefs.setBool(saveName + '$buildNum' + '$rankingNum!', setBool);
    }
  }

  Future<bool> loadBoolPrefs(bool def, String saveName,int buildNum,[int? rankingNum]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool flag = false;
    if(rankingNum == null){
      flag =  prefs.getBool(saveName + '$buildNum') ?? def;
    }else{
      flag =  prefs.getBool(saveName + '$buildNum' + '$rankingNum!') ?? def;
    }
    return flag;
  }

  Future<void> saveIntPrefs(int setInt,String saveName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(saveName, setInt);
  }

  Future<int> loadIntPrefs(String saveName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(saveName) ?? 0;
  }

  Future<void> removePrefs(String saveStr,int index,[int? day]) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(day == null){
      await prefs.remove(saveStr + '$index');
    }else{
      await prefs.remove(saveStr + '$index' + '$day!');
    }
  }
}

class TaskDataList {
  String task;
  List<bool> taskRankingList;
  bool checkBox;

  TaskDataList(
    this.task,
    this.taskRankingList,
    this.checkBox
  );
}