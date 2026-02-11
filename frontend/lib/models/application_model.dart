import 'job_model.dart';

class ApplicationModel {
  final String id;
  final dynamic job; // String (id) or JobModel
  final dynamic applicant; // String (id) or Map (user details)
  final String status;
  final DateTime createdAt;
  final DateTime? interviewDate;
  final String? interviewLocation;

  ApplicationModel({
    required this.id,
    required this.job,
    required this.applicant,
    required this.status,
    required this.createdAt,
    this.interviewDate,
    this.interviewLocation,
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
      interviewDate: json['interviewDate'] != null ? DateTime.parse(json['interviewDate']) : null,
      interviewLocation: json['interviewLocation'],
    );
  }
}
