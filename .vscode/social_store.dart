part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// مدل‌ها و حافظه‌ی مشترک
// هایلایت‌ها، آرشیو، تگ آدم‌ها، دوستان نزدیک، «علاقه‌ای ندارم»
// =====================================================================

/// یک تگ روی عکس (موقعیت x و y بین ۰ تا ۱)
class TagEntry {
  final String user;
  final double x;
  final double y;
  const TagEntry(this.user, this.x, this.y);

  Map<String, dynamic> toJson() => <String, dynamic>{'u': user, 'x': x, 'y': y};

  static TagEntry fromJson(Map<String, dynamic> m) => TagEntry(
        m['u'] as String,
        (m['x'] as num).toDouble(),
        (m['y'] as num).toDouble(),
      );
}

/// اطلاعات اضافه‌ی هر اثر (بدون دست زدن به کلاس UserPost)
class PostMeta {
  List<TagEntry> tags;
  bool closeFriends;
  bool commentsOff;
  bool hideLikes;
  bool archived;

  PostMeta({
    List<TagEntry>? tags,
    this.closeFriends = false,
    this.commentsOff = false,
    this.hideLikes = false,
    this.archived = false,
  }) : tags = tags ?? <TagEntry>[];

  Map<String, dynamic> toJson() => <String, dynamic>{
        't': tags.map((e) => e.toJson()).toList(),
        'cf': closeFriends,
        'co': commentsOff,
        'hl': hideLikes,
        'ar': archived,
      };

  static PostMeta fromJson(Map<String, dynamic> m) => PostMeta(
        tags: ((m['t'] as List<dynamic>?) ?? <dynamic>[])
            .map((e) => TagEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        closeFriends: (m['cf'] as bool?) ?? false,
        commentsOff: (m['co'] as bool?) ?? false,
        hideLikes: (m['hl'] as bool?) ?? false,
        archived: (m['ar'] as bool?) ?? false,
      );
}

/// هایلایت پروفایل: عنوان + کاور + چند استوری
/// هر آیتم یک «src» است: 'post:<id>' (استوری واقعی خودت) یا 'seed:<نام>' (نمونه)
class Highlight {
  final String id;
  String title;
  String cover;
  final List<String> items;

  Highlight({
    required this.id,
    required this.title,
    required this.cover,
    List<String>? items,
  }) : items = items ?? <String>[];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'cover': cover,
        'items': items,
      };

  static Highlight fromJson(Map<String, dynamic> m) => Highlight(
        id: m['id'] as String,
        title: m['title'] as String,
        cover: m['cover'] as String,
        items: ((m['items'] as List<dynamic>?) ?? <dynamic>[])
            .map((e) => e as String)
            .toList(),
      );
}

/// یک آیتم داخل آرشیو استوری
class ArchiveItem {
  final String src;
  final String label;
  final bool isPost;
  final bool closeFriends;
  const ArchiveItem({
    required this.src,
    required this.label,
    required this.isPost,
    this.closeFriends = false,
  });
}

class SocialStore extends ChangeNotifier {
  SocialStore._();
  static final SocialStore I = SocialStore._();

  final Map<String, PostMeta> _meta = <String, PostMeta>{};
  final List<Highlight> highlights = <Highlight>[];
  final Set<String> closeFriends = <String>{};
  final Map<String, String> hiddenPosts = <String, String>{};
  final Set<String> deletedArchive = <String>{};
  final Set<String> removedTagged = <String>{};
  String tagPolicy = 'everyone'; // everyone | following | nobody
  int _n = 0;
  SharedPreferences? _prefs;
  bool _listening = false;

  // ---------- اطلاعات اضافه‌ی آثار ----------
  PostMeta metaOf(String id) => _meta[id] ?? PostMeta();

  void setMeta(String id, PostMeta m) {
    _meta[id] = m;
    notifyListeners();
  }

  void updateMeta(String id, void Function(PostMeta m) change) {
    final PostMeta m = _meta.putIfAbsent(id, () => PostMeta());
    change(m);
    notifyListeners();
  }

  // ---------- هایلایت‌ها ----------
  Highlight createHighlight(String title, String cover, List<String> items) {
    _n++;
    final Highlight h = Highlight(
      id: 'hl_$_n',
      title: title,
      cover: cover,
      items: List<String>.of(items),
    );
    highlights.add(h);
    notifyListeners();
    return h;
  }

  void editHighlight(
    Highlight h, {
    String? title,
    String? cover,
    List<String>? items,
  }) {
    if (title != null) h.title = title;
    if (cover != null) h.cover = cover;
    if (items != null) {
      final List<String> copy = List<String>.of(items);
      h.items
        ..clear()
        ..addAll(copy);
    }
    notifyListeners();
  }

  void deleteHighlight(Highlight h) {
    highlights.remove(h);
    notifyListeners();
  }

  void removeFromHighlight(Highlight h, String src) {
    h.items.remove(src);
    if (h.items.isEmpty) {
      highlights.remove(h);
    } else if (h.cover == src) {
      h.cover = h.items.first;
    }
    notifyListeners();
  }

  // ---------- آرشیو ----------
  void deleteArchiveSeed(String src) {
    deletedArchive.add(src);
    notifyListeners();
  }

  // ---------- دوستان نزدیک ----------
  bool isClose(String user) => closeFriends.contains(user);

  void toggleClose(String user) {
    if (!closeFriends.remove(user)) closeFriends.add(user);
    notifyListeners();
  }

  // ---------- «علاقه‌ای ندارم» ----------
  bool isHidden(String key) => hiddenPosts.containsKey(key);

  void hidePost(String key, String author) {
    hiddenPosts[key] = author;
    notifyListeners();
  }

  void unhidePost(String key) {
    hiddenPosts.remove(key);
    notifyListeners();
  }

  // ---------- تگ‌ها ----------
  void setTagPolicy(String v) {
    tagPolicy = v;
    notifyListeners();
  }

  void removeTagged(String key) {
    removedTagged.add(key);
    notifyListeners();
  }

  // ---------- ذخیره و خواندن ----------
  Future<void> load() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      _prefs = p;
      final String? raw = p.getString('baravi_social');
      if (raw != null) {
        final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
        _n = (m['n'] as num?)?.toInt() ?? 0;
        final Map<String, dynamic> meta =
            (m['meta'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        meta.forEach(
          (k, v) => _meta[k] = PostMeta.fromJson(v as Map<String, dynamic>),
        );
        for (final dynamic e in (m['hl'] as List<dynamic>?) ?? <dynamic>[]) {
          highlights.add(Highlight.fromJson(e as Map<String, dynamic>));
        }
        for (final dynamic e in (m['cf'] as List<dynamic>?) ?? <dynamic>[]) {
          closeFriends.add(e as String);
        }
        final Map<String, dynamic> hid =
            (m['hid'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        hid.forEach((k, v) => hiddenPosts[k] = v as String);
        for (final dynamic e in (m['del'] as List<dynamic>?) ?? <dynamic>[]) {
          deletedArchive.add(e as String);
        }
        for (final dynamic e in (m['rt'] as List<dynamic>?) ?? <dynamic>[]) {
          removedTagged.add(e as String);
        }
        tagPolicy = (m['tp'] as String?) ?? 'everyone';
      }
    } catch (_) {}
    if (!_listening) {
      _listening = true;
      addListener(_save);
    }
  }

  void _save() {
    final SharedPreferences? p = _prefs;
    if (p == null) return;
    try {
      p.setString(
        'baravi_social',
        jsonEncode(<String, dynamic>{
          'n': _n,
          'meta': _meta.map(
            (k, v) => MapEntry<String, dynamic>(k, v.toJson()),
          ),
          'hl': highlights.map((h) => h.toJson()).toList(),
          'cf': closeFriends.toList(),
          'hid': hiddenPosts,
          'del': deletedArchive.toList(),
          'rt': removedTagged.toList(),
          'tp': tagPolicy,
        }),
      );
    } catch (_) {}
  }
}

// ---------------------------------------------------------------------
// توابع کمکی مشترک
// ---------------------------------------------------------------------
UserPost? findMyPost(String id) {
  for (final UserPost p in PostStore.I.posts) {
    if (p.id == id) return p;
  }
  return null;
}

/// آیا این آیتم هنوز وجود داره؟ (استوری حذف‌شده‌ی خودت دیگه نمایش داده نمی‌شه)
bool srcAlive(String src) {
  if (src.startsWith('post:')) return findMyPost(src.substring(5)) != null;
  return true;
}

Widget _imgError() => Container(
      color: const Color(0xFF1E1E28),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.white38),
      ),
    );

/// تصویر یک آیتم هایلایت/آرشیو (عکس واقعی خودت یا عکس نمونه)
Widget hlImage(
  String src, {
  Key? key,
  BoxFit fit = BoxFit.cover,
  int w = 700,
  int h = 1200,
}) {
  if (src.startsWith('post:')) {
    final String id = src.substring(5);
    final Uint8List? b = PostImages.of(id);
    if (b != null) {
      return Image.memory(
        b,
        key: key,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
      );
    }
    final UserPost? p = findMyPost(id);
    return Image.network(
      'https://picsum.photos/seed/my_work_${p?.imageSeed ?? 0}/$w/$h',
      key: key,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _imgError(),
    );
  }
  final String seed = src.startsWith('seed:') ? src.substring(5) : src;
  return Image.network(
    'https://picsum.photos/seed/$seed/$w/$h',
    key: key,
    fit: fit,
    width: double.infinity,
    height: double.infinity,
    errorBuilder: (_, __, ___) => _imgError(),
  );
}

/// تصویر یک اثر خودت
Widget myPostImage(UserPost p, {BoxFit fit = BoxFit.cover}) {
  final Uint8List? b = PostImages.of(p.id);
  if (b != null) {
    return Image.memory(
      b,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
    );
  }
  return Image.network(
    'https://picsum.photos/seed/my_work_${p.imageSeed}/600/600',
    fit: fit,
    width: double.infinity,
    height: double.infinity,
    errorBuilder: (_, __, ___) => _imgError(),
  );
}

/// لیست آرشیو استوری: استوری‌های واقعی خودت + چند استوری نمونه‌ی قدیمی
List<ArchiveItem> buildStoryArchive() {
  final List<ArchiveItem> out = <ArchiveItem>[];
  for (final UserPost p in PostStore.I.posts) {
    if (p.type != 'story') continue;
    out.add(
      ArchiveItem(
        src: 'post:${p.id}',
        label: 'امروز ${p.time}',
        isPost: true,
        closeFriends: SocialStore.I.metaOf(p.id).closeFriends,
      ),
    );
  }
  for (int i = 0; i < 12; i++) {
    final String src = 'seed:old_story_$i';
    if (SocialStore.I.deletedArchive.contains(src)) continue;
    out.add(ArchiveItem(src: src, label: '${i + 2} روز پیش', isPost: false));
  }
  return out;
}

/// هایلایت‌های نمونه برای پروفایل بقیه‌ی هنرمندها
List<Highlight> sampleHighlights(String username) {
  final int s = username.hashCode.abs();
  const List<String> titles = [
    'کارگاه',
    'اجراها',
    'پشت‌صحنه',
    'مسابقه',
    'تمرین',
    'دوره',
  ];
  final int count = 2 + s % 3;
  return List<Highlight>.generate(count, (i) {
    final int n = 3 + (s + i) % 3;
    final List<String> items =
        List<String>.generate(n, (k) => 'seed:hl_${s % 997}_${i}_$k');
    return Highlight(
      id: 'sample_$i',
      title: titles[(s + i) % titles.length],
      cover: items.first,
      items: items,
    );
  });
}

/// همه‌ی نام‌کاربری‌هایی که می‌شه تگ کرد / به دوستان نزدیک اضافه کرد
List<String> knownUsernames() {
  final Set<String> s = <String>{};
  for (final TalentUser u in allTalentUsers) {
    s.add(u.username);
  }
  s.addAll(AppState.I._followed);
  s.remove(kMyUsername);
  return s.toList();
}

final Set<String> kChampions = <String>{};
bool _isCompetitor(String n) =>
    RegExp(r'^استعداد_\d+_\d+$').hasMatch(n) || kChampions.contains(n);
int _compStars(String n) => _isCompetitor(n) ? 5 : 3;
int _compScore(String n) => _isCompetitor(n) ? 520000 : 300000;

void openUserByName(BuildContext context, String name) {
  if (name == kMyUsername) return;
  TalentUser? found;
  for (final TalentUser t in allTalentUsers) {
    if (t.username == name) found = t;
  }
  openUserProfile(
    context,
    found ??
        TalentUser(
            username: name,
            field: 'استعداد',
            stars: _compStars(name),
            score: _compScore(name)),
  );
}

/// پست‌های قابل نمایش در شبکه‌ی پروفایل (بدون استوری و بدون آرشیوشده‌ها)
List<UserPost> visibleGridPosts() {
  return PostStore.I.posts
      .where(
        (p) => p.type != 'story' && !SocialStore.I.metaOf(p.id).archived,
      )
      .toList();
}

Widget sheetHandle() => Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

Widget sheetTile(
  IconData icon,
  String label,
  VoidCallback onTap, {
  Color color = Colors.white,
}) {
  return ListTile(
    dense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    leading: Icon(icon, color: color, size: 22),
    title: Text(
      label,
      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
    ),
    onTap: onTap,
  );
}

Future<T?> showDarkSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF16161F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: builder,
  );
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class ProfileCubeImages extends ChangeNotifier {
  ProfileCubeImages._();
  static final ProfileCubeImages I = ProfileCubeImages._();

  final Map<String, Map<int, Uint8List>> _m = <String, Map<int, Uint8List>>{};
  SharedPreferences? _prefs;
  bool _listening = false;

  Uint8List? of(String username, int slot) => _m[username]?[slot];

  void set(String username, int slot, Uint8List bytes) {
    _m.putIfAbsent(username, () => <int, Uint8List>{})[slot] = bytes;
    notifyListeners();
  }

  Future<void> load() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      _prefs = p;
      final String? raw = p.getString('baravi_cube_images');
      if (raw != null) {
        final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
        m.forEach((user, slots) {
          final Map<String, dynamic> sm = slots as Map<String, dynamic>;
          final Map<int, Uint8List> um = <int, Uint8List>{};
          sm.forEach((k, v) => um[int.parse(k)] = base64Decode(v as String));
          _m[user] = um;
        });
      }
    } catch (_) {}
    if (!_listening) {
      _listening = true;
      addListener(_save);
    }
  }

  void _save() {
    final SharedPreferences? p = _prefs;
    if (p == null) return;
    try {
      final Map<String, dynamic> out = <String, dynamic>{};
      _m.forEach((user, slots) {
        final Map<String, dynamic> sm = <String, dynamic>{};
        slots.forEach((k, v) => sm['$k'] = base64Encode(v));
        out[user] = sm;
      });
      p.setString('baravi_cube_images', jsonEncode(out));
    } catch (_) {}
  }
}
