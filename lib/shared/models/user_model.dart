class User {
  // Asumimos que el backend envía un ID, aunque no salga explícito en el DTO de creación
  final int userId;
  final String nom;
  final String username;
  final String email;
  // Nullable: null significa que el usuario no pertenece a ningún equipo
  String? team;

  User({
    required this.userId,
    required this.nom,
    required this.username,
    required this.email,
    this.team,
  });

  /// Retorna true si l'usuari pertany a un equip
  bool get hasTeam => team != null && team!.isNotEmpty;

  User copyWith({
    int? userId,
    String? nom,
    String? username,
    String? email,
    String? team,
  }) {
    return User(
      userId: userId ?? this.userId,
      nom: nom ?? this.nom,
      username: username ?? this.username,
      email: email ?? this.email,
      team: team ?? this.team,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // El backend pot usar 'team_name' (UserDTO) o 'team' (dèsat localment)
    final teamValue = json['team_name'] ?? json['team'];
    return User(
      userId: json['user_id'] ?? 0,
      nom: json['nom'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      team: (teamValue == null || teamValue == '') ? null : teamValue as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nom': nom,
      'username': username,
      'email': email,
      'team': team,
    };
  }
}