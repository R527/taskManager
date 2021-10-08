import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskpagetest/taskControllerPage.dart';
import 'package:intl/intl.dart';
import '_task_setting.dart';
import '_time_controller_page.dart';
import 'home.dart';


int taskNum = 0;//タスクの数を保存

void main() {
  runApp(MyApp());
  print('main');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

// class HomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<HomePage> {
//
//   final GlobalKey<ScaffoldState> _openDrawerKey = GlobalKey<ScaffoldState>();//Drawer用
//   String dropdownValue = '月間';//月間年間ごとのグラフを切り替え用フラグ
//   final timeControllerList = <GraphData>[];//グラフのデータ格納
//   bool checkBoxFlag = false;
//   bool isLoading = true;
//
//   //List
//   List<TaskDataList> taskDataList = [];
//   List<bool> checkBoxFlagList = [];
//   List<String> taskList = [];
//   List<List<bool>> taskRankingList = [];
//
//   Future<void> init() async{
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     preferences.clear();
//
//     taskNum = await loadIntPrefs('taskNum');
//
//     for(int i = 0;i < taskNum; i++){
//       String task = '';
//       List<bool> list = [];
//
//       task = await loadStringPrefs('','setTask',i);
//       for(int x = 0;x < 3; x++){
//         list.add(await loadBoolPrefs('setTaskRanking',i,x));
//       }
//       taskDataList.add(TaskDataList(task, list, false));
//     }
//
//     isLoading = false;
//     print(isLoading);
//   }
//   @override
//   void initState() {
//     super.initState();
//     init();
//
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _openDrawerKey,
//       appBar: AppBar(
//         title: Text('Home'),
//         elevation: 0,
//         leading: IconButton(
//           icon:Icon(Icons.menu),
//           onPressed: (){
//             _openDrawerKey.currentState!.openDrawer();
//             isLoading = false;
//             print(isLoading);
//           },
//         ),
//       ),
//
//       //Drawer
//       drawer: Drawer(
//         child: ListView(
//           children: <Widget>[
//             Container(
//               height: 60,
//               width: double.infinity,
//               child: DrawerHeader(
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                 ), child: null,
//               ),
//             ),
//             _homeControllerPage('ホーム'),
//             _timeControllerPage('ロック管理'),
//             _taskControllerPage('タスク管理'),
//           ],
//         ),
//       ),
// //isLoading ? CircularProgressIndicator() : //todo　ロードが終わらないエラー
//       body: Center(
//         child: Column(
//           children: [
//             //グラフ表示
//             _lockCountView(),
//             //タスク表示
//             _addTaskButton(),
//             _taskView(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   //Drawer　Homeページへ
//   Widget _homeControllerPage(String text){
//     return Container(
//       child: ListTile(
//           title: Text(text),
//           trailing: Icon(Icons.arrow_forward),
//           onTap: (){
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => HomePage()),
//             );
//           }
//       ),
//       decoration: BoxDecoration(
//         border: Border(bottom: BorderSide(width: 1.0,color:Colors.grey)),
//       ),
//     );
//   }
//
//   //Drawer　Lock管理ページへ
//   Widget _timeControllerPage(String text){
//     return Container(
//       child: ListTile(
//           title: Text(text),
//           trailing: Icon(Icons.arrow_forward),
//           onTap: (){
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => TimeControllerPage()),
//             );
//           }
//       ),
//       decoration: BoxDecoration(
//         border: Border(bottom: BorderSide(width: 1.0,color:Colors.grey)),
//       ),
//     );
//   }
//
//   //Drawer　タスク管理ページへ
//   Widget _taskControllerPage(String text){
//     return Container(
//       child: ListTile(
//           title: Text(text),
//           trailing: Icon(Icons.arrow_forward),
//           onTap: (){
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => TaskControllerPage()),
//             );
//           }
//       ),
//       decoration: BoxDecoration(
//         border: Border(bottom: BorderSide(width: 1.0,color:Colors.grey)),
//       ),
//     );
//   }
//
//   //タスク達成数とスマホ使用時間のグラフ表示
//   Widget _lockCountView(){
//     return Container(
//       height: 260,
//       width: double.infinity,
//       color: Colors.white,
//       child: Column(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               Container(
//                 margin: EdgeInsets.only(top: 17),
//
//                 child:Text(_getDay()),//グラフの表示日時の範囲決定
//               ),
//
//               _dayChangedDropDownButton(),//表示日時の範囲切り替え
//             ],
//           ),
//           //_timeSeriesChart(),
//         ],
//       ),
//     );
//   }
//
//   //データ取得日時範囲変更
//   Widget _dayChangedDropDownButton() {
//     return DropdownButton<String>(
//       value: dropdownValue,
//       style: const TextStyle(
//         color: Colors.black,
//       ),
//       underline: Container(
//         height: 1,
//         color: Colors.black,
//       ),
//       onChanged: (String? newValue) {
//         setState(() {
//           dropdownValue = newValue!;
//         });
//       },
//       items: <String>['月間', '年間']
//           .map<DropdownMenuItem<String>>((String value) {
//         return DropdownMenuItem<String>(
//           value: value,
//           child: Text(value),
//         );
//       }).toList(),
//     );
//   }
//
//   //日付取得
//   String _getDay() {
//     var prevday;
//     var today;
//     setState(() {
//       today = DateFormat('yyyy:MM:dd').format(DateTime.now());
//       var now = DateTime.now();
//       switch (dropdownValue) {
//         case '月間':
//           prevday = DateFormat('yyyy:MM:dd').format(
//               new DateTime(now.year, now.month - 1, now.day));
//           break;
//         case '年間':
//           prevday = DateFormat('yyyy:MM:dd').format(
//               new DateTime(now.year - 1, now.month, now.day));
//           break;
//       }
//     });
//     return '$prevday  ~  $today';
//   }
//
//   //グラフの表示
//   // Widget _timeSeriesChart() {
//   //   return Container(
//   //     height: 200,
//   //     width: double.infinity,
//   //     child: charts.TimeSeriesChart(
//   //       _createTimeData(timeControllerList),
//   //     ),
//   //   );
//   // }
//
//   // List<charts.Series<GraphData, DateTime>> _createTimeData(
//   //     List<GraphData> timeControllerList) {
//   //   return [
//   //     charts.Series<GraphData, DateTime>(
//   //       id: 'TimeController',
//   //       data: timeControllerList,
//   //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//   //       domainFn: (timeData,_) => timeData.day,
//   //       measureFn: (timeData, _) => timeData.usePhone,
//   //     )
//   //   ];
//   // }
//
//   // Future<void> _createTimeDataList() async{
//   //   final SharedPreferences prefs =  await SharedPreferences.getInstance();
//   //   String today = DateFormat('yyyy:MM:dd').format(DateTime.now()).toString();
//   //   var now = DateTime.now();
//   //   timeControllerList.add(GraphData(now,10));
//   //   setState(() {
//   //
//   //   });
//
//     // switch (dropdownValue) {
//     //   case '月間':
//     //     break;
//     //   case '年間':
//     //     break;
//     // }
//
//     //return Future<List<GraphData>>.value(timeControllerList);
//
//   //タスクを追加するためのボタン
//   Widget _addTaskButton(){
//     return Container(
//       padding: EdgeInsets.only(left: 20,right: 10),
//       height: 40,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Container(
//             margin: EdgeInsets.only(right: 160),
//             child:Text('タスク一覧',style: TextStyle(fontSize: 16)),
//           ),
//           Container(
//             margin: EdgeInsets.only(right: 10),
//             child:ElevatedButton(
//               child: Text('削除',style: TextStyle(fontSize: 16)),
//               onPressed: (){
//                 // for(int i = 0;i < taskNum; i++){
//                 //   if(checkBoxFlagList[i]) {
//                 //     taskList.remove(i);
//                 //     taskRankingList.remove(i);
//                 //   }
//                 // }
//               },
//             ),
//           ),
//           ElevatedButton(
//             child: Text('追加',style: TextStyle(fontSize: 16)),
//             onPressed: (){
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => TaskSettingPage(taskNum + 1,'new')),//todo List.Length　+　１の処理を追加する
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _taskView(){
//     return Expanded(
//       child: Container(
//         child: ListView.builder(
//           shrinkWrap: true,
//           itemCount: taskNum,
//           itemBuilder: (context, index) {
//             return _taskItem(index);
//           },
//         )
//       )
//     );
//   }
//
//   Widget _taskItem(int index){
//     return Container(
//       margin: EdgeInsets.all(1),
//       decoration: BoxDecoration(
//           border: Border(bottom: BorderSide(width: 1,color:Colors.black))
//       ),
//       child: ListTile(
//         onTap: (){
//           //todo 削除機能などを取り付ける
//         },
//         title: Row( //todo エラーでてる
//           children: [
//             Checkbox(
//               value: taskDataList[index].checkBox,
//               onChanged: (e){
//                 setState(() {
//                   taskDataList[index].checkBox = e!;
//                 });
//               },
//             ),
//             //Text(),
//             Text(taskDataList[index].task),//todo Listからタスク内容を取得する
//           ],
//         )
//       )
//     );
//   }
//
//   void saveStringPrefs(String setStr,String saveName,int buildNum) async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString(saveName + '$buildNum', setStr);
//   }
//
//   Future<String> loadStringPrefs(String def,String saveName,int buildNum) async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(saveName + '$buildNum') ?? def;
//   }
//
//   void saveIntPrefs(int setInt,String saveName) async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(saveName, setInt);
//   }
//
//   Future<int> loadIntPrefs(String saveName) async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getInt(saveName) ?? 0;
//   }
//
//   void saveBoolPrefs(bool setBool,String saveName) async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(saveName, setBool);
//   }
//
//   Future<bool> loadBoolPrefs(String saveName, int buildNum,[int? rankingNum]) async{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(saveName + '$buildNum' + '$rankingNum!') ?? false;
//   }
// }
//
//
// class GraphData{
//   final DateTime day;
//   final int usePhone;
//
//   GraphData(this.day,this.usePhone);
// }
//
// class TaskDataList{
//   final String task;
//   final List<bool> rank;
//   bool checkBox;
//
//   TaskDataList(this.task,this.rank,this.checkBox);
// }