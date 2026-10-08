part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// دوستان نزدیک، «علاقه‌ای ندارم»، تگ‌ها و منشن‌ها
// و ردیف‌های جدید تنظیمات
// =====================================================================

// ---------------------------------------------------------------------
// دوستان نزدیک: استوری‌ای که برای «دوستان نزدیک» بزنی فقط اون‌ها می‌بینن
// ---------------------------------------------------------------------
class CloseFriendsScreen extends StatefulWidget {
  const CloseFriendsScreen({super.key});

  @override
  State<CloseFriendsScreen> createState() => _CloseFriendsScreenState();
}

class _CloseFriendsScreenState extends State<CloseFriendsScreen> {
  String _q = '';

  Widget _row(String u) {
    final bool on = SocialStore.I.isClose(u);
    return ListTile(
      onTap: () => SocialStore.I.toggleClose(u),
      leading: CubeAvatar(
        radius: 22,
        backgroundColor: const Color(0xFF1E1E28),
        backgroundImage: NetworkImage(avatarUrl(u)),
        onBackgroundImageError: (_, __) {},
      ),
      title: Text(
        u,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      trailing: Icon(
        on ? Icons.check_circle : Icons.radio_button_unchecked,
        color: on ? const Color(0xFF00C853) : Colors.grey,
      ),
    );
  }

  Widget _title(String t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دوستان نزدیک')),
      body: AnimatedBuilder(
        animation: SocialStore.I,
        builder: (context, _) {
          final List<String> members = SocialStore.I.closeFriends.toList();
          final List<String> others =
              knownUsernames().where((u) => !SocialStore.I.isClose(u)).toList();
          bool match(String u) =>
              _q.isEmpty || u.toLowerCase().contains(_q.toLowerCase());
          final List<String> m = members.where(match).toList();
          final List<String> o = others.where(match).toList();
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  onChanged: (v) => setState(() => _q = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'جستجو...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFF16161F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'فقط خودت می‌دانی چه کسانی در این فهرست‌اند. استوری‌هایی که برای «دوستان نزدیک» بگذاری، با نشان سبز فقط برای همین افراد دیده می‌شود.',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ),
              _title('اعضا (${members.length})'),
              if (m.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'هنوز کسی اضافه نشده است.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ...m.map(_row),
              _title('پیشنهادها'),
              ...o.map(_row),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------
// پست‌هایی که «علاقه‌ای ندارم» زدی؛ از اینجا می‌تونی برشون گردونی
// ---------------------------------------------------------------------
class NotInterestedScreen extends StatelessWidget {
  const NotInterestedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پست‌های «علاقه‌ای ندارم»')),
      body: AnimatedBuilder(
        animation: SocialStore.I,
        builder: (context, _) {
          final List<MapEntry<String, String>> list =
              SocialStore.I.hiddenPosts.entries.toList();
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'هنوز پستی را پنهان نکرده‌اید.\nاز منوی سه‌نقطه‌ی هر پست، «علاقه‌ای ندارم» را بزنید.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final MapEntry<String, String> e = list[i];
              final String seed = e.key.replaceAll('feed_', '');
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: hlImage(
                      'seed:talent_post_${(int.tryParse(seed) ?? 0) + 20}',
                      w: 120,
                      h: 120,
                    ),
                  ),
                ),
                title: Text(
                  'پست ${e.value}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: const Text(
                  'در فید شما نمایش داده نمی‌شود',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                trailing: TextButton(
                  onPressed: () => SocialStore.I.unhidePost(e.key),
                  child: const Text(
                    'بازگردانی',
                    style: TextStyle(color: Color(0xFF00E5FF)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------
// تگ‌ها و منشن‌ها: چه کسانی می‌توانند تو را تگ کنند + پست‌هایی که تگ شده‌ای
// ---------------------------------------------------------------------
class TaggedMeScreen extends StatelessWidget {
  const TaggedMeScreen({super.key});

  Widget _policy(String value, String title, String sub) {
    final bool on = SocialStore.I.tagPolicy == value;
    return ListTile(
      dense: true,
      onTap: () => SocialStore.I.setTagPolicy(value),
      leading: Icon(
        on ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: on ? const Color(0xFF00E5FF) : Colors.grey,
      ),
      title: Text(title, style: const TextStyle(fontSize: 13)),
      subtitle: Text(
        sub,
        style: const TextStyle(color: Colors.grey, fontSize: 11),
      ),
    );
  }

  Widget _section(String t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
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

  void _menu(BuildContext context, String key, String author) {
    showDarkSheet<void>(
      context,
      (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              sheetHandle(),
              sheetTile(Icons.person_outline, 'مشاهده پروفایل $author', () {
                Navigator.pop(ctx);
                openUserByName(context, author);
              }),
              sheetTile(
                Icons.label_off_outlined,
                'حذف تگ من از این پست',
                () {
                  Navigator.pop(ctx);
                  SocialStore.I.removeTagged(key);
                  showSnack(context, 'تگ شما حذف شد');
                },
                color: const Color(0xFFFF5252),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تگ‌ها و منشن‌ها')),
      body: AnimatedBuilder(
        animation: SocialStore.I,
        builder: (context, _) {
          final List<int> ids = List<int>.generate(6, (i) => i)
              .where(
                (i) => !SocialStore.I.removedTagged.contains('tagged_$i'),
              )
              .toList();
          final bool blocked = SocialStore.I.tagPolicy == 'nobody';
          return ListView(
            children: [
              _section('چه کسانی می‌توانند شما را تگ کنند؟'),
              _policy('everyone', 'همه', 'هر کاربری می‌تواند شما را تگ کند'),
              _policy(
                'following',
                'فقط افرادی که دنبال می‌کنم',
                'فقط دنبال‌شونده‌های شما اجازه‌ی تگ دارند',
              ),
              _policy('nobody', 'هیچ‌کس', 'کسی نمی‌تواند شما را تگ کند'),
              _section('پست‌هایی که در آن‌ها تگ شده‌اید'),
              if (blocked || ids.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'فعلاً پستی که در آن تگ شده باشید وجود ندارد.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  itemCount: ids.length,
                  itemBuilder: (context, k) {
                    final int i = ids[k];
                    final String author = 'استعداد_${(i % 8) + 1}';
                    return GestureDetector(
                      onTap: () => _menu(context, 'tagged_$i', author),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          hlImage('seed:tag_me_$i', w: 300, h: 300),
                          Positioned(
                            left: 4,
                            bottom: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                author,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------
// ردیف‌های جدید تنظیمات (بالای بخش «امکانات باراوی» قرار می‌گیرن)
// ---------------------------------------------------------------------
List<Widget> extraSettingsTiles(BuildContext context) {
  Widget tile(IconData icon, String title, Widget Function() page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_left, color: Colors.grey),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => page()),
      ),
    );
  }

  return <Widget>[
    tile(
      Icons.storefront_outlined,
      ts('showcase_title'),
      () => const ShowcaseHome(),
    ),
    tile(
      Icons.history,
      'آرشیو (استوری‌ها و پست‌ها)',
      () => const StoryArchiveScreen(),
    ),
    tile(
      Icons.star_border_rounded,
      'دوستان نزدیک',
      () => const CloseFriendsScreen(),
    ),
    tile(
      Icons.person_pin_outlined,
      'تگ‌ها و منشن‌ها',
      () => const TaggedMeScreen(),
    ),
    tile(
      Icons.visibility_off_outlined,
      'پست‌های «علاقه‌ای ندارم»',
      () => const NotInterestedScreen(),
    ),
  ];
}
