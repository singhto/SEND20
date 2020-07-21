import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/scaffold/show_cart.dart';
import 'package:foodlion/scaffold/show_food.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyFood extends StatefulWidget {
  final String idShop;
  MyFood({Key key, this.idShop}) : super(key: key);
  @override
  _MyFoodState createState() => _MyFoodState();
}

class Dedouncer {
  final int milliseconds;
  VoidCallback voidCallback;
  Timer timer;

  Dedouncer({this.milliseconds});

  run(VoidCallback voidCallback) {
    if (timer != null) {
      timer.cancel();
    }
    timer = Timer(Duration(microseconds: milliseconds), voidCallback);
  }
}

class _MyFoodState extends State<MyFood> {
  // Field
  bool statusData = true;
  List<FoodModel> foodModels = List();
  List<UserShopModel> userShopModels = List();
  String myIdShop;
  int amount = 0;
  List<String> nameShops = List();

  UserShopModel userShopModel;

  String searchString;
  List<FoodModel> searchFoodModels = List();
  final Dedouncer dedouncer = Dedouncer(milliseconds: 500);
  String nameShop;

  // Method
  @override
  void initState() {
    super.initState();
    myIdShop = widget.idShop;
    readAllFood();
    checkAmount();
  }

  Future<void> checkAmount() async {
    print('checkAmount Work');
    try {
      List<OrderModel> list = await SQLiteHelper().readDatabase();
      setState(() {
        amount = list.length;
      });
    } catch (e) {}
  }

  Future<String> getIdShop() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');
    return idShop;
  }

  Future<void> readAllFood() async {
    String idShop = await getIdShop();

    if (myIdShop != null) {
      idShop = myIdShop;
    }

    // print('idShop ===> $idShop');

    String url =
        'http://movehubs.com/app/getFoodWhereIdShop.php?isAdd=true&idShop=$idShop';

    Response response = await Dio().get(url);
    // print('response ===>> $response');

    if (response.toString() != 'null') {
      var result = json.decode(response.data);
      // print('result ===>>> $result');

      for (var map in result) {
        FoodModel model = FoodModel.fromJson(map);

if (nameShop == null) {
   nameShop = await MyAPI().findNameShopWhere(model.idShop);
}

        //UserShopModel userShopModels = UserShopModel.fromJson(map);
        setState(() {
          foodModels.add(model);
          searchFoodModels = foodModels;
          userShopModel = UserShopModel.fromJson(map);
          userShopModels.add(userShopModel);
          statusData = false;
        });
      }
    }
  }

  Widget showNoData() {
    return Center(
      child: Text(
        'ไม่มีรายการอาหาร',
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }

  Widget showListFood() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16, bottom: 16),
            width: 250.0,
            child: TextField(
              onChanged: (value) {
                dedouncer.run(() {
                  setState(() {
                    searchFoodModels = foodModels.where((FoodModel foodModel) {
                      return (foodModel.nameFood.toLowerCase().contains(value.toLowerCase()));
                    }).toList();
                  });
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: searchFoodModels.length,
            itemBuilder: (value, index) {
              return showContent(index);
            },
          ),
        ],
      ),
    );
  }

  Widget showContent(int index) {
    return GestureDetector(
      onTap: () {
        MaterialPageRoute route = MaterialPageRoute(
          builder: (value) => ShowFood(
            foodModel: searchFoodModels[index],
          ),
        );
        Navigator.of(context).push(route).then(
              (value) => checkAmount(),
            );
      },
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                width: 1.0,
                color: Colors.grey[200],
              ),
            ),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image(
                    height: 150.0,
                    width: 150.0,
                    image: NetworkImage(searchFoodModels [index].urlFood),
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          searchFoodModels [index].nameFood,
                          style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                        //RatingStars(),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          searchFoodModels [index].detailFood,
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          //'บรรจุ: กล่อง/ถุง',
                          'บรรจุ: ${searchFoodModels[index].qty}',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade300),
                          overflow: TextOverflow.ellipsis,
                        ),
                        showPrice(index),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget showPrice(int index) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            '${searchFoodModels[index].priceFood} บาท',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      );

  Widget showCart() => GestureDetector(
        onTap: () {
          MaterialPageRoute route =
              MaterialPageRoute(builder: (value) => ShowCart());
          Navigator.of(context).push(route).then(
                (value) => checkAmount(),
              );
        },
        child: MyStyle().showMyCart(amount),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nameShop == null ?'ร้าน' : 'ร้าน$nameShop'),
        actions: <Widget>[showCart()],
      ),
      body: statusData ? showNoData() : showListFood(),
    );
  }
}
