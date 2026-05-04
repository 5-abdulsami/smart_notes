import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 1)
class NoteModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  int order;

  @HiveField(6)
  bool isPinned;

  @HiveField(7)
  double fontSize;

  @HiveField(8)
  bool isBold;

  @HiveField(9)
  bool isUnderline;

  @HiveField(10)
  String? categoryId;

  NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.order = 0,
    this.isPinned = false,
    this.fontSize = 16.0,
    this.isBold = false,
    this.isUnderline = false,
    this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'order': order,
      'isPinned': isPinned,
      'fontSize': fontSize,
      'isBold': isBold,
      'isUnderline': isUnderline,
      'categoryId': categoryId,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      order: json['order'] ?? 0,
      isPinned: json['isPinned'] ?? false,
      fontSize: (json['fontSize'] ?? 16.0).toDouble(),
      isBold: json['isBold'] ?? false,
      isUnderline: json['isUnderline'] ?? false,
      categoryId: json['categoryId'],
    );
  }
}
