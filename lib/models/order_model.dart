class OrderModel {
  int id;
  String idFood;
  String idShop;
  String nameShop;
  String nameFood;
  String urlFood;
  String priceFood;
  String amountFood;

  OrderModel(
      {this.id,
      this.idFood,
      this.idShop,
      this.nameShop,
      this.nameFood,
      this.urlFood,
      this.priceFood,
      this.amountFood});

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idFood = json['idFood'];
    idShop = json['idShop'];
    nameShop = json['nameShop'];
    nameFood = json['nameFood'];
    urlFood = json['urlFood'];
    priceFood = json['priceFood'];
    amountFood = json['amountFood'];
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
    return data;
  }
}
