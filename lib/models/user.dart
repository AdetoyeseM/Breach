class User {
  final String id;
  final String email;
  final String? name;
  final List<String> interests;

  User({
    required this.id,
    required this.email,
    this.name,
    this.interests = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      interests: List<String>.from(json['interests'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'interests': interests,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    List<String>? interests,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      interests: interests ?? this.interests,
    );
  }
}
