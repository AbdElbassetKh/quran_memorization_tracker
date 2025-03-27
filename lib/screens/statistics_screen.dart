import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plan_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إحصائيات الحفظ')),
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

          final daysCompleted = provider.plan!.daysCompleted;
          final totalDays = provider.plan!.dailyPlans.length;
          final completionPercentage = provider.plan!.completionPercentage;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملخص التقدم',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 20),
                        _buildProgressIndicator(context, completionPercentage),
                        const SizedBox(height: 20),
                        _buildStatItem(
                          context,
                          'الأيام المكتملة',
                          '$daysCompleted من $totalDays',
                        ),
                        const SizedBox(height: 10),
                        _buildStatItem(
                          context,
                          'نسبة الإكمال',
                          '${completionPercentage.toStringAsFixed(2)}%',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMemorizationProgress(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, double percentage) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: percentage / 100,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${percentage.toStringAsFixed(2)}% مكتمل',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMemorizationProgress(
    BuildContext context,
    PlanProvider provider,
  ) {
    // This would be implemented with real data tracking which parts
    // have been memorized. For now, we'll create a placeholder:
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تقدم الحفظ',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'الأجزاء المحفوظة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _buildPartsGrid(context, 30), // 30 Juz
            const SizedBox(height: 20),
            Text(
              'الأحزاب المحفوظة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _buildPartsGrid(context, 60), // 60 Hizb
          ],
        ),
      ),
    );
  }

  Widget _buildPartsGrid(BuildContext context, int count) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        // Placeholder for memorization status - would be replaced
        // with real tracking data
        final isMemorized = index < 5; // First 5 parts for demonstration

        return Container(
          decoration: BoxDecoration(
            color:
                isMemorized
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isMemorized ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  void _createNewPlan(BuildContext context) {
    // For a StatelessWidget, we can use a variable to ensure we don't capture the BuildContext
    final BuildContext capturedContext = context;

    // Instead of using then, use async-await with a separate function
    _showDatePickerAndCreatePlan(capturedContext);
  }

  Future<void> _showDatePickerAndCreatePlan(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      final provider = Provider.of<PlanProvider>(context, listen: false);
      provider.createNewPlan(selectedDate);
    }
  }
}
