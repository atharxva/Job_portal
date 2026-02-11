import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isApplying = false;
  final ApiService _apiService = ApiService();

  Future<void> _apply() async {
    setState(() => _isApplying = true);
    try {
      await _apiService.applyForJob(widget.job.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Applied successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.job.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.job.company, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(widget.job.location, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(widget.job.salary, style: TextStyle(fontSize: 16, color: Colors.green[700], fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(widget.job.description),
            const SizedBox(height: 20),
            if (widget.job.requirements.isNotEmpty) ...[
               const Text('Requirements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               const SizedBox(height: 5),
               ...widget.job.requirements.map((req) => Text('• $req')),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (widget.job.isApplied || _isApplying) ? null : _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.job.isApplied ? Colors.grey : Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isApplying 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text(widget.job.isApplied ? 'Application Submitted' : 'Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
