import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/models/sub_food_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowFood extends StatefulWidget {
  final FoodModel foodModel;
  final String nameLocalChoose, distance;
  final lat, lng;
  final int transportInt;

  ShowFood(
      {Key key,
      this.foodModel,
      this.nameLocalChoose,
      this.lat,
      this.lng,
      this.distance,
      this.transportInt});
  @override
  _ShowFoodState createState() => _ShowFoodState();
}

class _ShowFoodState extends State<ShowFood> {
  // Field
  FoodModel foodModel;
  int amountFood = 0;
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
  List<String> priceOptions = List();
  List<String> sumOptions = List();

  String remake = '';
  String nameLocalChoose, distance;
  double latChoose, lngChoose, latShop, lngShop;

  int transport;

  bool statusChoose = false;

  // Method
  @override
  void initState() {
    super.initState();
    foodModel = widget.foodModel;
    nameLocalChoose = widget.nameLocalChoose;
    latChoose = widget.lat;
    lngChoose = widget.lng;
    distance = widget.distance;

    setupVariable();
    readSubMenu();
    findLocationShop();
    findTransport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(foodModel.nameFood,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            )),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              showImage(),
              MyStyle().mySizeBox(),
              showName(),
              showListFood(),
              SizedBox(
                height: 50.0,
              )
            ],
          ),
        ),
      ),
      bottomSheet: buildBottomSheet(context),
    );
  }

  Future<Null> findTransport() async {
    print('disss  === $distance');

    transport = widget.transportInt;
    print('transport ===>>> $transport');
  }

  Future<Null> findLocationShop() async {
    Map<String, dynamic> map =
        await MyAPI().findLocationShopWhere(foodModel.idShop);
    UserShopModel model = UserShopModel.fromJson(map);
    latShop = double.parse(model.lat);
    lngShop = double.parse(model.lng);

    print('${model.name} === $latShop $lngShop');
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
        MyStyle().mySizeBox(),
        buildRemake(),
        //buildAmount(),
        SizedBox(
          height: 50.0,
        ),
      ],
    );
  }

  Widget buildRemake() {
    return TextFormField(
      onChanged: (value) => remake = value.trim(),
      decoration: InputDecoration(
        labelText: "ใส่คำขอพิเศษหรือไม่ก็ได้เช่น รสชาติ, ไม่ใส่ผัก เป็นต้น",
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(),
        ),
      ),
    );
  }

  Column buildAmount() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 50.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            MyStyle().mySizeBox(),
            IconButton(
                icon: Icon(
                  Icons.remove_circle,
                  size: 36.0,
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
            Text(
              '$amountFood',
              style: MyStyle().h1PrimaryStyle,
            ),
            MyStyle().mySizeBox(),
            IconButton(
                icon: Icon(
                  Icons.add_circle,
                  size: 36.0,
                  color: Colors.green,
                ),
                onPressed: () {
                  setState(() {
                    amountFood++;
                  });
                }),
            MyStyle().mySizeBox(),
          ],
        ),
        SizedBox(
          height: 20.0,
        )
      ],
    );
  }

  Card showTotal() {
    return Card(
      child: ListTile(
        title: Text(
          '${foodModel.nameFood}',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        subtitle: Text('${foodModel.detailFood}'),
        trailing: buildText(),
      ),
    );
  }

  Text buildText() {
    for (var i = 0; i < 2; i++) {
      print('listSumOption === $listSumOption');
      int total = 0;
      for (var i in listSumOption) {
        total = total + i;
      }
    }
    return Text(
      'รวม $total บาท',
      style: TextStyle(
        fontSize: 22,
        color: Colors.red,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
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
                itemBuilder: (context, index) => Card(
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: <Widget>[
                      checkOption(index),
                      Expanded(
                        flex: 1,
                        child: showFoodMenu(index),
                      ),
                      Expanded(
                        flex: 3,
                        child: showAmountFood(index),
                      ),
                      Expanded(
                        flex: 1,
                        child: showSumPriceOption(index),
                      ),

                      // checkOption(index),
                      // showFoodMenu(index),
                      // showAmountFood(index),
                      // showSumPriceOption(index),
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  Widget showFoodMenu(int index) => Text(subFoodModels[index].nameFood,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey));

  Widget showSumPriceOption(int index) {
    listSumOption[index] = factorPriceOption[index] * listAmountOption[index];
    //print('listSumOption ตอนเพิ่มค่า $listSumOption');

    return Text(
      '${listSumOption[index]}',
      style: MyStyle().h2StylePrimary,
    );
  }

  int indexChoose = 0;

  Widget checkOption(int index) {
    //print('isChecks ==>> $isCheckeds');
    // print('index ==>> $index');
    return Container(
      width: 80,
      child: CheckboxListTile(
        value: isCheckeds[index],
        onChanged: (value) {
          //print('You Click Index = $index');
          statusChoose = value;
          setState(() {
            isCheckeds[index] = value;

            if (value) {
              listAmountOption[index] = 1;
              total = calculatrTotal();

              idOfChoose.add(indexChoose);
              indexChoose++;

              nameOptions.add(subFoodModels[index].nameFood);
              sizeOptions.add(listAmountOption[index].toString());
              priceOptions.add(subFoodModels[index].priceFood);

              int sum = listAmountOption[index] *
                  int.parse(subFoodModels[index].priceFood);
              sumOptions.add(sum.toString());
            } else {
              listAmountOption[index] = 0;
              total = calculatrTotal();

              print('idChoose ==>> $idOfChoose');
              //print('nameOption ==>> $nameOptions');

              int y = 0;
              for (var name in nameOptions) {
                if (name == subFoodModels[index].nameFood) {
                  print('$name index ===>>> ${idOfChoose[y]}');

                  idOfChoose
                      .removeWhere((element) => (element == idOfChoose[y]));

                  nameOptions.removeAt(y);
                  sizeOptions.removeAt(y);
                  priceOptions.removeAt(y);
                  sumOptions.removeAt(y);

                  setState(() {});

                  print('idChoose 222 ==>> $idOfChoose');
                  print('nameOption 222 ==>> $nameOptions');
                }
                y++;
              }
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
                Icons.remove,
                size: 20.0,
                color: Colors.orange,
              ),
              onPressed: () {
                if (statusChoose) {
                  if (listAmountOption[index] != 0) {
                    setState(() {
                      listAmountOption[index]--;

                      int y = 0;
                      for (var name in nameOptions) {
                        if (name == subFoodModels[index].nameFood) {
                          print('y ==>> $y');
                          sizeOptions[y] = listAmountOption[index].toString();
                          int sum = listAmountOption[index] *
                              int.parse(subFoodModels[index].priceFood);
                          sumOptions[y] = sum.toString();
                        }
                        y++;
                      }

                      total = calculatrTotal();
                      if (listAmountOption[index] == 0) {
                        isCheckeds[index] = false;
                      }
                    });
                  }
                }
              },
            ),
            MyStyle().mySizeBox(),
            Text('${listAmountOption[index]}',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                )),
            MyStyle().mySizeBox(),
            IconButton(
              icon: Icon(
                Icons.add,
                size: 20.0,
                color: Colors.orange,
              ),
              onPressed: () {
                if (statusChoose) {
                  setState(() {
                    listAmountOption[index]++;

                    int y = 0;
                    for (var name in nameOptions) {
                      if (name == subFoodModels[index].nameFood) {
                        print('y ==>> $y');
                        sizeOptions[y] = listAmountOption[index].toString();
                        int sum = listAmountOption[index] *
                            int.parse(subFoodModels[index].priceFood);
                        sumOptions[y] = sum.toString();
                      }
                      y++;
                    }

                    total = calculatrTotal();
                    isCheckeds[index] = true;
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget buildBottomSheet(BuildContext context) {
    return Container(
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
            } else if (total == 0) {
              normalDialog(context, 'ยังไม่มี รายการอาหาร',
                  'กรุณาเพิ่มจำนวน รายการอาหาร');
            } else if (idUser == null) {
              normalDialog(
                  context, 'ยังไม่ได้ Login', 'กรุณา Login ก่อน Order คะ');
            } else {
              int sumPrice = 0;
              for (var num in sumOptions) {
                sumPrice = sumPrice + int.parse(num.trim());
              }

              print(
                  'idFood=$idFood, idShop=$idShop,nameShop=$nameshop, nameFood=$nameFood, urlFood=$urlFood, priceFood=$priceFood, amountFood=$amountFood');
              print(
                  'nameOption = $nameOptions, sizeOption = $sizeOptions, priceOption = $priceOptions, sumOption = $sumOptions, remark = $remake');
              print(
                  'latUser = $latChoose, lngUser = $lngChoose, nameLocal = $nameLocalChoose, latShop = $latShop, lngShop = $lngShop, sumPrice = $sumPrice, transport = $transport, distance = $distance');
              OrderModel model = OrderModel(
                  idFood: idFood,
                  idShop: idShop,
                  nameShop: nameshop,
                  nameFood: nameFood,
                  urlFood: urlFood,
                  priceFood: priceFood,
                  amountFood: amountFood.toString(),
                  nameOption: nameOptions.toString(),
                  sizeOption: sizeOptions.toString(),
                  priceOption: priceOptions.toString(),
                  sumOption: sumOptions.toString(),
                  remark: remake,
                  latUser: latChoose.toString(),
                  lngUser: lngChoose.toString(),
                  nameLocal: nameLocalChoose,
                  latShop: latShop.toString(),
                  lngShop: lngShop.toString(),
                  sumPrice: sumPrice.toString(),
                  transport: transport.toString(),
                  distance: distance);
              print('model  ======= ${model.toJson()}');
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
    );
  }

  int calculatrTotal() {
    int index = 0;
    int totalInt = 0;
    print('listAmount ===> $listAmountOption');
    print('factorPrice ===> $factorPriceOption');

    for (var j in listAmountOption) {
      int total = listAmountOption[index] * factorPriceOption[index];
      totalInt = totalInt + total;
      index++;
    }
    return totalInt;
  }
}
