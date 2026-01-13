import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildFaqItem(
              'How do I create a team?',
              'Go to the Teams tab and click "Create a Team". Answer the questionnaire about your event type, specific event, and number of members.',
            ),
            _buildFaqItem(
              'How do I join a team?',
              'Go to the Teams tab to see available teams at your school. Click "Join" on a team you want to join.',
            ),
            _buildFaqItem(
              'Can I be in multiple teams?',
              'No, you can only be part of one team at a time. Leave your current team first if you want to join another.',
            ),
            _buildFaqItem(
              'How do I create tasks for my team?',
              'When viewing your team, click the "Add Task" button to create to-do items for your team members.',
            ),
            _buildFaqItem(
              'How do I update my profile?',
              'Click "Edit Profile" in the drawer menu to update your school, grade, and other information.',
            ),
            _buildFaqItem(
              'Where can I find FBLA resources?',
              'When you\'re in a team, the Resources section shows a link to the official FBLA competitive events page.',
            ),
            const SizedBox(height: 32),
            const Text(
              'Need More Help?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you have questions not answered here, contact your FBLA chapter advisor or visit the official FBLA website.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          answer,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
