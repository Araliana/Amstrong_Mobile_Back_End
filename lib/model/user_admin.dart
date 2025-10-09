class UserAdmin {
  final int id;
  final String username;
  final String? img;
  final String password;
  final DateTime? lastLogin;
  final DateTime? createdAt;

  UserAdmin({
    required this.id,
    required this.username,
    this.img,
    required this.password,
    this.lastLogin,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'img': img,
      'password': password,
      'last_login': lastLogin,
      'created_at': createdAt,
    };
  }

  factory UserAdmin.fromMap(Map<String, dynamic> map) {
    return UserAdmin(
      id: map['id'],
      username: map['username'],
      img: map['img'],
      password: map['password'],
      lastLogin: map['last_login'],
      createdAt: map['created_at'],
    );
  }
}
