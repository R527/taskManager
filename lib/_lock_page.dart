import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskpagetest/Comon/Enum/SaveGraph.dart';
import 'package:taskpagetest/Comon/Enum/SaveTask.dart';
import 'package:taskpagetest/Comon/Enum/SaveTime.dart';
import 'home.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

String loadString = '';

class LockPage extends StatefulWidget{
  @override
  _LockPage createState() => _LockPage();
}
//Task管理メインクラス
class _LockPage extends State<LockPage> with WidgetsBindingObserver{

  //バナー広告表示のため
  final BannerAd myBanner = BannerAd(
    adUnitId: Platform.isAndroid ? 'ca-app-pub-3940256099942544/6300978111' : '',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(onAdLoaded: (Ad ad) {
      print('$BannerAd loaded.');
    }),
  );

  String taskText = '';
  int achievementTask = 0;

  bool isLoading = true;
  //今日の日付取得
  String day = DateFormat('yyyy/MM/dd').format(DateTime.now());

  List<LockDataList> lockDataList = [];

  //初期化ロード処理
  void init() async{
    await myBanner.load();

    //タスク内容をロード
    taskText = await loadStringPrefs('',SaveTask.setTask.toString(),0);
    if(taskText == ''){
      taskText = 'タスク未入力です。';
    }

    //タスク達成数をロード
    var now = DateTime.now();
    String day = DateFormat('yyyy/MM/dd').format(now);
    achievementTask = await loadIntPrefs(SaveGraph.achievementTask.toString() + day);

    //ロック時間の取得
    int listLen = await loadIntPrefs(SaveTime.lockDataListlength.toString());
    if(listLen != 0){
      for(int i = 1;i < listLen + 1;i++){
        String startTime = '';
        String endTime = '';
        String usingPhoneTimeLimit = '';
        bool switchActive = false;
        List<bool> list = [];

        startTime = await loadStringPrefs('00:00',SaveTime.startTime.toString(),i);
        endTime = await loadStringPrefs('00:00',SaveTime.endTime.toString(),i);
        usingPhoneTimeLimit = await loadStringPrefs('15',SaveTime.UsingPhoneTimeLimit.toString(),i);
        switchActive = await loadBoolPrefs(false,SaveTime.switchActive.toString(),i);
        for(int x = 0;x < 7;x++){
          list.add(await loadBoolPrefs(false,SaveTime.dayOfWeek.toString(),i,x));
        }
        lockDataList.add(LockDataList(switchActive, false, startTime, endTime, usingPhoneTimeLimit, list));
      }
    }

    isLoading = false;
    setState(() {});
  }
  @override
  void initState() {
    setup();
    super.initState();
    init();
  }

  Future<void> setup() async {
    tz.initializeTimeZones();
    var tokyo = tz.getLocation('Asia/Tokyo');
    tz.setLocalLocation(tokyo);
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
              SizedBox(
                height: 64.0,
                width: double.infinity,
                child: AdWidget(ad: myBanner),
              ),
            ],
          ),
        )
      ),
    );
  }


  //タスク達成時用
  Widget _successButtonWidget(){
    return Container(
      margin: EdgeInsets.only(top: 20,bottom: 5),
      child:ElevatedButton(
          onPressed: () async{
            _scheduleLocalNotification();
            //スマホのホーム画面へ
            if(taskText != 'タスク未入力です。'){
              int num = achievementTask + 1;
              await saveIntPrefs(num,SaveGraph.achievementTask.toString() + day);
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage('達成')),
            );
          },
          child: Text('    達成！  ',style: TextStyle(fontSize: 20))),
    );
  }

  //タスク未達成時用
  Widget _failTaskButtonWidget(){
    return Container(
      margin: EdgeInsets.only(bottom: 40),
      child:ElevatedButton(
        onPressed: () async{
          _scheduleLocalNotification();
          //広告表示

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage('失敗')),
          );
        },
        child: Text('    失敗。  ',style: TextStyle(fontSize: 20))),
    );
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  //String型のデータをDateTimeに返還する
  DateTime getDateTime(String dateTimeStr){
    final _dateFormatter = DateFormat("y-M-d HH:mm");
    var now = DateTime.now().toString().substring(0,11);
    return _dateFormatter.parseStrict(now + dateTimeStr);
  }

  bool convertWeekDayNum(List<bool> list){
    var now = DateTime.now();
    bool flag = false;
    now.weekday == 7 ? flag = list[0] : flag =  list[now.weekday];
    return flag;
  }


  /// ローカル通知をスケジュールする
  void _scheduleLocalNotification() async {
    print('_scheduleLocalNotification');

    //ロック設定を取得して次に一番早いロック時間を計算する
    int timeLimit = 0;
    var now = DateTime.now();
    print(lockDataList.length);
    for(int i = 0;i < lockDataList.length; i++){
      //ロックがアクティブで時間曜日共にあっている場合
      if(lockDataList[i]._switchActive &&
          !getDateTime(lockDataList[i].startTime).isAfter(now) &&
          getDateTime(lockDataList[i].endTime).isAfter(now) &&
          convertWeekDayNum(lockDataList[i]._isDayOfWeekSelectedList)&&
          timeLimit > int.parse(lockDataList[i].setUsingPhoneTimeLimit)
      ){
        timeLimit = int.parse(lockDataList[i].setUsingPhoneTimeLimit) ;
        print('ロック該当している $timeLimit');
      }
    }

    //利用時間を制限してない場合はスケジュール設定をしない
    if(timeLimit == 0) return;

    // 初期化
    flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
          android: AndroidInitializationSettings('testimage'), // app_icon.pngを配置
          iOS: IOSInitializationSettings()),
    );
    // スケジュール設定する

    flutterLocalNotificationsPlugin.zonedSchedule(
        0, // id
        'Local Notification Title ', // title
        'Local Notification Body', // body
        tz.TZDateTime.now(tz.local).add(Duration(minutes: timeLimit)),
        NotificationDetails(
            android: AndroidNotificationDetails('my_channel_id', 'my_channel_name', //'my_channel_description',
                importance: Importance.max, priority: Priority.high),
            iOS: IOSNotificationDetails()),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true
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

  void saveBoolPrefs(bool setBool,String saveStr,int buildNum,[int? dayNum]) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(saveStr + buildNum.toString() + '$dayNum!', setBool);
  }

  Future<bool> loadBoolPrefs(bool def, String saveStr,int buildNum,[int? dayNum]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool flag = false;
    if(dayNum == null){
      flag = prefs.getBool(saveStr + buildNum.toString()) ?? def;
    }else{
      flag = prefs.getBool(saveStr + buildNum.toString() + '$dayNum!') ?? def;
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

class LockDataList {
  bool _switchActive;
  bool _checkBoxActive;

  String startTime;
  String endTime;
  String setUsingPhoneTimeLimit;
  List<bool> _isDayOfWeekSelectedList;

  LockDataList(
      this._switchActive,
      this._checkBoxActive,
      this.startTime,
      this.endTime,
      this.setUsingPhoneTimeLimit,
      this._isDayOfWeekSelectedList
      );
}