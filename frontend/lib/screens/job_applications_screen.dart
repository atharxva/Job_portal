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
  List<ApplicationModel> _allApplications = [];
  List<ApplicationModel> _filteredApplications = [];
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  void _fetchApplications() async {
    _applicationsFuture = _apiService.getJobApplications(widget.jobId);
    _allApplications = await _applicationsFuture;
    _filterApplications();
  }

  void _filterApplications() {
    setState(() {
      if (_selectedStatus == 'all') {
        _filteredApplications = _allApplications;
      } else {
        _filteredApplications = _allApplications.where((app) => app.status == _selectedStatus).toList();
      }
    });
  }

  Future<void> _updateStatus(String applicationId, String newStatus) async {
    try {
      await _apiService.updateApplicationStatus(applicationId, newStatus);
      if (mounted) {
        _fetchApplications();
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
      appBar: AppBar(title: const Text('Job Applications')),
      body: FutureBuilder<List<ApplicationModel>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _allApplications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: ['all', 'applied', 'interview', 'hired', 'rejected'].map((status) {
                    final isSelected = _selectedStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(status.toUpperCase(), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                        selected: isSelected,
                        selectedColor: _getStatusColor(status),
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedStatus = status;
                            _filterApplications();
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: _filteredApplications.isEmpty
                    ? Center(child: Text('No $_selectedStatus applications.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _filteredApplications.length,
                        itemBuilder: (context, index) {
                          final app = _filteredApplications[index];
                          final applicant = app.applicant as Map<String, dynamic>;

                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundImage: applicant['profileImage'] != null && applicant['profileImage'].isNotEmpty
                                          ? NetworkImage(applicant['profileImage'])
                                          : null,
                                      child: applicant['profileImage'] == null || applicant['profileImage'].isEmpty ? Text(applicant['firstName'][0]) : null,
                                    ),
                                    title: Text('${applicant['firstName']} ${applicant['lastName']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(applicant['email']),
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(app.status).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          app.status.toUpperCase(),
                                          style: TextStyle(color: _getStatusColor(app.status), fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      DropdownButton<String>(
                                        value: app.status,
                                        underline: Container(),
                                        icon: const Icon(Icons.edit_outlined, size: 20),
                                        items: const [
                                          DropdownMenuItem(value: 'applied', child: Text('Applied')),
                                          DropdownMenuItem(value: 'interview', child: Text('Interview')),
                                          DropdownMenuItem(value: 'hired', child: Text('Hired')),
                                          DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                                        ],
                                        onChanged: (val) {
                                          if (val == 'interview') {
                                            _showScheduleDialog(app.id);
                                          } else if (val != null) {
                                            _updateStatus(app.id, val);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  if (app.interviewDate != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.event, size: 16, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Interview: ${app.interviewDate!.day}/${app.interviewDate!.month}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.location_on, size: 16, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              app.interviewLocation ?? 'Online',
                                              style: const TextStyle(fontSize: 12, color: Colors.orange),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showScheduleDialog(String applicationId) async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final TextEditingController locationController = TextEditingController(text: 'Google Meet / Office');

    final bool? schedule = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Interview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Select Date'),
              subtitle: Text('${selectedDate.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) selectedDate = picked;
              },
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location / Link'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm Schedule'),
          ),
        ],
      ),
    );

    if (schedule == true) {
      try {
        await _apiService.scheduleInterview(applicationId, selectedDate, locationController.text);
        _fetchApplications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Interview scheduled!')));
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
      case 'all': return Colors.blueAccent;
      default: return Colors.blue;
    }
  }
}
