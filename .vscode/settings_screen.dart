part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// ---------------------------------------------------------------------
// تنظیمات (نسخه جدید با دسترسی به داوری، اعلان‌ها و پیام‌ها)
// ---------------------------------------------------------------------
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notif = true;
  bool _private = false;
  bool _sound = true;

  Widget _section(String t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Text(
        t,
        style: const TextStyle(
          color: Color(0xFF00E5FF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _switch(String title, String sub, bool value, ValueChanged<bool> cb) {
    return SwitchListTile(
      value: value,
      onChanged: cb,
      activeColor: const Color(0xFF00E5FF),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        sub,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_left, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        title: const Text('خروج از حساب'),
        content: const Text('مطمئنی می‌خوای از حساب خارج بشی؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _snack('خروج از حساب شبیه‌سازی شد');
            },
            child: const Text(
              'خروج',
              style: TextStyle(color: Color(0xFFFF0055)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        children: [
          _section('امکانات باراوی'),
          ...extraSettingsTiles(context),
          _tile(Icons.bookmark_border, 'ذخیره‌شده‌ها و مجموعه‌ها',
              () => _open(const SavedScreen())),
          _tile(Icons.gavel_rounded, 'مرکز داوری (نمره‌دهی ۱ تا ۱۰۰)',
              () => _open(const JudgeCenterScreen())),
          _tile(Icons.notifications_none, 'اعلان‌ها',
              () => _open(const NotificationsScreen())),
          _tile(Icons.chat_bubble_outline, 'پیام‌های مستقیم',
              () => _open(const MessagesScreen())),
          _section('اعلان‌ها'),
          _switch(
            'اعلان‌های برنامه',
            'لایک، نظر و امتیازهای داوران',
            _notif,
            (v) => setState(() => _notif = v),
          ),
          _switch(
            'صدای اعلان',
            'پخش صدا هنگام دریافت اعلان',
            _sound,
            (v) => setState(() => _sound = v),
          ),
          _section('حریم خصوصی'),
          _switch(
            'حساب خصوصی',
            'فقط دنبال‌کنندگان آثار شما را ببینند',
            _private,
            (v) => setState(() => _private = v),
          ),
          _section('حساب کاربری'),
          _tile(Icons.language, 'زبان برنامه', () => _snack('فارسی فعال است')),
          _tile(Icons.history, 'پاک کردن سابقه جستجو', () {
            AppState.I.clearSearchHistory();
            _snack('سابقه جستجو پاک شد');
          }),
          _tile(Icons.info_outline, 'درباره باراوی', () {
            showAboutDialog(
              context: context,
              applicationName: 'Baravi Talent Hub',
              applicationVersion: '1.0.0',
            );
          }),
          const Divider(color: Color(0xFF282836)),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFFF0055)),
            title: const Text(
              'خروج از حساب',
              style: TextStyle(color: Color(0xFFFF0055), fontSize: 14),
            ),
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }
}
