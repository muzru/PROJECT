import 'package:flutter/material.dart';

class AddSkillsPage extends StatefulWidget {
  const AddSkillsPage({super.key});
  @override
  State<AddSkillsPage> createState() => _AddSkillsPageState();
}

class _AddSkillsPageState extends State<AddSkillsPage> {
  final TextEditingController _skillController = TextEditingController();
  List<String> _skills = [];

  void _addSkill() {
    if (_skillController.text.isNotEmpty) {
      setState(() {
        _skills.add(_skillController.text);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your Skills",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: _skills
                  .map((skill) => Chip(
                        label: Text(skill),
                        onDeleted: () => _removeSkill(skill),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _skillController,
              decoration: InputDecoration(
                labelText: "Add a Skill",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addSkill,
                child: Text("Add Skill"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
