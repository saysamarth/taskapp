import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/template_model.dart';

class FieldEditorSheet extends StatefulWidget {
  final FieldConfig? field;
  final Function(FieldConfig) onSave;
  const FieldEditorSheet({
    Key? key,
    this.field,
    required this.onSave,
  }) : super(key: key);

  @override
  _FieldEditorSheetState createState() => _FieldEditorSheetState();
}

class _FieldEditorSheetState extends State<FieldEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _hintController;
  String _fieldType = 'text';
  bool _isRequired = false;
  List<String> _options = [];
  late TextEditingController _optionsController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _hintController = TextEditingController();
    _optionsController = TextEditingController();
    
    if (widget.field != null) {
      _labelController.text = widget.field!.label;
      _hintController.text = widget.field!.hint ?? '';
      _fieldType = widget.field!.type;
      _isRequired = widget.field!.requiredd;
      _options = widget.field!.options ?? [];
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _hintController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
  margin: EdgeInsets.only(bottom: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 1,
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withAlpha(75) 
      ),
    ),
   
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.field == null ? 'Add Field' : 'Edit Field',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: 'Field Label',
                hintText: 'E.g., Fire Extinguisher Checked',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a label';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _fieldType,
              decoration: InputDecoration(
                labelText: 'Field Type',
              ),
              items: [
                DropdownMenuItem(value: 'text', child: Text('Text')),
                DropdownMenuItem(value: 'number', child: Text('Number')),
                DropdownMenuItem(value: 'checkbox', child: Text('Checkbox')),
                DropdownMenuItem(value: 'dropdown', child: Text('Dropdown')),
                DropdownMenuItem(value: 'radio', child: Text('Multiple Choice')),
                DropdownMenuItem(value: 'date', child: Text('Date')),
                DropdownMenuItem(value: 'textarea', child: Text('Text Area')),
              ],
              onChanged: (value) {
                setState(() {
                  _fieldType = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _hintController,
              decoration: InputDecoration(
                labelText: 'Hint Text (Optional)',
                hintText: 'E.g., Check if the fire extinguisher is in place',
              ),
            ),
            SizedBox(height: 16),

            CheckboxListTile(
              title: Text('Required Field'),
              value: _isRequired,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _isRequired = value ?? false;
                });
              },
            ),

            if (_fieldType == 'dropdown' || _fieldType == 'radio')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text('Options', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8),
                  ..._options.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(entry.value),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () {
                              setState(() {
                                _options.removeAt(entry.key);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _optionsController,
                          decoration: InputDecoration(
                            hintText: 'Add option',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle),
                        onPressed: () {
                          if (_optionsController.text.isNotEmpty) {
                            setState(() {
                              _options.add(_optionsController.text);
                              _optionsController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (_options.isEmpty && _fieldType != 'text')
                    Text(
                      'Please add at least one option',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
            
            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if ((_fieldType == 'dropdown' || _fieldType == 'radio') && _options.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please add at least one option')),
                      );
                      return;
                    }
                    widget.onSave(FieldConfig(
                      id: widget.field?.id ?? Uuid().v4(),
                      type: _fieldType,
                      label: _labelController.text,
                      requiredd: _isRequired,
                      hint: _hintController.text.isNotEmpty ? _hintController.text : null,
                      options: (_fieldType == 'dropdown' || _fieldType == 'radio') ? _options : null,
                    ));
                  }
                },
                child: Text('Save Field'),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    ));
  }
}