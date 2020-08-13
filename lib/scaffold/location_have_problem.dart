import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

class LocationHaveProblem extends StatefulWidget {
  @override
  _LocationHaveProblemState createState() => _LocationHaveProblemState();
}

class _LocationHaveProblemState extends State<LocationHaveProblem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            Text('ไม่ได้เปิดพิกัดเครื่องครับ'),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton.icon(
                  onPressed: () {
                    print('click set Location');
                    AppSettings.openLocationSettings();
                  },
                  icon: Icon(Icons.check),
                  label: Text('Set Location'),
                ),
                 RaisedButton.icon(
                  onPressed: () {
                    exit(0);
                  },
                  icon: Icon(Icons.clear),
                  label: Text('Cancel'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
