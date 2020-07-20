import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/order_user_model.dart';
import 'package:foodlion/models/user_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';

class MyDeliveryHis extends StatefulWidget {
  @override
  _MyDeliveryHisState createState() => _MyDeliveryHisState();
}

class _MyDeliveryHisState extends State<MyDeliveryHis> {
  List<OrderUserModel> orderUserModels = List();
  List<String> nameShops = List();
  List<int> distances = List();
  List<int> transports = List();
  String idRider;

  @override
  void initState() {
    super.initState();
    readOrder();
  }

  Future<void> readOrder() async {
    orderUserModels.clear();
    nameShops.clear();
    distances.clear();
    transports.clear();

    String url =
        'http://movehubs.com/app/getOrderWhereStatusSuccess.php?isAdd=true';
    //String url = 'http://movehubs.com/app/getOrderWhereSuccess.php?isAdd=true&Success=ShopOrder';
    Response response = await Dio().get(url);
    var result = json.decode(response.data);
    print('result ==>> ${result.toString()}');

    for (var map in result) {
      OrderUserModel orderUserModel = OrderUserModel.fromJson(map);

      UserModel userModel =
          await MyAPI().findDetailUserWhereId(orderUserModel.idUser);

      UserShopModel userShopModel =
          await MyAPI().findDetailShopWhereId(orderUserModel.idShop);
      String nameShop = userShopModel.name;

      double distance = MyAPI().calculateDistance(
          double.parse(userModel.lat),
          double.parse(userModel.lng),
          double.parse(userShopModel.lat),
          double.parse(userShopModel.lng));
      print('distance ==>>> $distance');

      int distanceToInt = distance.round();
      print('distanceToInt ==>>> $distanceToInt');

      int transport = MyAPI().checkTransport(distanceToInt);

      setState(() {
        orderUserModels.add(orderUserModel);
        nameShops.add(nameShop);
        distances.add(distanceToInt);
        transports.add(transport);
      });
    }
  }

  ListView showContent() {
    return ListView.builder(
      itemCount: orderUserModels.length,
      itemBuilder: (value, index) => GestureDetector(
        //onTap: () => rountToDetailOrder(index),
        child: Card(
          color: index % 2 == 0 ? Colors.grey.shade300 : Colors.white,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  MyStyle().showTitle(nameShops[index]),
                  Icon(Icons.check_box, color: Colors.green,),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 16.0),
                    child: Text(
                      orderUserModels[index].dateTime,
                      style: MyStyle().h2Style,
                    ),
                  ),
                  MyStyle().showTitleH2Primary('เลขที่ :'),
                  MyStyle().showTitleH2Primary(orderUserModels[index].id),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'ระยะทาง = ${distances[index]} กิโลเมตร',
                      style: MyStyle().h2NormalStyle,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 16.0),
                    child: Text(
                      'ค่าขนส่ง = ${transports[index]} บาท',
                      style: MyStyle().h2Style,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Center showNoOrder() {
    return Center(
      child: Text(
        'ยังไม่มีรายการ',
        style: MyStyle().h1PrimaryStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: orderUserModels.length == 0 ? showNoOrder() : showContent(),
    );
  }
}
