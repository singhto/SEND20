import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/utility/my_constant.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:image_picker/image_picker.dart';

class ShowFoodShop extends StatefulWidget {
  final FoodModel foodModel;
  ShowFoodShop({Key key, this.foodModel});
  @override
  _ShowFoodShopState createState() => _ShowFoodShopState();
}

class _ShowFoodShopState extends State<ShowFoodShop> {
  // Field
  FoodModel foodModel;
  int amountFood = 1;
  String id,
      idFood,
      nameFood,
      urlFood,
      priceFood,
      detailFood,
      qtyFood,
      d1Food,
      d2Food,
      d3Food,
      d4Food,
      d5Food,
      d6Food,
      d7Food,
      d8Food,
      d9Food,
      p1Food,
      p2Food,
      p3Food,
      p4Food,
      p5Food,
      p6Food,
      p7Food,
      p8Food,
      p9Food;
  File file;
  bool isLoading = false;

  // Method
  @override
  void initState() {
    super.initState();
    foodModel = widget.foodModel;
    id = foodModel.id;
    idFood = foodModel.id;
    nameFood = foodModel.nameFood;
    urlFood = foodModel.urlFood;
    priceFood = foodModel.priceFood;
    detailFood = foodModel.detailFood;
    qtyFood = foodModel.qty;
    d1Food = foodModel.d1;
    d2Food = foodModel.d2;
    d3Food = foodModel.d3;
    d4Food = foodModel.d4;
    d5Food = foodModel.d5;
    d6Food = foodModel.d6;
    d7Food = foodModel.d7;
    d8Food = foodModel.d8;
    d9Food = foodModel.d9;
    p1Food = foodModel.p1;
    p2Food = foodModel.p2;
    p3Food = foodModel.p3;
    p4Food = foodModel.p4;
    p5Food = foodModel.p5;
    p6Food = foodModel.p6;
    p7Food = foodModel.p7;
    p8Food = foodModel.p8;
    p9Food = foodModel.p9;
  }

  Widget showName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: TextFormField(
            onChanged: (value) => nameFood = value.trim(),
            style: MyStyle().h2Style,
            initialValue: foodModel.nameFood,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.edit_attributes),
              labelText: 'ชื่ออาหาร',
              labelStyle: MyStyle().h2StylePrimary,
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            onChanged: (value) => qtyFood = value.trim(),
            style: MyStyle().h2Style,
            initialValue: foodModel.qty,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.edit_attributes),
              labelText: 'แพ็ค',
              labelStyle: MyStyle().h2StylePrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget showImage() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.add_a_photo,
                  size: 36.0,
                  color: MyStyle().dartColor,
                ),
                onPressed: () => chooseImage(
                      ImageSource.camera,
                    )),
            Container(
              width: 150,
              height: 150,
              child: showChooseImage(),
            ),
            IconButton(
                icon: Icon(
                  Icons.add_photo_alternate,
                  size: 36.0,
                  color: MyStyle().dartColor,
                ),
                onPressed: () => chooseImage(ImageSource.gallery)),
          ],
        ),
      );

  Widget showChooseImage() {
    return file == null
        ? Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CachedNetworkImage(
                  height: 150.0,
                  width: 150.0,
                  imageUrl: foodModel.urlFood,
                  fit: BoxFit.cover,
                  placeholder: (value, string) => MyStyle().showProgress(),
                ),
              ),
            ],
          )
        : Row(
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.file(
                    file,
                    height: 150.0,
                    width: 150.0,
                    fit: BoxFit.cover,
                  )),
            ],
          );
  }

  Future<void> chooseImage(ImageSource source) async {
    try {
      var response = await ImagePicker.pickImage(
        source: source,
        maxWidth: 600.0,
        maxHeight: 600.0,
      );
      setState(() {
        file = response;
      });
    } catch (e) {}
  }

  Widget subForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextFormField(
          onChanged: (value) => detailFood = value.trim(),
          style: MyStyle().h2Style,
          initialValue: foodModel.detailFood,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.edit_attributes),
            labelText: 'รายละเอียด',
            labelStyle: MyStyle().h3StylePrimary,
          ),
        ),
        TextFormField(
          onChanged: (value) => priceFood = value.trim(),
          style: MyStyle().h2Style,
          initialValue: foodModel.priceFood,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.edit_attributes),
            labelText: 'ราคา',
            labelStyle: MyStyle().h3StylePrimary,
          ),
        ),
      ],
    );
  }

  Future<void> uploadImageToServer() async {
    setState(() {
      isLoading = true;
    });

    String url = MyConstant().urlSaveFile;
    Random random = Random();
    int i = random.nextInt(100000);
    String nameFile = 'shop$i.jpg';
    //print('name = $nameFood, urlImage = $urlFood , detail = $detailFood, price = $priceFood, id = $id');

    setState(() {
      isLoading = false;
    });

    try {
      Map<String, dynamic> map = Map();

      map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
      FormData formData = FormData.fromMap(map);
      await Dio().post(url, data: formData).then((response) {
        urlFood = '${MyConstant().urlImagePathShop}$nameFile';
        print(
            'name = $nameFood, urlImage = $urlFood , detail = $detailFood, price = $priceFood, id = $id');
        insertDtaToMySQL();
      });
    } catch (e) {}
  }

  Future<void> insertDtaToMySQL() async {
    // urlImage = '${MyConstant().urlImagePathShop}$string';
    setState(() {
      isLoading = true;
    });
    String urlAPI =
        'http://movehubs.com/app/editFoodShopWhereId.php?isAdd=true&id=$id&NameFood=$nameFood&DetailFood=$detailFood&UrlFood=$urlFood&PriceFood=$priceFood&Qty=$qtyFood&D1=$d1Food&D2=$d2Food&D3=$d3Food&D4=$d4Food&D5=$d5Food&D6=$d6Food&D7=$d7Food&D8=$d8Food&D9=$d9Food&P1=$p1Food&P2=$p2Food&P3=$p3Food&P4=$p4Food&P5=$p5Food&P6=$p6Food&P7=$p7Food&P8=$p8Food&P9=$p9Food';

    try {
      await Dio().get(urlAPI).then(
        (response) {
          if (response.toString() == 'true') {
            Navigator.of(context).pop();
          } else {
            normalDialog(context, 'Register False', 'Please Try Again');
          }
        },
      );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขรายการอาหาร'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            showImage(),
            showName(),
            subForm(),
            SizedBox(
              height: 90.0,
            )
          ],
        ),
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
              setState(() {
                isLoading = true;
              });
              if (nameFood.isEmpty || detailFood.isEmpty || priceFood.isEmpty) {
                normalDialog(
                    context, 'ห้ามมีช่องว่างครับ', 'กรุณากรอกข้อมูลให้ครบ');
              } else if (file == null) {
                insertDtaToMySQL();
              } else {
                uploadImageToServer();
              }
            },
            child: Text(
              'บันทึกการแก้ไข',
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
}
