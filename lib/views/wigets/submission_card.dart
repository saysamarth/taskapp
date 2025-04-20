// lib/widgets/submission_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/form_submission_model.dart';

class SubmissionCard extends StatelessWidget {
  final FormSubmission submission;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const SubmissionCard({
    Key? key,
    required this.submission,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final timeFormatter = DateFormat('h:mm a');
    final submittedDate = dateFormatter.format(submission.submittedAt);
    final submittedTime = timeFormatter.format(submission.submittedAt);

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
                  Icon(
                    submission.isSynced ? Icons.cloud_done : Icons.cloud_upload,
                    size: 20,
                    color: submission.isSynced ? Colors.green : Colors.orange,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getSubmissionTitle(),
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submitted on:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '$submittedDate at $submittedTime',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    submission.isSynced ? 'Synced' : 'Pending sync',
                    style: TextStyle(
                      color: submission.isSynced ? Colors.green : Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (onDelete != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
        ),
      ),
    );
  }

  String _getSubmissionTitle() {
    return submission.submissionName ?? 'Untitled Submission';
  }
}
