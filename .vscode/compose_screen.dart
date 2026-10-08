part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// ثبت اثر جدید (جایگزین ComposeV2 و ComposeScreen)
// - انتخاب عکس از گالری، کپشن، صنف
// - تگ کردن آدم‌ها (روی عکس بزن، آدم رو انتخاب کن)
// - مخاطب استوری: همه / دوستان نزدیک
// - خاموش کردن نظرات و مخفی کردن تعداد پسند
// =====================================================================
class ComposeV3 extends StatefulWidget {
  final String initialType;
  final String? initialUrl;
  final String? initialCaption;
  const ComposeV3({
    super.key,
    this.initialType = 'post',
    this.initialUrl,
    this.initialCaption,
  });

  @override
  State<ComposeV3> createState() => _ComposeV3State();
}

class _ComposeV3State extends State<ComposeV3> {
  late String _type = widget.initialType;
  late String? _srcUrl = widget.initialUrl;

  @override
  void initState() {
    super.initState();
    _loadSrc();
  }

  Future<void> _loadSrc() async {
    final String? u = widget.initialUrl;
    if (u == null) return;
    try {
      final ByteData d = await NetworkAssetBundle(Uri.parse(u)).load(u);
      if (mounted && _srcUrl == u) {
        setState(() => _bytes = d.buffer.asUint8List());
      }
    } catch (_) {}
  }

  String _category = CategoryStore.I.topLevel.isEmpty
      ? 'all'
      : CategoryStore.I.topLevel.first['id'] as String;
  int _seed = 0;
  Uint8List? _bytes;
  XFile? _videoFile; // فایل ویدیوی انتخاب‌شده برای ریلز
  List<TagEntry> _tags = <TagEntry>[];
  bool _closeOnly = false;
  bool _commentsOff = false;
  bool _hideLikes = false;
  late final TextEditingController _caption =
      TextEditingController(text: widget.initialCaption ?? '');

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  String _url(int s) => 'https://picsum.photos/seed/my_work_$s/600/600';

  Widget _imageWidget() {
    final XFile? v = _videoFile;
    if (_type == 'reel' && v != null) {
      // ویدیو با پلیر واقعی نمایش داده می‌شود، نه به‌عنوان عکس
      return PickedVideoPreview(key: ValueKey(v.path), file: v);
    }
    final Uint8List? b = _bytes;
    if (b != null) {
      return Image.memory(
        b,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Image.network(
      _srcUrl ?? _url(_seed),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1E1E28)),
    );
  }

  /// برای ریلز، ویدیو انتخاب می‌شود؛ برای پست/استوری، عکس
  Future<void> _pick() async {
    if (_type == 'reel') {
      _pickVideo();
      return;
    }
    try {
      final XFile? f = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        imageQuality: 80,
      );
      if (f == null) return;
      final Uint8List b = await f.readAsBytes();
      if (mounted) setState(() => _bytes = b);
    } catch (_) {
      if (!mounted) return;
      showSnack(context, 'انتخاب عکس ممکن نشد');
    }
  }

  Future<void> _pickVideo() async {
    final XFile? f = await pickVideoFromDevice();
    if (f == null || !mounted) return;
    setState(() => _videoFile = f);
  }

  Future<void> _tagPeople() async {
    final List<TagEntry>? r = await Navigator.of(context).push<List<TagEntry>>(
      MaterialPageRoute<List<TagEntry>>(
        builder: (_) => TagPeopleScreen(image: _imageWidget(), initial: _tags),
      ),
    );
    if (r != null && mounted) setState(() => _tags = r);
  }

  void _pickAudience(bool close) {
    if (close && SocialStore.I.closeFriends.isEmpty) {
      showSnack(context, 'اول چند نفر را به دوستان نزدیک اضافه کن');
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const CloseFriendsScreen()),
      );
      return;
    }
    setState(() => _closeOnly = close);
  }

  void _publish() {
    final UserPost p = PostStore.I.add(
      type: _type,
      category: _category,
      caption: _caption.text.trim(),
      imageSeed: _seed,
    );
    if (_bytes != null) {
      PostImages.put(p.id, _bytes!);
      PostStore.I.touch();
    }
    SocialStore.I.setMeta(
      p.id,
      PostMeta(
        tags: List<TagEntry>.of(_tags),
        closeFriends: _type == 'story' && _closeOnly,
        commentsOff: _commentsOff,
        hideLikes: _hideLikes,
      ),
    );
    final String extra = _type == 'story'
        ? ' (در آرشیو هم ذخیره شد)'
        : ' (در فید اصلی هم نمایش داده می‌شود)';
    showSnack(context, '${typeTitle(_type)} شما منتشر شد 🚀$extra');
    final NavigatorState nav = Navigator.of(context);
    final Route<void> route =
        MaterialPageRoute<void>(builder: (_) => const MyWorksScreen());
    if (nav.canPop()) {
      nav.pushReplacement(route);
    } else {
      _caption.clear();
      setState(() {
        _bytes = null;
        _tags = <TagEntry>[];
        _closeOnly = false;
        _commentsOff = false;
        _hideLikes = false;
      });
      nav.push(route);
    }
  }

  Widget _preview() {
    final bool tall = _type != 'post';
    return Center(
      child: SizedBox(
        height: 300,
        child: AspectRatio(
          aspectRatio: tall ? 9 / 14 : 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _imageWidget(),
                if (_type == 'reel' && _videoFile == null)
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white70,
                      size: 54,
                    ),
                  ),
                if (_tags.isNotEmpty)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${_tags.length} تگ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gallery() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 11,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          if (i == 0) {
            return GestureDetector(
              onTap: _pick,
              child: Container(
                width: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF16161F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E5FF)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _type == 'reel'
                          ? Icons.video_call_outlined
                          : Icons.add_photo_alternate_outlined,
                      color: const Color(0xFF00E5FF),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _type == 'reel' ? 'ویدیو' : 'گالری',
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF00E5FF)),
                    ),
                  ],
                ),
              ),
            );
          }
          if (_type == 'reel') {
            // برای ریلز، نمونه‌های عکس بی‌معنی هستند
            return const SizedBox.shrink();
          }
          final int k = i - 1;
          final bool sel = _bytes == null && k == _seed;
          return GestureDetector(
            onTap: () => setState(() {
              _seed = k;
              _srcUrl = null;
              _bytes = null;
              _videoFile = null;
            }),
            child: Container(
              width: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: sel ? const Color(0xFF00E5FF) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  _url(k),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF1E1E28)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _categoryChips() {
    return Column(children: [
      categoryChipsRow(
        selected: _category,
        includeAllOption: false,
        onSelected: (id) => setState(() => _category = id),
      ),
      categorySubChipsRow(
        selected: _category,
        onSelected: (id) => setState(() => _category = id),
      ),
    ]);
  }

  Widget _audience() {
    final int n = SocialStore.I.closeFriends.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مخاطب استوری',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              avatar: const Icon(Icons.public, size: 16),
              label: const Text('همه'),
              selected: !_closeOnly,
              onSelected: (_) => _pickAudience(false),
            ),
            ChoiceChip(
              avatar: const Icon(
                Icons.star,
                size: 16,
                color: Color(0xFF00C853),
              ),
              label: Text('دوستان نزدیک ($n)'),
              selected: _closeOnly,
              onSelected: (_) => _pickAudience(true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _switchRow(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 13))),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _typeBar() {
    const List<String> types = ['reel', 'post', 'story'];
    return Container(
      color: const Color(0xFF14141A),
      child: SafeArea(
        top: false,
        child: Row(
          children: types.map((t) {
            final bool sel = _type == t;
            return Expanded(
              child: InkWell(
                onTap: () => setState(() {
                  _type = t;
                  if (t != 'reel') _videoFile = null;
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        typeIcon(t),
                        size: 22,
                        color: sel ? const Color(0xFF00E5FF) : Colors.grey,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        typeTitle(t),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          color: sel ? const Color(0xFF00E5FF) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${typeTitle(_type)} جدید'),
        actions: [
          TextButton(
            onPressed: _publish,
            child: const Text(
              'اشتراک‌گذاری',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _preview(),
                const SizedBox(height: 12),
                Text(
                  _type == 'reel'
                      ? 'اولین کادر = انتخاب ویدیو از دستگاه'
                      : 'گالری (اولین کادر = انتخاب عکس از دستگاه)',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                _gallery(),
                const SizedBox(height: 16),
                TextField(
                  controller: _caption,
                  textDirection: TextDirection.rtl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'کپشن بنویسید... (#هشتگ و @منشن هم بزنید)',
                    hintStyle:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF16161F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'صنف استعدادیابی',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                _categoryChips(),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.person_add_alt_1_outlined,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'تگ کردن آدم‌ها',
                    style: TextStyle(fontSize: 13),
                  ),
                  subtitle: _tags.isEmpty
                      ? null
                      : Text(
                          _tags.map((t) => t.user).join('، '),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                  trailing: const Icon(Icons.chevron_left, color: Colors.grey),
                  onTap: _tagPeople,
                ),
                if (_type == 'story') ...[
                  const SizedBox(height: 6),
                  _audience(),
                  const SizedBox(height: 10),
                ],
                _switchRow(
                  Icons.comments_disabled_outlined,
                  'خاموش کردن نظرات',
                  _commentsOff,
                  (v) => setState(() => _commentsOff = v),
                ),
                _switchRow(
                  Icons.favorite_border,
                  'مخفی کردن تعداد پسند',
                  _hideLikes,
                  (v) => setState(() => _hideLikes = v),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _typeBar(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// صفحه‌ی تگ کردن: روی عکس بزن → آدم رو انتخاب کن → تگ ثبت می‌شه
// روی هر تگ بزنی، حذف می‌شه
// ---------------------------------------------------------------------
class TagPeopleScreen extends StatefulWidget {
  final Widget image;
  final List<TagEntry> initial;
  const TagPeopleScreen(
      {super.key, required this.image, required this.initial});

  @override
  State<TagPeopleScreen> createState() => _TagPeopleScreenState();
}

class _TagPeopleScreenState extends State<TagPeopleScreen> {
  late final List<TagEntry> _tags = List<TagEntry>.of(widget.initial);

  Future<void> _pickUser(double x, double y) async {
    final String? u = await showDarkSheet<String>(
      context,
      (_) => const _UserPickerSheet(),
    );
    if (u == null || !mounted) return;
    setState(() {
      _tags.removeWhere((t) => t.user == u);
      _tags.add(
        TagEntry(
          u,
          x.clamp(0.05, 0.95).toDouble(),
          y.clamp(0.05, 0.95).toDouble(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تگ کردن آدم‌ها'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_tags),
            child: const Text(
              'تأیید',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, c) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) => _pickUser(
                    d.localPosition.dx / c.maxWidth,
                    d.localPosition.dy / c.maxHeight,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.image,
                      for (final TagEntry t in _tags)
                        Positioned(
                          left: (t.x * c.maxWidth - 45)
                              .clamp(2.0, c.maxWidth - 110)
                              .toDouble(),
                          top: (t.y * c.maxHeight - 14)
                              .clamp(2.0, c.maxHeight - 34)
                              .toDouble(),
                          child: GestureDetector(
                            onTap: () => setState(() => _tags.remove(t)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white54),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    t.user,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              _tags.isEmpty
                  ? 'روی عکس بزن تا کسی را تگ کنی 👆'
                  : '${_tags.length} نفر تگ شده‌اند. برای حذف روی برچسب بزن.',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserPickerSheet extends StatefulWidget {
  const _UserPickerSheet();

  @override
  State<_UserPickerSheet> createState() => _UserPickerSheetState();
}

class _UserPickerSheetState extends State<_UserPickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final List<String> all = knownUsernames();
    final List<String> shown = all
        .where((u) => _q.isEmpty || u.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 8),
      child: SizedBox(
        height: 420,
        child: Column(
          children: [
            sheetHandle(),
            TextField(
              autofocus: false,
              textDirection: TextDirection.rtl,
              onChanged: (v) => setState(() => _q = v.trim()),
              decoration: InputDecoration(
                hintText: 'جستجوی نام کاربری...',
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFF1E1E28),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: shown.isEmpty
                  ? const Center(
                      child: Text(
                        'کسی پیدا نشد',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: shown.length,
                      itemBuilder: (context, i) {
                        final String u = shown[i];
                        return ListTile(
                          onTap: () => Navigator.pop(context, u),
                          leading: CubeAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF1E1E28),
                            backgroundImage: NetworkImage(avatarUrl(u)),
                            onBackgroundImageError: (_, __) {},
                          ),
                          title: Text(
                            u,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
