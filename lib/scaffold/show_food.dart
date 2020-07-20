import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowFood extends StatefulWidget {
  final FoodModel foodModel;
  ShowFood({Key key, this.foodModel});
  @override
  _ShowFoodState createState() => _ShowFoodState();
}

class _ShowFoodState extends State<ShowFood> {
  // Field
  FoodModel foodModel;
  int amountFood = 1;
  String idShop, idUser, idFood, nameshop, nameFood, urlFood, priceFood;
  bool statusShop = false;
  String nameCurrentShop;

  // Method
  @override
  void initState() {
    super.initState();
    foodModel = widget.foodModel;
    setupVariable();
  }

  Future<void> setupVariable() async {
    idShop = foodModel.idShop;
    idFood = foodModel.id;
    nameshop = await MyAPI().findNameShopWhere(idShop);
    nameFood = foodModel.nameFood;
    urlFood = foodModel.urlFood;
    priceFood = foodModel.priceFood;

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      idUser = preferences.getString('Login');

      List<OrderModel> orderModels = await SQLiteHelper().readDatabase();
      if (orderModels.length != 0) {
        for (var model in orderModels) {
          nameCurrentShop = model.nameShop;
          if (idShop != model.idShop) {
            statusShop = true;
          }
        }
      }
    } catch (e) {}
  }

  Widget showContent() {
    return Container(
      child: Container(
        child: Column(
          children: <Widget>[
            showImage(),
            MyStyle().mySizeBox(),
            MyStyle().showTitle('รายละเอียด :'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: showDetail(),
            ),
            showPrice(),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'What do people call you?',
                  labelText: 'Name *',
                ),
                onSaved: (String value) {
                  // This optional block of code can be used to run
                  // code when the user saves the form.
                },
                validator: (String value) {
                  return value.contains('@') ? 'Do not use the @ char.' : null;
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showPrice() {
    return Row(
      children: <Widget>[
        MyStyle().showTitle('ราคา :'),
        Text(
          '${foodModel.priceFood} บาท',
          style: MyStyle().h1PrimaryStyle,
        ),
      ],
    );
  }

  Text showDetail() {
    return Text(
      foodModel.detailFood,
      style: MyStyle().h2StylePrimary,
    );
  }

  Text showName() {
    return Text(
      foodModel.nameFood,
      style: MyStyle().h1Style,
    );
  }

  Widget showImage() => CachedNetworkImage(
        height: 220.0,
        width: MediaQuery.of(context).size.width,
        imageUrl: foodModel.urlFood,
        placeholder: (value, string) => MyStyle().showProgress(),
        fit: BoxFit.cover,
      );

  Widget chooseAmount() {
    return Expanded(
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        //mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
              icon: Icon(
                Icons.add_circle,
                size: 28.0,
                color: Colors.green,
              ),
              onPressed: () {
                setState(() {
                  amountFood++;
                });
              }),
          MyStyle().mySizeBox(),
          Text(
            '$amountFood',
            style: MyStyle().h1PrimaryStyle,
          ),
          MyStyle().mySizeBox(),
          IconButton(
              icon: Icon(
                Icons.remove_circle,
                size: 28.0,
                color: Colors.red,
              ),
              onPressed: () {
                if (amountFood != 0) {
                  setState(() {
                    amountFood--;
                  });
                }
              }),
        ],
      ),
    );
  }

  Widget showButton() {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        chooseAmount(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(foodModel.nameFood),
      // ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              showImage(),
              showName(),
              showListFood(),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.comment),
                  hintText: 'คุณต้องการอะไรเพิ่มเติมมั้ย?',
                  labelText: 'คำขอพิเศษ *',
                ),
              ),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 50.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      MyStyle().mySizeBox(),
                      IconButton(
                          icon: Icon(
                            Icons.remove_circle,
                            size: 36.0,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            if (amountFood != 0) {
                              setState(() {
                                amountFood--;
                              });
                            }
                          }),
                      MyStyle().mySizeBox(),
                      Text(
                        '$amountFood',
                        style: MyStyle().h1PrimaryStyle,
                      ),
                      MyStyle().mySizeBox(),
                      IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            size: 36.0,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            setState(() {
                              amountFood++;
                            });
                          }),
                      MyStyle().mySizeBox(),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  )
                ],
              ),
              SizedBox(
                height: 90.0,
              ),
            ],
          ),
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
              if (statusShop) {
                normalDialog(context, 'ไม่สามารถเลือกได้ ?',
                    'โปรดเลือกอาหาร จากร้าน $nameCurrentShop คุณสามารถสั่งอาหา���ได้ครั้งละ 1 ร้านค้าค่��');
              } else if (amountFood == 0) {
                normalDialog(context, 'ยังไม่มี รายการอาหาร',
                    'กรุณาเพิ่มจำนวน รายการอาหาร');
              } else if (idUser == null) {
                normalDialog(
                    context, 'ยังไม่ได้ Login', 'กรุณา Login ก่อน Order คะ');
              } else {
                print(
                    'idFood=$idFood, idShop=$idShop,nameShop=$nameshop, nameFood=$nameFood, urlFood=$urlFood, priceFood=$priceFood, amountFood=$amountFood');
                OrderModel model = OrderModel(
                  idFood: idFood,
                  idShop: idShop,
                  nameShop: nameshop,
                  nameFood: nameFood,
                  urlFood: urlFood,
                  priceFood: priceFood,
                  amountFood: amountFood.toString(),
                );
                SQLiteHelper().insertDatabase(model);
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'เพิ่มลงในตะกร้า',
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

  Widget showListFood() {
    return Column(
      children: <Widget>[
        Card(
          child: ListTile(
            
            leading: Radio(value: null, groupValue: null, onChanged: null),
            title: Text('${foodModel.detailFood}', style: TextStyle(fontSize: 18),),
            trailing: Text('${foodModel.priceFood} บาท', style: TextStyle(fontSize: 18),),
          ),
        ),
         Card(
          child: ListTile(
            leading: Radio(value: null, groupValue: null, onChanged: null),
            title: Text('${foodModel.d1}', style: TextStyle(fontSize: 18),),
            trailing: Text('${foodModel.p1} บาท', style: TextStyle(fontSize: 18),),

          ),
        ),
        Card(
          child: ListTile(
            leading: Radio(value: null, groupValue: null, onChanged: null),
            title: Text('${foodModel.d2}', style: TextStyle(fontSize: 18),),
            trailing: Text('${foodModel.p2} บาท', style: TextStyle(fontSize: 18),),
          ),
        ),
        Card(
          child: ListTile(
            leading: Radio(value: null, groupValue: null, onChanged: null),
            title: Text('${foodModel.d3}', style: TextStyle(fontSize: 18),),
            trailing: Text('${foodModel.p3} บาท', style: TextStyle(fontSize: 18),),
          ),
        ),
        Card(
          child: ListTile(
            leading: Radio(value: null, groupValue: null, onChanged: null),
            title: Text('${foodModel.d4}', style: TextStyle(fontSize: 18),),
            trailing: Text('${foodModel.p4} บาท', style: TextStyle(fontSize: 18),),
          ),
        ),
        Card(
          child: ListTile(
            leading: Radio(value: null, groupValue: null, onChanged: null),
            title: Text('${foodModel.d5}', style: TextStyle(fontSize: 18),),
            trailing: Text('${foodModel.p5} บาท', style: TextStyle(fontSize: 18),),
          ),
        ),
        Card(
          child: ListTile(
            leading: Radio(value: null, groupValue: null, onChanged: null),
            title: Text('${foodModel.d6}', style: TextStyle(fontSize: 18),),
            trailing: Text('${foodModel.p6} บาท', style: TextStyle(fontSize: 18),),
          ),
        ),
        Card(
          child: ListTile(
            leading: Radio(value: null, groupValue: null, onChanged: null),
            title: Text('${foodModel.d7}', style: TextStyle(fontSize: 18),),
            trailing: Text('${foodModel.p7} บาท', style: TextStyle(fontSize: 18),),
          ),
        ),
        Card(
          child: ListTile(
            leading: Radio(value: null, groupValue: null, onChanged: null),
            title: Text('${foodModel.d8}', style: TextStyle(fontSize: 18),),
            trailing: Text('${foodModel.p8} บาท', style: TextStyle(fontSize: 18),),
          ),
        ),
        Card(
          child: ListTile(
            leading: Radio(value: null, groupValue: null, onChanged: null),
            title: Text('${foodModel.d9}', style: TextStyle(fontSize: 18),),
            trailing: Text('${foodModel.p9} บาท', style: TextStyle(fontSize: 18),),
          ),
        ),

      ],
    );
  }
}
