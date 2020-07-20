import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/banner_model.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/utility/find_token.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_constant.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/normal_toast.dart';
import 'package:foodlion/utility/sqlite_helper.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'my_food.dart';

class GuestV1 extends StatefulWidget {
  final double lat, lng;
  GuestV1({Key key, this.lat, this.lng}) : super(key: key);

  @override
  _GuestV1State createState() => _GuestV1State();
}

class _GuestV1State extends State<GuestV1> {
  List<UserShopModel> userShopModels = List();
  List<Widget> showWidgets = List();
  List<BannerModel> bannerModels = List();
  List<Widget> showBanners = List();
  String idUser, nameLogin;
  int amount = 0;
  double lat, lng;

  @override
  void initState() {
    super.initState();

    lat = widget.lat;
    lng = widget.lng;

    if (lat == null) {
      findLatLng();
    }

    findLatLng();
  }

  Future<Null> findLatLng() async {
    LocationData locationData = await findLocationData();
    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;
      print('lat ==>> $lat, lng ==>> $lng');
      readBanner();
      readShopThread();
      checkAmount();
      findUser();
    });
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  Widget showImageShop(UserShopModel model) {
    return Container(
      width: 80.0,
      height: 80.0,
      child: CircleAvatar(
        backgroundImage: NetworkImage(model.urlShop),
      ),
    );
  }

  Text showName(UserShopModel model) => Text(
        model.name,
        style: MyStyle().h2Style,
      );

  Widget createCard(UserShopModel model, String distance) {
    return GestureDetector(
      onTap: () {
        //print('You Click ${model.id}');

      
          normalDialog(context, 'เปิดทำการ 23 ก.ค.นี้ครับ',
              'โหลดแอพ SEND อีกครั้งหลังเปิดทำการ เพื่อใช้งาน ขอบคุณครับ');
        
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            showImageShop(model),
            Expanded(child: showName(model)),
            showDistance(distance),
          ],
        ),
      ),
    );
  }

  Widget showDistance(String distance) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.star,
              size: 14.0,color: Colors.yellow.shade400,
            ),
            Icon(
              Icons.star,
              size: 14.0,color: Colors.yellow.shade400,
            ),
            Icon(
              Icons.star,
              size: 14.0,color: Colors.yellow.shade400,
            ),
            Icon(
              Icons.star,
              size: 14.0,color: Colors.yellow.shade400,
            ),
            Icon(
              Icons.star,
              size: 14.0,color: Colors.yellow.shade400,
            ),

          ],
        ),
        Text('$distance Km.'),
      ],
    );
  }

  Future<void> readShopThread() async {
    String url = MyConstant().urlGetAllShop;

    try {
      Response response = await Dio().get(url);
      var result = json.decode(response.data);
      // print('result ===>>> $result');

      for (var map in result) {
        UserShopModel model = UserShopModel.fromJson(map);

        double distance = MyAPI().calculateDistance(
          lat,
          lng,
          double.parse(model.lat.trim()),
          double.parse(model.lng.trim()),
        );

        var myFormat = NumberFormat('##0.0#', 'en_US');

        setState(() {
          userShopModels.add(model);
          if (distance <= 10.0) {
            showWidgets.add(createCard(model, '${myFormat.format(distance)}'));
          }
        });
      }
    } catch (e) {}
  }

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nameLogin = preferences.getString('Name');
    });
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

  Widget showBanner() {
    return showBanners.length == 0
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: MyStyle().showProgress()),
          )
        : CarouselSlider(
            items: showBanners,
            enlargeCenterPage: true,
            aspectRatio: 16 / 7.5,
            pauseAutoPlayOnTouch: Duration(seconds: 2),
            autoPlay: true,
            autoPlayAnimationDuration: Duration(seconds: 2),
          );
  }

  Widget createBanner(BannerModel model) {
    return CachedNetworkImage(imageUrl: model.pathImage);
  }

  Future<void> readBanner() async {
    String url = MyConstant().urlGetAllBanner;
    try {
      Response response = await Dio().get(url);
      var result = json.decode(response.data);
      for (var map in result) {
        BannerModel model = BannerModel.fromJson(map);
        Widget bannerWieget = createBanner(model);
        setState(() {
          bannerModels.add(model);
          showBanners.add(bannerWieget);
        });
      }
    } catch (e) {}
  }

  Future<Null> editToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idUser = preferences.getString('id');

    if (idUser != null) {
      String token = await findToken();
      print('from Guest idUser = $idUser, token = $token');

      String url =
          'http://movehubs.com/app/editTokenUserWhereId.php?isAdd=true&id=$idUser&Token=$token';
      Response response = await Dio().get(url);
      if (response.toString() == 'true') {
        normalToast('อัพเดทตำแหน่งใหม่ สำเร็จ');
      }
    }
  }

  Widget showShop() {
    return showWidgets.length == 0
        ? MyStyle().showProgress()
        : Expanded(
            child: GridView.extent(
              mainAxisSpacing: 3.0,
              crossAxisSpacing: 3.0,
              maxCrossAxisExtent: 260.0,
              children: showWidgets,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('ร้านอาหารใกล้คุณ...'),
      // ),
      body: Column(
        children: <Widget>[
          showBanner(),
          //MyStyle().showTitle('ร้านอาหารใกล้คุณ'),
          showShop(),
        ],
      ),
    );
  }
}
