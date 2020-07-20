import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/shop_close_open_model.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetTime extends StatefulWidget {
  @override
  _SetTimeState createState() => _SetTimeState();
}

class _SetTimeState extends State<SetTime> {
  List<ShopCloseOpenModel> shopCloseOpenModels = List();
  bool isSwitchedMonday = false;
  Widget currentWidget;
  bool isSwitched = false;
  // Method
  @override
  void initState() {
    super.initState();
    readOpen();
  }

  Future<void> readOpen() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');
    //print(' id>>>>>>>> $idShop');

    String url =
        'http://movehubs.com/app/getShopOpenCloseWhereIdShop.php?isAdd=true&idShop=$idShop';
    Response response = await Dio().get(url);
    //print('res ===>> $response');
    if (response.toString() == 'null') {
      setState(() {
        currentWidget = Center(
          child: Text(
            'ไม่มี รายการอาหาร ที่รอส่ง คะ',
            style: MyStyle().h1PrimaryStyle,
          ),
        );
      });
    } else {
      var result = json.decode(response.data);
      for (var map in result) {
        ShopCloseOpenModel shopCloseOpenModel =
            ShopCloseOpenModel.fromJson(map);

        String dateString = shopCloseOpenModel.date;
        print('$dateString');

        setState(() {
          shopCloseOpenModels.add(shopCloseOpenModel);
        });
      }
    }
  }

  ListView showContent(BuildContext context) {
    return ListView.builder(
      itemCount: shopCloseOpenModels.length,
      itemBuilder: (value, index) => GestureDetector(
        onTap: () {},
        child: Card(
          child: ListTile(
            leading: Icon(
              Icons.access_time,
              color: Theme.of(context).primaryColor,
              size: 40.0,
            ),
            title:
                MyStyle().showTitleH2Primary(shopCloseOpenModels[index].date),
            subtitle: Row(
              children: <Widget>[
                MyStyle()
                    .showTitleH2Primary(shopCloseOpenModels[index].timeStart),
                Text(' ถึง '),
                MyStyle()
                    .showTitleH2Primary(shopCloseOpenModels[index].timeEnd),
              ],
            ),
            trailing: Switch(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                  print(isSwitched);
                });
               
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('กำหนดเวลาเปิดร้าน'),
      ),
      body: showContent(context),
    );
  }
}
