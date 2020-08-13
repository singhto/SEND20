import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

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
            Text('Have Problum Please Restart App'),
            RaisedButton(
              onPressed: () {
                AppSettings.openAppSettings();
              },
              child: Text('Restart App'),
            )
          ],
        ),
      ),
    );
  }
}
