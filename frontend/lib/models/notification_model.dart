class NotificationModel {
  final String id;
  final String receiverId;
  final String type;
  final Map<String, dynamic>? relatedUser;
  final Map<String, dynamic>? relatedPost;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.receiverId,
    required this.type,
    this.relatedUser,
    this.relatedPost,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      receiverId: json['receiver'] ?? '',
      type: json['type'] ?? '',
      relatedUser: json['relatedUser'] is Map<String, dynamic> ? json['relatedUser'] : null,
      relatedPost: json['relatedPost'] is Map<String, dynamic> ? json['relatedPost'] : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
