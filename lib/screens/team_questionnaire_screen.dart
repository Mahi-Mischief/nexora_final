import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexora_final/services/team_service.dart';

class TeamQuestionnaireScreen extends StatefulWidget {
  final String school;
  const TeamQuestionnaireScreen({super.key, required this.school});

  @override
  State<TeamQuestionnaireScreen> createState() => _TeamQuestionnaireScreenState();
}

class _TeamQuestionnaireScreenState extends State<TeamQuestionnaireScreen> {
  String? _selectedEventType;
  String? _selectedEvent;
  int? _memberCount;
  bool _loading = false;

  final List<String> _eventTypes = ['Presentation', 'Roleplay', 'Test'];

  final Map<String, List<String>> _events = {
    'Presentation': [
      'Business Plan',
      'Digital Citizenship',
      'Financial Consulting',
      'Global Business Management',
      'Management Decision Making',
      'Social Media Marketing',
    ],
    'Roleplay': [
      'Client Service',
      'Coding & Programming',
      'Network Design',
      'Sales Presentation',
    ],
    'Test': [
      'Accounting',
      'Business Calculation',
      'Entrepreneurship',
      'Finance',
      'Hospitality Management',
      'Management Information Systems',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a Team')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Setup',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Event Type Question
            const Text(
              'What type of event are you competing in?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedEventType,
              hint: const Text('Select event type'),
              items: _eventTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEventType = value;
                  _selectedEvent = null;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Event Name Question (show only if not Test)
            if (_selectedEventType != null && _selectedEventType != 'Test')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Which specific event?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedEvent,
                    hint: const Text('Select event'),
                    items: (_events[_selectedEventType] ?? []).map((event) {
                      return DropdownMenuItem(
                        value: event,
                        child: Text(event),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedEvent = value);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              )
            else if (_selectedEventType == 'Test')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Which test?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedEvent,
                    hint: const Text('Select test'),
                    items: (_events['Test'] ?? []).map((event) {
                      return DropdownMenuItem(
                        value: event,
                        child: Text(event),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedEvent = value);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Member Count Question
            const Text(
              'How many members in your team?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter number of members',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (value) {
                setState(() => _memberCount = int.tryParse(value));
              },
            ),
            const SizedBox(height: 32),

            // Create Team Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedEventType != null &&
                        _selectedEvent != null &&
                        _memberCount != null &&
                        _memberCount! > 0
                    ? _createTeam
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Team'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTeam() async {
    if (_selectedEventType == null || _selectedEvent == null || _memberCount == null) return;

    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('nexora_token');
      final user = prefs.getString('nexora_user');

      if (token == null || user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Not authenticated')),
        );
        return;
      }

      final teamName = 'Team $_selectedEvent';
      final team = await TeamService.createTeam(
        name: teamName,
        school: widget.school,
        eventType: _selectedEventType!.toLowerCase(),
        eventName: _selectedEvent!,
        memberCount: _memberCount!,
        token: token,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (team != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team created successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create team')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
