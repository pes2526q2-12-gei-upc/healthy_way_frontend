class IndividualRanking {
  final int rank;
  final int user_id;
  final String name;
  final double distance;
  final int points;
  final String modality;
  final String scope;
  final String teamName;

  IndividualRanking({
    required this.rank,
    required this.user_id,
    required this.name,
    required this.distance,
    required this.points,
    required this.modality,
    required this.scope,
    this.teamName = '',

  });

  factory IndividualRanking.fromJson(Map<String, dynamic> json) {
    return IndividualRanking(
      rank: json['rank'] ?? 0,
      user_id: json['user_id'] ?? 0,
      name: json['nom'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      points: json['points'] ?? 0,
      modality: json['modality'] ?? '',
      scope: json['scope'] ?? '',
      teamName: json['teamName'] ?? '',
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