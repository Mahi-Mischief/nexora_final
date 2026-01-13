class TeamTask {
  final int id;
  final int teamId;
  final String title;
  final bool isCompleted;
  final String createdBy;
  final int createdById;
  final DateTime createdAt;

  TeamTask({
    required this.id,
    required this.teamId,
    required this.title,
    required this.isCompleted,
    required this.createdBy,
    required this.createdById,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'team_id': teamId,
    'title': title,
    'is_completed': isCompleted,
    'created_by': createdBy,
    'created_by_id': createdById,
    'created_at': createdAt.toIso8601String(),
  };

  factory TeamTask.fromJson(Map<String, dynamic> json) => TeamTask(
    id: json['id'] ?? 0,
    teamId: json['team_id'] ?? 0,
    title: json['title'] ?? '',
    isCompleted: json['is_completed'] ?? false,
    createdBy: json['created_by'] ?? 'Unknown',
    createdById: json['created_by_id'] ?? 0,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
  );
}
