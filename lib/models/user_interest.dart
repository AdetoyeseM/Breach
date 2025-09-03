import 'category_models.dart';

class UserInterest {
  final int id;
  final Category category;
  final User user;

  UserInterest({
    required this.id,
    required this.category,
    required this.user,
  });

  factory UserInterest.fromJson(Map<String, dynamic> json) {
    return UserInterest(
      id: json['id'],
      category: Category.fromJson(json['category']),
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.toJson(),
      'user': user.toJson(),
    };
  }
}


