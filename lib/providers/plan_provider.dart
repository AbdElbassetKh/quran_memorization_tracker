import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memorization_plan.dart';
import 'dart:convert';

class PlanProvider with ChangeNotifier {
  static const String _startDateKey = 'plan_start_date';
  static const String _completedDaysKey = 'completed_days';

  MemorizationPlan? _plan;
  bool _isLoading = true;

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
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createNewPlan(DateTime startDate) async {
    _isLoading = true;
    notifyListeners();

    _plan = MemorizationPlan(startDate: startDate);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_startDateKey, startDate.toIso8601String());
    await prefs.setStringList(_completedDaysKey, []);

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

  DailyPlan getTodaysPlan() {
    if (_plan == null) return DailyPlan(date: DateTime.now(), tasks: []);

    return _plan!.getDailyPlan(DateTime.now());
  }

  DailyPlan getPlanForDate(DateTime date) {
    if (_plan == null) return DailyPlan(date: date, tasks: []);

    return _plan!.getDailyPlan(date);
  }
}
