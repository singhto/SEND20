import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_constant.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/sqlite_helper.dart';
import 'package:foodlion/widget/view_myfood.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class ViewShop extends StatefulWidget {
  @override
  _ViewShopState createState() => _ViewShopState();
}

class _ViewShopState extends State<ViewShop> {
  // Field
  List<UserShopModel> userShopModels = List();
  List<Widget> showWidgets = List();
  String idUser, nameLogin;
  int amount = 0;
  double lat, lng, latChoose, lngChoose;
  bool statusShowCard = false;

  bool statusLoad = true;

  bool statusDistance = true;

  // Method
  @override
  void initState() {
    super.initState();

    findLatLng();
  }

  Future<Null> findLatLng() async {
    LocationData locationData = await findLocationData();

    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;

      latChoose = lat;
      lngChoose = lng;

      readShopThread(lat, lng);

    });
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {}
      return null;
    }
  }



  Future<void> readShopThread(double lat1, double lng1) async {
    //print('ที่อ่าน $lat1, $lng1');
    String url = MyConstant().urlGetAllShop;

    statusDistance = true;
    statusLoad = true;
    statusShowCard = false;

    try {
      await Dio().get(url).then((value) {
        var result = json.decode(value.data);
        //print('result ===>>> $result');

        if (showWidgets.length != 0) {
          showWidgets.clear();
        }

        int i = 0;

        for (var map in result) {
          i++;
          UserShopModel model = UserShopModel.fromJson(map);

          double distance = MyAPI().calculateDistance(
            lat1,
            lng1,
            double.parse(model.lat.trim()),
            double.parse(model.lng.trim()),
          );

          //print('distance ===>>>>> $distance');
          //print('statusDistance ก่อน setState $statusDistance');
          //print('statusLoad ก่อน sets ==>> $statusLoad');

          var myFormat = NumberFormat('##0.0#', 'en_US');

          setState(() {
            userShopModels.add(model);
            statusLoad = false;
            if (distance <= 10.0) {
              statusDistance = false;
              //print('statusDistance หลัง setState $statusDistance');
              //print('statusLoad หลัง sets ==>> $statusLoad');
              showWidgets
                  .add(createCard(model, '${myFormat.format(distance)}'));
              statusShowCard = true;
            }
          });
        }
      });
    } catch (e) {}
  }

  Widget showImageShop2(UserShopModel model) => Container(
        child: CachedNetworkImage(
          height: 100.0,
          width: MediaQuery.of(context).size.width,
          imageUrl: model.urlShop,
          placeholder: (value, string) => MyStyle().showProgress(),
          fit: BoxFit.cover,
        ),
      );

  Widget createCard(UserShopModel model, String distance) {
    return GestureDetector(
      onTap: () {
        if (MyAPI().checkTimeShop()) {
          MaterialPageRoute route = MaterialPageRoute(
            builder: (cont) => ViewMyFood(
              idShop: model.id,
              lat: latChoose,
              lng: lngChoose,
              distance: distance,
            ),
          );
          Navigator.of(context).push(route).then((value) {});
        } else {
          normalDialog(context, 'SEND ปิดแล้ว',
              'SEND DRIVE บริการส่งเวลา 7.30- 20.00 น.');
        }
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            showImageShop2(model),
            SizedBox(
              height: 4.0,
            ),
            showName(model),
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
        MyStyle().showRatting(),
        Text(
          '$distance กม.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget showName(UserShopModel model) => Expanded(
        child: Text(model.name,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor,
              letterSpacing: 2.0,
            )),
      );

  Widget showShop() {
    //print('ขนาดของ showWinget ที่ showShop = ${showWidgets.length}');
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

  AppBar buildAppBar() {
    return AppBar(
      title: Center(
        child: GestureDetector(
          onTap: () {},
          child: Center(
            child: Text(
              'ร้านค้าในระยะ 10 กิโลเมตร',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: <Widget>[
          statusLoad
              ? MyStyle().showProgress()
              : statusShowCard
                  ? showShop()
                  : Container(
                      child: Center(
                        child: MyStyle()
                            .showTitleH2Dark('ขออภัยคะ ไม่พบร้านอาหารใกล้คุณ'),
                      ),
                    ),
        ],
      ),
    );
  }
}
