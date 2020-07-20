import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/scaffold/review_shop.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/widget/my_food_shop.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoShop extends StatefulWidget {
  @override
  _InfoShopState createState() => _InfoShopState();
}

class _InfoShopState extends State<InfoShop> {
  UserShopModel userShopModel;
  String id, idFood, nameFood, urlFood, priceFood, detailFood, status;
  bool isSwitched = false;

  @override
  void initState() {
    super.initState();
    findShop();
    //status = userShopModel.status;
  }

  Future<Null> updateShopStatus() async {
    
    String url =
        'http://movehubs.com/app/updateShopStatus.php?isAdd=true&id=$id&status=$status';
    Response response = await Dio().get(url);
  }

  Future<Null> findShop() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');
    print('idShop = $idShop');

    try {
      var object = await MyAPI().findDetailShopWhereId(idShop);
      setState(() {
        userShopModel = object;
      });
    } catch (e) {}
  }

  Marker yourLocation() {
    return Marker(
        markerId: MarkerId('myLoaction'),
        position: LatLng(
          double.parse(userShopModel.lat),
          double.parse(userShopModel.lng),
        ),
        infoWindow: InfoWindow(title: userShopModel.name));
  }

  Set<Marker> myMarker() {
    return <Marker>[yourLocation()].toSet();
  }

  Container showMap() {
    LatLng latLng = LatLng(
        double.parse(userShopModel.lat), double.parse(userShopModel.lng));
    CameraPosition position = CameraPosition(target: latLng, zoom: 16);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200.0,
      child: GoogleMap(
        initialCameraPosition: position,
        onMapCreated: (controller) {},
        markers: myMarker(),
      ),
    );
  }

  Container showImage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Image.network(
        userShopModel.urlShop,
        fit: BoxFit.cover,
        height: 220.0,
      ),
    );
  }

  Padding showDetailShop() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                userShopModel.name,
                style: MyStyle().h1PrimaryStyle,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(
                    Icons.star,
                    size: 16.0,
                    color: Colors.yellow.shade600,
                  ),
                  Icon(
                    Icons.star,
                    size: 16.0,
                    color: Colors.yellow.shade600,
                  ),
                  Icon(
                    Icons.star,
                    size: 16.0,
                    color: Colors.yellow.shade600,
                  ),
                  Icon(
                    Icons.star,
                    size: 16.0,
                    color: Colors.yellow.shade600,
                  ),
                  Icon(
                    Icons.star,
                    size: 16.0,
                    color: Colors.yellow.shade600,
                  ),
                ],
              ),
            ],
          ),
          //RatingStars(),
          SizedBox(
            height: 3.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'พิกัด : ${userShopModel.lat}, ${userShopModel.lng}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    'ที่อยู่ : ${userShopModel.addressShop}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
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
            ],
          ),
          SizedBox(
            height: 3.0,
          ),
        ],
      ),
    );
  }

  Row editShop(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ReviewShop()));
          },
          child: Text(
            'รีวิว',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        FlatButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyFoodShop()));
          },
          child: Text(
            'เมนูอาหาร',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pushNamed(context, '/settime');
          },
          child: Text(
            'กำหนดเวลา',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        SizedBox(
          height: 6.0,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 250.0,
      child: userShopModel == null
          ? MyStyle().showProgress()
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  showImage(),
                  showDetailShop(),
                  showMap(),
                  editShop(context),
                ],
              ),
            ),
    );
  }
}
