import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/utility/my_style.dart';

class HaveProblem extends StatefulWidget {
  @override
  _HaveProblemState createState() => _HaveProblemState();
}

class _HaveProblemState extends State<HaveProblem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'พบข้อผิดพลาด',
              style: MyStyle().h2NormalStyleGrey,
            ),
            MyStyle().mySizeBox(),
            Icon(
              Icons.location_off,
              size: 100,
              color: Colors.grey,
            ),
            MyStyle().mySizeBox(),
            RaisedButton(
              onPressed: () {
                AppSettings.openAppSettings();
              
              },
              child: Text(
                'เปิด พิกัดเครื่อง & การแจ้งเตือน',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green,),
              ),
            ),
            SizedBox(height: 30,),

            RaisedButton(
              onPressed: () {
                exit(0);
              },
              child: Text(
                'ปิด',
                style: MyStyle().h2StylePrimary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
