class NotiUserModel {
  String id;
  String idUser;
  String title;
  String massage;
  String dateTime;

  NotiUserModel(
      {this.id, this.idUser, this.title, this.massage, this.dateTime});

  NotiUserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idUser = json['idUser'];
    title = json['title'];
    massage = json['massage'];
    dateTime = json['dateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idUser'] = this.idUser;
    data['title'] = this.title;
    data['massage'] = this.massage;
    data['dateTime'] = this.dateTime;
    return data;
  }
}
