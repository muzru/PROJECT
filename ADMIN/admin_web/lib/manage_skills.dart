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
  bool _isLoading = false;
  List<Map<String, dynamic>> _skills = [];

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  Future<void> _fetchSkills() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase
          .from('tbl_technicalskill')
          .select()
          .order('technicalskill_name');

      if (mounted) {
        setState(() {
          _skills = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching skills: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addSkill() async {
    if (_skillController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a skill name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the maximum ID to determine the next ID
      final maxIdResponse = await supabase
          .from('tbl_technicalskill')
          .select('technicalskill_id')
          .order('technicalskill_id', ascending: false)
          .limit(1);

      final newId = maxIdResponse.isNotEmpty
          ? (maxIdResponse[0]['technicalskill_id'] as int) + 1
          : 1;

      // Insert the new skill
      final response = await supabase.from('tbl_technicalskill').insert({
        'technicalskill_id': newId,
        'technicalskill_name': _skillController.text.trim(),
      }).select();

      if (mounted) {
        setState(() {
          _skills.add(response[0]);
          _skillController.clear();
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Skill added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding skill: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateSkill(int index, String newName) async {
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill name cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final skillId = _skills[index]['technicalskill_id'];

      await supabase.from('tbl_technicalskill').update(
          {'technicalskill_name': newName}).eq('technicalskill_id', skillId);

      if (mounted) {
        setState(() {
          _skills[index]['technicalskill_name'] = newName;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Skill updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating skill: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSkill(int index) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final skillId = _skills[index]['technicalskill_id'];

      await supabase
          .from('tbl_technicalskill')
          .delete()
          .eq('technicalskill_id', skillId);

      if (mounted) {
        setState(() {
          _skills.removeAt(index);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Skill deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting skill: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEditDialog(int index) {
    final TextEditingController editController = TextEditingController(
      text: _skills[index]['technicalskill_name'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Skill'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            labelText: 'Skill Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateSkill(index, editController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Skill'),
        content: Text(
          'Are you sure you want to delete "${_skills[index]['technicalskill_name']}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteSkill(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add skill section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Skill',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillController,
                          decoration: const InputDecoration(
                            labelText: 'Skill Name',
                            hintText: 'Enter skill name',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _addSkill,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Skill'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Skills list
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Skills List',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    Expanded(
                      child: _isLoading && _skills.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : _skills.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_add_disabled,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No skills found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Add a new skill to get started',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _skills.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(0xFF2E6F40)
                                            .withOpacity(0.1),
                                        child: const Icon(
                                          Icons.build,
                                          color: Color(0xFF2E6F40),
                                        ),
                                      ),
                                      title: Text(
                                        _skills[index]['technicalskill_name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // subtitle: Text(
                                      //   'ID: ${_skills[index]['technicalskill_id']}',
                                      //   style: TextStyle(
                                      //     color: Colors.grey.shade600,
                                      //     fontSize: 12,
                                      //   ),
                                      // ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () =>
                                                _showEditDialog(index),
                                            tooltip: 'Edit',
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _showDeleteConfirmation(index),
                                            tooltip: 'Delete',
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
