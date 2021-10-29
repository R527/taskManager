import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskpagetest/_time_setting_page.dart';
import 'package:taskpagetest/taskControllerPage.dart';

import 'Comon/CustomDrawer.dart';
import 'home.dart';

class TimeControllerPage extends StatefulWidget{
  @override
  _TimeControllerPage createState() => _TimeControllerPage();
}

class _TimeControllerPage extends State<TimeControllerPage>{

  final GlobalKey<ScaffoldState> _openDrawerkey = GlobalKey<ScaffoldState>();

  bool isLoading = true;

  //List
  List<LockDataList> lockDataList = [];
  List<String> defDayOfWeekList = ['日','月','火','水','木','金','土'];

  Future<void> init()async{

    int listLen = await loadIntPrefs(0,'lockDataList.length');
    if(listLen != 0){
      for(int i = 1;i < listLen + 1;i++){

        String startTime = '';
        String endTime = '';
        String usingPhoneTimeLimit = '';
        bool switchActive = false;
        List<bool> list = [];

        startTime = await loadStringPrefs('00:00','startTime','$i');
        endTime = await loadStringPrefs('00:00','endTime','$i');
        usingPhoneTimeLimit = await loadStringPrefs('15','UsingPhoneTimeLimit','$i');
        switchActive = await loadBoolPrefs(false,'switchActive','$i');
        for(int x = 0;x < 7;x++){
          list.add(await loadBoolPrefs(false,'dayOfWeek','$i',x));
        }

        lockDataList.add(LockDataList(switchActive, false, startTime, endTime, usingPhoneTimeLimit, list));
      }
    }
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  String createDayOfWeek(List<bool> list){
    String str = '';
    bool value = list.every((element) => element == true);
      if(value == true) {
        str = '毎日';
      }else{
        for(int i = 0;i < 7;i++){
          if(list[i] == true){
            str += defDayOfWeekList[i];
          }
        }
      }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _openDrawerkey,
      appBar: AppBar(
        title: Text('ロック管理'),
        leading: IconButton(
          icon:Icon(Icons.menu),
          onPressed: (){
            _openDrawerkey.currentState!.openDrawer();
          },
        ),
        actions: [
          IconButton(
            onPressed: (){
              //既に設定されているロック設定を削除する
              int len = lockDataList.length;
              if(len == 0) return;
              for(int i = 0;i < lockDataList.length; i++){
                if(lockDataList[i]._checkBoxActive) {
                  lockDataList.removeAt(i);
                  i--;
                }
              }
              //一旦Prefs全削除
              for(int i = 0;i < len; i++){
                removePrefs('startTime',i);
                removePrefs('endTime',i);
                removePrefs('UsingPhoneTimeLimit',i);
                removePrefs('switchActive',i);
                for(int x = 0;x < 7; x++){
                  removePrefs('dayOfWeek',i,x);
                }
              }
              //セーブしなおし
              for(int i = 0;i < lockDataList.length; i++){
                saveStringPrefs(lockDataList[i].startTime,'startTime','$i');
                saveStringPrefs(lockDataList[i].endTime,'endTime','$i');
                saveStringPrefs(lockDataList[i].setUsingPhoneTimeLimit,'UsingPhoneTimeLimit','$i');
                saveBoolPrefs(lockDataList[i]._switchActive,'switchActive','$i');
                for(int x = 0;x < 7; x++){
                  saveBoolPrefs(lockDataList[i]._isDayOfWeekSelectedList[x],'dayOfWeek','$i',x);
                }
              }
              //List数セーブ
              saveIntPrefs(lockDataList.length,'lockDataList.length');
              setState(() {});
            },
            icon: Icon(Icons.delete),
          ),
          IconButton(
            onPressed: (){
              //todo 新しいロック設定を追加する
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TimeSettingPage(lockDataList.length + 1,true)),
              );
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      drawer: CustomDrawer(),
      body:Center(
        child: isLoading ? CircularProgressIndicator() :Column(
          children: <Widget>[
            Flexible(
                child: ListView.builder(
                  itemBuilder: (context,index){
                    return _ListViewController(index);
                  },
                  itemCount: lockDataList.length,
                )
            ),
          ],
        ),
      ),
    );
  }

  //Listを作るところ
  Widget _ListViewController(int index){
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1,color:Colors.grey))
      ),
      child: ListTile(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TimeSettingPage(index + 1,false)),
            );
          },
          title:Row(
            children: [
              Checkbox(
                  value: lockDataList[index]._checkBoxActive,
                  onChanged: (e){
                    setState(() => lockDataList[index]._checkBoxActive = e!);

                  }),
              Expanded(
                child: Column(
                  children: [
                    _lockSettingTextStyle(lockDataList[index].startTime + ' ~ ' + lockDataList[index].endTime,20,index),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _lockSettingTextStyle(createDayOfWeek(lockDataList[index]._isDayOfWeekSelectedList) + '  ',14,index),
                        _lockSettingTextStyle(lockDataList[index].setUsingPhoneTimeLimit + '分間',14,index),
                      ],
                    )
                  ],
                ),
              ),
              Switch(
                  value: lockDataList[index]._switchActive,
                  onChanged: (bool e){
                    setState(() => lockDataList[index]._switchActive = e);
                    saveBoolPrefs(lockDataList[index]._switchActive,'switchActive','$index');
                  }
              ),
            ],
          )
      )
    );
  }

  Widget _lockSettingTextStyle(String text,double size,int index){
    return Text(
      text,
      style: TextStyle(
        color: lockDataList[index]._switchActive ? Colors.black : Colors.grey,
        fontSize: size
      ),
    );
  }

  void saveStringPrefs(String setStr,String saveStr,String buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(saveStr + buildNum, setStr);
  }

  Future<String> loadStringPrefs(String def,String saveStr,String buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(saveStr + buildNum) ?? def;
  }

  void saveBoolPrefs(bool setBool,String saveStr,String buildNum,[int? dayNum]) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(saveStr + buildNum + '$dayNum!', setBool);
  }

  Future<bool> loadBoolPrefs(bool def, String saveStr,String buildNum,[int? dayNum]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool flag = false;
    if(dayNum == null){
      flag = prefs.getBool(saveStr + buildNum) ?? def;
    }else{
      flag = prefs.getBool(saveStr + buildNum + '$dayNum!') ?? def;
    }
    return flag;
  }

  void saveIntPrefs(int setInt,String saveStr) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(saveStr, setInt);
  }

  Future<int> loadIntPrefs(int def, String saveStr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(saveStr) ?? def;
  }

  void removePrefs(String saveStr,int index,[int? day]) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(day == null){
      prefs.remove(saveStr + '$index');
    }else{
      prefs.remove(saveStr + '$index' + '$day!');
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



