class IndividualRanking {
  final int totalPoints;
  final double totalDistance;
  final String name;
  final int userId;
  final String teamName;

  IndividualRanking({
    required this.totalPoints,
    required this.totalDistance,
    required this.name,
    required this.userId,
    required this.teamName,
  });

  factory IndividualRanking.fromJson(Map<String, dynamic> json) {
    return IndividualRanking(
      totalPoints: json['total_points'] ?? 0,
      totalDistance: (json['total_distance'] as num?)?.toDouble() ?? 0.0,
      name: json['nom'] ?? '',
      userId: json['user_id'] ?? 0,
      teamName: json['team_name'] ?? 'none',
    );
  }
}

class TeamRanking {
  final String name;
  final String zone;
  final int points;
  final double distance;

  TeamRanking({
    required this.name,
    required this.zone,
    required this.points,
    required this.distance,
  });

  factory TeamRanking.fromJson(Map<String, dynamic> json) {
    return TeamRanking(
      name: json['name'] ?? '',
      zone: json['zone'] ?? '',
      points: json['points'] ?? 0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}