import 'package:flutter_application_1/model/category.dart';

class Menu {
  final String id;
  final String name;
  final String img;
  final double price;
  final String description;
  final int typeId;
  final Category category;
  final bool isActive;

  Menu({
    required this.id,
    required this.name,
    required this.img,
    required this.price,
    required this.description,
    required this.typeId,
    required this.category,
    required this.isActive,
  });
  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      id: map['id'],
      name: map['name'],
      img: map['img'],
      price: map['price'],
      description: map['description'],
      category: Category.fromMap(
        (map['dish_type'] as Map).cast<String, dynamic>(),
      ),
      typeId: map['type_id'],
      isActive: map['is_active'] == 1,
    );
  }
}
