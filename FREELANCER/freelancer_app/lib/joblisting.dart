import 'package:flutter/material.dart';

class JobListingPage extends StatefulWidget {
  @override
  _JobListingPageState createState() => _JobListingPageState();
}

class _JobListingPageState extends State<JobListingPage> {
  final List<Map<String, String>> jobs = [
    {
      'title': 'Graphic Designer',
      'description':
          'Looking for a creative designer to create engaging visuals for our marketing campaign. Must have experience in Photoshop and Illustrator.'
    },
    {
      'title': 'Web Developer',
      'description':
          'Need a skilled developer to build a responsive website with React and Firebase. Should have experience with authentication and database integration.'
    },
    {
      'title': 'Content Writer',
      'description':
          'Seeking a talented writer to produce blog posts and website content. Should be proficient in SEO and research-based writing.'
    },
  ];

  void _showJobDetails(BuildContext context, Map<String, String> job) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job['title']!,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(job['description']!, style: TextStyle(fontSize: 16)),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showConfirmation(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('Apply', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Application Submitted"),
          content: Text("Your application has been successfully submitted!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Job Listings")),
      body: ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(jobs[index]['title']!),
              onTap: () => _showJobDetails(context, jobs[index]),
            ),
          );
        },
      ),
    );
  }
}
