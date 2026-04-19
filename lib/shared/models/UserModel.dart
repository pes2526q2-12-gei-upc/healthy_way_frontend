class User {
  // Asumimos que el backend envía un ID, aunque no salga explícito en el DTO de creación
  final int userId;
  final String nom;
  final String username;
  final String email;

  User({
    required this.userId,
    required this.nom,
    required this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      nom: json['nom'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nom': nom,
      'username': username,
      'email': email,
    };
  }
}