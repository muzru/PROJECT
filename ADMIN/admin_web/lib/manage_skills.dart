import 'package:flutter/material.dart';

class ManageSkillsPage extends StatefulWidget {
  @override
  _ManageSkillsPageState createState() => _ManageSkillsPageState();
}

class _ManageSkillsPageState extends State<ManageSkillsPage> {
  final TextEditingController _skillController = TextEditingController();
  List<String> skills = [];

  void _addSkill() {
    if (_skillController.text.isNotEmpty) {
      setState(() {
        skills.add(_skillController.text);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(int index) {
    setState(() {
      skills.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Skills"),
        backgroundColor: Color(0xFF2E6F40),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add a Skill:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter skill name",
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addSkill,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E6F40)),
                  child: Text("Add"),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text("Skills List:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: skills.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(skills[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeSkill(index),
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
}
