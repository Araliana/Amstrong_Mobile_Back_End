enum MenuType { makanan, minuman, cemilan, desert }

class Menu {
  final int id;
  final String name;
  final String img;
  final int price;
  final String description;
  final MenuType category;
  final bool isActive;
  final DateTime createdAt;

  Menu({
    required this.id,
    required this.name,
    required this.img,
    required this.price,
    required this.description,
    required this.category,
    required this.isActive,
    required this.createdAt,
  });

  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      id: map['id'],
      name: map['name'],
      img: map['img'],
      price: map['price'],
      description: map['description'],
      category: map['category'],
      isActive: map['is_active'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
