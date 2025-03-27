import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/memorization_plan.dart';

class PlanProvider with ChangeNotifier {
  static const String _startDateKey = 'plan_start_date';
  static const String _completedDaysKey = 'completed_days';
  static const String _completedTasksKey = 'completed_tasks';

  MemorizationPlan? _plan;
  bool _isLoading = true;
  Map<String, bool> _completedTasks = {};

  PlanProvider() {
    _loadPlan();
  }

  bool get isLoading => _isLoading;
  MemorizationPlan? get plan => _plan;

  Future<void> _loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final String? startDateStr = prefs.getString(_startDateKey);

    if (startDateStr != null) {
      final startDate = DateTime.parse(startDateStr);
      _plan = MemorizationPlan(startDate: startDate);

      // Load completed days
      final List<String>? completedDaysStr = prefs.getStringList(
        _completedDaysKey,
      );
      if (completedDaysStr != null) {
        final completedDates =
            completedDaysStr.map((dateStr) => DateTime.parse(dateStr)).toList();

        for (var date in completedDates) {
          _plan!.markDailyPlanAsCompleted(date);
        }
      }

      // Load completed tasks
      final completedTasksStr = prefs.getString(_completedTasksKey);
      if (completedTasksStr != null) {
        _completedTasks = Map<String, bool>.from(
          Map<String, dynamic>.from(
            json.decode(completedTasksStr),
          ).map((key, value) => MapEntry(key, value as bool)),
        );
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createNewPlan(DateTime startDate) async {
    _isLoading = true;
    notifyListeners();

    // Clear all existing data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data

    // Reset internal state
    _completedTasks = {};
    _plan = MemorizationPlan(startDate: startDate);

    // Save new plan data
    await prefs.setString(_startDateKey, startDate.toIso8601String());
    await prefs.setStringList(_completedDaysKey, []);
    await prefs.setString(_completedTasksKey, json.encode(_completedTasks));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markDayAsCompleted(DateTime date) async {
    if (_plan == null) return;

    _plan!.markDailyPlanAsCompleted(date);

    final prefs = await SharedPreferences.getInstance();
    final List<String> completedDays =
        _plan!.dailyPlans
            .where((plan) => plan.isCompleted)
            .map((plan) => plan.date.toIso8601String())
            .toList();

    await prefs.setStringList(_completedDaysKey, completedDays);

    notifyListeners();
  }

  Future<void> markTaskCompleted(String taskKey, bool completed) async {
    _completedTasks[taskKey] = completed;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_completedTasksKey, json.encode(_completedTasks));

    notifyListeners();
  }

  bool isTaskCompleted(String taskKey) {
    return _completedTasks[taskKey] ?? false;
  }

  DailyPlan getTodaysPlan() {
    if (_plan == null) return DailyPlan(date: DateTime.now(), tasks: []);

    return _plan!.getDailyPlan(DateTime.now());
  }

  DailyPlan getPlanForDate(DateTime date) {
    if (_plan == null) return DailyPlan(date: date, tasks: []);

    return _plan!.getDailyPlan(date);
  }

  List<PlanTask> getCompletedTasksByType(PlanTaskType type) {
    if (_plan == null) return [];

    List<PlanTask> completedTasks = [];
    for (var dailyPlan in _plan!.dailyPlans) {
      for (var task in dailyPlan.tasks) {
        if (task.type == type) {
          final taskKey =
              '${dailyPlan.date.toIso8601String()}_${task.type.toString()}_${task.title}';
          if (_completedTasks[taskKey] == true) {
            completedTasks.add(task);
          }
        }
      }
    }
    return completedTasks;
  }

  void resetProgress() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedDaysKey);
    await prefs.remove(_completedTasksKey);

    _completedTasks = {};
    if (_plan != null) {
      _plan!.daysCompleted = 0;
      for (var plan in _plan!.dailyPlans) {
        plan.isCompleted = false;
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
