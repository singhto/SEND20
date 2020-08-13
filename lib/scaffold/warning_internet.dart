import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

class WarningInternet extends StatefulWidget {
  @override
  _WarningInternetState createState() => _WarningInternetState();
}

class _WarningInternetState extends State<WarningInternet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            Text('ไม่มี Internet'),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton.icon(
                  onPressed: () {
                    print('click set Internet');
                    AppSettings.openDataRoamingSettings();
                  },
                  icon: Icon(Icons.check),
                  label: Text('Set Internet'),
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
