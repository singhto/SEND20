class SendLocationModeil {
  String id;
  String idUser;
  String lat;
  String lng;
  String nameLocation;
  String dateAdd;

  SendLocationModeil(
      {this.id,
      this.idUser,
      this.lat,
      this.lng,
      this.nameLocation,
      this.dateAdd});

  SendLocationModeil.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idUser = json['idUser'];
    lat = json['Lat'];
    lng = json['Lng'];
    nameLocation = json['NameLocation'];
    dateAdd = json['DateAdd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idUser'] = this.idUser;
    data['Lat'] = this.lat;
    data['Lng'] = this.lng;
    data['NameLocation'] = this.nameLocation;
    data['DateAdd'] = this.dateAdd;
    return data;
  }
}
