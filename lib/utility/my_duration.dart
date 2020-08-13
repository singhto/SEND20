import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodlion/scaffold/have_problem.dart';

Future<Null> myDuration(bool myBool, BuildContext context) async {
    print('my Dutation ทำงาน');
    Duration duration = Duration(seconds: 10);
    await Timer(duration, () {
      if (myBool) {
        //normalToast('ครบ 10 วินาทีแล้ว shopWidget.lengtho ==>0');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HaveProblem(),
            ),
            (route) => false);
      }
    });
  }