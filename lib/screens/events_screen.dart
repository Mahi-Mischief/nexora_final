import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexora_final/services/team_service.dart';
import 'package:nexora_final/models/team.dart';
import 'package:nexora_final/models/team_task.dart';
import 'package:nexora_final/screens/team_questionnaire_screen.dart';
import 'dart:convert';
import 'package:nexora_final/models/user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nexora_final/providers/auth_provider.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Teams'),
            Tab(text: 'Volunteering'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTeamsTab(),
          _buildVolunteeringTab(),
        ],
      ),
    );
  }

  Widget _buildTeamsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadTeamData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Error loading teams'));
        }

        final data = snapshot.data!;
        final teams = data['teams'] as List<Team>? ?? [];
        final userTeamId = data['userTeamId'] as int?;
        final userTeam = data['userTeam'] as Team?;

        // If user is in a team, show team detail view
        if (userTeam != null && userTeamId != null) {
          return _buildTeamDetailView(userTeam);
        }

        // Otherwise show team list for joining
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create a Team'),
                onPressed: () async {
                  final school = data['school'] as String? ?? 'Unknown';
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => TeamQuestionnaireScreen(school: school),
                    ),
                  );
                  if (result == true && mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
            Expanded(
              child: teams.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text(
                              'No teams yet',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to create a team for your school!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        final isUserInTeam = userTeamId == team.id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              Icons.group,
                              color: isUserInTeam ? Colors.green : Colors.grey,
                            ),
                            title: Text(
                              team.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${team.eventType.capitalize()} - ${team.eventName}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.people, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${team.memberCount} members',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Led by ${team.createdByUsername}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: isUserInTeam
                                ? const Chip(label: Text('Joined'))
                                : ElevatedButton(
                                    onPressed: () => _joinTeam(team.id!),
                                    child: const Text('Join'),
                                  ),
                            onTap: isUserInTeam
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(team.name),
                                        content: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Event: ${team.eventType} - ${team.eventName}'),
                                            const SizedBox(height: 8),
                                            Text('Members: ${team.memberCount}'),
                                            const SizedBox(height: 8),
                                            Text('Leader: ${team.createdByUsername}'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _joinTeam(team.id!);
                                            },
                                            child: const Text('Join Team'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeamDetailView(Team team) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${team.eventType.capitalize()} - ${team.eventName}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${team.memberCount} members'),
                        const SizedBox(width: 16),
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('Led by ${team.createdByUsername}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // FBLA Documents Link
            const Text(
              'Resources',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description, color: Colors.blue),
                title: const Text('FBLA Official Documents & Rubrics'),
                subtitle: const Text('View scoring rubrics and guidelines'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () async {
                  final url = 'https://www.fbla.org/participants/competitive-events/';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // To-Do List Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Event To-Do List',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddTaskDialog(team.id!),
                  tooltip: 'Add task',
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<TeamTask>>(
              future: () async {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('nexora_token');
                return TeamService.fetchTeamTasks(team.id!, token: token);
              }(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.checklist, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No tasks yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            if (team.id != null) {
                              _toggleTask(team.id!, task.id, value ?? false);
                            }
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Colors.grey[600] : null,
                          ),
                        ),
                        subtitle: Text(
                          'By ${task.createdBy}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: team.id != null
                              ? () => _deleteTask(team.id!, task.id)
                              : null,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _loadTeamData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('nexora_token');
    final userJson = prefs.getString('nexora_user');

    if (token == null || userJson == null) {
      return {};
    }

    final user = NexoraUser.fromJson(jsonDecode(userJson));
    final school = user.school ?? 'Unknown';
    final teams = await TeamService.fetchTeamsBySchool(school, token: token);
    final userTeam = await TeamService.getUserTeam(token: token);

    return {
      'teams': teams,
      'userTeamId': userTeam?.id,
      'userTeam': userTeam,
      'school': school,
    };
  }

  Future<void> _joinTeam(int teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('nexora_token');

    if (token == null) return;

    final success = await TeamService.joinTeam(teamId, token: token);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined team!')),
      );
      setState(() {});
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join team. You may already be in a team.')),
      );
    }
  }

  Future<void> _showAddTaskDialog(int teamId) async {
    final controller = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter task description',
            border: OutlineInputBorder(),
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _createTask(teamId, controller.text);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _createTask(int teamId, String title) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('nexora_token');

    if (token == null) return;

    final success = await TeamService.createTask(teamId, title, token: token);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added!')),
      );
      setState(() {});
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add task')),
      );
    }
  }

  Future<void> _toggleTask(int teamId, int taskId, bool isCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('nexora_token');

    if (token == null) return;

    final success = await TeamService.updateTask(teamId, taskId, isCompleted, token: token);
    if (success && mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteTask(int teamId, int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('nexora_token');

    if (token == null) return;

    final success = await TeamService.deleteTask(teamId, taskId, token: token);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted')),
      );
      setState(() {});
    }
  }

  Widget _buildVolunteeringTab() {
    final user = ref.watch(authProvider).user;
    final isTeacher = user?.role?.toLowerCase() == 'teacher';
    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadVolunteeringEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data ?? [];

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Available Opportunities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (isTeacher)
                      ElevatedButton.icon(
                        onPressed: () => _showCreateEventDialog(context, user),
                        icon: const Icon(Icons.add),
                        label: const Text('Create'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (events.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.volunteer_activism, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text('No volunteering events yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            isTeacher ? 'Create one to get started!' : 'Check back later for opportunities',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      event['title'] ?? 'Untitled Event',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isTeacher && event['createdBy'] == user?.id)
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () => _deleteEvent(context, index),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(event['description'] ?? '', style: TextStyle(color: Colors.grey[700])),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text('${event['hours']} hours', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      const SizedBox(width: 16),
                                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(event['location'] ?? 'TBD', style: TextStyle(fontSize: 12, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Created by: ${event['createdByName'] ?? 'Unknown'}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }

  Future<List<Map<String, dynamic>>> _loadVolunteeringEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('volunteering_events');
    if (eventsJson == null) return [];
    try {
      final decoded = jsonDecode(eventsJson) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveVolunteeringEvents(List<Map<String, dynamic>> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('volunteering_events', jsonEncode(events));
  }

  void _showCreateEventDialog(BuildContext context, NexoraUser? user) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    double hours = 1.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Volunteering Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Event Title', hintText: 'e.g., Community Cleanup'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description', hintText: 'What will volunteers do?'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location', hintText: 'Where will this happen?'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text('Hours: ${hours.toStringAsFixed(1)}', style: const TextStyle(fontSize: 14)),
                    ),
                    SizedBox(
                      width: 100,
                      child: Slider(
                        value: hours,
                        min: 0.5,
                        max: 8,
                        divisions: 15,
                        onChanged: (value) => setState(() => hours = value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an event title')),
                  );
                  return;
                }

                final events = await _loadVolunteeringEvents();
                final newEvent = {
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'location': locationController.text.isEmpty ? 'TBD' : locationController.text,
                  'hours': hours,
                  'createdAt': DateTime.now().toIso8601String(),
                  'createdBy': user?.id ?? 0,
                  'createdByName': '${user?.firstName ?? ""} ${user?.lastName ?? ""}'.trim(),
                };

                // Get user info properly
                final scaffold = ScaffoldMessenger.of(context);
                if (mounted) {
                  Navigator.pop(context);
                }

                events.add(newEvent);
                await _saveVolunteeringEvents(events);
                setState(() {});

                scaffold.showSnackBar(
                  const SnackBar(content: Text('Event created successfully!')),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteEvent(BuildContext context, int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final events = await _loadVolunteeringEvents();
              events.removeAt(index);
              await _saveVolunteeringEvents(events);
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
