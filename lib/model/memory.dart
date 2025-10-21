class Memory {
  final int? id;
  final String name;
  final String category;
  final String quote;
  final String imagePath;
  final DateTime createdAt;

  Memory({
    this.id,
    required this.name,
    required this.category,
    required this.quote,
    required this.imagePath,
    required this.createdAt,
  });

  factory Memory.fromMap(Map<String, dynamic> map) => Memory(
    id: map['id'] as int?,
    name: map['name'] ?? '',
    category: map['category'] ?? '',
    quote: map['quote'] ?? '',
    imagePath: map['imagePath'] ?? '',
    createdAt: DateTime.parse(map['created_at']),
  );
}
