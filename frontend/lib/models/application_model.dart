import 'job_model.dart';

class ApplicationModel {
  final String id;
  final dynamic job; // String (id) or JobModel
  final dynamic applicant; // String (id) or Map (user details)
  final String status;
  final DateTime createdAt;

  ApplicationModel({
    required this.id,
    required this.job,
    required this.applicant,
    required this.status,
    required this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['_id'] ?? '',
      job: json['job'] is Map<String, dynamic> 
          ? JobModel.fromJson(json['job']) 
          : json['job'] ?? '',
      applicant: json['applicant'], 
      status: json['status'] ?? 'applied',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
