import 'package:foodlion/models/order_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteHelper {
  // Field
  String nameDatabase = 'foodData3.db';
  String tableDatabase = 'orderTABLE';
  int versionDatabase = 1;
  String idColumn = 'id';
  String idFood = 'idFood';
  String idShop = 'idShop';
  String nameShop = 'nameShop';
  String nameFood = 'nameFood';
  String detailFood = 'detailFood';
  String urlFood = 'urlFood';
  String priceFood = 'priceFood';
  String amountFood = 'amountFood';

  String nameOption = 'nameOption'; //['ใส้กรอก' 'ทูน่า']
  String sizeOption = 'sizeOption'; //['s' 'm']
  String priceOption = 'priceOption'; //['10' '30']
  String sumOption = 'sumOption'; // '40'
  String remark = 'remark';

  String latUser = 'latUser';
  String lngUser = 'lngUser';
  String nameLocal = 'nameLocal';
  String latShop = 'latShop';
  String lngShop = 'lngShop';
  String sumPrice = 'sumPrice';
  String transport = 'transport';
  String distance = 'distance';
  



  // Method
  SQLiteHelper() {
    initDatabase();
  }

  Future<void> initDatabase() async {
    await openDatabase(join(await getDatabasesPath(), nameDatabase),
        onCreate: (Database database, int version) {
      return database.execute(
          'CREATE TABLE $tableDatabase ($idColumn INTEGER PRIMARY KEY, $idFood TEXT, $idShop TEXT, $nameShop TEXT, $nameFood TEXT, $detailFood TEXT,$urlFood TEXT, $priceFood TEXT, $amountFood TEXT, $nameOption TEXT,$sizeOption TEXT,$priceOption TEXT,$sumOption TEXT,$remark TEXT,$latUser TEXT,$lngUser TEXT,$nameLocal TEXT,$latShop TEXT,$lngShop TEXT,$sumPrice TEXT,$transport TEXT,$distance TEXT)');
    }, version: versionDatabase);
  }

  Future<Database> connectedDatabase() async {
    Database database =
        await openDatabase(join(await getDatabasesPath(), nameDatabase));
    return database;
  }

  Future<void> insertDatabase(OrderModel orderModel) async {
    
    Database database = await connectedDatabase();
    try {
      database.insert(
        tableDatabase,
        orderModel.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      ).then((value) {
        print('Insert Database สำเร็จ');
      });
      // database.close();
    } catch (e) {
      print('e insertDatabase ==>> ${e.toString()}');
    }
  }

  Future<List<OrderModel>> readDatabase() async {
    Database database = await connectedDatabase();
    List<OrderModel> orderModels = List();

    try {
      List<Map<String, dynamic>> list = await database.query(tableDatabase);
      for (var map in list) {
        OrderModel orderModel = OrderModel.fromJson(map);
        orderModels.add(orderModel);
      }
      database.close();
      return orderModels;
    } catch (e) {
      print('e readDatabase ==>> ${e.toString()}');
      // database.close();
      return null;
    }
  }

  Future<void> deleteSQLiteWhereId(int id) async {
    Database database = await connectedDatabase();
    try {
      await database.delete(tableDatabase, where: '$idColumn = $id');
      // await database.delete(tableDatabase);
    } catch (e) {
      print('e delete ==>> ${e.toString()}');
    }
  }

  Future<void> deleteSQLiteAll() async {
    Database database = await connectedDatabase();
    try {
      await database.delete(tableDatabase);
    } catch (e) {
      print('e delete ==>> ${e.toString()}');
    }
  }
}
