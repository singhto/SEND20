import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/get_foodname_model.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/widget/my_food_shop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:http/http.dart' as http;

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
      d1,
      d2,
      d3,
      d4,
      d5,
      d6,
      d7,
      d8,
      d9,
      p1,
      p2,
      p3,
      p4,
      p5,
      p6,
      p7,
      p8,
      p9,
      dropdownValue = 'One';
  File file;
  bool isLoading = false;
  List<GetFoodName> _list = [];
  List<GetFoodName> _search = [];
  int selectedIndex = 0;

  // Method
  @override
  void initState() {
    super.initState();
    findIdShop();
    fetchData();
  }

  onSearch(String text) async {
    _search.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    _list.forEach((f) {
      if (f.foodName.contains(text) || f.id.toString().contains(text))
        _search.add(f);
      {}
    });
    setState(() {});
  }

  Future<Null> fetchData() async {
    setState(() {
      isLoading = true;
    });
    _list.clear();
    final response =
        await http.get('http://movehubs.com/app/getAllFoodName.php');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int index = 0;
      setState(() {
        for (Map i in data) {
          _list.add(GetFoodName.fromJson(i));
          index++;
          isLoading = false;
          print('data>>> $i');
        }
      });
    }
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
      height: MediaQuery.of(context).size.height * 0.15,
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
              style: MyStyle().h2Style,
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
        qtyForm()
      ],
    );
  }

  Widget subForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              onChanged: (value) => detailFood = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.filter_1),
                hintText: 'เมนูย่อย :',
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              keyboardType: TextInputType.number,
              onChanged: (value) => priceFood = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'ราคา :',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget subForm1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              onChanged: (value) => d1 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.filter_2),
                hintText: 'เมนูย่อย2 :',
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              keyboardType: TextInputType.number,
              onChanged: (value) => p1 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'ราคา :',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget subForm2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              onChanged: (value) => d2 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.filter_3),
                hintText: 'เมนูย่อย3 :',
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              keyboardType: TextInputType.number,
              onChanged: (value) => p2 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'ราคา :',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget subForm3() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              onChanged: (value) => d3 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.filter_4),
                hintText: 'เมนูย่อย4 :',
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              keyboardType: TextInputType.number,
              onChanged: (value) => p3 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'ราคา :',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget subForm4() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              onChanged: (value) => d4 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.filter_5),
                hintText: 'เมนูย่อย5 :',
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              keyboardType: TextInputType.number,
              onChanged: (value) => p4 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'ราคา :',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget subForm5() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              onChanged: (value) => d5 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.filter_6),
                hintText: 'เมนูย่อย6 :',
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              keyboardType: TextInputType.number,
              onChanged: (value) => p5 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'ราคา :',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget subForm6() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              onChanged: (value) => d6 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.filter_7),
                hintText: 'เมนูย่อย7 :',
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              keyboardType: TextInputType.number,
              onChanged: (value) => p6 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'ราคา :',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget subForm7() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              onChanged: (value) => d7 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.filter_8),
                hintText: 'เมนูย่อย8 :',
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              keyboardType: TextInputType.number,
              onChanged: (value) => p7 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'ราคา :',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget subForm8() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              onChanged: (value) => d8 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.filter_9),
                hintText: 'เมนูย่อย9 :',
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              keyboardType: TextInputType.number,
              onChanged: (value) => p8 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'ราคา :',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget subForm9() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              onChanged: (value) => d9 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.exposure),
                hintText: 'เมนูย่อย10 :',
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              style: MyStyle().h2Style,
              keyboardType: TextInputType.number,
              onChanged: (value) => p9 = value.trim(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'ราคา :',
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
    try {
      String url =
          'http://movehubs.com/app/addFoodShop.php?isAdd=true&idShop=$idShop&NameFood=$nameFood&DetailFood=$detailFood&UrlFood=$urlFood&PriceFood=$priceFood&Score=$score&Qty=$qty&D1=$d1&D2=$d2&D3=$d3&D4=$d4&D5=$d5&D6=$d6&D7=$d7&D8=$d8&D9=$d9&P1=$p1&P2=$p2&P3=$p3&P4=$p4&P5=$p5&P6=$p6&P7=$p7&P8=$p8&P9=$p9';

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
          subForm(),
          totalSubForm(),
          MyStyle().mySizeBox(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoading ? MyStyle().showProgress() : null,
          ),
         SizedBox(height: 90.0,)
        ],
      ),
      bottomSheet: Container(
        height: 60.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -1),
              blurRadius: 6.0,
            )
          ],
        ),
        child: Center(
          child: FlatButton(
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
            child: Text(
              'บันทึกข้อมูล',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ExpandChild totalSubForm() {
    return ExpandChild(
        hideArrowOnExpanded: true,
        arrowColor: Colors.red,
        arrowSize: 40,
        child: Column(
          children: <Widget>[
            subForm1(),
            ExpandChild(
              hideArrowOnExpanded: true,
              arrowColor: Colors.red,
              arrowSize: 40,
              child: Column(
                children: <Widget>[
                  subForm2(),
                  ExpandChild(
                    hideArrowOnExpanded: true,
                    arrowColor: Colors.red,
                    arrowSize: 40,
                    child: Column(
                      children: <Widget>[
                        subForm3(),
                        ExpandChild(
                          hideArrowOnExpanded: true,
                          arrowColor: Colors.red,
                          arrowSize: 40,
                          child: Column(
                            children: <Widget>[
                              subForm4(),
                              ExpandChild(
                                hideArrowOnExpanded: true,
                                arrowColor: Colors.red,
                                arrowSize: 40,
                                child: Column(
                                  children: <Widget>[
                                    subForm5(),
                                    ExpandChild(
                                      hideArrowOnExpanded: true,
                                      arrowColor: Colors.red,
                                      arrowSize: 40,
                                      child: Column(
                                        children: <Widget>[
                                          subForm6(),
                                          ExpandChild(
                                            hideArrowOnExpanded: true,
                                            arrowColor: Colors.red,
                                            arrowSize: 40,
                                            child: Column(
                                              children: <Widget>[
                                                subForm7(),
                                                ExpandChild(
                                                  hideArrowOnExpanded: true,
                                                  arrowColor: Colors.red,
                                                  arrowSize: 40,
                                                  child: Column(
                                                    children: <Widget>[
                                                      subForm8(),
                                                      ExpandChild(
                                                        hideArrowOnExpanded:
                                                            true,
                                                        arrowColor: Colors.red,
                                                        arrowSize: 40,
                                                        child: Column(
                                                          children: <Widget>[
                                                            subForm9(),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
