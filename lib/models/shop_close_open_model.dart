class ShopCloseOpenModel {
  String id;
  String idShop;
  String date;
  String timeStart;
  String timeEnd;

  ShopCloseOpenModel(
      {this.id, this.idShop, this.date, this.timeStart, this.timeEnd});

  ShopCloseOpenModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idShop = json['idShop'];
    date = json['date'];
    timeStart = json['timeStart'];
    timeEnd = json['timeEnd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idShop'] = this.idShop;
    data['date'] = this.date;
    data['timeStart'] = this.timeStart;
    data['timeEnd'] = this.timeEnd;
    return data;
  }
}
