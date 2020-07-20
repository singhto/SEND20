import 'package:flutter/material.dart';

class MyStyle {
  // Field
  Color primaryColor = Color.fromARGB(0xff, 0xef, 0x79, 0x36);
  Color dartColor = Color.fromARGB(0xff, 0xb7, 0x4a, 0x02);
  Color lightColor = Color.fromARGB(0xff, 0xff, 0xaa, 0x64);

  String font = 'ThaiSansNeue';

  // Method
  Widget showMyCart(int typeFood) {
    return Container(
      margin: EdgeInsets.only(right: 16.0),
      height: 36.0,
      child: Row(
        children: <Widget>[
          Text(
            '$typeFood',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.shopping_cart),
        ],
      ),
    );
  }

    Widget seachMenu(int typeFood) {
    return Container(
      margin: EdgeInsets.only(right: 16.0),
      height: 36.0,
      child: Row(
        children: <Widget>[
   
          Icon(Icons.search),
        ],
      ),
    );
  }

  Widget showLogo() {
    return Container(
      height: 120.0,
      child: Image.asset('images/logo_1024.png'),
    );
  }
    Widget showLogoRider() {
    return Container(
      height: 120.0,
      child: Image.asset('images/delivery.png'),
    );
  }

    Widget showLogoShop() {
    return Container(
      height: 120.0,
      child: Image.asset('images/shopicon.png'),
    );
  }

  Icon signInIcon = Icon(
    Icons.fingerprint,
    size: 36.0,
    color: Color.fromARGB(0xff, 0xb7, 0x4a, 0x02),
  );

  Icon signUpIcon = Icon(
    Icons.system_update,
    size: 36.0,
    color: Color.fromARGB(0xff, 0xb7, 0x4a, 0x02),
  );

  TextStyle hiStyleWhite = TextStyle(
    fontFamily: 'ThaiSansNeue',
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
  );

  TextStyle h3StylePrimary = TextStyle(
    fontSize: 16.0,
    color: Color.fromARGB(0xff, 0xef, 0x79, 0x36),
  );

  TextStyle h3StyleDark = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18.0,
    color: Color.fromARGB(0xff, 0xb7, 0x4a, 0x02),
  );

  TextStyle h2StyleWhite = TextStyle(
    fontFamily: 'ThaiSansNeue',
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18.0,
  );

  TextStyle h2Style = TextStyle(
    fontFamily: 'ThaiSansNeue',
    color: Color.fromARGB(0xff, 0xb7, 0x4a, 0x02),
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );

  TextStyle h2NormalStyle = TextStyle(
    fontFamily: 'ThaiSansNeue',
    color: Color.fromARGB(0xff, 0xb7, 0x4a, 0x02),
    fontSize: 20.0,
  );

  TextStyle h2StylePrimary = TextStyle(
    fontFamily: 'ThaiSansNeue',
    color: Color.fromARGB(0xff, 0xef, 0x79, 0x36),
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );

  TextStyle h1Style = TextStyle(
    fontFamily: 'ThaiSansNeue',
    color: Color.fromARGB(0xff, 0xb7, 0x4a, 0x02),
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
  );

  TextStyle h1PrimaryStyle = TextStyle(
    fontFamily: 'ThaiSansNeue',
    color: Color.fromARGB(0xff, 0xef, 0x79, 0x36),
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
  );

  Widget mySizeBox() {
    return SizedBox(
      width: 8.0,
      height: 16.0,
    );
  }

  Widget showTitle(String string) {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8.0),
          child: Text(
            string,
            style: TextStyle(
              fontFamily: 'ThaiSansNeue',
              color: Color.fromARGB(0xff, 0xb7, 0x4a, 0x02),
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget showTitleH2Primary(String string) {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            string,
            style: TextStyle(
              fontFamily: 'ThaiSansNeue',
              color: Color.fromARGB(0xff, 0xef, 0x79, 0x36),
              // fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget showTitleH2Dark(String string) {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            string,
            style: TextStyle(
              fontFamily: 'ThaiSansNeue',
              color: Color.fromARGB(0xff, 0xb7, 0x4a, 0x02),
              // fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget showTitleH2DartBold(String string) {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            string,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'ThaiSansNeue',
              color: Color.fromARGB(0xff, 0xb7, 0x4a, 0x02),
              // fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget showProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }



  Widget contentSignIn() {
    return Container(
      width: 250.0,
      child: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              labelText: 'User :',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Password :',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Container(
            width: 250.0,
            child: RaisedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.fingerprint),
              label: Text('Sign In'),
            ),
          ),
        ],
      ),
    );
  }

  MyStyle();
}
