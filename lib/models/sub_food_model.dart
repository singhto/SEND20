class SubFoodModel {
  String id;
  String idFood;
  String nameFood;
  String statusFood;
  String priceFood;

  SubFoodModel(
      {this.id, this.idFood, this.nameFood, this.statusFood, this.priceFood});

  SubFoodModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idFood = json['idFood'];
    nameFood = json['NameFood'];
    statusFood = json['StatusFood'];
    priceFood = json['PriceFood'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idFood'] = this.idFood;
    data['NameFood'] = this.nameFood;
    data['StatusFood'] = this.statusFood;
    data['PriceFood'] = this.priceFood;
    return data;
  }
}
