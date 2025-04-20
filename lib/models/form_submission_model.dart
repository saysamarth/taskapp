import 'dart:convert';

class FormSubmission {
  final String id;
  final String templateId;
  final Map<String, dynamic> formData;
  final DateTime submittedAt;
  final DateTime? syncedAt;
  final bool isSynced;
  final String? userId;
  final String? submissionName;
  FormSubmission({
    required this.id,
    required this.templateId,
    required this.formData,
    required this.submittedAt,
    required this.submissionName,
    this.syncedAt,
    this.isSynced = false,
    this.userId,

  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'formData': formData,
      'submittedAt': submittedAt.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
      'isSynced': isSynced,
      'userId': userId,
    };
  }

  factory FormSubmission.fromJson(Map<String, dynamic> json) {
    return FormSubmission(
      id: json['id'],
      templateId: json['templateId'],
      formData: json['formData'],
      submittedAt: DateTime.parse(json['submittedAt']),
      syncedAt:
          json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
      isSynced: json['isSynced'] ?? false,
      userId: json['userId'],
      submissionName: json['submissionName'],
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory FormSubmission.fromJsonString(String jsonString) {
    return FormSubmission.fromJson(jsonDecode(jsonString));
  }

  FormSubmission markSynced() {
    return FormSubmission(
      id: id,
      templateId: templateId,
      formData: formData,
      submittedAt: submittedAt,
      syncedAt: DateTime.now(),
      isSynced: true,
      userId: userId,
      submissionName: submissionName,
    );
  }
}
