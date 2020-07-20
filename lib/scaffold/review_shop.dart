import 'package:flutter/material.dart';
import 'package:foodlion/utility/my_style.dart';

class ReviewShop extends StatefulWidget {
  @override
  _ReviewShopState createState() => _ReviewShopState();
}

class _ReviewShopState extends State<ReviewShop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('คะแนนของร้าน'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.star,
                        size: 30.0,
                        color: Colors.grey,
                      ),
                      Icon(
                        Icons.star,
                        size: 30.0,
                        color: Colors.grey,
                      ),
                      Icon(
                        Icons.star,
                        size: 30.0,
                        color: Colors.grey,
                      ),
                      Icon(
                        Icons.star,
                        size: 30.0,
                        color: Colors.grey,
                      ),
                      Icon(
                        Icons.star,
                        size: 30.0,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    'ยังไม่มีรีวิวครับ',
                    style: MyStyle().h1Style
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
