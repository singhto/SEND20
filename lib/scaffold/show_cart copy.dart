import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/delivery_model.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/models/user_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/scaffold/home.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/normal_toast.dart';
import 'package:foodlion/utility/sqlite_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowCart extends StatefulWidget {
  final double lat, lng;
  ShowCart({Key key, this.lat, this.lng}) : super(key: key);
  @override
  _ShowCartState createState() => _ShowCartState();
}

class _ShowCartState extends State<ShowCart> {
  // Filed
  List<OrderModel> orderModels = List();
  //List<String> nameShops = List();
  List<UserShopModel> userShopModels = List();
  List<int> idShopOnSQLites = List();
  List<int> transports = List();
  List<String> distances = List();
  List<int> sumTotals = List();

  double latUser, lngUser;

  UserModel userModel;
  UserShopModel userShopModel;

  int totalPrice = 0, totalDelivery = 0, sumTotal = 0;
  String phone;
  String remake = '';

  String myDistance;

  List<List<String>> listNameOptions = List();
  List<List<String>> listPriceOptions = List();
  List<List<String>> listSizeOptions = List();
  List<List<String>> listSumOptions = List();
  List<List<String>> listTransportOptions = List();
  List<List<String>> sumOptions = List();
  List<List<String>> listSumOptions2 = List();

  // Method
  @override
  void initState() {
    super.initState();

    latUser = widget.lat;
    lngUser = widget.lng;

    findLocationUser();
  }

  Future<void> findLocationUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');
    //print('idUser = $idUser');

    String url =
        'http://movehubs.com/app/getUserWhereId.php?isAdd=true&id=$idUser';
    Response response = await Dio().get(url);
    var result = json.decode(response.data);
    for (var map in result) {
      // print('map ==> $map');
      userModel = UserModel.fromJson(map);
      readSQLite();
    }
  }

  Future<void> readSQLite() async {
    if (orderModels.length != 0) {
      orderModels.clear();
      totalPrice = 0;
      totalDelivery = 0;

      sumTotal = 0;
    }

    try {
      var object = await SQLiteHelper().readDatabase();
      print("แสดงจำนวน Record SQLite ==>> ${object.length}");
      if (object.length != 0) {
        orderModels = object;

        for (var model in orderModels) {
          String string = model.nameOption;
          string = string.substring(1, string.length - 1);
          List<String> nameOptions = string.split(',');
          int index = 0;
          for (var string1 in nameOptions) {
            nameOptions[index] = string1.trim();

            index++;
          }

          String price = model.priceOption;
          price = price.substring(1, price.length - 1);
          List<String> priceOptions = price.split(',');
          int indexPrice = 0;
          for (var string1 in priceOptions) {
            priceOptions[indexPrice] = string1.trim();

            indexPrice++;
          }

          String size = model.sizeOption;
          size = size.substring(1, size.length - 1);
          List<String> sizeOptions = size.split(',');
          int indexsize = 0;
          for (var string1 in sizeOptions) {
            sizeOptions[indexsize] = string1.trim();

            indexsize++;
          }

          String sum = model.sumOption;
          sum = sum.substring(1, sum.length - 1);
          List<String> sumOptions = sum.split(',');
          int indexsum = 0;
          for (var string1 in sumOptions) {
            sumOptions[indexsum] = string1.trim();

            indexsum++;
          }

          String sumPrice = model.sumPrice;
          sumPrice = sumPrice.substring(1, sumPrice.length - 1);
          List<String> sumPrices = sumPrice.split(',');
          int indexprice = 0;
          for (var string1 in sumPrices) {
            sumPrices[indexprice] = string1.trim();

            indexprice++;
          }

          List<String> transports = size.split(',');
          int indextransports = 0;
          for (var string1 in transports) {
            transports[indextransports] = string1.trim();

            indextransports++;
          }

          setState(() {
            listNameOptions.add(nameOptions);
            listPriceOptions.add(priceOptions);
            listSizeOptions.add(sizeOptions);
            listSumOptions.add(sumPrices);
            listTransportOptions.add(transports);
            listSumOptions2.add(sumOptions);
          });
        }

        totalDelivery = int.parse(orderModels[0].transport);

        myDistance = orderModels[0].distance;

        for (var model in orderModels) {
          totalPrice = totalPrice + (int.parse(model.sumPrice));
          findLatLngShop(model);
          sumTotal = totalPrice;
        }
      }
    } catch (e) {
      //print('e readSQLite ==>> ${e.toString()}');
    }
  }

  Future<void> findLatLngShop(OrderModel orderModel) async {
    Map<String, dynamic> map = Map();
    map = await MyAPI().findLocationShopWhere(orderModel.idShop);
    // print('map =====>>>>>>> ${map.toString()}');

    setState(() {
      userShopModel = UserShopModel.fromJson(map);
      userShopModels.add(userShopModel);

      double lat1 = latUser;
      double lng1 = lngUser;
      //print('lat1, lng1 ===>>>>>>> $lat1,$lng1');

      if (lat1 == null) {
        lat1 = double.parse(userModel.lat);
        lng1 = double.parse(userModel.lng);
      }

      double lat2 = double.parse(userShopModel.lat);
      double lng2 = double.parse(userShopModel.lng);

      int indexOld = 0;

      int index = int.parse(orderModel.idShop);
      if (checkMemberIdShop(index)) {
        checkMemberTrue(orderModel, indexOld, index, lat1, lng1, lat2, lng2);
      } else {
        transports.add(0);
        distances.add('');
      }
    });
  }

  Future<Null> checkMemberTrue(OrderModel orderModel, int indexOld, int index,
      double lat1, double lng1, double lat2, double lng2) async {
    idShopOnSQLites.add(int.parse(orderModel.idShop));
    indexOld = index;
    //print('Work indexOld ===>>> $indexOld');

    double distance = MyAPI().calculateDistance(lat1, lng1, lat2, lng2);
    //print('distance ############==>>>>> $distance');

    // print('distanceAint = $distanceAint');

    var myFormat = NumberFormat('##0.0#', 'en_US');
    String distanceString = myFormat.format(distance);
    distances.add(distanceString);

    int distanceAint = distance.round();

    int transport = await MyAPI().checkTransport(distanceAint);

    //print('transport ===>>> $transport');
    setState(() {
      transports.add(transport);
      sumTotals.add(transport);
      //totalDelivery = totalDelivery + transport;
      sumTotal = sumTotal + totalDelivery;
    });
  }

  bool checkMemberIdShop(int idShop) {
    bool result = true;
    for (var member in idShopOnSQLites) {
      if (member == idShop) {
        result = false;
        return result;
      }
    }
    return result;
  }

  Column showContent() {
    return Column(
      children: <Widget>[
        showListCart(),
        showBottom(),
      ],
    );
  }

  Future<void> confirmDialog(BuildContext context, String title, String message,
      {Icon icon}) async {
    if (icon == null) {
      icon = Icon(
        Icons.question_answer,
        size: 36,
        color: MyStyle().dartColor,
      );
    }
    showDialog(
      context: context,
      builder: (value) => AlertDialog(
        title: showTitle(title, icon),
        content: Text(
          message,
          style: MyStyle().h2StylePrimary,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              //print('Confirm Here');
              if (MyAPI().checkTimeShop()) {
                Navigator.of(context).pop();
                orderThread();
              } else {
                Navigator.of(context).pop();
                normalDialog(
                    context, 'ร้านปิดครับ', 'อยู่นอกเวลาทำการครับ ร้านปิด');
              }
            },
            child: Text(
              'ยืนยัน',
              style: MyStyle().h2Style,
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'ยกเลิก',
              style: MyStyle().h2Style,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> orderThread() async {
    DateTime dateTime = DateTime.now();
    List<String> idFoods = List();
    List<String> amountFoods = List();
    List<String> remarks = List();
    String tokenShop,
        remarke,
        latUser,
        lngUser,
        nameLocal,
        transportSQLite,
        distanceSQLite,
        nameOption,
        sizeOption,
        priceOption,
        sumPrice,
        transport;

    UserShopModel userShopModel =
        await MyAPI().findDetailShopWhereId(idShopOnSQLites[0].toString());
    tokenShop = userShopModel.token;

    for (var model in orderModels) {
      idFoods.add(model.idFood);
      amountFoods.add(model.amountFood);
      remarks.add(model.remark);
      latUser = model.latUser;
      lngUser = model.lngUser;
      nameLocal = model.nameLocal;
      transportSQLite = model.transport;
      distanceSQLite = model.distance;
      nameOption = model.nameOption;
      sizeOption = model.sizeOption;
      priceOption = model.priceOption;
      sumPrice = model.sumPrice;
      transport = model.transport;
    }

    String url =
        'http://movehubs.com/app/addOrder3.php?isAdd=true&idUser=${userModel.id}&idShop=${idShopOnSQLites[0]}&DateTime=$dateTime&idFoods=${idFoods.toString()}&amountFoods=${amountFoods.toString()}&totalDelivery=$totalDelivery&totalPrice=$totalPrice&sumTotal=$sumTotal&remarke=${remarks.toString()}&latUser=${latUser.toString()}&lngUser=${lngUser.toString()}&nameLocal=$nameLocal&distance=$distanceSQLite&nameOption=$nameOption&sizeOption=$sizeOption&priceOption=$priceOption&sumPrice=$sumPrice&transport=$transport';

    //print('========= url ===== $url');

    Response response = await Dio().get(url);
    if (response.toString() == 'true') {
      //print(' amoutFood ===>> $amountFoods remarke ==>> $remarke  latUser ==>> $latUser lngUser ==>> $lngUser nameLocal==>> $nameLocal');
      //print('===============.....Success Order');

      await SQLiteHelper().deleteSQLiteAll().then((value) {
        MyAPI().notificationAPI(
            tokenShop, 'มีรายการอาหารจาก SEND', 'มีรายการอาหารสั่งมา คะ');
        notiToRider();
        Navigator.of(context).pop();
        routeToOrderUser();
        normalToast('สั่งอาหารสำเร็จ');
      });
    } else {
      normalDialog(context, 'มีความผิดปกติ',
          'กรุณาทิ้งไว้สักครู่ แล้วค่อย Confirm Order ใหม่ คะ');
    }
  }

  ///end Thard

  void routeToOrderUser() {
    // MaterialPageRoute materialPageRoute =
    //     MaterialPageRoute(builder: (value) => ShowOrderUser());
    // Navigator.of(context).push(materialPageRoute);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
        (route) => false);
  }

  Future<Null> notiToRider() async {
    String urlGetAllOrderStatus0 = 'http://movehubs.com/app/getAllRider.php';
    Response response = await Dio().get(urlGetAllOrderStatus0);

    var result = json.decode(response.data);
    for (var map in result) {
      DelivaryModel delivaryModel = DelivaryModel.fromJson(map);

      if (delivaryModel.token.isNotEmpty) {
        // print('Sent Token to in aaaaa ===>> ${delivaryModel.token}');
        MyAPI().notificationAPI(
            delivaryModel.token,
            'มีรายการสั่งอาหารของร้าน${userShopModel.name}',
            'ลูกค้า SEND สั่งอาหารครับ');
      }
    }
  }

  Widget showSum(String title, String message, Color color) {
    return Container(
      decoration: BoxDecoration(color: color),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: MyStyle().hiStyleWhite,
                ),
                Text(
                  message,
                  style: MyStyle().hiStyleWhite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showBottom() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          showSum('รวมค่าอาหาร', totalPrice.toString(), MyStyle().lightColor),
          showSum('ค่าส่ง ($myDistance กม.)', totalDelivery.toString(),
              MyStyle().lightColor),
          showSum('รวม', sumTotal.toString(), MyStyle().primaryColor),
          Center(
            child: OutlineButton(
              onPressed: () async {
                await MyAPI()
                    .findPhone(userModel.id.toString(), 'User')
                    .then((phone) {
                  if (phone == 'null') {
                    phoneForm();
                  } else {
                    //confirmDialog(context, 'ยืนยัน', 'กรุณายืนยันออร์นี้ครับ');
                    orderThread();
                  }
                });
              },
              textColor: Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.send,
                      color: Colors.orange,
                    ),
                    Text(
                      '  ยืนยันสั่งซื้อ   ',
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                          color: Colors.orange[700]),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget showListCart() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: orderModels.length,
                itemBuilder: (value, index) => Container(
                  decoration: BoxDecoration(
                      color:
                          index % 2 == 0 ? Colors.grey.shade300 : Colors.white),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              orderModels[index].nameFood,
                              style: MyStyle().h2Stylegrey,
                            ),
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.delete_forever,
                                color: MyStyle().dartColor,
                              ),
                              onPressed: () {
                                confirmAnDelete(orderModels[index]);
                              }),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: listNameOptions[index].length,
                        itemBuilder: (context, index2) => Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  listNameOptions[index][index2],
                                  style: MyStyle().h2StylegreyNormal,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                listPriceOptions[index][index2],
                                style: MyStyle().h2StylegreyNormal,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                listSizeOptions[index][index2],
                                style: MyStyle().h2StylegreyNormal,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                listSumOptions2[index][index2],
                                style: MyStyle().h2StylegreyNormal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            orderModels[index].remark,
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> confirmAnDelete(OrderModel model) async {
    //print('id delete ==>>> ${model.id}');
    showDialog(
      context: context,
      builder: (value) => AlertDialog(
        title: Text('ยื่นยันการลบ',style: MyStyle().h1PrimaryStyle,),
        content: Text('คุณต้องการลบ ${model.nameFood}',style: MyStyle().h2StylegreyNormal,),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              processDelete(model.id);
            },
            child: Text('ยืนยันลบ',style: MyStyle().h2Stylered,),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('ไม่ลบ',style: MyStyle().h2Stylegrey,),
          ),
        ],
      ),
    );
  }

  Future<void> processDelete(int id) async {
    await SQLiteHelper().deleteSQLiteWhereId(id).then((value) {
      setState(() {
        readSQLite();
      });
    });
  }

  String calculateTotal(String price, String amount) {
    int princtInt = int.parse(price);
    int amountInt = int.parse(amount);
    int total = princtInt * amountInt;

    return total.toString();
  }

  Future<Null> phoneForm() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('กรุณากรอกเบอร์ติดต่อ เพื่อสะดวกต่อ คนส่งของ'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150,
                child: TextField(
                  onChanged: (value) => phone = value.trim(),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'เบอร์ติดต่อ :',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 200.0,
                child: RaisedButton.icon(
                  onPressed: () {
                    if (phone == null || phone.isEmpty) {
                      normalToast('เบอร์ติดต่อห้ามว่างเปล่า');
                    } else if (phone.length == 10) {
                      MyAPI().addPhoneThread(
                          userModel.id.toString(), 'User', phone);
                      orderThread();
                      routeToOrderUser();
                      //Navigator.pop(context);
                    } else {
                      normalToast('กรุณากรอกเบอร์ ให้ครบ ห้ามมีช่องว่าง ');
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text('บันทึก'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'อาหารในตะกร้า',
          style: MyStyle().h2StyleWhite,
        ),
      ),
      body: orderModels.length == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart,
                    color: Colors.grey,
                    size: 60,
                  ),
                  MyStyle().mySizeBox(),
                  Text(
                    'ไม่มีรายการอาหารในตะกร้า',
                    style: MyStyle().h2Stylegrey
                  ),
                ],
              ),
            )
          : showContent(),
    );
  }
}
