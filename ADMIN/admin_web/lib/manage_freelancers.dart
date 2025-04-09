import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageFreelancers extends StatefulWidget {
  const ManageFreelancers({super.key});

  @override
  _ManageFreelancersState createState() => _ManageFreelancersState();
}

class _ManageFreelancersState extends State<ManageFreelancers> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchFreelancers() async {
    final response = await supabase.from('tbl_freelancer').select();
    return response;
  }

  Future<void> updateStatus(String freelancerId, int status) async {
    final response = await supabase
        .from('tbl_freelancer')
        .update({'freelancer_status': status}) // Corrected field name
        .eq('id', freelancerId);

    if (response.error != null) {
      print("Error updating status: ${response.error!.message}");
    } else {
      print("Status updated successfully");
      setState(() {}); // Refresh UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Freelancers")),
      body: FutureBuilder(
        future: fetchFreelancers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching data"));
          }

          final freelancers = snapshot.data!;
          return ListView.builder(
            itemCount: freelancers.length,
            itemBuilder: (context, index) {
              final freelancer = freelancers[index];
              return ListTile(
                title: Text(freelancer['freelancer_name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          updateStatus(freelancer['id'], 1), // Accept
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: Text("Accept"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () =>
                          updateStatus(freelancer['id'], 0), // Reject
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Reject"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
