import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/application_model.dart';

class JobApplicationsScreen extends StatefulWidget {
  final String jobId;
  const JobApplicationsScreen({super.key, required this.jobId});

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<ApplicationModel>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _applicationsFuture = _apiService.getJobApplications(widget.jobId);
  }

  Future<void> _updateStatus(String applicationId, String newStatus) async {
    try {
      await _apiService.updateApplicationStatus(applicationId, newStatus);
      if (mounted) {
        setState(() {
          _applicationsFuture = _apiService.getJobApplications(widget.jobId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Applications')),
      body: FutureBuilder<List<ApplicationModel>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No applications yet.'));
          }

          final applications = snapshot.data!;
          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              final applicant = app.applicant as Map<String, dynamic>; // Assuming populated

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: applicant['profileImage'] != null && applicant['profileImage'].isNotEmpty
                              ? NetworkImage(applicant['profileImage'])
                              : null,
                          child: applicant['profileImage'] == null || applicant['profileImage'].isEmpty
                              ? Text(applicant['firstName'][0])
                              : null,
                        ),
                        title: Text('${applicant['firstName']} ${applicant['lastName']}'),
                        subtitle: Text(applicant['email']),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status: ${app.status.toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: app.status,
                            items: const [
                              DropdownMenuItem(value: 'applied', child: Text('Applied')),
                              DropdownMenuItem(value: 'interview', child: Text('Interview')),
                              DropdownMenuItem(value: 'hired', child: Text('Hired')),
                              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                            ],
                            onChanged: (val) {
                              if (val != null) _updateStatus(app.id, val);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
