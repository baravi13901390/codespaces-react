part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// انتخاب عکس از گالری + ذخیره دائمی
// =====================================================================
class PostImages {
  static final Map<String, Uint8List> _m = <String, Uint8List>{};
  static Uint8List? of(String id) => _m[id];
  static void put(String id, Uint8List b) => _m[id] = b;
  static void remove(String id) => _m.remove(id);
}

class Persist {
  static SharedPreferences? _p;

  static Future<void> load() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      _p = p;
      final String? raw = p.getString('baravi_posts');
      int maxN = 0;
      if (raw != null) {
        final List<dynamic> l = jsonDecode(raw) as List<dynamic>;
        for (final dynamic e in l) {
          final Map<String, dynamic> m = e as Map<String, dynamic>;
          final UserPost post = UserPost(
            id: m['id'] as String,
            type: m['type'] as String,
            category: m['category'] as String,
            caption: m['caption'] as String,
            time: m['time'] as String,
            imageSeed: (m['seed'] as num).toInt(),
            likes: (m['likes'] as num).toInt(),
            liked: m['liked'] as bool,
            saved: m['saved'] as bool,
          );
          PostStore.I.posts.add(post);
          final String? img = m['img'] as String?;
          if (img != null) PostImages.put(post.id, base64Decode(img));
          final int n = int.tryParse(post.id.split('_').last) ?? 0;
          if (n > maxN) maxN = n;
        }
        PostStore.I._n = maxN;
      }
      final String? sc = p.getString('baravi_scores');
      if (sc != null) {
        final Map<String, dynamic> m = jsonDecode(sc) as Map<String, dynamic>;
        m.forEach((k, v) => JudgeState.I._scores[k] = (v as num).toInt());
      }
      final List<String>? fl = p.getStringList('baravi_follow');
      if (fl != null) AppState.I._followed.addAll(fl);
      final String? mf = p.getString('baravi_myfield');
      if (mf != null) AppState.I.myField = mf;
    } catch (_) {}
  }

  static void start() {
    PostStore.I.addListener(_save);
    JudgeState.I.addListener(_save);
    AppState.I.addListener(_save);
  }

  static void _save() {
    final SharedPreferences? p = _p;
    if (p == null) return;
    try {
      final List<Map<String, dynamic>> list = PostStore.I.posts.map((x) {
        final Uint8List? b = PostImages.of(x.id);
        return <String, dynamic>{
          'id': x.id,
          'type': x.type,
          'category': x.category,
          'caption': x.caption,
          'time': x.time,
          'seed': x.imageSeed,
          'likes': x.likes,
          'liked': x.liked,
          'saved': x.saved,
          'img': (b != null && b.length < 400000) ? base64Encode(b) : null,
        };
      }).toList();
      p.setString('baravi_posts', jsonEncode(list));
      p.setString('baravi_scores', jsonEncode(JudgeState.I._scores));
      p.setStringList('baravi_follow', AppState.I._followed.toList());
      p.setString('baravi_myfield', AppState.I.myField);
    } catch (_) {}
  }
}
