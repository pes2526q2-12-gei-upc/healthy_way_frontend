// Model que reflecteix el TeamDTO de la API
class TeamModel {
  final String name;
  final String? description;
  final bool open;
  final String zone; // 'Barcelona' | 'Girona' | 'Lleida' | 'Tarragona'
  final int numMembers;
  final String? creatorUsername; // Nom d'usuari del creador

  const TeamModel({
    required this.name,
    this.description,
    this.open = true,
    required this.zone,
    this.numMembers = 0,
    this.creatorUsername,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      name: json['name'] ?? '',
      description: json['description'] as String?,
      open: json['open'] ?? true,
      zone: json['zone'] ?? '',
      numMembers: json['numMembers'] ?? 0,
      creatorUsername: json['creatorUsername'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'open': open,
      'zone': zone,
      if (creatorUsername != null) 'creatorUsername': creatorUsername,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      if (description != null) 'description': description,
      'open': open,
      'zone': zone,
    };
  }
}
