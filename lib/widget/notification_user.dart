import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/noti_user_model.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationUser extends StatefulWidget {
  @override
  _NotificationUserState createState() => _NotificationUserState();
}

class _NotificationUserState extends State<NotificationUser> {
  Widget currentWidget;
  List<NotiUserModel> notiUserModels = List();

// Method
  @override
  void initState() {
    super.initState();
    readNoti();
  }

  Future<void> readNoti() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');

    String url =
        'http://movehubs.com/app/getNotiWhereIdUser.php?isAdd=true&idUser=$idUser';
    Response response = await Dio().get(url);
    //print('res ===>> $response');

    if (response.toString() == 'null') {
      setState(() {
        currentWidget = Center(
          child: Text(
            'ไม่มีแจ้งเตือน',
            style: MyStyle().h1PrimaryStyle,
          ),
        );
      });
    } else {
      var result = json.decode(response.data);
      for (var map in result) {
        NotiUserModel notiUserModel = NotiUserModel.fromJson(map);

        String titleString = notiUserModel.title;
        //titleString = titleString.substring(1, (titleString.length - 1));
        print('titleString ==> $titleString');
        //List<String> title = titleString.split(',');

        //print('massage ==> $notiUserModels');

        setState(() {
          notiUserModels.add(notiUserModel);
          currentWidget = showContent();
        });
      }
    }
  }

  Widget showContent() => ListView.builder(
        itemCount: notiUserModels.length,
        itemBuilder: (value, index) => Card(
          child: ListTile(
            leading: MyStyle().showLogo(),
            title: Expanded(
              child: Text(
                '${notiUserModels[index].title} ${notiUserModels[index].dateTime}',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            subtitle: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                        '${notiUserModels[index].massage}',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แจ้งเตือน'),
      ),
      body: currentWidget == null ? MyStyle().showProgress() : currentWidget,
    );
  }
}
