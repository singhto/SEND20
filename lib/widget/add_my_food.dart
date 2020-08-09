import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/scaffold/home.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/normal_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMyFood extends StatefulWidget {
  @override
  _AddMyFoodState createState() => _AddMyFoodState();
}

class _AddMyFoodState extends State<AddMyFood> {
  // Field
  String idShop, nameFood, detailFood, urlFood, priceFood, score = '0';
  File file;
  bool isLoading = false;

  // Method
  @override
  void initState() {
    super.initState();
    findIdShop();
  }

  Future<void> findIdShop() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      idShop = preferences.getString('id');
    } catch (e) {}
  }

  Widget showImageFood() {
    isLoading = false;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.2,
      child: file == null ? Image.asset('images/food2.png') : Image.file(file),
    );
  }

  Widget nameForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          child: TextField(
            onChanged: (value) => nameFood = value.trim(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.fastfood),
              hintText: 'ชื่ออาหาร :',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget detailForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          child: TextField(
            onChanged: (value) => detailFood = value.trim(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.details),
              hintText: 'รายละเอียด :',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget priceForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          child: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) => priceFood = value.trim(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.attach_money),
              hintText: 'ราคา :',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget cameraButton() {
    return OutlineButton.icon(
      onPressed: () => chooseImage(ImageSource.camera),
      icon: Icon(Icons.add_a_photo),
      label: Text('ถ่ายภาพ'),
    );
  }

  Future<void> chooseImage(ImageSource source) async {
    try {
      var object = await ImagePicker()
          .getImage(source: source, maxWidth: 800.0, maxHeight: 800.0);

      setState(() {
        file = File(object.path);
      });
    } catch (e) {}
  }

  Widget galleryButton() {
    return OutlineButton.icon(
      onPressed: () => chooseImage(ImageSource.gallery),
      icon: Icon(Icons.add_photo_alternate),
      label: Text('คลังภาพ'),
    );
  }

  Widget showButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        cameraButton(),
        galleryButton(),
      ],
    );
  }

  Widget saveButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton.icon(
        color: MyStyle().primaryColor,
        onPressed: () {
          isLoading = true;
          if (file == null) {
            normalDialog(
                context, 'Non Choose Image', 'Please Click Camera or Gallery');
          } else if (nameFood == null ||
              nameFood.isEmpty ||
              detailFood == null ||
              detailFood.isEmpty ||
              priceFood == null ||
              priceFood.isEmpty) {
            normalDialog(context, 'Have Space', 'Please Fill Every Blank');
          } else {
            uploadImage();
          }
        },
        icon: Icon(
          Icons.fastfood,
          color: Colors.white,
        ),
        label: Text(
          'Save Food',
          style: MyStyle().h2StyleWhite,
        ),
      ),
    );
  }

  Future<void> uploadImage() async {
    try {
      String url = 'http://movehubs.com/app/saveFood.php';
      Random random = Random();
      int i = random.nextInt(100000);
      String nameImage = 'food$i.jpg';
      print('nameImage = $nameImage');

      Map<String, dynamic> map = Map();
      // map['file'] = UploadFileInfo(file, nameImage);
      // FormData formData = FormData.from(map);
      map['file'] =
          await MultipartFile.fromFile(file.path, filename: nameImage);
      FormData formData = FormData.fromMap(map);
      await Dio().post(url, data: formData).then((response) {
        urlFood = 'http://movehubs.com/app/Food/$nameImage';
        print('urlFood ===>>> $urlFood');
        saveFoodThread();
        isLoading = false;
      });
    } catch (e) {}
  }

  Future<void> saveFoodThread() async {
    isLoading = true;
    try {
      String url =
          'http://movehubs.com/app/addFoodShop.php?isAdd=true&idShop=$idShop&NameFood=$nameFood&DetailFood=$detailFood&UrlFood=$urlFood&PriceFood=$priceFood&Score=$score';

      Response response = await Dio().get(url);

      if (response.toString() == 'true') {
        MaterialPageRoute route = MaterialPageRoute(builder: (value) => Home());
        normalToast('เพิ่มข้อมูลเรียบร้อย');
        Navigator.of(context).pushAndRemoveUntil(route, (value) => false);
      } else {
        normalDialog(context, 'ไม่สามารถลงเมนูได้ครับ', 'กรุณาติดต่อ 089-7037118');
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Center(child: Text('เพิ่มรายการอาหาร')),
      // ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          MyStyle().showTitle('เพิ่มรายการอาหาร'),
          MyStyle().mySizeBox(),
          showImageFood(),
          MyStyle().mySizeBox(),
          showButton(),
          MyStyle().mySizeBox(),
          nameForm(),
          MyStyle().mySizeBox(),
          detailForm(),
          MyStyle().mySizeBox(),
          priceForm(),
          MyStyle().mySizeBox(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoading ? MyStyle().showProgress() : null,
          ),
          saveButton(),
          MyStyle().mySizeBox(),
        ],
      ),
    );
  }
}
