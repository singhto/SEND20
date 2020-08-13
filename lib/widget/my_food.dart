import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
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
  final String nameLocalChoose, distance;
  final double lat;
  final double lng;


  MyFood(
      {Key key,
      this.idShop,
      this.nameLocalChoose,
      this.lat,
      this.lng,
      this.distance})
      : super(key: key);
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
  String nameShop, nameLocalChoose, distance;
  double latChoose, lngChoose;

  UserShopModel myUserShopModel;
  int transportInt;

  // Method
  @override
  void initState() {
    super.initState();

    myIdShop = widget.idShop;
    nameLocalChoose = widget.nameLocalChoose;
    latChoose = widget.lat;
    lngChoose = widget.lng;
    distance = widget.distance;

    readAllFood();
    checkAmount();
    calculateTransportFromDistance();
  }

  Future<Null> calculateTransportFromDistance () async {

    print('distance  ==== ==  $distance');

    double distanceDou = double.parse(distance);
    int distanceInt = distanceDou.ceil();

    int i = await MyAPI().checkTransport(distanceInt);

    print('i ###### $i');
    setState(() {
      transportInt = i;
    });
  }

  Future<void> checkAmount() async {
    //print('checkAmount Work');
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

    // myUserShopModel = await MyAPI().findDetailShopWhereId(idShop);

    if (myIdShop != null) {
      idShop = myIdShop;
    }

    print('idShop ===> $idShop');
    myUserShopModel = await MyAPI().findDetailShopWhereId(idShop);


    print('idshop $idShop, url === ${myUserShopModel.urlShop}');

    String url =
        'http://movehubs.com/app/getFoodWhereIdShop.php?isAdd=true&idShop=$idShop';

    Response response = await Dio().get(url);
    // print('response ===>> $response');

    if (response.toString() != 'null') {
      var result = json.decode(response.data);
      // print('result ===>>> $result');

      for (var map in result) {
        FoodModel model = FoodModel.fromJson(map);
        print('mappppp ==== $map');

        if (nameShop == null) {
          nameShop = await MyAPI().findNameShopWhere(model.idShop);
        }
        userShopModel = UserShopModel.fromJson(map);
        
        print('url Image = ${userShopModel.urlShop}');

        setState(() {
          foodModels.add(model);
          searchFoodModels = foodModels;

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
          infoShop(),
          showSearch(),
          listMenuFood(),
        ],
      ),
    );
  }

  ListView listMenuFood() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: searchFoodModels.length,
      itemBuilder: (value, index) {
        return showContent(index);
      },
    );
  }

  Padding showSearch() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        margin: EdgeInsets.only(top: 5, bottom: 5),
        //width: 250.0,
        child: TextField(
          onChanged: (value) {
            dedouncer.run(() {
              setState(() {
                searchFoodModels = foodModels.where((FoodModel foodModel) {
                  return (foodModel.nameFood
                      .toLowerCase()
                      .contains(value.toLowerCase()));
                }).toList();
              });
            });
          },
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                size: 30.0,
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                      width: 0.8, color: Theme.of(context).primaryColor)),
              hintText: 'ค้นหารายการอาหาร'),
        ),
      ),
    );
  }

  Widget showContent(int index) {
    return GestureDetector(
      onTap: () {
        MaterialPageRoute route = MaterialPageRoute(
          builder: (value) => ShowFood(
            foodModel: searchFoodModels[index],
            nameLocalChoose: nameLocalChoose,
            lat: latChoose,
            lng: lngChoose,
            distance: distance,
            transportInt: transportInt,
          ),
        );
        Navigator.of(context).push(route).then(
              (value) => checkAmount(),
            );
      },
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
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
                showImagefood(index),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          searchFoodModels[index].nameFood,
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
                          searchFoodModels[index].detailFood,
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 4.0,
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

  Widget showImagefood(int index) => ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: CachedNetworkImage(
          height: 100.0,
          width: 100.0,
          imageUrl: searchFoodModels[index].urlFood,
          placeholder: (value, string) => MyStyle().showProgress(),
          fit: BoxFit.cover,
        ),
      );

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
        title: Text('ร้าน$nameShop'),
        actions: <Widget>[showCart()],
      ),
      body: statusData ? showNoData() : showListFood(),
    );
  }

  Widget infoShop() {
    return Column(
      children: [
        showImageShop(),
        Text('ระยะ $distance'),
        Text('สถานที่ส่ง $nameLocalChoose'),
        Text(transportInt == null ?'' : 'ค่าขนส่ง $transportInt'),
      ],
    );
  }

  Widget showImageShop() => Container(
        width: 100,
        child: myUserShopModel == null
            ? MyStyle().showProgress()
            : CachedNetworkImage(
                imageUrl: myUserShopModel.urlShop,
                placeholder: (context, url) => MyStyle().showProgress(),
                errorWidget: (context, url, error) => Center(
                  child: Text('ไม่มีรูปภาพ'),
                ),
              ),
      );
}
