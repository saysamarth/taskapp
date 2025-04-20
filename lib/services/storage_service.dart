import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taskapp/models/template_model.dart';
import 'package:taskapp/models/form_submission_model.dart';

class StorageService {
  static const String templatesBox = 'templates';
  static const String submissionsBox = 'submissions';
  static const String pendingSyncBox = 'pendingSync';

  // Initialize Hive
  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDir.path);

    await Hive.openBox<String>(templatesBox);
    await Hive.openBox<String>(submissionsBox);
    await Hive.openBox<String>(pendingSyncBox);
  }

  Future<void> saveTemplate(Template template) async {
    final box = Hive.box<String>(templatesBox);
    await box.put(template.id, template.toJsonString());
  }

  Future<Template?> getTemplate(String id) async {
    final box = Hive.box<String>(templatesBox);
    final templateJson = box.get(id);
    if (templateJson == null) return null;
    return Template.fromJsonString(templateJson);
  }

  Future<List<Template>> getAllTemplates() async {
    final box = Hive.box<String>(templatesBox);
    return box.values
        .map((jsonString) => Template.fromJsonString(jsonString))
        .toList();
  }

  Future<void> deleteTemplate(String id) async {
    final box = Hive.box<String>(templatesBox);
    await box.delete(id);
  }

  Future<void> deleteSubmission(String id) async {
    final box = Hive.box<String>(submissionsBox);
    final pendingBox = Hive.box<String>(pendingSyncBox);
    await box.delete(id);
    await pendingBox.delete(id);
  }

  Future<void> saveSubmission(FormSubmission submission) async {
    final box = Hive.box<String>(submissionsBox);
    await box.put(submission.id, submission.toJsonString());
    if (!submission.isSynced) {
      final pendingBox = Hive.box<String>(pendingSyncBox);
      await pendingBox.put(submission.id, submission.toJsonString());
    }
  }

  Future<FormSubmission?> getSubmission(String id) async {
    final box = Hive.box<String>(submissionsBox);
    final submissionJson = box.get(id);
    if (submissionJson == null) return null;
    return FormSubmission.fromJsonString(submissionJson);
  }

  Future<List<FormSubmission>> getAllSubmissions() async {
    final box = Hive.box<String>(submissionsBox);
    return box.values
        .map((jsonString) => FormSubmission.fromJsonString(jsonString))
        .toList();
  }

  Future<List<FormSubmission>> getSubmissionsByTemplate(
    String templateId,
  ) async {
    final box = Hive.box<String>(submissionsBox);
    return box.values
        .map((jsonString) => FormSubmission.fromJsonString(jsonString))
        .where((submission) => submission.templateId == templateId)
        .toList();
  }

  Future<List<FormSubmission>> getPendingSyncSubmissions() async {
    final box = Hive.box<String>(pendingSyncBox);
    return box.values
        .map((jsonString) => FormSubmission.fromJsonString(jsonString))
        .toList();
  }

  Future<void> markSubmissionSynced(String id) async {
    final box = Hive.box<String>(submissionsBox);
    final pendingBox = Hive.box<String>(pendingSyncBox);

    final submissionJson = box.get(id);
    if (submissionJson != null) {
      final submission = FormSubmission.fromJsonString(submissionJson);
      final syncedSubmission = submission.markSynced();
      await box.put(id, syncedSubmission.toJsonString());
      await pendingBox.delete(id);
    }
  }

  Future<void> clearAllData() async {
    final templatesBoxInstance = Hive.box<String>(templatesBox);
    final submissionsBoxInstance = Hive.box<String>(submissionsBox);
    final pendingSyncBoxInstance = Hive.box<String>(pendingSyncBox);
    await templatesBoxInstance.clear();
    await submissionsBoxInstance.clear();
    await pendingSyncBoxInstance.clear();
  }
}
