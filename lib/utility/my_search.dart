import 'package:flutter/material.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/sqlite_helper.dart';
import 'package:foodlion/widget/my_food.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MySearch extends StatefulWidget {
  @override
  _MySearchState createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {
  List<UserShopModel> _list = [];
  List<UserShopModel> _search = [];
  int amount = 0;

  var loading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<Null> fetchData() async {
    setState(() {
      loading = true;
    });
    _list.clear();
    final response = await http.get('http://movehubs.com/app/getAllShop.php');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int index = 0;
      setState(() {
        for (Map i in data) {
          _list.add(UserShopModel.fromJson(i));
          index++;
          loading = false;
        }
      });
    }
  }

  Future<void> checkAmount() async {
    print('checkAmount Work');
    try {
      List<OrderModel> list = await SQLiteHelper().readDatabase();
      setState(() {
        amount = list.length;
      });
    } catch (e) {}
  }

  TextEditingController controller = new TextEditingController();

  onSearch(String text) async {
    _search.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    _list.forEach((f) {
      if (f.name.contains(text) || f.id.toString().contains(text))
        _search.add(f);
      {}
    });
    setState(() {});
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              //color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.search),
                    title: TextField(
                      controller: controller,
                      onChanged: onSearch,
                      decoration: InputDecoration(
                          hintText: 'ค้นหา', border: InputBorder.none),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        controller.clear();
                        onSearch('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            loading
                ? MyStyle().showProgress()
                : Expanded(
                    child: _search.length != 0 || controller.text.isNotEmpty
                        ? ListView.builder(
                            itemCount: _search.length,
                            itemBuilder: (context, i) {
                              final b = _search[i];
                              return Container(
                                padding: EdgeInsets.all(10.0),
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(1.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(Icons.alarm),
                                          title: Text(
                                            b.name,
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          onTap: () {
                                            if (MyAPI().checkTimeShop()) {
                                              MaterialPageRoute route =
                                                  MaterialPageRoute(
                                                      builder: (value) =>
                                                          MyFood(idShop: b.id,));
                                              Navigator.of(context)
                                                  .push(route)
                                                  .then(
                                                      (value) => checkAmount());
                                            } else {
                                              normalDialog(
                                                  context,
                                                  'ร้านปิดแล้ว',
                                                  'ต้องขอ อภัยมากๆ ครับ ร้านเปิดบริการ 8.00- 19.00');
                                            }
                                          },
                                          subtitle: Text('${b.lat} ${b.lng}'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            itemBuilder: (context, i) {
                              final a = _list[i];
                            },
                            itemCount: _list.length,
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
