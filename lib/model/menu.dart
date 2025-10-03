class Menu {
  final int id;
  final String name;
  final String img;
  final int price;
  final String? description;

  Menu({
    required this.id,
    required this.name,
    required this.img,
    required this.price,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'img': img,
      'price': price,
      'description': description,
    };
  }

  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      id: map['id'],
      name: map['name'],
      img: map['img'],
      price: map['price'],
      description: map['description'],
    );
  }
}
