import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/models/order_user_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowOrderUser extends StatefulWidget {
  @override
  _ShowOrderUserState createState() => _ShowOrderUserState();
}

class _ShowOrderUserState extends State<ShowOrderUser> {
  // Field
  bool status, shopBool = true, riderBool = true, userBool = true;
  Widget currentWidget;
  List<OrderUserModel> orderUserModels = List();
  List<String> nameShops = List();
  List<List<FoodModel>> listFoodModels = List();
  List<List<String>> listAmounts = List();

  final GlobalKey<RefreshIndicatorState> _refresh = GlobalKey<RefreshIndicatorState>();

  // Method
  @override
  void initState() {
    super.initState();
    readOrder();
  }

  Future<void> readOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');

    String url =
        'http://movehubs.com/app/getOrderWhereIdUser.php?isAdd=true&idUser=$idUser';
    Response response = await Dio().get(url);
    // print('res ===>> $response');

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
        OrderUserModel orderUserModel = OrderUserModel.fromJson(map);

        String amountString = orderUserModel.amountFoods;
        amountString = amountString.substring(1, (amountString.length - 1));
        //print('amountString ==> $amountString');
        List<String> amounts = amountString.split(',');

        int j = 0;
        for (var string in amounts) {
          amounts[j] = string.trim();
          j++;
        }

        String idFoodString = orderUserModel.idFoods;
        // print('idFoodString1 $idFoodString');
        idFoodString = idFoodString.substring(1, (idFoodString.length - 1));
        List<String> idFoods = idFoodString.split(',');

        int i = 0;
        for (var string in idFoods) {
          idFoods[i] = string.trim();
          i++;
        }

        // print('idFoods ===>> ${idFoods.toString()}');
        List<FoodModel> foodModels = List();
        for (var idFood in idFoods) {
          // print('idFood = $idFood');
          FoodModel foodModel = await MyAPI().findDetailFoodWhereId(idFood);
          // print('nameFood = ${foodModel.nameFood}');
          foodModels.add(foodModel);
        }

        String nameShop =
            await MyAPI().findNameShopWhere(orderUserModel.idShop);
        setState(() {
          listAmounts.add(amounts);
          listFoodModels.add(foodModels);
          nameShops.add(nameShop);
          orderUserModels.add(orderUserModel);
          currentWidget = showContent();
        });
      }
    }
  }

  Widget showContent() => ListView.builder(
        itemCount: orderUserModels.length,
        itemBuilder: (value, index) => GestureDetector(
          child: Card(
            color: index % 2 == 0 ? Colors.grey.shade300 : Colors.white,
            child: Column(
              children: <Widget>[
                showShop(index),
                showDateTime(index),
                headTitle(),
                showListViewOrder(index),
                Divider(),
                showTotalPrice(index),
                showTotalDelivery(index),
                showSumTotal(index),
                showProcessOrder(index),
              ],
            ),
          ),
        ),
      );

  Widget showTotalPrice(int index) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16.0),
            child: MyStyle().showTitleH2Dark(
                'ค่าอาหาร ${orderUserModels[index].totalPrice} บาท'),
          ),
        ],
      );

  Widget showTotalDelivery(int index) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16.0),
            child: MyStyle().showTitleH2Primary(
                'ค่าขนส่ง ${orderUserModels[index].totalDelivery} บาท'),
          ),
        ],
      );

  Widget showSumTotal(int index) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16.0),
            child: MyStyle().showTitleH2DartBold(
                'ราคารวม ${orderUserModels[index].sumTotal} บาท'),
          ),
        ],
      );

  Widget showProcessOrder(int index) => Row(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: orderUserModels[index].success == 'ShopOrder' ||
                          orderUserModels[index].success == 'RiderOrder' ||
                          orderUserModels[index].success == 'Success'
                      ? Colors.pink.shade300
                      : Colors.grey.shade300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('กำลังปรุงอาหาร'),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: orderUserModels[index].success == 'RiderOrder' ||
                          orderUserModels[index].success == 'Success'
                      ? Colors.orange.shade400
                      : Colors.grey.shade400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('กำลังไปส่ง'),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: orderUserModels[index].success == 'Success'
                      ? Colors.green.shade800
                      : Colors.grey.shade700),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'สำเร็จ',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget headTitle() => Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              'รายการอาหาร',
              style: MyStyle().h3StyleDark,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'จำนวน',
              style: MyStyle().h3StyleDark,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'รวม',
              style: MyStyle().h3StyleDark,
            ),
          ),
        ],
      );

  Widget showListViewOrder(int index) => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: listFoodModels[index].length,
        itemBuilder: (value, index2) => Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  //Text(listFoodModels[index][index2].nameFood,style: TextStyle(fontSize: 18.0,),),
                  //Text(listFoodModels[index][index2].detailFood,style: TextStyle(fontSize: 18.0,),),
                  Text(
                    '${listFoodModels[index][index2].nameFood} ${listFoodModels[index][index2].detailFood}',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  Text('${orderUserModels[index].remarke}'),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: <Widget>[
                  Text(
                    listAmounts[index][index2],
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  Text(''),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: <Widget>[
                  Text(
                    '${(int.parse(listFoodModels[index][index2].priceFood)) * (int.parse(listAmounts[index][index2]))}',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  Text(''),
                ],
              ),
            ),
          ],
        ),
      );

  Widget showDateTime(int index) =>
      MyStyle().showTitleH2Primary(orderUserModels[index].dateTime);

  Widget showShop(int index) => MyStyle().showTitle('ร้าน ${nameShops[index]}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการสั่งอาหาร'),
      ),
      body: RefreshIndicator(
        key: _refresh,
        child: currentWidget == null ? MyStyle().showProgress() : currentWidget,
        onRefresh: _handleRefresh,
      ),
      
    );
  }

  Future<Null> _handleRefresh() async {
    await Future.delayed(
      Duration(seconds: 2),
    );
    setState(() {
    });
    return null;
  }
}
