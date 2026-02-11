import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/job_model.dart';

class CreateJobScreen extends StatefulWidget {
  final JobModel? existingJob;
  const CreateJobScreen({super.key, this.existingJob});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  
  final _apiService = ApiService();
  bool _isLoading = false;

  bool get isEditMode => widget.existingJob != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final job = widget.existingJob!;
      _titleController.text = job.title;
      _companyController.text = job.company;
      _locationController.text = job.location;
      _descriptionController.text = job.description;
      _salaryController.text = job.salary;
      _requirementsController.text = job.requirements.join(', ');
      _contactNameController.text = job.contactName ?? '';
      _contactEmailController.text = job.contactEmail ?? '';
    }
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final requirements = _requirementsController.text.split(',').map((e) => e.trim()).toList();
      
      final job = JobModel(
        id: isEditMode ? widget.existingJob!.id : '',
        title: _titleController.text,
        company: _companyController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        salary: _salaryController.text,
        requirements: requirements,
        contactName: _contactNameController.text.isNotEmpty ? _contactNameController.text : null,
        contactEmail: _contactEmailController.text.isNotEmpty ? _contactEmailController.text : null,
        postedBy: isEditMode ? widget.existingJob!.postedBy : null,
        applicants: isEditMode ? widget.existingJob!.applicants : [],
        createdAt: isEditMode ? widget.existingJob!.createdAt : DateTime.now(),
      );

      if (isEditMode) {
        await _apiService.updateJob(job);
      } else {
        await _apiService.createJob(job);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditMode ? 'Job updated successfully!' : 'Job posted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save job: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Job' : 'Post a Job'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue[50]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: _buildInputDecoration('Job Title', Icons.work_outline),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyController,
                    decoration: _buildInputDecoration('Company', Icons.business),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: _buildInputDecoration('Location', Icons.location_on_outlined),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _salaryController,
                    decoration: _buildInputDecoration(r'Salary (e.g. $50k - $70k)', Icons.payments_outlined),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _buildInputDecoration('Description', Icons.description_outlined),
                    maxLines: 4,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _requirementsController,
                    decoration: _buildInputDecoration('Requirements (comma separated)', Icons.list_alt),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactNameController,
                    decoration: _buildInputDecoration('Contact Person (Optional)', Icons.person_outline),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactEmailController,
                    decoration: _buildInputDecoration('Contact Email (Optional)', Icons.alternate_email),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveJob,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : Text(isEditMode ? 'Update Job' : 'Post Job', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
