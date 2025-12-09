class Memo {
  final String id;
  final String name;
  final String quote;
  final String category;
  final String img;
  final bool isActive;

  Memo({
    required this.id,
    required this.name,
    required this.quote,
    required this.img,
    required this.category,
    required this.isActive,
  });

  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'] as String,
      name: map['name'] as String,
      quote: map['quote'] as String,
      img: map['img'] as String,
      category: map['category'],
      isActive: map['is_active'],
    );
  }
}
