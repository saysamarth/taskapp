import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:taskapp/models/form_submission_model.dart';
import 'package:taskapp/models/template_model.dart';
import 'storage_service.dart';

class SyncService {
  final StorageService _storageService;
  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService({
    required StorageService storageService,
    required FirebaseFirestore firestore,
    required Connectivity connectivity,
  }) : _storageService = storageService,
       _firestore = firestore,
       _connectivity = connectivity;

  void init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      result,
    ) {
      if (result != ConnectivityResult.none) {
        syncPendingData();
      }
    });
    checkConnectivityAndSync();
  }

  Future<void> checkConnectivityAndSync() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await syncPendingData();
    }
  }

  Future<void> syncPendingData() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingSubmissions =
          await _storageService.getPendingSyncSubmissions();
      for (final submission in pendingSubmissions) {
        await _firestore
            .collection('submissions')
            .doc(submission.id)
            .set(submission.toJson());
        await _storageService.markSubmissionSynced(submission.id);
      }
      // Sync templates
      final templates = await _storageService.getAllTemplates();
      for (final template in templates) {
        if (!template.isPredefined) {
          await _firestore
              .collection('templates')
              .doc(template.id)
              .set(template.toJson());
        }
      }
      await syncPredefinedTemplates();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncPredefinedTemplates() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('templates')
              .where('isPredefined', isEqualTo: true)
              .get();

      for (final doc in querySnapshot.docs) {
        final template = Template.fromJson(doc.data());
        await _storageService.saveTemplate(template);
      }
    } catch (e) {
      print('Error syncing predefined templates: $e');
    }
  }

  Future<void> uploadSubmission(FormSubmission submission) async {
    await _storageService.saveSubmission(submission);
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        await _firestore
            .collection('submissions')
            .doc(submission.id)
            .set(submission.toJson());
        await _storageService.markSubmissionSynced(submission.id);
      } catch (e) {
        print('Error uploading submission: $e');
      }
    }
  }

  Future<void> uploadTemplate(Template template) async {
    await _storageService.saveTemplate(template);
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none &&
        !template.isPredefined) {
      try {
        await _firestore
            .collection('templates')
            .doc(template.id)
            .set(template.toJson());
      } catch (e) {
        print('Error uploading template: $e');
      }
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    await _storageService.deleteTemplate(templateId);
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        await _firestore.collection('templates').doc(templateId).delete();
      } catch (e) {
        print('Error deleting template from Firebase: $e');
      }
    }
  }

  Future<void> deleteSubmission(String submissionId) async {
    await _storageService.deleteSubmission(submissionId);
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        await _firestore.collection('submissions').doc(submissionId).delete();
      } catch (e) {
        print('Error deleting submission from Firebase: $e');
      }
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
