import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageWorkTypesPage extends StatefulWidget {
  const ManageWorkTypesPage({super.key});

  @override
  State<ManageWorkTypesPage> createState() => _ManageWorkTypesPageState();
}

class _ManageWorkTypesPageState extends State<ManageWorkTypesPage> {
  final TextEditingController _workTypeController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  List<Map<String, dynamic>> _workTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchWorkTypes();
  }

  @override
  void dispose() {
    _workTypeController.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkTypes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase
          .from('tbl_worktype')
          .select('worktype_id, worktype_name')
          .order('worktype_name');

      if (mounted) {
        setState(() {
          _workTypes = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching work types: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addWorkType() async {
    if (_workTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a work type name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the maximum ID to determine the next ID
      final maxIdResponse = await supabase
          .from('tbl_worktype')
          .select('worktype_id')
          .order('worktype_id', ascending: false)
          .limit(1);

      final newId = maxIdResponse.isNotEmpty
          ? (maxIdResponse[0]['worktype_id'] as int) + 1
          : 1;

      // Insert the new work type
      final response = await supabase.from('tbl_worktype').insert({
        'worktype_id': newId,
        'worktype_name': _workTypeController.text.trim(),
      }).select();

      if (mounted) {
        setState(() {
          _workTypes.add(response[0]);
          _workTypeController.clear();
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Work type added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding work type: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateWorkType(int index, String newName) async {
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Work type name cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final workTypeId = _workTypes[index]['worktype_id'];

      await supabase
          .from('tbl_worktype')
          .update({'worktype_name': newName}).eq('worktype_id', workTypeId);

      if (mounted) {
        setState(() {
          _workTypes[index]['worktype_name'] = newName;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Work type updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating work type: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteWorkType(int index) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final workTypeId = _workTypes[index]['worktype_id'];

      await supabase
          .from('tbl_worktype')
          .delete()
          .eq('worktype_id', workTypeId);

      if (mounted) {
        setState(() {
          _workTypes.removeAt(index);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Work type deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting work type: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEditDialog(int index) {
    final TextEditingController editController = TextEditingController(
      text: _workTypes[index]['worktype_name'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Work Type'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            labelText: 'Work Type Name',
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
              _updateWorkType(index, editController.text.trim());
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
        title: const Text('Delete Work Type'),
        content: Text(
          'Are you sure you want to delete "${_workTypes[index]['worktype_name']}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteWorkType(index);
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
          // Add work type section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Work Type',
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
                          controller: _workTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Work Type Name',
                            hintText: 'Enter work type name',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addWorkType(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _addWorkType,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Work Type'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Work types list
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
                          'Work Types',
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
                      child: _isLoading && _workTypes.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : _workTypes.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.work_off,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No work types found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Add a new work type to get started',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _workTypes.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(0xFF2E6F40)
                                            .withOpacity(0.1),
                                        child: const Icon(
                                          Icons.work,
                                          color: Color(0xFF2E6F40),
                                        ),
                                      ),
                                      title: Text(
                                        _workTypes[index]['worktype_name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // subtitle: Text(
                                      //   'ID: ${_workTypes[index]['worktype_id']}',
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
