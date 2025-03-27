import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/plan_provider.dart';
import '../models/memorization_plan.dart';
import '../widgets/task_card.dart';

class DailyPlanScreen extends StatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  State<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends State<DailyPlanScreen> {
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late List<PlanTask> _tasks;
  late Map<String, bool> _completedTasks;

  @override
  void initState() {
    super.initState();
    _tasks = [];
    _completedTasks = {};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  void _loadTasks() {
    final provider = Provider.of<PlanProvider>(context, listen: false);
    if (provider.plan != null) {
      final dailyPlan = provider.getPlanForDate(_selectedDate);
      setState(() {
        _tasks = dailyPlan.tasks;
        _completedTasks = {
          for (var task in _tasks)
            '${task.type.toString()}_${task.title}': provider.isTaskCompleted(
              '${_selectedDate.toIso8601String()}_${task.type.toString()}_${task.title}',
            ),
        };
      });
    }
  }

  void _toggleTaskCompletion(PlanTask task) {
    final taskKey =
        '${_selectedDate.toIso8601String()}_${task.type.toString()}_${task.title}';
    final newStatus =
        !(_completedTasks['${task.type.toString()}_${task.title}'] ?? false);

    setState(() {
      _completedTasks['${task.type.toString()}_${task.title}'] = newStatus;
    });

    final provider = Provider.of<PlanProvider>(context, listen: false);
    provider.markTaskCompleted(taskKey, newStatus);

    // Check if all tasks are completed
    final allCompleted = _completedTasks.values.every((completed) => completed);
    if (allCompleted) {
      provider.markDayAsCompleted(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خطة الحفظ اليومية')),
      body: Consumer<PlanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.plan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لم يتم إنشاء خطة للحفظ بعد'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _createNewPlan(context),
                    child: const Text('إنشاء خطة جديدة'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Calendar widget
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _selectedDate,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _loadTasks();
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(
                      alpha: Theme.of(context).colorScheme.primary.a * 0.5,
                      red: Theme.of(context).colorScheme.primary.r.toDouble(),
                      green: Theme.of(context).colorScheme.primary.g.toDouble(),
                      blue: Theme.of(context).colorScheme.primary.b.toDouble(),
                    ),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                ),
              ),
              const Divider(),

              // Date display
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat.yMMMMEEEEd().format(_selectedDate),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    if (_tasks.isNotEmpty)
                      Text(
                        'المهام: ${_tasks.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                  ],
                ),
              ),

              // Tasks list
              Expanded(
                child:
                    _tasks.isEmpty
                        ? Center(
                          child: Text(
                            'لا توجد مهام لهذا اليوم',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        )
                        : ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            final taskKey =
                                '${task.type.toString()}_${task.title}';
                            final isCompleted =
                                _completedTasks[taskKey] ?? false;

                            return TaskCard(
                              task: task,
                              isCompleted: isCompleted,
                              onToggleComplete:
                                  () => _toggleTaskCompletion(task),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _createNewPlan(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null && mounted) {
      Provider.of<PlanProvider>(
        context,
        listen: false,
      ).createNewPlan(selectedDate);
    }
  }
}
