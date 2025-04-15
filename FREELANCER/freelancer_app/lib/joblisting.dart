import 'package:flutter/material.dart';
import 'package:freelancer_app/workdetails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllJobsPage extends StatefulWidget {
  const AllJobsPage({super.key});

  @override
  _AllJobsPageState createState() => _AllJobsPageState();
}

class _AllJobsPageState extends State<AllJobsPage> {
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _workTypes = [
    {'worktype_id': 'All', 'worktype_name': 'All'}
  ];
  String _selectedWorkTypeId = 'All';

  @override
  void initState() {
    super.initState();
    _fetchJobs();
    _fetchFilters();
  }

  Future<void> _fetchJobs() async {
    try {
      // Fetch all jobs with worktype details
      final jobsResponse =
          await Supabase.instance.client.from('tbl_work').select('''
            work_id,
            created_at,
            work_name,
            work_details,
            work_amount,
            work_file,
            worktype_id,
            work_status,
            client_id,
            freelancer_id,
            tbl_worktype (worktype_name)
          ''').order('created_at', ascending: false);

      List<Map<String, dynamic>> allJobs =
          (jobsResponse as List).cast<Map<String, dynamic>>();

      // Filter jobs manually using a for loop based on worktype_id
      List<Map<String, dynamic>> filteredJobs = [];

      for (var job in allJobs) {
        bool matchesWorkType = _selectedWorkTypeId == 'All' ||
            job['worktype_id'].toString() == _selectedWorkTypeId;

        if (matchesWorkType) {
          filteredJobs.add(job);
        }
      }

      debugPrint('Filtered jobs: $filteredJobs');
      setState(() {
        _jobs = filteredJobs;
      });
    } catch (e) {
      debugPrint('Error fetching jobs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching jobs: $e")),
      );
    }
  }

  Future<void> _fetchFilters() async {
    try {
      // Fetch work types
      final workTypesResponse = await Supabase.instance.client
          .from('tbl_worktype')
          .select('worktype_id, worktype_name');
      final workTypes = (workTypesResponse as List).map((item) {
        return {
          'worktype_id': item['worktype_id'].toString(),
          'worktype_name': item['worktype_name'] as String,
        };
      }).toList();
      debugPrint('Work types fetched: $workTypes');

      setState(() {
        _workTypes = [
          {'worktype_id': 'All', 'worktype_name': 'All'},
          ...workTypes
        ];
      });
    } catch (e) {
      debugPrint('Error fetching filters: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching filters: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Jobs"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<Map<String, dynamic>>(
                    isExpanded: true,
                    value: _workTypes.firstWhere(
                      (type) => type['worktype_id'] == _selectedWorkTypeId,
                      orElse: () =>
                          {'worktype_id': 'All', 'worktype_name': 'All'},
                    ),
                    items: _workTypes.map((type) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: type,
                        child: Text(type['worktype_name'] ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWorkTypeId = value!['worktype_id']!;
                        _fetchJobs();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _jobs.length,
              itemBuilder: (context, index) {
                final job = _jobs[index];
                final workTypeName =
                    job['tbl_worktype']?['worktype_name'] ?? 'Unknown';
                // Convert work_amount to double and handle potential parsing errors
                final amount =
                    double.tryParse(job['work_amount']?.toString() ?? '0') ??
                        0.0;
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(job['work_name'] ?? 'Untitled Job'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("\$${amount.toStringAsFixed(2)}"),
                        Text("Type: $workTypeName"),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WorkDetailsPage(workId: job['work_id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
