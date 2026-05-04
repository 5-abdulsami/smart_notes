import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 4)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue;

  @HiveField(3)
  int order;

  @HiveField(4)
  DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.colorValue = 0xFF2196F3, // Default blue
    required this.order,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      colorValue: json['colorValue'] ?? 0xFF2196F3,
      order: json['order'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
