import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/widget/my_food_shop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMyFood extends StatefulWidget {
  @override
  _AddMyFoodState createState() => _AddMyFoodState();
}

class _AddMyFoodState extends State<AddMyFood> {
  // Field
  String idShop,
      nameFood,
      detailFood,
      urlFood,
      priceFood,
      score = '5',
      qty,
      dropdownValue = 'One';
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
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              onChanged: (value) => nameFood = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.fastfood),
                hintText: 'ชื่ออาหาร :',
                // enabledBorder: OutlineInputBorder(
                //   borderSide: BorderSide(color: Colors.grey),
                // ),
              ),
            ),
          ),
        ),
        qtyForm(),
      ],
    );
  }

  Widget detailForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              onChanged: (value) => detailFood = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.details),
                hintText: 'รายละเอียด : ขนาด หรือความพิเศษของสินค้านี้',
                // enabledBorder: OutlineInputBorder(
                //   borderSide: BorderSide(color: Colors.grey),
                // ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget qtyForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'แพ็ค :',
          style: TextStyle(fontSize: 18.0),
        ),
        SizedBox(
          width: 20.0,
        ),
        DropdownButton<String>(
          hint: Text('เลือก'),
          value: qty,
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          style: TextStyle(color: Colors.deepOrange),
          onChanged: (String newValue) {
            setState(() {
              qty = newValue;
            });
          },
          items: <String>[
            'กล่อง',
            'กระปุก',
            'ขวด',
            'ถุง',
            'ห่อ',
            'แก้ว',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget priceForm() {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) => priceFood = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'ราคาต่อหน่วย : กรอกเฉพาะตัวเลขเท่านั้น',
                // enabledBorder: OutlineInputBorder(
                //   borderSide: BorderSide(color: Colors.grey),
                // ),
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
      var object = await ImagePicker.pickImage(
        source: source,
        maxWidth: 800.00,
        maxHeight: 800.00,
      );

      setState(() {
        file = object;
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
          if (file == null) {
            normalDialog(
                context, 'Non Choose Image', 'Please Click Camera or Gallery');
          } else if (nameFood == null ||
              nameFood.isEmpty ||
              detailFood == null ||
              detailFood.isEmpty ||
              qty == null ||
              qty.isEmpty ||
              priceFood == null ||
              priceFood.isEmpty) {
            normalDialog(context, 'กรอกข้อมูลให้ครบ',
                'กรุณากรอกข้อมูลให้ครบทุกช่องครับ');
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
    setState(() {
      isLoading = true;
    });
    try {
      String url = 'http://movehubs.com/app/saveFood.php';
      Random random = Random();
      int i = random.nextInt(100000);
      String nameImage = 'food$i.jpg';
      //print('nameImage = $nameImage');
      setState(() {
        isLoading = false;
      });
      Map<String, dynamic> map = Map();
      // map['file'] = UploadFileInfo(file, nameImage);
      // FormData formData = FormData.from(map);
      map['file'] =
          await MultipartFile.fromFile(file.path, filename: nameImage);
      FormData formData = FormData.fromMap(map);
      await Dio().post(url, data: formData).then((response) {
        urlFood = 'http://movehubs.com/app/Food/$nameImage';
        //print('urlFood ===>>> $urlFood');
        saveFoodThread();
      });
    } catch (e) {}
  }

  Future<void> saveFoodThread() async {
    setState(() {
      isLoading = true;
    });

    try {
      String url =
          'http://movehubs.com/app/addFoodShop.php?isAdd=true&idShop=$idShop&NameFood=$nameFood&DetailFood=$detailFood&UrlFood=$urlFood&PriceFood=$priceFood&Score=$score&Qty=$qty';

      Response response = await Dio().get(url);
      setState(() {
        isLoading = false;
      });
      if (response.toString() == 'true') {
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => MyFoodShop());
        Navigator.of(context).pushAndRemoveUntil(route, (value) => false);
      } else {
        normalDialog(context, 'Cannot Add Food', 'Please Try Again');
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มเมนูอาหาร'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          showImageFood(),
          MyStyle().mySizeBox(),
          showButton(),
          MyStyle().mySizeBox(),
          nameForm(),
          MyStyle().mySizeBox(),
          detailForm(),
          SizedBox(
            width: 20.0,
          ),
          Expanded(child: priceForm()),
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
