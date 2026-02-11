class JobModel {
  final String id;
  final String title;
  final String description;
  final String company;
  final String location;
  final String salary;
  final String? contactName;
  final String? contactEmail;
  final List<String> requirements;
  final Map<String, dynamic>? postedBy;
  final List<String> applicants;
  final DateTime createdAt;
  final bool isApplied;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    required this.salary,
    this.contactName,
    this.contactEmail,
    required this.requirements,
    this.postedBy,
    required this.applicants,
    required this.createdAt,
    this.isApplied = false,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      contactName: json['contactName'],
      contactEmail: json['contactEmail'],
      requirements: List<String>.from(json['requirements'] ?? []),
      postedBy: json['postedBy'] is Map<String, dynamic> ? json['postedBy'] : null,
      applicants: List<String>.from(json['applicants'] ?? []),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isApplied: json['isApplied'] ?? false,
    );
  }
}
