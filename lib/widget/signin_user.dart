import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/user_model.dart';
import 'package:foodlion/scaffold/home.dart';
import 'package:foodlion/utility/my_constant.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/widget/curve_clipper.dart';
import 'package:foodlion/widget/register_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'main_home.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
  ],
);

class SingInUser extends StatefulWidget {
  @override
  _SingInUserState createState() => _SingInUserState();
}

class _SingInUserState extends State<SingInUser> {
  // Filed
  GoogleSignInAccount _currentUser;
  String user, password;
  bool isLoading = false;

  // Method

  Future<void> _handleSignIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      print(_currentUser);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MainHome()));
    } catch (error) {
      print(error);
    }
  }

  Widget loginGoogle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FlatButton.icon(
            color: Colors.red,
            textColor: Colors.white,
            onPressed: () => _handleSignIn(),
            icon: Text(
              'G',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            label: Text('เข้าระบบด้วย Google')),
        FlatButton.icon(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () {},
            icon: Text(
              'f',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            label: Text('เข้าระบบด้วย Facebook signin')),
      ],
    );
  }

  Future<void> checkAuthen() async {
    setState(() {
      isLoading = true;
    });

    String url = '${MyConstant().urlGetUserWhereUser}?isAdd=true&User=$user';

    try {
      Response response = await Dio().get(url);
      setState(() {
        isLoading = false;
      });
      if (response.toString() == 'null') {
        normalDialog(context, 'User False', 'No $user in my Database');
      } else {
        var result = json.decode(response.data);
        for (var map in result) {
          UserModel model = UserModel.fromJson(map);
          // print('map ===>>> $map');
          // UserShopModel model = UserShopModel.fromJson(map);
          if (password == model.password) {
            successLogin(model);
          } else {
            normalDialog(
                context, 'Password False', 'Please Try Agains Password False');
          }
        }
      }
    } catch (e) {}
  }

  Future<void> successLogin(UserModel model) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('id', model.id);
      preferences.setString('Name', model.name);
      preferences.setString('Lat', model.lat);
      preferences.setString('Lng', model.lng);
      preferences.setString('Login', 'User');

      MaterialPageRoute route = MaterialPageRoute(builder: (value) => Home());
      Navigator.of(context).pushAndRemoveUntil(route, (value) => false);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),
              MyStyle().showLogo(),
              // ClipPath(
              //   clipper: CurveClipper(),
              //   child: Image(
              //     height: MediaQuery.of(context).size.height / 2.5,
              //     image: NetworkImage('http://movehubs.com/img/logoSigin.jpg'),
              //     fit: BoxFit.cover,
              //   ),
              // ),
              // Text(
              //   'SEND',
              //   style: TextStyle(
              //     color: Theme.of(context).primaryColor,
              //     fontSize: 34.0,
              //     fontWeight: FontWeight.bold,
              //     letterSpacing: 10.0,
              //   ),
              // ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: TextField(
                  onChanged: (value) => user = value.trim(),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Email / Phone',
                      prefixIcon: Icon(
                        Icons.account_box,
                        size: 30.0,
                      )),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: TextField(
                  onChanged: (valur) => password = valur.trim(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock,
                      size: 30.0,
                    ),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(
                height: 40.0,
              ),
              GestureDetector(
                onTap: () async {
                  if (user == null ||
                      user.isEmpty ||
                      password == null ||
                      password.isEmpty) {
                    normalDialog(
                        context, 'ใส่ข้อมูลไม่ครบ', 'กรอกข้อมูลให้ถูกต้องครับ');
                  } else {
                    checkAuthen();
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 60.0),
                  alignment: Alignment.center,
                  height: 45.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: GestureDetector(
                    //onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterUser())),
                    child: Container(
                      alignment: Alignment.center,
                      color: Theme.of(context).primaryColor,
                      height: 80.0,
                      child: Text(
                        'ยังไม่ได้เป็นสมาชิกใช่หรือไม่? สมัครใช้บริการ',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
