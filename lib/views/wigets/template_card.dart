import 'package:flutter/material.dart';
import '../../models/template_model.dart';

class TemplateCard extends StatelessWidget {
  final Template template;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const TemplateCard({
    Key? key,
    required this.template,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (template.icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Icon(
                        _getIconData(template.icon!),
                        size: 28,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  // Title and badge for predefined templates
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            template.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (template.isPredefined)
                          Chip(
                            label: Text('Predefined'),
                            backgroundColor: Colors.blueGrey[100],
                            labelStyle: TextStyle(fontSize: 12),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                  ),
                ],
              ),   
              SizedBox(height: 8),
              Text(
                template.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${template.fields.length} ${template.fields.length == 1 ? 'field' : 'fields'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (template.isPredefined)
                    Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: Colors.grey[500],
                    ),
                  if (!template.isPredefined && (onEdit != null || onDelete != null))
                    Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        TextButton.icon(
                          icon: Icon(Icons.edit, size: 18),
                          label: Text('Edit'),
                          onPressed: onEdit,
                        ),
                      if (onDelete != null)
                        TextButton.icon(
                          icon: Icon(Icons.delete, size: 18),
                          label: Text('Delete'),
                          onPressed: onDelete,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fire_extinguisher':
        return Icons.local_fire_department;
      case 'electrical':
        return Icons.electrical_services;
      case 'hazard':
        return Icons.warning;
      case 'safety':
        return Icons.health_and_safety;
      case 'inspection':
        return Icons.search;
      default:
        return Icons.assignment;
    }
  }
}