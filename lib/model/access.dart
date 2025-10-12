class Access {
  final int id;
  final String name;
  final String accessPath;
  final String category;
  final DateTime createdAt;

  Access({
    required this.id,
    required this.name,
    required this.accessPath,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'access_path': accessPath,
      'category': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Access.fromMap(Map<String, dynamic> map) {
    return Access(
      id: map['id'],
      name: map['name'],
      accessPath: map['access_path'],
      category: map['category'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
