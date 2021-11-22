import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:taskpagetest/Comon/CustomDrawer.dart';
import 'package:taskpagetest/Comon/Enum/SaveGraph.dart';
import 'Comon/Enum/SaveTask.dart';
import '_task_setting.dart';

class HomePage extends StatefulWidget {
  HomePage(this.achievementTaskFlag);
  String achievementTaskFlag;//タスクが達成したらtrue
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {

  //Prefs全消去
  bool isPrefsClear = false;
  //テスト用
  int apllicationLength = 0;
  int usingHouer = 0;

  //バナー広告表示のため
  final BannerAd myBanner = BannerAd(
    adUnitId: Platform.isAndroid ? 'ca-app-pub-3940256099942544/6300978111' : '',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(onAdLoaded: (Ad ad) {
      print('$BannerAd loaded.');
    }),
  );

  //グラフ関連
  int taskNum = 0;//タスクの数を保存
  List<TaskDataList> taskDataList = [];
  final GlobalKey<ScaffoldState> _openDrawerKey = GlobalKey<ScaffoldState>();//Drawer用
  String dropdownValue = '月間';//月間年間ごとのグラフを切り替え用フラグ
  final usePhoneList = <UsePhoneData>[];//グラフのデータ格納

  //利用時間取得
  // List<AppUsageInfo> _infos = [];
  int seconds = 0;

  bool isLoading = true;

  Future<void> init() async{
    await myBanner.load();
    //Prefs 全削除
    if(isPrefsClear){
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.clear();
    }

    //タスク内容をロードする
    taskNum = await loadIntPrefs(SaveTask.taskDataListLength.toString());
    if(taskNum != 0){
      List<TaskDataList> taskList = [];
      for(int i = 0;i < taskNum; i++){
        String task = '';
        List<bool> list = [];
        task = await loadStringPrefs('',SaveTask.setTask.toString(),i);
        for(int x = 0;x < 3; x++) list.add(await loadBoolPrefs(SaveTask.setTaskRanking.toString(),i,x));
        taskList.add(TaskDataList(task, list, false));
      }

      for(int x = 0;x < 3; x++){
        for(int i = 0;i < taskNum; i++){
          if(taskList[i].taskRankingList[x]){
            taskDataList.add(taskList[i]);
          }
        }
      }
    }

    print('削除処理');
    //ロック画面からタスク達成した場合一つ削除する
    if(widget.achievementTaskFlag == '達成' && taskDataList.length > 0){
      print('removeTask');
      taskDataList.removeAt(0);
      //一旦Prefs全削除
      for(int i = 0;i < taskNum + 3; i++){
        await removePrefs(SaveTask.setTask.toString(),i);
        for(int x = 0;x < 3; x++){
          await removePrefs(SaveTask.setTaskRanking.toString(),i,x);
        }

      }

      //セーブしなおし
      if(taskNum > 1){
        print(taskDataList[0].task);
        for(int i = 0;i < taskNum - 1; i++){
          await saveStringPrefs(taskDataList[i].task,SaveTask.setTask.toString(),i);
          for(int x = 0;x < 3; x++){
            await saveBoolPrefs(taskDataList[i].taskRankingList[x],SaveTask.setTaskRanking.toString(),i,x);
          }
        }
      }
      //List数セーブ
      await saveIntPrefs(taskDataList.length,SaveTask.taskDataListLength.toString());
    }



    //グラフデータ関連
    var now = DateTime.now();
    final _dateFormatter = DateFormat("yyyy/MM/dd'");

    //昨日までのグラフデータをロードする
    for(int i = 0;i < 365;i++){
      String day = DateFormat('yyyy/MM/dd').format(now.add(Duration(days:i) * -1));
      int usePhone = await loadIntPrefs(SaveGraph.usePhone.toString() + day);
      int achievementTask = await loadIntPrefs(SaveGraph.achievementTask.toString() + day);
      DateTime dateTime = _dateFormatter.parseStrict(day);
      usePhoneList.add(UsePhoneData(dateTime,usePhone,achievementTask));
    }

    isLoading = false;
    print(isLoading);
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
        child: isLoading ? CircularProgressIndicator() :Column(
          children: [
            //グラフ表示
            _lockCountView(),
            //タスク表示
            _addTaskButton(),
            _taskView(),
            SizedBox(
              height: 64.0,
              width: double.infinity,
              child: AdWidget(ad: myBanner),
            ),
            // Text('アプリ数:$apllicationLength'+'利用時間:$usingHouer')
          ],
        ),
      ),
     //  floatingActionButton: FloatingActionButton(
     //    onPressed: initUsage
     // ),
      //Drawer
      drawer: CustomDrawer(),
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
          _timeSeriesChart(),
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

  //グラフの表示
  Widget _timeSeriesChart() {
    return Container(
      height: 200,
      width: double.infinity,
      child: charts.TimeSeriesChart(
        _createTimeData(usePhoneList.sublist(0,_getEndMonthOfDay())),
      ),
    );
  }

  List<charts.Series<UsePhoneData, DateTime>> _createTimeData(
      List<UsePhoneData> usePhoneList) {
    return [
      charts.Series<UsePhoneData, DateTime>(
        id: 'usePhoneController',
        data: usePhoneList,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (timeData,_) => timeData.day,
        measureFn: (timeData, _) => timeData.usePhone,
      ),
      charts.Series<UsePhoneData, DateTime>(
        id: 'achievementTaskController',
        data: usePhoneList,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (timeData,_) => timeData.day,
        measureFn: (timeData, _) => timeData.achievementTask,
      )
    ];
  }

  int _getEndMonthOfDay(){
    int day = 0;
    dropdownValue == '月間' ? day = 30:day = 365;
    return day;
  }

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
                await saveIntPrefs(taskDataList.length,SaveTask.taskDataListLength.toString());
                taskNum = await loadIntPrefs(SaveTask.taskDataListLength.toString());
                setState(() {});
              },
            ),
          ),
          IconButton(
            icon:Icon(Icons.add),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskSettingPage(taskDataList.length,true)),
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
              itemCount: taskDataList.length,
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

  //スマホ利用時間取得
  // void getUsageStats() async {
  //   seconds = 0;
  //   try {
  //     final now= DateTime.now();
  //     DateTime startDate = DateTime(now.year, now.month, now.day, now.hour -1);
  //     DateTime endDate = DateTime(now.year, now.month, now.day,now.hour);
  //     List<EventUsageInfo> infos = await AppUsage.getAppUsage(startDate, endDate);
  //     setState(() {
  //       _infos = infos;
  //     });
  //
  //     for(final info in infos){
  //       seconds += info.usage.inSeconds;
  //     }
  //     print(seconds ~/ 3600);
  //     usingHouer = seconds ~/ 3600;
  //     apllicationLength = _infos.length;
  //     print(_infos.length);
  //   } on AppUsageException catch (exception) {
  //     print(exception);
  //   }
  // }

  // Future<void> initUsage() async {
  //   UsageStats.grantUsagePermission();
  //   DateTime now = new DateTime.now();
  //   DateTime endDate = now;
  //   DateTime startDate = endDate.subtract(Duration(days: 1));
  //
  //   List<EventUsageInfo> queryEvents =
  //   await UsageStats.queryEvents(startDate, endDate);
  //   // List<NetworkInfo> networkInfos =
  //   // await UsageStats.queryNetworkUsageStats(startDate, endDate);
  //   // Map<String?, NetworkInfo?> netInfoMap = Map.fromIterable(networkInfos,
  //   //     key: (v) => v.packageName, value: (v) => v);
  //
  //   this.setState(() {
  //     events = queryEvents.reversed.toList();
  //     //_netInfoMap = netInfoMap;
  //   });
  //   print(events.length);
  // }



  Future<void> saveStringPrefs(String setStr,String saveName,int buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(buildNum == null){
      await prefs.setString(saveName, setStr);
    }else{
      await prefs.setString(saveName + '$buildNum', setStr);
    }
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


class UsePhoneData{
  final DateTime day;
  final int usePhone;
  final int achievementTask;
  UsePhoneData(this.day,this.usePhone,this.achievementTask);
}

class TaskDataList{
  final String task;
  final List<bool> taskRankingList;
  bool checkBox;

  TaskDataList(this.task,this.taskRankingList,this.checkBox);
}