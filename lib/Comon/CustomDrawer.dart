import 'package:flutter/material.dart';
import 'package:taskpagetest/taskControllerPage.dart';

import '../lock_page.dart';
import '../time_controller_page.dart';
import '../home.dart';


class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
          _lockControllerPage('ロック画面'),
        ],
      ),
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
              MaterialPageRoute(builder: (context) => HomePage('')),
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

  //Drawer　Homeページへ
  Widget _lockControllerPage(String text){
    return Container(
      child: ListTile(
          title: Text(text),
          trailing: Icon(Icons.arrow_forward),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LockPage()),
            );
          }
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0,color:Colors.grey)),
      ),
    );
  }
}


// class CustomDrawer extends StatefulWidget {
//   const CustomDrawer({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         children: <Widget>[
//           Container(
//             height: 60,
//             width: double.infinity,
//             child: DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ), child: null,
//             ),
//           ),
//           _homeControllerPage('ホーム'),
//           _timeControllerPage('ロック管理'),
//           _taskControllerPage('タスク管理'),
//           _lockControllerPage('ロック画面'),
//         ],
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
//               MaterialPageRoute(builder: (context) => HomePage('')),
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
//   //Drawer　Homeページへ
//   Widget _lockControllerPage(String text){
//     return Container(
//       child: ListTile(
//           title: Text(text),
//           trailing: Icon(Icons.arrow_forward),
//           onTap: (){
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => LockPage()),
//             );
//           }
//       ),
//       decoration: BoxDecoration(
//         border: Border(bottom: BorderSide(width: 1.0,color:Colors.grey)),
//       ),
//     );
//   }
// }


