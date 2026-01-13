class Team {
  final int? id;
  final String name;
  final String school;
  final String eventType; // 'presentation', 'roleplay', 'test'
  final String eventName; // specific event (e.g., 'Business Plan', 'Social Media Challenge')
  final int memberCount;
  final int createdById;
  final String createdByUsername;
  final DateTime createdAt;

  Team({
    this.id,
    required this.name,
    required this.school,
    required this.eventType,
    required this.eventName,
    required this.memberCount,
    required this.createdById,
    required this.createdByUsername,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'school': school,
    'event_type': eventType,
    'event_name': eventName,
    'member_count': memberCount,
    'created_by': createdById,
    'created_by_username': createdByUsername,
    'created_at': createdAt.toIso8601String(),
  };

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'],
    name: json['name'] ?? '',
    school: json['school'] ?? '',
    eventType: json['event_type'] ?? 'presentation',
    eventName: json['event_name'] ?? '',
    memberCount: json['member_count'] ?? 0,
    createdById: json['created_by'] ?? 0,
    createdByUsername: json['created_by_username'] ?? '',
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
  );
}
