import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodlion/models/order_user_model.dart';
import 'package:foodlion/scaffold/rider_success.dart';
import 'package:foodlion/scaffold/show_cart.dart';
import 'package:foodlion/widget/add_my_food.dart';
import 'package:foodlion/widget/guest.dart';
import 'package:foodlion/widget/guestV1.dart';
import 'package:foodlion/widget/handle_shop.dart';
import 'package:foodlion/widget/info_shop.dart';
import 'package:foodlion/widget/main_home.dart';
import 'package:foodlion/widget/my_delivery.dart';
import 'package:foodlion/widget/my_delivery_his.dart';
import 'package:foodlion/widget/my_delivery_shopOrder.dart';
import 'package:foodlion/widget/my_food.dart';
import 'package:foodlion/widget/my_food_shop.dart';
import 'package:foodlion/widget/order_shop.dart';
import 'package:foodlion/widget/register_delivery.dart';
import 'package:foodlion/widget/register_shop.dart';
import 'package:foodlion/widget/register_user.dart';
import 'package:foodlion/widget/show_order_user.dart';
import 'package:foodlion/widget/signin_delivery.dart';
import 'package:foodlion/widget/signin_shop.dart';
import 'package:foodlion/widget/signin_user.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utility/my_style.dart';

class Home extends StatefulWidget {
  final Widget currentWidget;
  final int indexLogin;
  final OrderUserModel orderUserModel;
  final String nameShop;
  final int distance;
  final int transport;
  Home(
      {Key key,
      this.currentWidget,
      this.indexLogin,
      this.orderUserModel,
      this.nameShop,
      this.distance,
      this.transport})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Field
  Widget cuttentWidget = MyStyle().showProgress();
  String nameLogin, avatar, modeLogin, loginType, token, nameShop, id;
  bool statusLogin = false; //false => no login
  int amount = 0, distance, transport;
  OrderUserModel orderUserModel;
  double lat, lng;

  Location location = Location();
  bool serviceLocationEnable;
  PermissionStatus permissionStatus;

  // Method
  @override
  void initState() {
    super.initState();

    orderUserModel = widget.orderUserModel;
    nameShop = widget.nameShop;
    distance = widget.distance;
    transport = widget.transport;
    checkPermission();

    //findLatLng2();
  }



  Future<Null> checkPermission() async {
    try {
      serviceLocationEnable = await location.serviceEnabled();
      print('servcicerEnable111 =====>>> $serviceLocationEnable');
      if (!serviceLocationEnable) {
        //สภาวะที่ไม่เปิด service location
        serviceLocationEnable = await location.requestService();
        print('servcicerEnable22222 =====>>> $serviceLocationEnable');

        if (!serviceLocationEnable) {
          exit(0);
        } else {
          findLatLng2();
        }
      } else {
        findLatLng2();
      }
    } catch (e) {
      print('e checkPersion ${e.toString()}');
    }
  }

  Future<Null> findLatLng() async {
    print('################## findLatLng on Home Work $lat');

    LocationData locationData = await findLocationData();

    print(' ==>> $lat, lng ==>> $lng');

    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;

      print('latHome ==>> $lat, lng ==>> $lng');

      checkLogin();
      checkWidget();
    });
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    print('nnnn $lat');

    try {
      return await location.getLocation();
    } on PlatformException catch (e) {
      print('sssss $lat');
      if (e.code == 'PERMISSION_DENIED') {}
      return null;
    }
  }

  Future<Null> findLatLng2() async {
     LocationData locationData = await callculateFindLatLngOneTime();
     print('locationDataData $locationData');

     setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;

      print('latHome ==>> $lat, lng ==>> $lng');

      checkLogin();
      checkWidget();
    });


  }

  Future<LocationData> callculateFindLatLngOneTime() async {
    var currentLocation;
    try {
      currentLocation = (await location.getLocation());
    } catch (e) {
      print('e  calut ====>>> ${e.toString()}');
      currentLocation = null;
      if (currentLocation == null) {
        exit(0);
       
      }
    }
    return currentLocation;
  }

  void checkWidget() {
    Widget myWidget = widget.currentWidget;

    if (myWidget != null) {
      print('Widget NotNull');
      setState(() {
        cuttentWidget = myWidget;
      });
    }
  }

  Future<void> checkLogin() async {
    // print('#############CheckLogin On Home Work#############');
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      modeLogin = preferences.getString('Login');
      nameLogin = preferences.getString('Name');
      avatar = preferences.getString('UrlShop');
      loginType = preferences.getString('Login');
      id = preferences.getString('id');

      if (modeLogin == 'Shop') {
        if (!(nameLogin == null || nameLogin.isEmpty)) {
          setState(() {
            statusLogin = true;
            cuttentWidget = OrderShop();
          });
        }
      } else if (modeLogin == 'User') {
        MaterialPageRoute route = MaterialPageRoute(
          builder: (context) => MainHome(),
        );
        Navigator.pushAndRemoveUntil(context, route, (route) => false);
      } else if (modeLogin == 'Dev') {
        String url =
            'http://movehubs.com/app/getOrderWhereIdDevAnSuccess.php?isAdd=true&idDelivery=$id&Success=RiderOrder';
        Response response = await Dio().get(url);
        print('res Dev ######################===>>>> $response');

        if (response.toString() != 'null') {
          var result = json.decode(response.data);
          for (var map in result) {
            print('map = $map');

            OrderUserModel orderUserModel = OrderUserModel.fromJson(map);

            MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => RiderSuccess(
                orderUserModel: orderUserModel,
              ),
            );
            Navigator.pushAndRemoveUntil(context, route, (route) => false);
          }
        } else {
          setState(() {
            statusLogin = true;
            cuttentWidget = MyDelivery();
          });
        }
      } else {
        setState(() {
          cuttentWidget = SingInUser();
        });
      }
    } catch (e) {}
  }

  Widget showDrawer() {
    // print('modeLogin ===>>> $modeLogin');
    Widget myWidget;
    if (modeLogin == 'Shop') {
      myWidget = shopList();
    } else if (modeLogin == 'User') {
      myWidget = userList();
    } else if (modeLogin == 'Dev') {
      myWidget = deliveryList();
    } else {
      myWidget = generalList();
    }
    return Drawer(
      child: myWidget,
    );
  }

  ListView generalList() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        showHead(),
        menuGuestV1(),
        //menuHome(),
        menuSignIn(),
        menuSignUp(),
      ],
    );
  }

  ListView userList() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        showHeadUser(),
        menuHome(),
        menuShowCart(),
        menuUserOrder(),
        menuSignOut(),
      ],
    );
  }

  ListView shopList() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        showHeadShop(),
        menuOrderShop(),
        handleMenu(),
        menuInfoShop(),
        menuMyFoodShop(),
        menuAddMyFood(),
        menuSignOut(),
      ],
    );
  }

  ListView deliveryList() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        showHeadUser(),
        menuDeliveryOrder(),
        menuDeliveyShopOrder(),
        menuDeliveryHis(),
        menuSignOut(),
      ],
    );
  }

  Widget menuMyFood() {
    return ListTile(
      leading: Icon(
        Icons.restaurant_menu,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'รายการอาหาร',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'เมนูอาหารของฉัน',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          cuttentWidget = MyFood();
        });
      },
    );
  }

  Widget menuMyFoodShop() {
    return ListTile(
      leading: Icon(
        Icons.restaurant_menu,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'รายการอาหาร',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'รายการอาหารของร้าน',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        setState(() {
          cuttentWidget = MyFoodShop();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget menuAddMyFood() {
    return ListTile(
      leading: Icon(
        Icons.playlist_add,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'เพิ่ม รายการ อาหาร',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'เพิ่มข้อมูลรายการอาหารของฉัน',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          cuttentWidget = AddMyFood();
        });
      },
    );
  }

  Widget menu() {
    return ListTile(
      leading: Icon(
        Icons.android,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'text',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'sub text',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget handleMenu() {
    return ListTile(
      leading: Icon(
        Icons.room_service,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'ห้องครัว',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'รายการอาหารที่กำลังทำ...',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          cuttentWidget = HandleShop();
        });
      },
    );
  }

  Widget menuInfoShop() {
    return ListTile(
      leading: Icon(
        Icons.home,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'รายละเอียดร้าน',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'ดูรีวิว, เมนู, ตั้งค่า..',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        setState(() {
          cuttentWidget = InfoShop();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget menuUserOrder() {
    return ListTile(
      leading: Icon(
        Icons.directions_bike,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'รายการสั่งอาหาร',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'รายการสั่งอาหาร ที่รอส่ง',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        setState(() {
          cuttentWidget = ShowOrderUser();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget menuShowCart() {
    return ListTile(
      leading: Icon(
        Icons.shopping_cart,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'ตะกร้า',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'แสดงรายการสินค้า ที่มีใน ตะกร้า',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        routeToShowCart();
      },
    );
  }

  Widget menuOrderShop() {
    return ListTile(
      leading: Icon(
        Icons.playlist_add_check,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'รับออเดอร์',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'รอรับออเดอร์จากลูกค้า',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          cuttentWidget = OrderShop();
        });
      },
    );
  }

  Widget menuDeliveryOrder() {
    return ListTile(
      leading: Icon(
        Icons.assignment_late,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'HOME',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'รายการอาหารที่ร้านยังไม่ได้กดรับ',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          cuttentWidget = MyDelivery();
        });
      },
    );
  }

  Widget menuDeliveyShopOrder() {
    return ListTile(
      leading: Icon(
        Icons.playlist_add_check,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'SHOP ORDER',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'รายการอาหารที่ร้านกดรับออเดอร์',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          cuttentWidget = MyDeliveryShopOrder();
        });
      },
    );
  }

  Widget menuDeliveryHis() {
    return ListTile(
      leading: Icon(
        Icons.access_time,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'ประวัติการส่ง',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'รายการส่งอาหารของคุณ',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          cuttentWidget = MyDeliveryHis();
        });
      },
    );
  }

  Widget menuSignOut() {
    return ListTile(
      leading: Icon(
        Icons.exit_to_app,
        color: MyStyle().dartColor,
        size: 36.0,
      ),
      title: Text(
        'ออกจากระบบ',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'กดที่นี่ เพื่อออกจากระบบ',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        // Navigator.of(context).pop();
        signOutProcess();
      },
    );
  }

  Future<void> signOutProcess() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.clear();

      // exit(0);

      MaterialPageRoute route = MaterialPageRoute(builder: (value) => Home());
      Navigator.of(context).pushAndRemoveUntil(route, (value) => false);
    } catch (e) {}
  }

  Widget menuSignUp() {
    return ListTile(
      leading: iconSignUp(),
      title: Text(
        'สมัครใช้บริการ',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'คลิกเพื่อสมัครใช้บริการ',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        chooseRegister('สมัครสมาชิก', true);
      },
    );
  }

  Icon iconSignUp() {
    return Icon(
      Icons.system_update,
      size: 36,
      color: MyStyle().dartColor,
    );
  }

  Widget menuSignIn() {
    return ListTile(
      leading: iconSignIn(),
      title: Text(
        'เข้าสู่ระบบ',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'กรุณาเข้าสู่ระบบก่อน',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        Navigator.of(context).pop();
        chooseRegister('เข้าสู่ระบบ', false);
      },
    );
  }

  Icon iconSignIn() {
    return Icon(
      Icons.fingerprint,
      size: 36.0,
      color: MyStyle().dartColor,
    );
  }

  Widget showButtom(bool registerBool) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 80.0,
          width: 200.0,
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (registerBool) {
                    setState(() {
                      cuttentWidget = RegisterUser();
                    });
                  } else {
                    setState(() {
                      cuttentWidget = SingInUser();
                    });
                  }
                  Navigator.of(context).pop();
                },
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.touch_app,
                      size: 30.0,
                    ),
                    title: Text(
                      'สั่งอาหาร',
                      style: MyStyle().h2StylePrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 80.0,
          width: 200.0,
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (registerBool) {
                    setState(() {
                      cuttentWidget = RegisterShop();
                    });
                  } else {
                    setState(() {
                      cuttentWidget = SignInshop();
                    });
                  }
                  Navigator.of(context).pop();
                },
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.store_mall_directory,
                      size: 30.0,
                    ),
                    title: Text(
                      'ขายอาหาร',
                      style: MyStyle().h2StylePrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
            height: 80.0,
            width: 200.0,
            child: ListView(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (registerBool) {
                      setState(() {
                        cuttentWidget = RegisterDelivery();
                      });
                    } else {
                      setState(() {
                        cuttentWidget = SignDelivery();
                      });
                    }
                    Navigator.of(context).pop();
                  },
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.directions_bike,
                        size: 30.0,
                      ),
                      title: Text(
                        'ส่งอาหาร',
                        style: MyStyle().h2StylePrimary,
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Future<void> chooseRegister(String title, bool registerBool) async {
    showDialog(
      context: context,
      builder: (value) => AlertDialog(
        title: ListTile(
          title: Center(
            child: Text(
              '$title',
              style: MyStyle().h1Style,
            ),
          ),
        ),
        content: showButtom(registerBool),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'ปิด',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget menuHome() {
    return ListTile(
      leading: Icon(
        Icons.pin_drop,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'แผนที่',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'ร้านค้ามากมายบนแผนที่',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        setState(() {
          Navigator.of(context).pop();
          cuttentWidget = Guest();
        });
      },
    );
  }

  Widget menuGuestV1() {
    return ListTile(
      leading: Icon(
        Icons.fastfood,
        size: 36.0,
        color: MyStyle().dartColor,
      ),
      title: Text(
        'ร้านค้า',
        style: MyStyle().h2Style,
      ),
      subtitle: Text(
        'ร้านค้าในรัศมี 10 กม.',
        style: MyStyle().h3StylePrimary,
      ),
      onTap: () {
        setState(() {
          Navigator.of(context).pop();
          cuttentWidget = GuestV1();
        });
      },
    );
  }

  Widget showLogo() {
    return Container(
      height: 80.0,
      width: 80.0,
      child: Image.asset('images/logo_1024.png'),
    );
  }

  Widget showHead() {
    // print('nameLogin ==>>> $nameLogin');
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/bic3.png'), fit: BoxFit.cover),
      ),
      currentAccountPicture: showLogo(),
      accountName: Text(
        'Guest',
        style: MyStyle().h2StyleWhite,
      ),
      accountEmail: Text('Login'),
    );
  }

  Widget showHeadUser() {
    // print('nameLogin ==>>> $nameLogin');
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/bic3.png'), fit: BoxFit.cover),
      ),
      currentAccountPicture: showLogo(),
      accountName: Text(
        nameLogin,
        style: MyStyle().h2StyleWhite,
      ),
      accountEmail: Text('Login'),
    );
  }

  Widget showHeadShop() {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/bic4.png'), fit: BoxFit.cover),
      ),
      currentAccountPicture: showLogo(),
      accountName: Text(
        nameLogin,
        style: MyStyle().h2StyleWhite,
      ),
      accountEmail: Text('Login'),
    );
  }

  Widget showAvatar() => CircleAvatar(
        backgroundImage: NetworkImage(avatar),
      );

  Widget showCart() {
    return loginType == 'User'
        ? GestureDetector(
            onTap: () {
              routeToShowCart();
            },
            child: MyStyle().showMyCart(amount),
          )
        : MyStyle().mySizeBox();
  }

  void routeToShowCart() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (value) => ShowCart());
    Navigator.of(context).push(materialPageRoute).then((value) => checkLogin());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: showDrawer(),
      appBar: AppBar(
        title: Text(
          'SEND',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 3.0,
          ),
        ),
      ),
      body: cuttentWidget,
    );
  }
}
