import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:healthy_way_frontend/core/services/team_service.dart';
import 'package:healthy_way_frontend/shared/models/team_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('TeamService Tests', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});

    test('getTeamByName() should return TeamModel on 200', () async {
      final mockClient = MockClient((request) async {
        final jsonResponse = {
          'name': 'Team Alpha',
          'zone': 'Barcelona',
          'open': true,
          'numMembers': 3
        };
        return http.Response(jsonEncode(jsonResponse), 200);
      });

      final service = TeamService(client: mockClient);
      final team = await service.getTeamByName('Team Alpha');

      expect(team, isNotNull);
      expect(team!.name, 'Team Alpha');
      expect(team.numMembers, 3);
    });

    test('createTeam() should return created TeamModel on 201', () async {
      final mockClient = MockClient((request) async {
        final jsonResponse = {
          'name': 'New Team',
          'zone': 'Girona',
          'open': true,
          'numMembers': 1
        };
        return http.Response(jsonEncode(jsonResponse), 201);
      });

      final service = TeamService(client: mockClient);
      const newTeam = TeamModel(name: 'New Team', zone: 'Girona');
      final result = await service.createTeam(newTeam);

      expect(result, isNotNull);
      expect(result!.name, 'New Team');
    });

    test('joinTeam() should return true on 200/201', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['username'], 'testuser');
        return http.Response('', 200);
      });

      final service = TeamService(client: mockClient);
      final success = await service.joinTeam('TeamX', 'testuser');

      expect(success, true);
    });

    test('getAllTeams() should return list of teams on 200', () async {
      final mockClient = MockClient((request) async {
        final jsonResponse = [
          {'name': 'Team1', 'zone': 'BCN', 'numMembers': 10},
          {'name': 'Team2', 'zone': 'BCN', 'numMembers': 5},
        ];
        return http.Response(jsonEncode(jsonResponse), 200);
      });

      final service = TeamService(client: mockClient);
      final teams = await service.getAllTeams();

      expect(teams.length, 2);
      expect(teams[0].name, 'Team1');
      expect(teams[1].name, 'Team2');
    });
  });
}
