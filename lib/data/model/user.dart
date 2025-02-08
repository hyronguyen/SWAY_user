class User {
  int? id;
  String? name;
  String? mail;
  String? phone;
  String? password;
  String? gender;

  User({this.id, this.name, this.mail, this.phone, this.password, this.gender});
  
  User.fromJson(Map<String, dynamic> json){
    id = json["id"];
    name = json["name"];
    mail = json["mail"];
    phone = json["phone"];
    password = json["password"];
    gender = json["gender"];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["name"] = name;
    data["mail"] = mail;
    data["phone"] = phone;
    data["password"] = password;
    data["gender"] = gender;
    return data;
  }
}