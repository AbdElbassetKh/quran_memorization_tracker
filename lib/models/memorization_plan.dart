import 'package:intl/intl.dart';

enum PlanTaskType {
  dailyReading,
  dailyListening,
  weeklyPreparation,
  nightlyPreparation,
  memorization,
  recentReview,
  distantReview,
  restDay,
}

class PlanTask {
  final PlanTaskType type;
  final String title;
  final String description;
  final dynamic
  content; // Could be QuranJuz, QuranHizb, QuranThumn, or List of them

  PlanTask({
    required this.type,
    required this.title,
    required this.description,
    this.content,
  });
}

class DailyPlan {
  final DateTime date;
  final List<PlanTask> tasks;
  bool isCompleted;

  DailyPlan({
    required this.date,
    required this.tasks,
    this.isCompleted = false,
  });

  String get formattedDate => DateFormat.yMMMd().format(date);
  bool get isRestDay => tasks.any((task) => task.type == PlanTaskType.restDay);
}

class MemorizationPlan {
  final DateTime startDate;
  late List<DailyPlan> dailyPlans;
  int daysCompleted = 0;

  // Content tracking indices
  int _juzIndex = 0;
  int _hizbIndex = 0;
  int _thumnIndex = 0;

  MemorizationPlan({required this.startDate}) {
    _generatePlan();
  }

  void _generatePlan() {
    dailyPlans = [];
    DateTime currentDate = startDate;

    // Counters for tracking rest days
    int dailyReadingCounter = 0;
    int weeklyPrepCounter = 0;
    int nightlyPrepCounter = 0;
    int memorizationCounter = 0;
    int memorizationThumnIndex =
        0; // Added to track memorization Thumn separately

    // Generate plan for 1 year (approximate time to complete the Quran memorization)
    for (int day = 0; day < 365; day++) {
      List<PlanTask> tasks = [];

      // Daily reading: Read one Juz every day, rest every 10 days
      dailyReadingCounter++;
      bool isRestDay = dailyReadingCounter % 10 == 0;

      if (!isRestDay) {
        _juzIndex = (_juzIndex + 1) % 30;
        _hizbIndex = (_hizbIndex + 1) % 60;

        tasks.add(
          PlanTask(
            type: PlanTaskType.dailyReading,
            title: 'القراءة اليومية',
            description: 'قراءة جزء كامل',
            content: 'الجزء ${_juzIndex == 0 ? 30 : _juzIndex}',
          ),
        );

        tasks.add(
          PlanTask(
            type: PlanTaskType.dailyListening,
            title: 'الاستماع اليومي',
            description: 'سماع حزب واحد',
            content: 'الحزب ${_hizbIndex == 0 ? 60 : _hizbIndex}',
          ),
        );
      } else {
        tasks.add(
          PlanTask(
            type: PlanTaskType.restDay,
            title: 'يوم راحة',
            description: 'يوم راحة من القراءة والاستماع اليومي',
          ),
        );
      }

      // Weekly preparation: Read one Hizb daily for 10 days
      if (day < 20) {
        // First 20 days cover the first 2 weekly preparation cycles
        if (day < 10) {
          // First 10 days - first Hizb
          weeklyPrepCounter++;
          if (weeklyPrepCounter <= 10) {
            tasks.add(
              PlanTask(
                type: PlanTaskType.weeklyPreparation,
                title: 'التحضير الأسبوعي',
                description: 'قراءة الحزب 1 يومياً',
                content: 'الحزب 1',
              ),
            );
          }
        } else {
          // Next 10 days - second Hizb
          tasks.add(
            PlanTask(
              type: PlanTaskType.weeklyPreparation,
              title: 'التحضير الأسبوعي',
              description: 'قراءة الحزب 2 يومياً',
              content: 'الحزب 2',
            ),
          );
        }
      }

      // Nightly preparation: Listen and read one Thumn daily after first 10 days
      if (day >= 10) {
        nightlyPrepCounter++;
        if (nightlyPrepCounter % 5 != 0) {
          // Rest every 5 days
          if (!isRestDay) {
            _thumnIndex++;
            final int currentThumn = ((_thumnIndex - 1) % 8) + 1;
            final int currentHizb = ((_thumnIndex - 1) ~/ 8) + 1;

            tasks.add(
              PlanTask(
                type: PlanTaskType.nightlyPreparation,
                title: 'التحضير الليلي',
                description: 'الاستماع وقراءة ثمن واحد (المراد حفظه غداً)',
                content: 'الثمن $currentThumn من الحزب $currentHizb',
              ),
            );
          }
        }
      }

      // Memorization: Read a Thumn 7 times and then memorize it, after first nightly prep
      if (day >= 11) {
        memorizationCounter++;
        if (memorizationCounter % 5 != 0) {
          // Rest every 5 days
          if (!isRestDay) {
            memorizationThumnIndex++; // Increment our separate memorization counter
            final int currentThumn = ((memorizationThumnIndex - 1) % 8) + 1;
            final int currentHizb = ((memorizationThumnIndex - 1) ~/ 8) + 1;

            tasks.add(
              PlanTask(
                type: PlanTaskType.memorization,
                title: 'التحضير القبلي والحفظ',
                description: 'قراءة ثمن 7 مرات ثم حفظه',
                content: 'الثمن $currentThumn من الحزب $currentHizb',
              ),
            );
          }
        }
      }

      // Recent review: After memorizing first Hizb (8 Thumns)
      if (day >= 19) {
        if (!isRestDay) {
          tasks.add(
            PlanTask(
              type: PlanTaskType.recentReview,
              title: 'مراجعة القريب',
              description: 'قراءة غيبية لآخر حزبين تم حفظهما',
              content:
                  'الحزبان ${(memorizationThumnIndex ~/ 8)} و ${(memorizationThumnIndex ~/ 8) - 1}',
            ),
          );
        }
      }

      // Distant review: After a new Hizb enters recent review
      if (day >= 27) {
        if (!isRestDay) {
          tasks.add(
            PlanTask(
              type: PlanTaskType.distantReview,
              title: 'مراجعة البعيد',
              description: 'قراءة غيبية خلال 10 أيام لما حفظ قبل آخر حزبين',
              content: 'الأحزاب 1 إلى ${(memorizationThumnIndex ~/ 8) - 2}',
            ),
          );
        }
      }

      dailyPlans.add(
        DailyPlan(date: currentDate, tasks: tasks, isCompleted: false),
      );

      currentDate = currentDate.add(Duration(days: 1));
    }
  }

  DailyPlan getDailyPlan(DateTime date) {
    final index = dailyPlans.indexWhere(
      (plan) =>
          DateFormat.yMd().format(plan.date) == DateFormat.yMd().format(date),
    );

    if (index != -1) {
      return dailyPlans[index];
    }

    // If no plan exists for this date, return an empty plan
    return DailyPlan(
      date: date,
      tasks: [
        PlanTask(
          type: PlanTaskType.restDay,
          title: 'خارج نطاق الخطة',
          description: 'هذا اليوم خارج نطاق خطة الحفظ المعدة',
        ),
      ],
    );
  }

  void markDailyPlanAsCompleted(DateTime date) {
    final index = dailyPlans.indexWhere(
      (plan) =>
          DateFormat.yMd().format(plan.date) == DateFormat.yMd().format(date),
    );

    if (index != -1) {
      dailyPlans[index].isCompleted = true;
      daysCompleted++;
    }
  }

  double get completionPercentage => daysCompleted / dailyPlans.length * 100;
}
