import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_way_frontend/shared/models/team_model.dart';

void main() {
  group('TeamModel Tests', () {
    test('fromJson() should parse full team data correctly', () {
      final json = {
        'name': 'Team Alpha',
        'description': 'Test team description',
        'open': true,
        'zone': 'Barcelona',
        'numMembers': 5,
        'creatorUsername': 'creator123'
      };

      final team = TeamModel.fromJson(json);

      expect(team.name, 'Team Alpha');
      expect(team.description, 'Test team description');
      expect(team.open, true);
      expect(team.zone, 'Barcelona');
      expect(team.numMembers, 5);
      expect(team.creatorUsername, 'creator123');
    });

    test('toJson() should return correct map', () {
      const team = TeamModel(
        name: 'Team Beta',
        zone: 'Girona',
        open: false,
        creatorUsername: 'user1'
      );

      final json = team.toJson();

      expect(json['name'], 'Team Beta');
      expect(json['zone'], 'Girona');
      expect(json['open'], false);
      expect(json['creatorUsername'], 'user1');
    });

    test('toUpdateJson() should not include name or creatorUsername', () {
      const team = TeamModel(
        name: 'Fixed Name',
        description: 'New Desc',
        zone: 'Lleida',
        creatorUsername: 'admin'
      );

      final json = team.toUpdateJson();

      expect(json.containsKey('name'), false);
      expect(json.containsKey('creatorUsername'), false);
      expect(json['description'], 'New Desc');
      expect(json['zone'], 'Lleida');
    });
  });
}
