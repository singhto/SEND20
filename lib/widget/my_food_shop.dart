import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/scaffold/home.dart';
import 'package:foodlion/scaffold/show_food_shop.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/widget/add_my_food.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyFoodShop extends StatefulWidget {
  final String idShop;
  MyFoodShop({Key key, this.idShop}) : super(key: key);
  @override
  _MyFoodShopState createState() => _MyFoodShopState();
}

class _MyFoodShopState extends State<MyFoodShop> {
  // Field
  bool statusData = true;
  List<FoodModel> foodModels = List();
  String myIdShop;
   bool isSwitched = true;

  // Method
  @override
  void initState() {
    super.initState();
    myIdShop = widget.idShop;
    readAllFood();
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
    } else if (foodModels.length != 0) {
      foodModels.clear();
    }

    String url =
        'http://movehubs.com/app/getFoodWhereIdShop.php?isAdd=true&idShop=$idShop';

    Response response = await Dio().get(url);
    // print('response ===>> $response');
    if (response.toString() != 'null') {
      var result = json.decode(response.data);
      // print('result ===>>> $result');

      for (var map in result) {
        FoodModel model = FoodModel.fromJson(map);
        setState(() {
          foodModels.add(model);
          statusData = false;
        });
      }
    }
  }

  Widget showNoData() {
    return Center(
      child: Text(
        'ไม่มีรายการอาหาร กรุณาเพิ่ม',
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }

  Widget showListFood() {
    return ListView.builder(
      itemCount: foodModels.length,
      itemBuilder: (value, index) => showContent(index),
    );
  }

  Widget showContent(int index) => Row(
        children: <Widget>[
          showImageFood(index),
          showText(index),
        ],
      );

  Widget showText(int index) => Container(
        padding: EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width * 0.5,
        // height: MediaQuery.of(context).size.width * 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            showNameFood(index),
            showDetailFood(index),
            showPrice(index),
            showButton(index),
          ],
        ),
      );

  Row showButton(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Center(
                child: Switch(
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
        IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.yellow.shade800,
            ),
            onPressed: () {
              MaterialPageRoute route = MaterialPageRoute(
                  builder: (value) => ShowFoodShop(
                        foodModel: foodModels[index],
                      ));
              Navigator.of(context).push(route).then((value) {
                setState(() {
                  readAllFood();
                });
              });
            }),
        IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () => deleteConfirmDialog(index)),
      ],
    );
  }

  Future<void> deleteConfirmDialog(int index) async {
    showDialog(
      context: context,
      builder: (value) => AlertDialog(
        title: Text(
          'ยืนยันการลบเมนูอาหาร',
          style: MyStyle().h1PrimaryStyle,
        ),
        content: Text(
            'คุณต้องการลบ ${foodModels[index].nameFood} จริงๆ หรือคะ โปรด ยื่นยัน'),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteThread(foodModels[index].id);
              },
              child: Text('ยืนยัน')),
          FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ไม่ยังไม่ลบ')),
        ],
      ),
    );
  }

  Future<void> deleteThread(String id) async {
    String url =
        'http://movehubs.com/app/deleteFoodWhereId.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      setState(() {
        readAllFood();
      });
    });
  }

  Widget showPrice(int index) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            'ราคา : ${foodModels[index].priceFood} บาท',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      );

  Widget showDetailFood(int index) {
    String string = foodModels[index].detailFood;
    if (string.length > 50) {
      string = string.substring(0, 49);
      string = '$string ...';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.5 - 20,
          child: Text(
            string,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget showNameFood(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          //width: MediaQuery.of(context).size.width * 0.5 - 30,
          child: Text(
            foodModels[index].nameFood,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget showImageFood(int index) {
    return Container(
      padding: EdgeInsets.all(20.0),
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.width * 0.5,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            image: DecorationImage(
              image: NetworkImage(foodModels[index].urlFood),
              fit: BoxFit.cover,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('แก้ไขรายการอาหาร')),
       
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'เพิ่ม',
            onPressed: () {
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'เพิ่ม',
            onPressed: () {
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddMyFood()));
            },
          ),
        ],
      ),
      body: statusData ? showNoData() : showListFood(),
    );
  }
}
