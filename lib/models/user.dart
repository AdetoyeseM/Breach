class UserDTO {
  String? token;
  int? userId;

  UserDTO({this.token, this.userId});

  UserDTO.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = token;
    data['userId'] = userId;
    return data;
  }
}
