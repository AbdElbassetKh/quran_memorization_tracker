import 'package:flutter/material.dart';
import '../models/memorization_plan.dart';

class TaskCard extends StatelessWidget {
  final PlanTask task;
  final bool isCompleted;
  final VoidCallback onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.isCompleted,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onToggleComplete,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (task.content != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          task.content.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Checkbox(
                value: isCompleted,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (_) => onToggleComplete(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskIcon() {
    IconData iconData;
    Color iconColor;

    switch (task.type) {
      case PlanTaskType.dailyReading:
        iconData = Icons.menu_book;
        iconColor = Colors.blue;
        break;
      case PlanTaskType.dailyListening:
        iconData = Icons.headphones;
        iconColor = Colors.purple;
        break;
      case PlanTaskType.weeklyPreparation:
        iconData = Icons.calendar_view_week;
        iconColor = Colors.orange;
        break;
      case PlanTaskType.nightlyPreparation:
        iconData = Icons.nights_stay;
        iconColor = Colors.indigo;
        break;
      case PlanTaskType.memorization:
        iconData = Icons.psychology;
        iconColor = Colors.red;
        break;
      case PlanTaskType.recentReview:
        iconData = Icons.history;
        iconColor = Colors.teal;
        break;
      case PlanTaskType.distantReview:
        iconData = Icons.update;
        iconColor = Colors.brown;
        break;
      case PlanTaskType.restDay:
        iconData = Icons.weekend;
        iconColor = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withValues(
          alpha: iconColor.a * 0.1,
          red: iconColor.r.toDouble(),
          green: iconColor.g.toDouble(),
          blue: iconColor.b.toDouble(),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }
}
