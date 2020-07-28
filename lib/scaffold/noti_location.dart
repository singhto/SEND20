import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodlion/utility/my_style.dart';

class NotiLocation extends StatefulWidget {
  @override
  _NotiLocationState createState() => _NotiLocationState();
}

class _NotiLocationState extends State<NotiLocation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ค้นหาพิกัดล้มเหลว!'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                //AppSettings.openLocationSettings();
              },
              child: Icon(
                Icons.location_off,
                size: 60.0,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              'อนุญาติให้ SEND เข้าถึงพิกัดของมือถือ',
              style: MyStyle().h2NormalStyle,
            ),
            Text(
              'เพื่อค้นหาร้านอาหารที่อยู่ใกล้คุณ',
              style: MyStyle().h2NormalStyle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('กรุณากลับไปที่เมนู '),
                GestureDetector(
                  onTap: () {
                    //AppSettings.openLocationSettings();
                  },
                  child: Icon(
                    Icons.settings,
                    color: Colors.grey,
                  ),
                ),
                Text(' เพื่อตั้งค่าการใช้งานใหม่'),
              ],
            ),
            SizedBox(height: 30),
            RaisedButton(
              onPressed: () {
                exit(0);
              },
              child: Text('ปิด แล้วลองใหม่',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Colors.red)),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
