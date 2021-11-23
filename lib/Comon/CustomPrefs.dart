import 'package:shared_preferences/shared_preferences.dart';

Future<String> loadStringPrefs(String def,String saveName,int buildNum) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(saveName + '$buildNum') ?? def;
}

Future<void> saveStringPrefs(String setStr,String saveName,[int? buildNum]) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if(buildNum == null){
    await prefs.setString(saveName, setStr);
  }else{
    await prefs.setString(saveName + buildNum.toString(), setStr);
  }
}

Future<void> saveIntPrefs(int setInt,String saveName) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(saveName, setInt);
}

Future<int> loadIntPrefs(String saveName) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(saveName) ?? 0;
}

Future<void> saveBoolPrefs(bool setBool,String saveStr,int buildNum,[int? dayNum]) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if(dayNum == null){
    await prefs.setBool(saveStr + buildNum.toString(), setBool);
  }else{
    await prefs.setBool(saveStr + buildNum.toString() + '$dayNum!', setBool);
  }

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