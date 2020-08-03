import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/utility/my_style.dart';

class UserHome extends StatefulWidget {
  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  Widget currentWidget;
  List<UserShopModel> userShopModels = List();
  List<Widget> showWidgets = List();

  @override
  void initState() {
    super.initState();
    readShop();
  }

  Future<Null> readShop() async {
    String url = 'http://movehubs.com/app/getAllShopAdmin.php';

    try {
      Response response = await Dio().get(url);

      //print('response $response');
      if (response.toString() == 'null') {
        setState(() {
          currentWidget = Container(
            child: Center(
              child: Text(
                'ไม่มีร้านค้าในพื้นที่ครับ',
                style: MyStyle().h1PrimaryStyle,
              ),
            ),
          );
        });
      } else {
        var result = json.decode(response.data);

        for (var map in result) {
          UserShopModel model = UserShopModel.fromJson(map);

          setState(() {
            userShopModels.add(model);
            showWidgets.add(createCard(model));
          });
        }
      }
    } catch (e) {}
  }

  Widget createCard(UserShopModel model) {
    return GestureDetector(
      onTap: () {},
      child: Card(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          showImageShop(model),
          showName(model),
        ],
      )),
    );
  }

  Widget showName(UserShopModel model) => Expanded(
        child: Text(
          model.name,
          style: TextStyle(
            fontSize: 12.0,
          ),
        ),
      );
  Widget showImageShop(UserShopModel model) {
    return Container(
      width: 90.0,
      height: 90.0,
      child: CircleAvatar(
        backgroundImage: NetworkImage(model.urlShop),
      ),
    );
  }

  Widget showShop() {
    return userShopModels.length == 0
        ? MyStyle().showProgress()
        : Expanded(
            child: GridView.extent(
                maxCrossAxisExtent: 150.0, children: showWidgets));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        children: <Widget>[
          showShop(),
        ],
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return AppBar(
      //brightness: Brightness.light,
      //backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      title: Center(
        child: Text(
          'SEND',
          style: TextStyle(
            //color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 3.0,
          ),
        ),
      ),
    );
  }
}
