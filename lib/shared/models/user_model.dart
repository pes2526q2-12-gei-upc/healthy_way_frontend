class User {
  final int userId;
  final String nom;
  final String username;
  final String email;
  String? team;
  double? totalRunningDistance;
  double? totalCyclingDistance;
  int? totalPoints;

  User({
    required this.userId,
    required this.nom,
    required this.username,
    required this.email,
    this.team,
    this.totalRunningDistance,
    this.totalCyclingDistance,
    this.totalPoints,
  });

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
    final teamValue = json['team_name'] ?? json['team'];
    return User(
      userId: json['user_id'] ?? 0,
      nom: json['nom'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      team: (teamValue == null || teamValue == '') ? null : teamValue as String,
      totalRunningDistance: json['total_running_distance'] != null ? (json['total_running_distance'] as num).toDouble() : null,
      totalCyclingDistance: json['total_cycling_distance'] != null ? (json['total_cycling_distance'] as num).toDouble() : null,
      totalPoints: json['total_points'] != null ? (json['total_points'] as num).toInt() : null,
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