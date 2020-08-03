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

  List<bool> isCheckeds = List();
  List<int> listAmountOption = List();
  List<int> listSumOption = List();
  List<int> factorPriceOption = List();
  int total = 0;

  List<int> idOfChoose = List();
  List<String> nameOptions = List();
  List<String> sizeOptions = List();

  int indexChoose = 0;

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
        isCheckeds.add(false);
        listAmountOption.add(0);

        SubFoodModel model = SubFoodModel.fromJson(map);

        int factor = int.parse(model.priceFood.trim());
        listSumOption.add(0);
        factorPriceOption.add(factor);

        if (chooseSubMenu == null) {
          chooseSubMenu = model.nameFood;
        }
        setState(() {
          subFoodModels.add(model);
          total = calculatrTotal();
        });
      }
    }
  }

  Widget showListFood() {
    return Column(
      children: <Widget>[
        showTotal(),
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

  Card showTotal() {
    return Card(
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
          'รวม $total',
          style: TextStyle(
            fontSize: 22,
            color: Colors.red,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
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
                    checkOption(index),
                    Text(subFoodModels[index].nameFood),
                    showAmountFood(index),
                    showSumPriceOption(index),
                  ],
                ),
              ),
            ],
          );
  }

  Widget showSumPriceOption(int index) {
    //print('listsSumOption[$index] == ${listSumOption[index]}');
    //print('listsSumAmountOption[$index] == ${listAmountOption[index]}');

    listSumOption[index] = factorPriceOption[index] * listAmountOption[index];

    //print('listSumOption[$index] ==>> ${listSumOption[index]}');
    return Text('${listSumOption[index]}');
  }

  Widget checkOption(int index) {
    //print('isCheck $isCheckeds');
    //print('index $index');
    return Container(
      width: 80.0,
      child: CheckboxListTile(
        value: isCheckeds[index],
        onChanged: (value) {
          setState(() {
            isCheckeds[index] = value;

            if (value) {
              listAmountOption[index] = 1;
              total = calculatrTotal();

              idOfChoose.add(indexChoose);
              indexChoose++;
              nameOptions.add(subFoodModels[index].nameFood);
              //print('nameOptions === $nameOptions');
              sizeOptions.add(subFoodModels[index].priceFood);
            } else {
              listAmountOption[index] = 0;
              total = calculatrTotal();

              nameOptions.removeWhere(
                  (element) => (element == subFoodModels[index].nameFood));

              //print('nameOptions === $nameOptions');
              String id = subFoodModels[index].id;
              //sizeOptions.removeAt(int)
              //sizeOptions.removeWhere((element) => (element == subFoodModels[index].priceFood));
            }
          });
        },
      ),
    );
  }

  Widget showAmountFood(int index) {
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
                  if (listAmountOption[index] != 0) {
                    setState(() {
                      listAmountOption[index]--;
                      total = calculatrTotal();
                      if (listAmountOption[index] == 0) {
                        isCheckeds[index] = false;
                      }
                    });
                  }
                }),
            MyStyle().mySizeBox(),
            Text('${listAmountOption[index]}',
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
                    listAmountOption[index]++;
                    total = calculatrTotal();
                    isCheckeds[index] = true;
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

                print(
                    'nameOption = $nameOptions, sizeOption = $sizeOptions, priceOption = ?, sumOption = ?, remark = ?');
                print(
                    'latUser = ?, lngUser = ? latShop = ?, lngShop = ?, sumPrice = ?, transport = ?, distance = ?');
                // OrderModel model = OrderModel(
                //   idFood: idFood,
                //   idShop: idShop,
                //   nameShop: nameshop,
                //   nameFood: nameFood,
                //   urlFood: urlFood,
                //   priceFood: priceFood,
                //   amountFood: amountFood.toString(),
                // );
                // SQLiteHelper().insertDatabase(model);
                // Navigator.of(context).pop();
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

  int calculatrTotal() {
    int index = 0;
    int totalInt = 0;
    print('listAmount === $listAmountOption');
    print('factorPrice === $factorPriceOption');
    for (var j in listAmountOption) {
      int total = listAmountOption[index] * factorPriceOption[index];
      totalInt = totalInt + total;

      index++;
    }
    return totalInt;
  }
}
