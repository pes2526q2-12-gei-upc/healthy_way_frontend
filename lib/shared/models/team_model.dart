// Model que reflecteix el TeamDTO de la API
class TeamModel {
  final String name;
  final String? description;
  final bool open;
  final String zone; // 'Barcelona' | 'Girona' | 'Lleida' | 'Tarragona'
  final String modality; // 'running' | 'cycling'
  final int numMembers;

  const TeamModel({
    required this.name,
    this.description,
    this.open = true,
    required this.zone,
    required this.modality,
    this.numMembers = 0,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      name: json['name'] ?? '',
      description: json['description'] as String?,
      open: json['open'] ?? true,
      zone: json['zone'] ?? '',
      modality: json['modality'] ?? '',
      numMembers: json['numMembers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'open': open,
      'zone': zone,
      'modality': modality,
      'numMembers': numMembers,
    };
  }
}
