//Modelo activity con los atributos distance: number,start_time: Date,end_time: Date,modality: string,pace: number,route_id: number;

class Activity {
  final double distance;
  final DateTime startTime;
  final DateTime endTime;
  final String modality;
  final double pace;
  final int routeId;

  Activity({
    required this.distance,
    required this.startTime,
    required this.endTime,
    required this.modality,
    required this.pace,
    required this.routeId,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      distance: json['distance']?.toDouble() ?? 0.0,
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      modality: json['modality'] ?? '',
      pace: json['pace']?.toDouble() ?? 0.0,
      routeId: json['route_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'modality': modality,
      'pace': pace,
      'route_id': routeId,
    };
  }
}

