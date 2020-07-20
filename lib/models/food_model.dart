class FoodModel {
  String id;
  String idShop;
  String nameFood;
  String detailFood;
  String urlFood;
  String priceFood;
  String score;
  String qty;
  String d1;
  String d2;
  String d3;
  String d4;
  String d5;
  String d6;
  String d7;
  String d8;
  String d9;
  String p1;
  String p2;
  String p3;
  String p4;
  String p5;
  String p6;
  String p7;
  String p8;
  String p9;

  FoodModel(
      {this.id,
      this.idShop,
      this.nameFood,
      this.detailFood,
      this.urlFood,
      this.priceFood,
      this.score,
      this.qty,
      this.d1,
      this.d2,
      this.d3,
      this.d4,
      this.d5,
      this.d6,
      this.d7,
      this.d8,
      this.d9,
      this.p1,
      this.p2,
      this.p3,
      this.p4,
      this.p5,
      this.p6,
      this.p7,
      this.p8,
      this.p9});

  FoodModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idShop = json['idShop'];
    nameFood = json['NameFood'];
    detailFood = json['DetailFood'];
    urlFood = json['UrlFood'];
    priceFood = json['PriceFood'];
    score = json['Score'];
    qty = json['Qty'];
    d1 = json['D1'];
    d2 = json['D2'];
    d3 = json['D3'];
    d4 = json['D4'];
    d5 = json['D5'];
    d6 = json['D6'];
    d7 = json['D7'];
    d8 = json['D8'];
    d9 = json['D9'];
    p1 = json['P1'];
    p2 = json['P2'];
    p3 = json['P3'];
    p4 = json['P4'];
    p5 = json['P5'];
    p6 = json['P6'];
    p7 = json['P7'];
    p8 = json['P8'];
    p9 = json['P9'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idShop'] = this.idShop;
    data['NameFood'] = this.nameFood;
    data['DetailFood'] = this.detailFood;
    data['UrlFood'] = this.urlFood;
    data['PriceFood'] = this.priceFood;
    data['Score'] = this.score;
    data['Qty'] = this.qty;
    data['D1'] = this.d1;
    data['D2'] = this.d2;
    data['D3'] = this.d3;
    data['D4'] = this.d4;
    data['D5'] = this.d5;
    data['D6'] = this.d6;
    data['D7'] = this.d7;
    data['D8'] = this.d8;
    data['D9'] = this.d9;
    data['P1'] = this.p1;
    data['P2'] = this.p2;
    data['P3'] = this.p3;
    data['P4'] = this.p4;
    data['P5'] = this.p5;
    data['P6'] = this.p6;
    data['P7'] = this.p7;
    data['P8'] = this.p8;
    data['P9'] = this.p9;
    return data;
  }
}
