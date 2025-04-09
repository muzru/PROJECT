import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageSkillsPage extends StatefulWidget {
  const ManageSkillsPage({super.key});

  @override
  State<ManageSkillsPage> createState() => _ManageSkillsPageState();
}

class _ManageSkillsPageState extends State<ManageSkillsPage> {
  final TextEditingController _skillController = TextEditingController();
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> skills = []; // Store full skill data

  @override
  void initState() {
    super.initState();
    _fetchSkills(); // Load skills on page load
  }

  /// Fetch skills from the database
  Future<void> _fetchSkills() async {
    final response = await supabase.from('tbl_technicalskill').select();
    setState(() {
      skills = List<Map<String, dynamic>>.from(response);
    });
  }

  /// Add a new skill to the database
  Future<void> _addSkill() async {
    if (_skillController.text.isNotEmpty) {
      final newSkill = {
        'technicalskill_name': _skillController.text,
      };

      final response = await supabase
          .from('tbl_technicalskill')
          .insert(newSkill)
          .select()
          .single();

      setState(() {
        skills.add(response);
        _skillController.clear();
      });
    }
  }

  /// Update an existing skill in the database
  Future<void> _updateSkill(int index, String newName) async {
    final skillId = skills[index]['technicalskill_id'];

    await supabase.from('tbl_technicalskill').update(
        {'technicalskill_name': newName}).match({'technicalskill_id': skillId});

    setState(() {
      skills[index]['technicalskill_name'] = newName;
    });
  }

  /// Delete a skill from the database
  Future<void> _removeSkill(int index) async {
    final skillId = skills[index]['technicalskill_id'];

    await supabase
        .from('tbl_technicalskill')
        .delete()
        .match({'technicalskill_id': skillId});

    setState(() {
      skills.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Skills"),
        backgroundColor: const Color(0xFF2E6F40),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add a Skill:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter skill name",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addSkill,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6F40)),
                  child: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Skills List:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: skills.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(skills[index]['technicalskill_name']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeSkill(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show a dialog to edit a skill
  void _showEditDialog(int index) {
    TextEditingController editController =
        TextEditingController(text: skills[index]['technicalskill_name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Skill"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: "Enter new skill name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _updateSkill(index, editController.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
