import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskpagetest/taskControllerPage.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
import '_task_setting.dart';
import '_time_controller_page.dart';




class HomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {

  bool isPrefsClear = false;

  int taskNum = 0;//タスクの数を保存
  final GlobalKey<ScaffoldState> _openDrawerKey = GlobalKey<ScaffoldState>();//Drawer用
  String dropdownValue = '月間';//月間年間ごとのグラフを切り替え用フラグ
  final timeControllerList = <GraphData>[];//グラフのデータ格納
  bool checkBoxFlag = false;
  bool isLoading = true;

  //List
  List<TaskDataList> taskDataList = [];
  List<bool> checkBoxFlagList = [];
  List<String> taskList = [];
  List<List<bool>> taskRankingList = [];

  Future<void> init() async{
    if(isPrefsClear){
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.clear();
    }


    taskNum = await loadIntPrefs('taskDataListLength');
    if(taskNum != 0){
      for(int i = 0;i < taskNum; i++){
        String task = '';
        List<bool> list = [];

        task = await loadStringPrefs('','setTask',i);
        for(int x = 0;x < 3; x++) list.add(await loadBoolPrefs('setTaskRanking',i,x));
        taskDataList.add(TaskDataList(task, list, false));
      }
    }
    isLoading = false;
    setState(() {});//画面を再描画するときに必要
  }
  @override
  void initState() {
    super.initState();
    init();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _openDrawerKey,
      appBar: AppBar(
        title: Text('Home'),
        elevation: 0,
        leading: IconButton(
          icon:Icon(Icons.menu),
          onPressed: (){
            _openDrawerKey.currentState!.openDrawer();
          },
        ),
      ),

      body:  Center(
        child: isLoading ? CircularProgressIndicator() :Column( //todo　ロードが終わらないエラー
          children: [
            //グラフ表示
            _lockCountView(),
            //タスク表示
            _addTaskButton(),
            _taskView(),
          ],
        ),
      ),
      //Drawer
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
//

    );
  }

  //Drawer　Homeページへ
  Widget _homeControllerPage(String text){
    return Container(
      child: ListTile(
        title: Text(text),
        trailing: Icon(Icons.arrow_forward),
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0,color:Colors.grey)),
      ),
    );
  }

  //Drawer　Lock管理ページへ
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

  //Drawer　タスク管理ページへ
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

  //タスク達成数とスマホ使用時間のグラフ表示
  Widget _lockCountView(){
    return Container(
      height: 260,
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 17),

                child:Text(_getDay()),//グラフの表示日時の範囲決定
              ),

              _dayChangedDropDownButton(),//表示日時の範囲切り替え
            ],
          ),
          //_timeSeriesChart(),
        ],
      ),
    );
  }

  //データ取得日時範囲変更
  Widget _dayChangedDropDownButton() {
    return DropdownButton<String>(
      value: dropdownValue,
      style: const TextStyle(
        color: Colors.black,
      ),
      underline: Container(
        height: 1,
        color: Colors.black,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: <String>['月間', '年間']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  //日付取得
  String _getDay() {
    var prevday;
    var today;
    setState(() {
      today = DateFormat('yyyy:MM:dd').format(DateTime.now());
      var now = DateTime.now();
      switch (dropdownValue) {
        case '月間':
          prevday = DateFormat('yyyy:MM:dd').format(
              new DateTime(now.year, now.month - 1, now.day));
          break;
        case '年間':
          prevday = DateFormat('yyyy:MM:dd').format(
              new DateTime(now.year - 1, now.month, now.day));
          break;
      }
    });
    return '$prevday  ~  $today';
  }

  // //グラフの表示
  // Widget _timeSeriesChart() {
  //   return Container(
  //     height: 200,
  //     width: double.infinity,
  //     child: charts.TimeSeriesChart(
  //       _createTimeData(timeControllerList),
  //     ),
  //   );
  // }
  //
  // List<charts.Series<GraphData, DateTime>> _createTimeData(
  //     List<GraphData> timeControllerList) {
  //   return [
  //     charts.Series<GraphData, DateTime>(
  //       id: 'TimeController',
  //       data: timeControllerList,
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (timeData,_) => timeData.day,
  //       measureFn: (timeData, _) => timeData.usePhone,
  //     )
  //   ];
  // }
  //
  // Future<void> _createTimeDataList() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String today = DateFormat('yyyy:MM:dd').format(DateTime.now()).toString();
  //   var now = DateTime.now();
  //   timeControllerList.add(GraphData(now, 10));
  //   setState(() {});
  //
  //   switch (dropdownValue) {
  //     case '月間':
  //       break;
  //     case '年間':
  //       break;
  //   }
  // }

  //タスクを追加するためのボタン
  Widget _addTaskButton(){
    return Container(
      padding: EdgeInsets.only(left: 30),
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(right: 170),
            child:Text('タスク一覧',style: TextStyle(fontSize: 16)),
          ),
          Container(
            margin: EdgeInsets.only(right: 10),
            child:IconButton(
              icon: Icon(Icons.delete),

              onPressed: () async{
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
                taskNum = await loadIntPrefs('taskDataListLength');
                setState(() {});
              },
            ),
          ),
          IconButton(
            icon:Icon(Icons.add),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskSettingPage(taskDataList.length,true)),//todo List.Length　+　１の処理を追加する
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _taskView(){
    return Expanded(
        child: Container(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: taskNum,
              itemBuilder: (context, index) {
                return Container(
                    margin: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(width: 1,color:Colors.black))
                    ),
                    child: ListTile(
                        onTap: (){
                          //タスク設定見直し
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TaskSettingPage(index,true)),
                          );
                        },
                        title: Row(
                          children: [
                            Checkbox(
                              value: taskDataList[index].checkBox,
                              onChanged: (e){
                                setState(() {
                                  taskDataList[index].checkBox = e!;
                                });
                              },
                            ),
                            Text(taskDataList[index].task),
                          ],
                        )
                    )
                );
              },
            )
        )
    );
  }


  Future<void> saveStringPrefs(String setStr,String saveName,int buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(saveName + '$buildNum', setStr);
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

  Future<void> saveBoolPrefs(bool setBool,String saveName,int buildNum, [int? rankingNum]) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(rankingNum == null){
      await prefs.setBool(saveName + buildNum.toString(), setBool);
    }else{
      await prefs.setBool(saveName + buildNum.toString() + rankingNum.toString(), setBool);
    }
  }

  Future<bool> loadBoolPrefs(String saveName, int buildNum,[int? rankingNum]) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool flag = false;
    if(rankingNum == null){
      flag = prefs.getBool(saveName + '$buildNum') ?? false;
    }else{
      flag = prefs.getBool(saveName + '$buildNum' + '$rankingNum!') ?? false;
    }
    return flag;
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

class GraphData{
  final DateTime day;
  final int usePhone;

  GraphData(this.day,this.usePhone);
}

class TaskDataList{
  final String task;
  final List<bool> taskRankingList;
  bool checkBox;

  TaskDataList(this.task,this.taskRankingList,this.checkBox);
}