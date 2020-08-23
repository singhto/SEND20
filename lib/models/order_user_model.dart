class OrderUserModel {
  String id;
  String idUser;
  String idShop;
  String dateTime;
  String idFoods;
  String amountFoods;
  String idDelivery;
  String success;
  String totalDelivery;
  String totalPrice;
  String sumTotal;
  String remarke;
  String latUser;
  String lngUser;
  String nameLocal;
  String distance;
  String nameOption;
  String sizeOption;
  String priceOption;
  String sumPrice;
  String transport;

  OrderUserModel(
      {this.id,
      this.idUser,
      this.idShop,
      this.dateTime,
      this.idFoods,
      this.amountFoods,
      this.idDelivery,
      this.success,
      this.totalDelivery,
      this.totalPrice,
      this.sumTotal,
      this.remarke,
      this.latUser,
      this.lngUser,
      this.nameLocal,
      this.distance,
      this.nameOption,
      this.sizeOption,
      this.priceOption,
      this.sumPrice,
      this.transport});

  OrderUserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idUser = json['idUser'];
    idShop = json['idShop'];
    dateTime = json['DateTime'];
    idFoods = json['idFoods'];
    amountFoods = json['amountFoods'];
    idDelivery = json['idDelivery'];
    success = json['Success'];
    totalDelivery = json['totalDelivery'];
    totalPrice = json['totalPrice'];
    sumTotal = json['sumTotal'];
    remarke = json['remarke'];
    latUser = json['latUser'];
    lngUser = json['lngUser'];
    nameLocal = json['nameLocal'];
    distance = json['distance'];
    nameOption = json['nameOption'];
    sizeOption = json['sizeOption'];
    priceOption = json['priceOption'];
    sumPrice = json['sumPrice'];
    transport = json['transport'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idUser'] = this.idUser;
    data['idShop'] = this.idShop;
    data['DateTime'] = this.dateTime;
    data['idFoods'] = this.idFoods;
    data['amountFoods'] = this.amountFoods;
    data['idDelivery'] = this.idDelivery;
    data['Success'] = this.success;
    data['totalDelivery'] = this.totalDelivery;
    data['totalPrice'] = this.totalPrice;
    data['sumTotal'] = this.sumTotal;
    data['remarke'] = this.remarke;
    data['latUser'] = this.latUser;
    data['lngUser'] = this.lngUser;
    data['nameLocal'] = this.nameLocal;
    data['distance'] = this.distance;
    data['nameOption'] = this.nameOption;
    data['sizeOption'] = this.sizeOption;
    data['priceOption'] = this.priceOption;
    data['sumPrice'] = this.sumPrice;
    data['transport'] = this.transport;
    return data;
  }
}

// {
//     "id": "",
//     "idUser": "",
//     "idShop": "",
//     "DateTime": "",
//     "idFoods": "",
//     "amountFoods": "",
//     "idDelivery": "",
//     "Success": "",
//     "totalDelivery": "",
//     "totalPrice": "",
//     "sumTotal": "",
//     "remarke": "",
//     "latUser": "",
//     "lngUser": "",
//     "nameLocal": "",
//     "distance": "",
//     "nameOption": "",
//     "sizeOption": "",
//     "priceOption": "",
//     "sumPrice": "",
//     "transport": ""
// }