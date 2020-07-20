import 'package:flutter/material.dart';
import 'package:foodlion/scaffold/home.dart';
import 'package:foodlion/utility/my_style.dart';

class RegisterShopSuccess extends StatefulWidget {
  @override
  _RegisterShopSuccessState createState() => _RegisterShopSuccessState();
}

class _RegisterShopSuccessState extends State<RegisterShopSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(child: Text('สมัครสำเร็จ')),
          leading: IconButton(
              icon: Icon(
                Icons.home,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Home()));
              })),
      body: Container(
        alignment: FractionalOffset.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.assignment_turned_in,
              size: 60.0,
              color: Theme.of(context).primaryColor,
            ),
            MyStyle().mySizeBox(),
            Text('ขอบคุณที่ร่วมเป็นส่วนหนึ่งกับ SEND',
                style: MyStyle().h1PrimaryStyle),
            Text(
              'เราจะติดต่อกลับภายใน 24 ชั่วโมง',
              style: MyStyle().h2NormalStyle,
            ),
            MyStyle().mySizeBox(),
          ],
        ),
      ),
    );
  }
}
