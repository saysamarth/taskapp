import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/template_model.dart';
import 'package:taskapp/services/sync_service.dart';
import 'package:taskapp/views/wigets/field_editor.dart';

class CreateTemplateScreen extends StatefulWidget {
  final SyncService syncService;
  final Template? existingTemplate;
  
  const CreateTemplateScreen({
    super.key,
    required this.syncService,
    this.existingTemplate,
  });

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<FieldConfig> _fields = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.existingTemplate != null) {
      _titleController.text = widget.existingTemplate!.title;
      _descriptionController.text = widget.existingTemplate!.description;
      _fields = List.from(widget.existingTemplate!.fields);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTemplate == null ? 'Create Template' : 'Edit Template'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Template Title',
                      hintText: 'E.g., Fire Safety Inspection',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe what this template is for',
                    ),
                    maxLines: 3,
                  ),

                  SizedBox(height: 24),

                  Text(
                    'Form Fields',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  SizedBox(height: 12),

                  ..._fields.asMap().entries.map((entry) {
                    final index = entry.key;
                    final field = entry.value;
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    field.label,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editField(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _removeField(index),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('Type: ${_getFieldTypeLabel(field.type)}'),
                            if (field.requiredd)
                              Text('Required: Yes', style: TextStyle(fontWeight: FontWeight.bold)),
                            if (field.options != null && field.options!.isNotEmpty)
                              Text('Options: ${field.options!.join(", ")}'),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  OutlinedButton.icon(
                    onPressed: _addField,
                    icon: Icon(Icons.add),
                    label: Text('Add Field'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveTemplate,
                  child: Text('Save Template'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFieldTypeLabel(String type) {
    switch (type) {
      case 'text': return 'Text';
      case 'number': return 'Number';
      case 'checkbox': return 'Checkbox';
      case 'dropdown': return 'Dropdown';
      case 'radio': return 'Multiple Choice';
      case 'date': return 'Date';
      case 'textarea': return 'Text Area';
      default: return type;
    }
  }

  void _addField() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FieldEditorSheet(
        onSave: (field) {
          setState(() {
            _fields.add(field);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editField(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FieldEditorSheet(
        field: _fields[index],
        onSave: (field) {
          setState(() {
            _fields[index] = field;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  void _saveTemplate() async {
    if (_formKey.currentState!.validate()) {
      if (_fields.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add at least one field')),
        );
        return;
      }
      final template = Template(
        id: widget.existingTemplate?.id ?? Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        fields: _fields,
        createdAt: widget.existingTemplate?.createdAt ?? DateTime.now(),
        isPredefined: false,
      );
      await widget.syncService.uploadTemplate(template);
      Navigator.pop(context);
    }
  }
}