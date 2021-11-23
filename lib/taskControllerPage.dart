import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskpagetest/Comon/CustomDrawer.dart';
import 'package:taskpagetest/Comon/Enum/SaveTask.dart';
import 'Comon/CustomPrefs.dart';
import 'task_setting.dart';

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
    taskLen = await loadIntPrefs(SaveTask.taskDataListLength.toString());
    //Listの数が１以上ならロードする
    if(taskLen != 0){
      for(int i = 0;i < taskLen; i++){
        List<bool> list = [];
        String task = '';

        task = await loadStringPrefs('',SaveTask.setTask.toString(),i);
        for(int x = 0;x < 3; x++) list.add(await loadBoolPrefs(false,SaveTask.setTaskRanking.toString(),i,x));
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
                //いらないタスク捨てる
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
                  await removePrefs(SaveTask.setTask.toString(),i);
                  for(int x = 0;x < 3; x++){
                    await removePrefs(SaveTask.setTaskRanking.toString(),i,x);
                  }
                }

                //セーブしなおし
                for(int i = 0;i < taskDataList.length; i++){

                  await saveStringPrefs(taskDataList[i].task,SaveTask.setTask.toString(),i);

                  for(int x = 0;x < 3; x++){
                    await saveBoolPrefs(taskDataList[i].taskRankingList[x],SaveTask.setTaskRanking.toString(),i,x);
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
      drawer: CustomDrawer(),
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