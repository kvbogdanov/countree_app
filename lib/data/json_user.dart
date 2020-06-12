class JsonUser {
  String email;
  String fullname;
  int role;
  int id;
  int idSystem;
  int totalTrees;
  int moderatedTrees;


  JsonUser({
    this.email,
    this.fullname,
    this.role,
    this.id,
    this.idSystem,
    this.totalTrees,
    this.moderatedTrees
  });

  factory JsonUser.fromJson(Map<String, dynamic> parsedJson) {
    Map json = parsedJson['user'];

    print(json);
    return JsonUser(
      email: json['email'],
      fullname: json['fullname'],
      role: json['role'],
      id: json['id'],
      idSystem: (json['id'] is int)?json['id']:int.parse(json['id']),
      totalTrees: (json['total_trees'] is int)?json['total_trees']:int.parse(json['total_trees']),
      moderatedTrees: (json['moderated_trees'] is int)?json['moderated_trees']:int.parse(json['moderated_trees'])
    );
  }
}