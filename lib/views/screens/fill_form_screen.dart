import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/template_model.dart';
import '../../models/form_submission_model.dart';
import '../wigets/dynamic_form.dart';
import 'package:taskapp/services/sync_service.dart';

class FillFormScreen extends StatefulWidget {
  final Template template;
  final SyncService syncService;
  final Map<String, dynamic>? initialValues;
  final bool viewOnly;
  final String? submissionId;
  
  const FillFormScreen({
    Key? key,
    required this.template,
    required this.syncService,
    this.initialValues,
    this.viewOnly = false,
    this.submissionId,
  }) : super(key: key);

  @override
  _FillFormScreenState createState() => _FillFormScreenState();
}

class _FillFormScreenState extends State<FillFormScreen> {
  bool _isSubmitting = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.viewOnly ? 'View Submission' : 'Fill Form'),
      ),
      body: Column(
        children: [
          Expanded(
            child: DynamicForm(
              template: widget.template,
              initialValues: widget.initialValues,
              onSubmit: _handleSubmit,
              readOnly: widget.viewOnly,
            ),
          ),
          if (!widget.viewOnly)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(Map<String, dynamic> formData) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final submission = FormSubmission(
        id: const Uuid().v4(),
        templateId: widget.template.id,
        formData: formData,
        submittedAt: DateTime.now(),
        submissionName: widget.template.title,
      );
      await widget.syncService.uploadSubmission(submission);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form submitted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit form. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}