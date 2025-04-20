import 'dart:convert';

class FieldConfig {
  final String id;
  final String type;
  final String label;
  final bool requiredd;
  final List<String>? options;
  final String? hint;
  final String? defaultValue;
 

  FieldConfig({
    required this.id,
    required this.type,
    required this.label,
    this.requiredd = false,
    this.options,
    this.hint,
    this.defaultValue,

  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'label': label,
      'required': requiredd,
      if (options != null) 'options': options,
      if (hint != null) 'hint': hint,
      if (defaultValue != null) 'defaultValue': defaultValue,
    };
  }

  factory FieldConfig.fromJson(Map<String, dynamic> json) {
    return FieldConfig(
      id: json['id'],
      type: json['type'],
      label: json['label'],
      requiredd: json['required'] ?? false,
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      hint: json['hint'],
      defaultValue: json['defaultValue'],
    );
  }
}

class Template {
  final String id;
  final String title;
  final String description;
  final List<FieldConfig> fields;
  final String? createdBy;
  final DateTime createdAt;
  final bool isPredefined;

  final String? icon;

  Template({
    required this.id,
    required this.title,
    required this.description,
    required this.fields,
    this.createdBy,
    required this.createdAt,
    this.isPredefined = false,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fields': fields.map((field) => field.toJson()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPredefined': isPredefined,
      'icon': icon,
    };
  }

  factory Template.fromJson(Map<String, dynamic> json) {
  return Template(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    fields: (json['fields'] as List?)
        ?.map((field) => FieldConfig.fromJson(field))
        .toList() ?? [],
    createdBy: json['createdBy'],
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now(),
    isPredefined: json['isPredefined'] ?? false,
    icon: json['icon'],
  );
}

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory Template.fromJsonString(String jsonString) {
    return Template.fromJson(jsonDecode(jsonString));
  }
}