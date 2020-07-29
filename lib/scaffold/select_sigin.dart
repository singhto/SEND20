import 'package:flutter/material.dart';
import 'package:foodlion/widget/register_user.dart';

void main() {
  runApp(SelectSigin());
}

class SelectSigin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.fastfood)),
                Tab(icon: Icon(Icons.store_mall_directory)),
                Tab(icon: Icon(Icons.directions_bike)),
              ],
            ),
            title: Text('สมัครสมาชิก'),
          ),
          body: TabBarView(
            children: [
              GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterUser())),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.fastfood,
                        size: 150,
                      ),
                      Text('สมัครสั่งอาหาร')
                    ],
                  )),
              Icon(Icons.store_mall_directory),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}
