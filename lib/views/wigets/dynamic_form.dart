import 'package:flutter/material.dart';
import '../../models/template_model.dart';

class DynamicForm extends StatefulWidget {
  final Template template;
  final Map<String, dynamic>? initialValues;
  final Function(Map<String, dynamic>) onSubmit;
  final bool readOnly;
  
  const DynamicForm({
    Key? key,
    required this.template,
    this.initialValues,
    required this.onSubmit,
    this.readOnly = false,
  }) : super(key: key);

  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;
  
  @override
  void initState() {
    super.initState();
    _formData = widget.initialValues ?? {};

    for (var field in widget.template.fields) {
      if (!_formData.containsKey(field.id) && field.defaultValue != null) {
        _formData[field.id] = field.defaultValue;
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.template.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  widget.template.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          // Dynamic form fields
          Expanded(
            child: ListView.builder(
              itemCount: widget.template.fields.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final field = widget.template.fields[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildFormField(field),
                );
              },
            ),
          ),

          if (!widget.readOnly)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitForm,
                  child: Text('Submit'),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildFormField(FieldConfig field) {
    switch (field.type) {
      case 'text':
        return _buildTextField(field);
      case 'number':
        return _buildNumberField(field);
      case 'dropdown':
        return _buildDropdownField(field);
      case 'checkbox':
        return _buildCheckboxField(field);
      case 'radio':
        return _buildRadioField(field);
      case 'date':
        return _buildDateField(field);
      case 'textarea':
        return _buildTextAreaField(field);
      default:
        return _buildTextField(field);
    }
  }
  
  Widget _buildTextField(FieldConfig field) {
    return TextFormField(
      initialValue: _formData[field.id]?.toString(),
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.hint,
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        if (!widget.readOnly) {
          setState(() {
            _formData[field.id] = value;
          });
        }
      },
      readOnly: widget.readOnly,
      enabled: !widget.readOnly,
      validator: field.requiredd 
          ? (value) => value == null || value.isEmpty ? 'This field is required' : null
          : null,
    );
  }
  
  Widget _buildNumberField(FieldConfig field) {
    return TextFormField(
      initialValue: _formData[field.id]?.toString(),
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.hint,
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (!widget.readOnly) {
          setState(() {
            _formData[field.id] = double.tryParse(value) ?? value;
          });
        }
      },
      readOnly: widget.readOnly,
      enabled: !widget.readOnly,
      validator: (value) {
        if (field.requiredd && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }
  
  Widget _buildDropdownField(FieldConfig field) {
    return DropdownButtonFormField<String>(
      value: _formData[field.id],
      decoration: InputDecoration(
        labelText: field.label,
        border: OutlineInputBorder(),
      ),
      items: field.options?.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList() ?? [],
      onChanged: widget.readOnly ? null : (value) {
        setState(() {
          _formData[field.id] = value;
        });
      },
      validator: field.requiredd 
          ? (value) => value == null ? 'This field is required' : null
          : null,
    );
  }
  
  Widget _buildCheckboxField(FieldConfig field) {
    bool isChecked = _formData[field.id] == true;
    return FormField<bool>(
      initialValue: isChecked,
      validator: field.requiredd 
          ? (value) => value == true ? null : 'This field is required'
          : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: widget.readOnly ? null : (value) {
                    setState(() {
                      _formData[field.id] = value;
                      isChecked = value ?? false;
                      state.didChange(value);
                    });
                  },
                ),
                Expanded(child: Text(field.label)),
              ],
            ),
            if (state.hasError)
              Text(
                state.errorText!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildRadioField(FieldConfig field) {
    return FormField<String>(
      initialValue: _formData[field.id],
      validator: field.requiredd 
          ? (value) => value == null || value.isEmpty ? 'This field is required' : null
          : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            ...field.options?.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _formData[field.id],
                onChanged: widget.readOnly ? null : (value) {
                  setState(() {
                    _formData[field.id] = value;
                    state.didChange(value);
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }).toList() ?? [],
            if (state.hasError)
              Text(
                state.errorText!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildDateField(FieldConfig field) {
    DateTime? selectedDate = _formData[field.id] != null 
        ? DateTime.tryParse(_formData[field.id].toString())
        : null;
        
    return FormField<DateTime>(
      initialValue: selectedDate,
      validator: field.requiredd 
          ? (value) => value == null ? 'This field is required' : null
          : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: widget.readOnly ? null : () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                    _formData[field.id] = pickedDate.toIso8601String();
                    state.didChange(pickedDate);
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: field.label,
                  hintText: widget.readOnly ? null : 'Select date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate != null
                          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                          : 'No date selected',
                    ),
                    if (!widget.readOnly)
                      Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Text(
                state.errorText!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildTextAreaField(FieldConfig field) {
    return TextFormField(
      initialValue: _formData[field.id]?.toString(),
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.hint,
        border: OutlineInputBorder(),
      ),
      maxLines: 5,
      onChanged: (value) {
        if (!widget.readOnly) {
          setState(() {
            _formData[field.id] = value;
          });
        }
      },
      readOnly: widget.readOnly,
      enabled: !widget.readOnly,
      validator: field.requiredd 
          ? (value) => value == null || value.isEmpty ? 'This field is required' : null
          : null,
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_formData);
    }
  }
}