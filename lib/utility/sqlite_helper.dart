import 'package:foodlion/models/order_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteHelper {
  // Field
  String nameDatabase = 'foodData.db';
  String tableDatabase = 'orderTABLE';
  int versionDatabase = 1;
  String idColumn = 'id';
  String idFood = 'idFood';
  String idShop = 'idShop';
  String nameShop = 'nameShop';
  String nameFood = 'nameFood';
  String urlFood = 'urlFood';
  String priceFood = 'priceFood';
  String amountFood = 'amountFood';

  // Method
  SQLiteHelper() {
    initDatabase();
  }

  Future<void> initDatabase() async {
    await openDatabase(join(await getDatabasesPath(), nameDatabase),
        onCreate: (Database database, int version) {
      return database.execute(
          'CREATE TABLE $tableDatabase ($idColumn INTEGER PRIMARY KEY, $idFood TEXT, $idShop TEXT, $nameShop TEXT, $nameFood TEXT, $urlFood TEXT, $priceFood TEXT, $amountFood TEXT)');
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
      );
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
