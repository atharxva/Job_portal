import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/job_model.dart';
import '../models/application_model.dart';
import 'job_detail_screen.dart';
import 'my_applications_screen.dart';
import 'welcome_screen.dart';

class CandidateDashboard extends StatefulWidget {
  const CandidateDashboard({super.key});

  @override
  State<CandidateDashboard> createState() => _CandidateDashboardState();
}

class _CandidateDashboardState extends State<CandidateDashboard> {
  final ApiService _apiService = ApiService();
  late Future<List<JobModel>> _jobsFuture;
  List<JobModel> _allJobs = [];
  List<JobModel> _filteredJobs = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> _logout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  void _fetchJobs() async {
    _jobsFuture = _apiService.getAllJobs();
    _allJobs = await _jobsFuture;
    setState(() {
      _filteredJobs = _allJobs;
    });
  }

  void _filterJobs(String query) {
    setState(() {
      _filteredJobs = _allJobs
          .where((job) =>
              job.title.toLowerCase().contains(query.toLowerCase()) ||
              job.company.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Dream Job'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _fetchJobs(),
          ),
          IconButton(
            icon: const Icon(Icons.assignment_outlined),
            padding: EdgeInsets.zero,
            tooltip: 'My Applications',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
              );
              _fetchJobs(); // Refresh if they withdrew
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<JobModel>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _allJobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _fetchJobs();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterJobs,
                    decoration: InputDecoration(
                      hintText: 'Search by title or company...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                // Upcoming Interviews Section
                FutureBuilder<List<ApplicationModel>>(
                  future: _apiService.getMyApplications(),
                  builder: (context, AsyncSnapshot<List<ApplicationModel>> appSnapshot) {
                    if (!appSnapshot.hasData || appSnapshot.data == null) return const SizedBox.shrink();
                    final List<ApplicationModel> upcoming = appSnapshot.data!
                        .where((ApplicationModel a) => a.interviewDate != null)
                        .toList();
                    if (upcoming.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('Upcoming Interviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: upcoming.length,
                            itemBuilder: (context, index) {
                              final ApplicationModel app = upcoming[index];
                              final job = app.job as JobModel;
                              return Container(
                                width: 200,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 12, color: Colors.orange),
                                        const SizedBox(width: 4),
                                        Text('${app.interviewDate!.day}/${app.interviewDate!.month}', style: const TextStyle(fontSize: 11)),
                                      ],
                                    ),
                                    Text(app.interviewLocation ?? 'Online', style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text(
                    'Featured Opportunities',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                ),
                if (_allJobs.any((job) => job.isFeatured))
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _allJobs.where((j) => j.isFeatured).length,
                      itemBuilder: (context, index) {
                        final job = _allJobs.where((j) => j.isFeatured).toList()[index];
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                            );
                            _fetchJobs();
                          },
                          child: Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 16, bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.blueAccent, Colors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        job.title,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                  ],
                                ),
                                Text(
                                  job.company,
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                                  maxLines: 1,
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.white.withOpacity(0.7), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      job.location,
                                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                                    ),
                                    const Spacer(),
                                    Text(
                                      job.salary,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('No featured jobs at the moment.', style: TextStyle(color: Colors.grey)),
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'All Job Postings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _filteredJobs.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 100),
                            Center(child: Text('No jobs match your search.')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = _filteredJobs[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 2,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        job.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                      ),
                                    ),
                                    if (job.isApplied)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Applied',
                                          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(job.company, style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(job.location, style: const TextStyle(color: Colors.grey)),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.payments_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(job.salary, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => JobDetailScreen(job: job),
                                    ),
                                  );
                                  _fetchJobs(); // Potential refresh
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
