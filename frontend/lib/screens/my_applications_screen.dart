import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/application_model.dart';
import '../models/job_model.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<ApplicationModel>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshApplications();
  }

  void _refreshApplications() {
    setState(() {
      _applicationsFuture = _apiService.getMyApplications();
    });
  }

  Future<void> _withdraw(String applicationId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application'),
        content: const Text('Are you sure you want to withdraw this application?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Withdraw', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.withdrawApplication(applicationId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application withdrawn')));
          _refreshApplications();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'hired': return Colors.green;
      case 'rejected': return Colors.red;
      case 'interview': return Colors.orange;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: FutureBuilder<List<ApplicationModel>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You have not applied to any jobs.'));
          }

          final applications = snapshot.data!;
          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              final job = app.job as JobModel; // Assuming populated as JobModel

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  job.company,
                                  style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          if (app.status == 'applied' || app.status == 'interview')
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                              tooltip: 'Withdraw Application',
                              onPressed: () => _withdraw(app.id),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildStatusStepper(app.status),
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

  Widget _buildStatusStepper(String currentStatus) {
    int currentStep = 0;
    if (currentStatus == 'applied') currentStep = 0;
    if (currentStatus == 'interview') currentStep = 1;
    if (currentStatus == 'hired' || currentStatus == 'rejected') currentStep = 2;

    return Row(
      children: [
        _buildStep(0, 'Applied', currentStep >= 0, currentStatus == 'applied'),
        _buildConnector(currentStep >= 1),
        _buildStep(1, 'Interview', currentStep >= 1, currentStatus == 'interview'),
        _buildConnector(currentStep >= 2),
        _buildStep(
          2,
          currentStatus == 'rejected' ? 'Rejected' : 'Result',
          currentStep >= 2,
          currentStatus == 'hired' || currentStatus == 'rejected',
          isRejected: currentStatus == 'rejected',
        ),
      ],
    );
  }

  Widget _buildStep(int step, String label, bool isActive, bool isCurrent, {bool isRejected = false}) {
    Color color = isActive ? (isRejected ? Colors.red : Colors.blueAccent) : Colors.grey[300]!;
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color,
          child: isCurrent
              ? const Icon(Icons.circle, size: 8, color: Colors.white)
              : (isActive ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isActive ? Colors.blueAccent : Colors.grey[300],
      ),
    );
  }
}
