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