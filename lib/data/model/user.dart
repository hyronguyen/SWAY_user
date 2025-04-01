class User {
  String? fullname;
  String? email;
  String? phone;
  String? password;
  String? gender;
  String? birthday; // Đổi thành String thay vì DateTime
  String? avarta;

  User({
    this.fullname,
    this.email,
    this.phone,
    this.password,
    this.gender,
    this.birthday,
    this.avarta,
  });

  // Hàm tạo đối tượng User từ JSON
  User.fromJson(Map<String, dynamic> json) {
    fullname = json["fullname"];
    email = json["email"];
    phone = json["phone"];
    password = json["password"];
    gender = json["gender"];
    // Chuyển đổi birthday từ String thành Date chỉ khi có giá trị
    birthday = json["birthday"];
    avarta = json["avarta"];
  }

  // Hàm chuyển đổi User thành JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["fullname"] = fullname;
    data["email"] = email;
    data["phone"] = phone;
    data["password"] = password;
    data["gender"] = gender;
    // Không cần phải chuyển đổi DateTime thành String nữa
    data["birthday"] = birthday;
    data["avarta"] = avarta;
    return data;
  }
}
