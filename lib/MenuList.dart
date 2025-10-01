class MenuList {
  int? id;
  String name;
  String img;
  int price;
  String? description;

  MenuList({
    this.id,
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

  @override
  String toString() {
    return "id : $id\nname : $name\nimg : $img\nprice : $price\ndesc : $description";
  }
}
