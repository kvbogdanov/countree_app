class JsonUser {
  String email;
  String fullname;
  int role;
  int id;


  JsonUser({
    this.email,
    this.fullname,
    this.role,
    this.id
  });

  factory JsonUser.fromJson(Map<String, dynamic> parsedJson) {
    Map json = parsedJson['user'];
    return JsonUser(
      email: json['email'],
      fullname: json['fullname'],
      role: json['role'],
      id: json['id'],
    );
  }
}