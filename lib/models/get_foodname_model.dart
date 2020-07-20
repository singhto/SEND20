class GetFoodName {
  String id;
  String foodName;

  GetFoodName({this.id, this.foodName});

  GetFoodName.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    foodName = json['foodName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['foodName'] = this.foodName;
    return data;
  }
}
