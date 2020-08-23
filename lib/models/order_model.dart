import 'dart:convert';

class OrderModel {
  int id;
  String idFood;
  String idShop;
  String nameShop;
  String nameFood;
  String urlFood;
  String priceFood;
  String amountFood;
  String nameOption;
  String sizeOption;
  String priceOption;
  String sumOption;
  String remark;
  String latUser;
  String lngUser;
  String nameLocal;
  String latShop;
  String lngShop;
  String sumPrice;
  String transport;
  String distance;
  String detailFood;

  OrderModel(
      {this.id,
      this.idFood,
      this.idShop,
      this.nameShop,
      this.nameFood,
      this.urlFood,
      this.priceFood,
      this.amountFood,
      this.nameOption,
      this.sizeOption,
      this.priceOption,
      this.sumOption,
      this.remark,
      this.latUser,
      this.lngUser,
      this.nameLocal,
      this.latShop,
      this.lngShop,
      this.sumPrice,
      this.transport,
      this.distance,
      this.detailFood});

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idFood = json['idFood'];
    idShop = json['idShop'];
    nameShop = json['nameShop'];
    nameFood = json['nameFood'];
    urlFood = json['urlFood'];
    priceFood = json['priceFood'];
    amountFood = json['amountFood'];
    nameOption = json['nameOption'];
    sizeOption = json['sizeOption'];
    priceOption = json['priceOption'];
    sumOption = json['sumOption'];
    remark = json['remark'];
    latUser = json['latUser'];
    lngUser = json['lngUser'];
    nameLocal = json['nameLocal'];
    latShop = json['latShop'];
    lngShop = json['lngShop'];
    sumPrice = json['sumPrice'];
    transport = json['transport'];
    distance = json['distance'];
    detailFood = json['detailFood'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idFood'] = this.idFood;
    data['idShop'] = this.idShop;
    data['nameShop'] = this.nameShop;
    data['nameFood'] = this.nameFood;
    data['urlFood'] = this.urlFood;
    data['priceFood'] = this.priceFood;
    data['amountFood'] = this.amountFood;
    data['nameOption'] = this.nameOption;
    data['sizeOption'] = this.sizeOption;
    data['priceOption'] = this.priceOption;
    data['sumOption'] = this.sumOption;
    data['remark'] = this.remark;
    data['latUser'] = this.latUser;
    data['lngUser'] = this.lngUser;
    data['nameLocal'] = this.nameLocal;
    data['latShop'] = this.latShop;
    data['lngShop'] = this.lngShop;
    data['sumPrice'] = this.sumPrice;
    data['transport'] = this.transport;
    data['distance'] = this.distance;
    data['detailFood'] = this.detailFood;
    return data;
  }
}

// {
//     "id": 1,
//     "idFood": "",
//     "idShop": "",
//     "nameShop": "",
//     "nameFood": "",
//     "urlFood": "",
//     "priceFood": "",
//     "amountFood": "",
//     "nameOption": "",
//     "sizeOption": "",
//     "priceOption": "",
//     "sumOption": "",
//     "remark": "",
//     "latUser": "",
//     "lngUser": "",
//     "nameLocal": "",
//     "latShop": "",
//     "lngShop": "",
//     "sumPrice": "",
//     "transport": "",
//     "distance": ""
// }
