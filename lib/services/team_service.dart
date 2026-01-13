import 'dart:convert';
import 'package:nexora_final/services/api.dart';
import 'package:nexora_final/models/team.dart';
import 'package:nexora_final/models/team_task.dart';

class TeamService {
  static Future<List<Team>> fetchTeamsBySchool(String school, {String? token}) async {
    final resp = await Api.get('/api/teams/school?school=$school', token: token);
    if (resp.statusCode == 200) {
      final j = jsonDecode(resp.body) as List<dynamic>;
      return j.map((team) => Team.fromJson(team as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static Future<Team?> createTeam({
    required String name,
    required String school,
    required String eventType,
    required String eventName,
    required int memberCount,
    required String token,
  }) async {
    final resp = await Api.post(
      '/api/teams',
      body: {
        'name': name,
        'school': school,
        'event_type': eventType,
        'event_name': eventName,
        'member_count': memberCount,
      },
      token: token,
    );

    if (resp.statusCode == 201) {
      final j = jsonDecode(resp.body) as Map<String, dynamic>;
      return Team.fromJson(j);
    }
    return null;
  }

  static Future<bool> joinTeam(int teamId, {required String token}) async {
    final resp = await Api.post(
      '/api/teams/$teamId/join',
      token: token,
    );
    return resp.statusCode == 200;
  }

  static Future<bool> leaveTeam(int teamId, {required String token}) async {
    final resp = await Api.post(
      '/api/teams/$teamId/leave',
      token: token,
    );
    return resp.statusCode == 200;
  }

  static Future<Team?> getUserTeam({required String token}) async {
    final resp = await Api.get('/api/teams/user/current', token: token);
    if (resp.statusCode == 200) {
      if (resp.body.isEmpty || resp.body.trim() == 'null') return null;
      final decoded = jsonDecode(resp.body);
      if (decoded == null) return null;
      if (decoded is Map<String, dynamic>) {
        return Team.fromJson(decoded);
      }
    }
    return null;
  }

  // Task Operations

  static Future<List<TeamTask>> fetchTeamTasks(int teamId, {String? token}) async {
    final resp = await Api.get('/api/teams/$teamId/tasks', token: token);
    if (resp.statusCode == 200) {
      final j = jsonDecode(resp.body) as List<dynamic>;
      return j.map((task) => TeamTask.fromJson(task as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static Future<bool> createTask(int teamId, String title, {required String token}) async {
    final resp = await Api.post(
      '/api/teams/$teamId/tasks',
      body: {'title': title},
      token: token,
    );
    return resp.statusCode == 201;
  }

  static Future<bool> updateTask(int teamId, int taskId, bool isCompleted, {required String token}) async {
    final resp = await Api.put(
      '/api/teams/$teamId/tasks/$taskId',
      body: {'is_completed': isCompleted},
      token: token,
    );
    return resp.statusCode == 200;
  }

  static Future<bool> deleteTask(int teamId, int taskId, {required String token}) async {
    final resp = await Api.delete(
      '/api/teams/$teamId/tasks/$taskId',
      token: token,
    );
    return resp.statusCode == 200;
  }
}
