import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskpagetest/_time_controller_page.dart';

//タスク管理用のPage
class TimeSettingPage extends StatefulWidget{
  TimeSettingPage(this.buildNum,this.newBuild);
  final int buildNum;
  final bool newBuild;
  @override
  _TimeSettingPage createState() => _TimeSettingPage();
}

class _TimeSettingPage extends State<TimeSettingPage> {

  //設定した時間を保存
  String setFirstTime = '00:00';
  String setEndTime = '00:00';
  String setUsingPhoneTimeLimit = '15';

  //時間設定
  var initialTime;
  late TimeOfDay _timeOfDay = TimeOfDay(hour: 0, minute: 0);
  late DateTime _datetime = DateTime(0);
  //曜日関連
  bool _weeklyFlag = false;
  List<bool> _isDayOfWeekSelected = [false, false, false, false, false, false, false];

  //時間関連
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async{
    if(!widget.newBuild){
      setFirstTime = await loadStringPrefs('00:00','startTime',widget.buildNum);
      setEndTime = await loadStringPrefs('00:00', 'endTime',widget.buildNum);
      setUsingPhoneTimeLimit = await loadStringPrefs('15', 'UsingPhoneTimeLimit',widget.buildNum);
      for(int i = 0;i < 7;i++){
        _isDayOfWeekSelected[i] = await loadBoolPrefs(false, 'dayOfWeek',widget.buildNum,i);
      }
      setState(() {});
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ロック設定'),
        actions: [
          ElevatedButton(
            onPressed: (){
              //ダイアログ表示

              if(!_isDayOfWeekSelected.every((element) => element == false)){

                //設定内容を保存
                for(int i = 0;i < 7; i++){
                  saveBoolPrefs(_isDayOfWeekSelected[i],'dayOfWeek',widget.buildNum,i);
                }
                saveStringPrefs(setFirstTime,'startTime',widget.buildNum);
                saveStringPrefs(setEndTime,'endTime',widget.buildNum);
                saveStringPrefs(setUsingPhoneTimeLimit,'UsingPhoneTimeLimit',widget.buildNum);

                //新規作成の場合　Listの数を更新
                if(widget.newBuild)saveIntPrefs(widget.buildNum,'lockDataList.length');
                setState(() {});
              //ロック管理画面に戻る
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimeControllerPage()),
                );
              }else{
                _showDialog();
              }
            },
            child: Text('適応',style: TextStyle(fontSize: 20))
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            _timeSettingText(setFirstTime,'開始時間'),
            _timeSettingText(setEndTime,'終了時間'),
            _timeSettingText(setUsingPhoneTimeLimit + '分間','利用時間'),
            _dayOfWeekSettingToggleButton(),
          ],
        ),
      )
    );
  }

  Future _showDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            //title: Text('Dialog'),
            content: Text('曜日を選択してください。'),
          ),
    );
  }


  Widget _timeSettingText(String setTime,String setStr){
    return Container(
      margin: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(setStr,style: TextStyle(fontSize: 20))),
          TextButton(

            child: Text(setTime,style: TextStyle(fontSize: 22)),
            onPressed: () async {
              if (setStr == '開始時間' || setStr == '終了時間') {
                final TimeOfDay? timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: _timeOfDay
                );
                if (timeOfDay != null) setState(() => {_timeOfDay = timeOfDay});
                //データ保存と表示
                String str = timeOfDay.toString().substring(10, 15);
                setStr == '開始時間' ? setFirstTime = str : setEndTime = str;
              } else {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(

                        height: MediaQuery.of(context).size.height / 3,
                        child: CupertinoPicker(

                          itemExtent: 30,

                          onSelectedItemChanged: (int value) {
                            setUsingPhoneTimeLimit = ((value * 5) + 15).toString();
                            setState(() {});
                          },
                          children: [
                            Text('15'),
                            Text('20'),
                            Text('25'),
                            Text('30'),
                            Text('35'),
                            Text('40'),
                            Text('45'),
                            Text('50'),
                            Text('55'),
                            Text('60'),
                          ],
                        ),
                      );

                    });
              }
            }
          )

        ],
      ),
    );
  }


  //新規作成時表示バグがあるので修正
  String _getTimeSettingText(String setStr,String setTime){
    String str = '';
    if(widget.newBuild && (setStr == '開始時間' || setStr == '終了時間')){
      str = '00:00';
    }else if(widget.newBuild & (setStr == '利用時間')){
      str = '15分間';
    }else{
      str = setTime;
    }
    setState(() {});
    return str;
  }

  //曜日設定のトグルボタン
  Widget _dayOfWeekSettingToggleButton(){
    return Container(
      margin: EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 10),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Text('曜日設定',style: TextStyle(fontSize: 20)),
            margin: EdgeInsets.only(bottom: 15),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ToggleButtons(
                        children: [
                          _dayOfWeekSettingButton('日'),
                          _dayOfWeekSettingButton('月'),
                          _dayOfWeekSettingButton('火'),
                          _dayOfWeekSettingButton('水'),
                          _dayOfWeekSettingButton('木'),
                          _dayOfWeekSettingButton('金'),
                          _dayOfWeekSettingButton('土'),

                        ],
                        //direction:SizedBox.fromSize(child: ),
                        onPressed: (int index) {
                          setState(() {
                            _isDayOfWeekSelected[index] = !_isDayOfWeekSelected[index];
                          });
                        },
                        isSelected: _isDayOfWeekSelected
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _weeklyFlag,
                        onChanged: _handleCheckbox,
                      ),
                      Text('全ての曜日にチェックを入れる'),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  //曜日設定トグルボタンをリセットする
  void _handleCheckbox(bool? e){
    if(e != null){
      setState(() {
        _weeklyFlag = e;
        for(int i = 0;i < 7; i++){
          _isDayOfWeekSelected[i] = _weeklyFlag;
        }
      });
    }
  }

  //曜日設定用のボタン
  Widget _dayOfWeekSettingButton(String buttonStr){
    return Container(
      child:Text(buttonStr),
    );
  }

  void saveStringPrefs(String setStr,String saveStr,int buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(saveStr + '$buildNum', setStr);
  }

  Future<String> loadStringPrefs(String def,String saveStr,int buildNum) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(saveStr + '$buildNum') ?? def;
  }

  void saveBoolPrefs(bool setBool,String saveStr,int buildNum,[int? dayNum]) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(saveStr + '$buildNum' + '$dayNum!', setBool);
  }

  Future<bool> loadBoolPrefs(bool def, String saveStr,int buildNum,[int? dayNum]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(saveStr + '$buildNum' + '$dayNum!') ?? def;
  }

  void saveIntPrefs(int setInt,String saveStr) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(saveStr, setInt);
  }
}


