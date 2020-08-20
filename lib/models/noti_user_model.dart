class NotiUserModel {
  String id;
  String idUser;
  String title;
  String massage;
  String dateTime;
  String image;
  String link;

  NotiUserModel(
      {this.id, this.idUser, this.title, this.massage, this.dateTime, this.image, this.link});

  NotiUserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idUser = json['idUser'];
    title = json['title'];
    massage = json['massage'];
    dateTime = json['dateTime'];
    image = json['image'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idUser'] = this.idUser;
    data['title'] = this.title;
    data['massage'] = this.massage;
    data['dateTime'] = this.dateTime;
    data['image'] = this.image;
    data['link'] = this.link;
    return data;
  }
}
