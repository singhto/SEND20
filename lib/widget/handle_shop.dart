import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/models/order_user_model.dart';
import 'package:foodlion/models/user_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HandleShop extends StatefulWidget {
  @override
  _HandleShopState createState() => _HandleShopState();
}

class _HandleShopState extends State<HandleShop> {
  List<OrderUserModel> orderUserModels = List();
  List<UserModel> userModels = List();
  List<List<FoodModel>> listFoodModels = List();
  List<List<String>> listAmounts = List();
  List<List<String>> listSums = List();
  List<List<String>> listStatuss = List();
  List<String> nameShops = List();
  Widget currentWidget;
  List<String> nameUsers = List();

  @override
  void initState() {
    super.initState();
    readOrder();
  }

  Future<Null> readOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');

    String url =
        'http://movehubs.com/app/getOrderWhereIdShopNew.php?isAdd=true&idShop=$idShop';
    Response response = await Dio().get(url);

    print('res ===>> $response');

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
        UserModel userModel =
            await MyAPI().findDetailUserWhereId(orderUserModel.idUser);

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
          nameUsers.add(userModel.name);
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
                showTotalPrice(index),
                //showTotalDelivery(index),
                //showSumTotal(index),
                showProcessOrder(index),
              ],
            ),
          ),
        ),
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

  Widget showTotalPrice(int index) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: EdgeInsets.only(right: 16.0),
              child: Text(
                'รวม ${orderUserModels[index].totalPrice} บาท',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: Theme.of(context).primaryColor,
                ),
              ),
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
              flex: 3,
              child: Center(
                  child: Text(listFoodModels[index][index2].nameFood,
                      style: MyStyle().h2NormalStyle)),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(listFoodModels[index][index2].priceFood,
                    style: MyStyle().h2NormalStyle),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(listAmounts[index][index2],
                    style: MyStyle().h2NormalStyle),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                    '${(int.parse(listFoodModels[index][index2].priceFood)) * (int.parse(listAmounts[index][index2]))}',
                    style: MyStyle().h2NormalStyle),
              ),
            ),
          ],
        ),
      );

  Widget headTitle() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Text(
                'รายการอาหาร',
                style: MyStyle().h3StyleDark,
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'ราคา',
                  style: MyStyle().h3StyleDark,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'จำนวน',
                  style: MyStyle().h3StyleDark,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'รวม',
                  style: MyStyle().h3StyleDark,
                ),
              ),
            ),
          ],
        ),
      );

  Widget showDateTime(int index) =>
      Row(
        children: <Widget>[
          MyStyle().showTitleH2Primary('วันที่ :'),
          MyStyle().showTitleH2Primary(orderUserModels[index].dateTime),
          MyStyle().showTitleH2Primary('เลขที่ :'),
          MyStyle().showTitleH2Primary(orderUserModels[index].id),
        ],
      );

  Widget showShop(int index) => MyStyle().showTitle('คุณ ${nameUsers[index]}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentWidget == null ? MyStyle().showProgress() : currentWidget,
    );
  }
}
