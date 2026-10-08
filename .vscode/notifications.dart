part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// ---------------------------------------------------------------------
// اعلان‌ها
// ---------------------------------------------------------------------
class AppNotification {
  final String type;
  final String user;
  final String text;
  final String time;
  bool read;
  AppNotification({
    required this.type,
    required this.user,
    required this.text,
    required this.time,
    this.read = false,
  });
}

final List<AppNotification> _seedNotifications =
    List<AppNotification>.generate(12, (i) {
  const List<String> types = ['judge', 'like', 'comment', 'follow'];
  const List<String> times = [
    '۲ دقیقه پیش',
    '۱۵ دقیقه پیش',
    '۱ ساعت پیش',
    '۳ ساعت پیش',
    'دیروز',
    '۲ روز پیش',
  ];
  final String type = types[i % 4];
  final TalentUser u = allTalentUsers[(i * 3) % allTalentUsers.length];
  String text;
  switch (type) {
    case 'judge':
      text = 'به اثر شما نمره ${70 + (i * 7) % 30} از ۱۰۰ داد ⭐';
      break;
    case 'like':
      text = 'اثر شما را پسندید ❤️';
      break;
    case 'comment':
      text = 'نظر داد: «کارت واقعاً حرفه‌ای بود 👌»';
      break;
    default:
      text = 'شما را دنبال کرد';
  }
  return AppNotification(
    type: type,
    user: u.username,
    text: text,
    time: times[i % times.length],
    read: i > 4,
  );
});

TalentUser userByName(String name) {
  return allTalentUsers.firstWhere(
    (u) => u.username == name,
    orElse: () => allTalentUsers.first,
  );
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<AppNotification> _items = _seedNotifications;

  @override
  void initState() {
    super.initState();
    AppState.I.addListener(_onApp);
  }

  @override
  void dispose() {
    AppState.I.removeListener(_onApp);
    super.dispose();
  }

  void _onApp() {
    if (mounted) setState(() {});
  }

  int get _unread => _items.where((n) => !n.read).length;

  IconData _icon(String type) {
    switch (type) {
      case 'judge':
        return Icons.star_rounded;
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      default:
        return Icons.person_add_alt_1;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'judge':
        return const Color(0xFFFFB300);
      case 'like':
        return const Color(0xFFFF0055);
      case 'comment':
        return const Color(0xFF00E5FF);
      default:
        return Colors.greenAccent;
    }
  }

  Widget _trailing(AppNotification n) {
    if (n.type == 'follow') {
      final bool f = AppState.I.isFollowing(n.user);
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              f ? const Color(0xFF2A2A36) : const Color(0xFF00E5FF),
          foregroundColor: f ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(0, 32),
        ),
        onPressed: () => AppState.I.toggleFollow(n.user),
        child: Text(
          f ? 'دنبال می‌کنید' : 'دنبال کردن',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      );
    }
    if (!n.read) {
      return const Icon(Icons.circle, size: 10, color: Color(0xFF00E5FF));
    }
    return Icon(_icon(n.type), size: 18, color: _color(n.type));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_unread > 0 ? 'اعلان‌ها ($_unread جدید)' : 'اعلان‌ها'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              for (final AppNotification n in _items) {
                n.read = true;
              }
            }),
            child: const Text(
              'خواندن همه',
              style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final AppNotification n = _items[i];
          return Container(
            color: n.read ? null : const Color(0x1400E5FF),
            child: ListTile(
              onTap: () {
                setState(() => n.read = true);
                openUserProfile(context, userByName(n.user));
              },
              leading: Stack(
                clipBehavior: Clip.none,
                children: [
                  CubeAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(avatarUrl(n.user)),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: _color(n.type),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_icon(n.type), size: 10, color: Colors.black),
                    ),
                  ),
                ],
              ),
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: n.user,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' ${n.text}'),
                  ],
                ),
                style: const TextStyle(fontSize: 13),
              ),
              subtitle: Text(
                '${guildPathByTitle(userByName(n.user).field)} • ${n.time}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              trailing: _trailing(n),
            ),
          );
        },
      ),
    );
  }
}
