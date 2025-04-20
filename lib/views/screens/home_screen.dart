import 'package:flutter/material.dart';
import '../../models/template_model.dart';
import '../../models/form_submission_model.dart';
import 'package:taskapp/services/storage_service.dart';
import 'package:taskapp/services/sync_service.dart';
import 'package:taskapp/views/wigets/template_card.dart';
import 'package:taskapp/views/wigets/submission_card.dart';
import 'package:taskapp/views/screens/create_template_screen.dart';
import 'package:taskapp/views/screens/fill_form_screen.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final SyncService syncService;

  const HomeScreen({
    Key? key,
    required this.storageService,
    required this.syncService,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Template> _templates = [];
  List<FormSubmission> _submissions = [];
  List<Template> _predefinedTemplates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPredefinedTemplates().then((_) => _loadData());
  }

  Future<void> _loadPredefinedTemplates() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/predefined_template.json',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      List<Template> templates = [];
      for (var i = 0; i < jsonList.length; i++) {
        try {
          var json = Map<String, dynamic>.from(jsonList[i]);
          Template template = Template.fromJson(json);
          templates.add(template);
        } catch (e) {
          print('Error parsing template at index $i: $e');
        }
      }
      setState(() {
        _predefinedTemplates = templates;
      });
    } catch (e) {
      print('Error loading predefined templates: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final templates = await widget.storageService.getAllTemplates();
      final submissions = await widget.storageService.getAllSubmissions();
      final allTemplates = [...templates, ..._predefinedTemplates];
      setState(() {
        _templates = allTemplates;
        _submissions = submissions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          'Safety App',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await widget.syncService.syncPendingData();
              _loadData();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Templates',
          ),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CreateTemplateScreen(
                            syncService: widget.syncService,
                          ),
                    ),
                  ).then((_) => _loadData());
                },
                tooltip: 'Create template',
                label: Text('Create'),
                icon: Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _submissions.isEmpty
          ? _buildEmptyState(
            'No form submissions yet',
            'Fill out a template to see your submissions here',
            Icons.description,
          )
          : ListView.builder(
            itemCount: _submissions.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final submission = _submissions[index];
              return SubmissionCard(
                submission: submission,
                onTap: () => _viewSubmission(submission),
                // onDelete: () => _deleteSubmission(submission),
              );
            },
          );
    } else {
      final predefinedTemplates =
          _templates.where((t) => t.isPredefined).toList();
      final userTemplates = _templates.where((t) => !t.isPredefined).toList();
      return _templates.isEmpty
          ? _buildEmptyState(
            'No templates yet',
            'Create your first template by clicking the + button',
            Icons.add_box,
          )
          : ListView(
            padding: EdgeInsets.all(16),
            children: [
              if (predefinedTemplates.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Predefined Templates',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                ...predefinedTemplates.map(
                  (template) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TemplateCard(
                      template: template,
                      onTap: () => _useTemplate(template),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Your Templates',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
              ...userTemplates.map(
                (template) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TemplateCard(
                    template: template,
                    onTap: () => _useTemplate(template),
                    onEdit: () => _editTemplate(template),
                    onDelete: () => _deleteTemplate(template),
                  ),
                ),
              ),
            ],
          );
    }
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _editTemplate(Template template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateTemplateScreen(
              syncService: widget.syncService,
              existingTemplate: template,
            ),
      ),
    ).then((_) => _loadData());
  }

  void _viewSubmission(FormSubmission submission) async {
    Template? template = await widget.storageService.getTemplate(
      submission.templateId,
    );
    if (template == null) {
      try {
        template = _predefinedTemplates.firstWhere(
          (t) => t.id == submission.templateId,
        );
      } catch (e) {
        template = null;
      }
    }
    if (template == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Template not found')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FillFormScreen(
              template: template!,
              syncService: widget.syncService,
              initialValues: submission.formData,
              viewOnly: true,
              submissionId: submission.id,
            ),
      ),
    );
  }

  void _useTemplate(Template template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FillFormScreen(
              template: template,
              syncService: widget.syncService,
            ),
      ),
    ).then((_) => _loadData());
  }

  void _deleteTemplate(Template template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Template'),
            content: Text('Are you sure you want to delete this template?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await widget.storageService.deleteTemplate(template.id);
      await widget.syncService.deleteTemplate(template.id);
      _loadData();
    }
  }

  // void _deleteSubmission(FormSubmission submission) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: Text('Delete Submission'),
  //           content: Text('Are you sure you want to delete this submission?'),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(false),
  //               child: Text('Cancel'),
  //             ),
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(true),
  //               child: Text('Delete'),
  //             ),
  //           ],
  //         ),
  //   );
  //   if (confirmed == true) {
  //     await widget.storageService.deleteSubmission(submission.id);
  //     await widget.syncService.deleteSubmission(submission.id);
  //     _loadData();
  //   }
  // }
}
