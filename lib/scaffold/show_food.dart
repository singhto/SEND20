import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/models/sub_food_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowFood extends StatefulWidget {
  final FoodModel foodModel;
  ShowFood({Key key, this.foodModel});
  @override
  _ShowFoodState createState() => _ShowFoodState();
}

class _ShowFoodState extends State<ShowFood> {
  // Field
  FoodModel foodModel;
  int amountFood = 1;
  String idShop,
      idUser,
      idFood,
      nameshop,
      nameFood,
      urlFood,
      priceFood,
      statusFood;
  bool statusShop = false;
  String nameCurrentShop;
  SubFoodModel subFoodModel;
  List<SubFoodModel> subFoodModels = List();

  String chooseSubMenu;

  // Method
  @override
  void initState() {
    super.initState();
    foodModel = widget.foodModel;

    setupVariable();
    readSubMenu();
  }

  Future<void> setupVariable() async {
    idShop = foodModel.idShop;
    idFood = foodModel.id;
    nameshop = await MyAPI().findNameShopWhere(idShop);
    nameFood = foodModel.nameFood;
    urlFood = foodModel.urlFood;
    priceFood = foodModel.priceFood;

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      idUser = preferences.getString('Login');

      List<OrderModel> orderModels = await SQLiteHelper().readDatabase();
      if (orderModels.length != 0) {
        for (var model in orderModels) {
          nameCurrentShop = model.nameShop;
          if (idShop != model.idShop) {
            statusShop = true;
          }
        }
      }
    } catch (e) {}
  }

  Widget showName() {
    return Text(
      foodModel.nameFood,
      style: MyStyle().h1Style,
    );
  }

  Widget showImage() => CachedNetworkImage(
        height: 220.0,
        width: MediaQuery.of(context).size.width,
        imageUrl: foodModel.urlFood,
        placeholder: (value, string) => MyStyle().showProgress(),
        fit: BoxFit.cover,
      );

  Widget chooseAmount() {
    return Expanded(
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
              icon: Icon(
                Icons.add_circle,
                size: 28.0,
                color: Colors.green,
              ),
              onPressed: () {
                setState(() {
                  amountFood++;
                });
              }),
          MyStyle().mySizeBox(),
          Text(
            '$amountFood',
            style: MyStyle().h1PrimaryStyle,
          ),
          MyStyle().mySizeBox(),
          IconButton(
              icon: Icon(
                Icons.remove_circle,
                size: 28.0,
                color: Colors.red,
              ),
              onPressed: () {
                if (amountFood != 0) {
                  setState(() {
                    amountFood--;
                  });
                }
              }),
        ],
      ),
    );
  }

  Widget showButton() {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        chooseAmount(),
      ],
    );
  }

  Future<Null> readSubMenu() async {
    String idFood = foodModel.id;
    String url =
        'http://movehubs.com/app/getSubFoodWhereIdFood.php?isAdd=true&idFood=$idFood';

    Response response = await Dio().get(url);
    if (response.toString() != 'null') {
      var result = json.decode(response.data);
      for (var map in result) {
        SubFoodModel model = SubFoodModel.fromJson(map);
        if (chooseSubMenu == null) {
          chooseSubMenu = model.nameFood;
        }
        setState(() {
          subFoodModels.add(model);
        });
      }
    }
  }

  Widget showListFood() {
    return Column(
      children: <Widget>[
        Card(
          child: ListTile(
            title: Text(
              '${foodModel.nameFood} ${foodModel.detailFood}',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            //subtitle: showAmountFood(),
            trailing: Text(
              'รวม ...',
              style: TextStyle(
                fontSize: 22,
                color: Colors.red,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        showListSubMunu(),
        Padding(padding: EdgeInsets.only(top: 20.0)),
        Text(
          'คำขอพิเศษ',
          style:
              TextStyle(color: Theme.of(context).primaryColor, fontSize: 25.0),
        ),
        Padding(padding: EdgeInsets.only(top: 20.0)),
        TextFormField(
          decoration: InputDecoration(
            labelText: "คำขอ",
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(),
            ),
          ),

  
        ),
      ],
    );
  }

  Widget showListSubMunu() {
    return subFoodModels.length == 0
        ? Text('ไม่มีเมนูย่อย')
        : Column(
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: subFoodModels.length,
                itemBuilder: (context, index) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Radio(
                      value: subFoodModels[index].nameFood,
                      groupValue: chooseSubMenu,
                      onChanged: (value) {
                        setState(() {
                          chooseSubMenu = value;
                        });
                      },
                    ),
                    Text(subFoodModels[index].nameFood),
                    showAmountFood(),
                    Text(subFoodModels[index].priceFood),
                  ],
                ),
              ),
            ],
          );
  }

  Widget showAmountFood() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            MyStyle().mySizeBox(),
            IconButton(
                icon: Icon(
                  Icons.remove_circle,
                  size: 20.0,
                  color: Colors.red,
                ),
                onPressed: () {
                  if (amountFood != 0) {
                    setState(() {
                      amountFood--;
                    });
                  }
                }),
            MyStyle().mySizeBox(),
            Text('$amountFood',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                )),
            MyStyle().mySizeBox(),
            IconButton(
                icon: Icon(
                  Icons.add_circle,
                  size: 20.0,
                  color: Colors.green,
                ),
                onPressed: () {
                  setState(() {
                    amountFood++;
                  });
                }),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              showImage(),
              MyStyle().mySizeBox(),
              showName(),
              showListFood(),
              SizedBox(
                height: 90.0,
              )
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        height: 60.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -1),
              blurRadius: 6.0,
            )
          ],
        ),
        child: Center(
          child: FlatButton(
            onPressed: () {
              if (statusShop) {
                normalDialog(context, 'ไม่สามารถเลือกได้ ?',
                    'โปรดเลือกอาหาร จากร้าน $nameCurrentShop คุณสามารถสั่งอาหารได้ครั้งละ 1 ร้าน');
              } else if (amountFood == 0) {
                normalDialog(context, 'ยังไม่มี รายการอาหาร',
                    'กรุณาเพิ่มจำนวน รายการอาหาร');
              } else if (idUser == null) {
                normalDialog(
                    context, 'ยังไม่ได้ Login', 'กรุณา Login ก่อน Order คะ');
              } else {
                print(
                    'idFood=$idFood, idShop=$idShop,nameShop=$nameshop, nameFood=$nameFood, urlFood=$urlFood, priceFood=$priceFood, amountFood=$amountFood');
                OrderModel model = OrderModel(
                  idFood: idFood,
                  idShop: idShop,
                  nameShop: nameshop,
                  nameFood: nameFood,
                  urlFood: urlFood,
                  priceFood: priceFood,
                  amountFood: amountFood.toString(),
                );
                SQLiteHelper().insertDatabase(model);
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'เพิ่มลงในตะกร้า',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
