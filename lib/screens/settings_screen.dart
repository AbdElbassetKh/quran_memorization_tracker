import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/plan_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableNotifications = true;
  bool _darkMode = false;
  String _language = 'العربية';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableNotifications = prefs.getBool('enable_notifications') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _language = prefs.getString('language') ?? 'العربية';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_notifications', _enableNotifications);
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setString('language', _language);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ الإعدادات')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('بدء خطة حفظ جديدة'),
            subtitle: const Text('سيتم إعادة ضبط التقدم الحالي'),
            trailing: const Icon(Icons.refresh),
            onTap: () => _confirmResetPlan(context),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('الإشعارات'),
            subtitle: const Text('تفعيل الإشعارات اليومية'),
            value: _enableNotifications,
            onChanged: (value) {
              setState(() {
                _enableNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('الوضع الليلي'),
            subtitle: const Text('تفعيل الوضع الليلي'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
            },
          ),
          ListTile(
            title: const Text('اللغة'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(),
          ListTile(
            title: const Text('عن التطبيق'),
            trailing: const Icon(Icons.info_outline),
            onTap: () => _showAboutDialog(context),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('حفظ الإعدادات'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetPlan(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('بدء خطة جديدة'),
            content: const Text(
              'هل أنت متأكد من أنك تريد بدء خطة حفظ جديدة؟ سيتم فقدان جميع بيانات التقدم الحالية.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _createNewPlan(context);
                },
                child: const Text('تأكيد'),
              ),
            ],
          ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: const Text('اختر اللغة'),
            children: [
              _buildLanguageOption(context, 'العربية'),
              _buildLanguageOption(context, 'English'),
            ],
          ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String language) {
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          _language = language;
        });
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text(language, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (_language == language)
              Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AboutDialog(
            applicationName: 'تطبيق متابعة حفظ القرآن الكريم',
            applicationVersion: '1.0.0',
            applicationIcon: Icon(
              Icons.menu_book,
              color: Theme.of(context).colorScheme.primary,
              size: 40,
            ),
            children: const [
              SizedBox(height: 16),
              Text(
                'تطبيق لتتبع سير خطة حفظ القرآن الكريم، يساعدك على متابعة تقدمك في الحفظ والمراجعة.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'تم تطويره بواسطة فريق متابعة حفظ القرآن الكريم',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
    );
  }

  Future<void> _createNewPlan(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null && mounted) {
      final provider = Provider.of<PlanProvider>(context, listen: false);
      provider.createNewPlan(selectedDate);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إنشاء خطة حفظ جديدة')));
      }
    }
  }
}
