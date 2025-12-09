class Category {
  final String id;
  final String name;
  final DateTime? createdAt;

  Category({required this.id, required this.name, this.createdAt});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'created_at': createdAt?.toIso8601String()};
  }
}
