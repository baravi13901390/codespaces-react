part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// هایلایت‌های پروفایل (دایره‌های ثابت زیر بیو)
// - ساخت هایلایت از آرشیو استوری، انتخاب کاور و نام
// - نمایش تمام‌صفحه با نوار پیشرفت، توقف با نگه داشتن، رد شدن با تپ
// - نگه داشتن روی هایلایت خودت = ویرایش / حذف
// =====================================================================
String _coverOf(Highlight h) {
  if (srcAlive(h.cover)) return h.cover;
  return h.items.firstWhere(srcAlive, orElse: () => h.cover);
}

class ProfileHighlights extends StatelessWidget {
  final String username;
  final bool isOwn;
  const ProfileHighlights({
    super.key,
    required this.username,
    required this.isOwn,
  });

  void _open(BuildContext context, Highlight h) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            HighlightViewerScreen(highlight: h, owner: username, isOwn: isOwn),
      ),
    );
  }

  void _manage(BuildContext context, Highlight h) {
    showDarkSheet<void>(
      context,
      (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              sheetHandle(),
              sheetTile(Icons.edit_outlined, 'ویرایش هایلایت', () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => NewHighlightScreen(editing: h),
                  ),
                );
              }),
              sheetTile(
                Icons.delete_outline,
                'حذف هایلایت',
                () {
                  Navigator.pop(ctx);
                  SocialStore.I.deleteHighlight(h);
                  showSnack(context, 'هایلایت حذف شد');
                },
                color: const Color(0xFFFF5252),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle({
    required Widget child,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool ring = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          width: 68,
          child: Column(
            children: [
              Container(
                width: 62,
                height: 62,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ring
                        ? const Color(0xFF00E5FF)
                        : const Color(0xFF3A3A4A),
                    width: 1.6,
                  ),
                ),
                child: ClipOval(child: child),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconFill(IconData icon) {
    return Container(
      color: const Color(0xFF1E1E28),
      child: Center(
        child: Icon(icon, color: const Color(0xFF00E5FF), size: 26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[SocialStore.I, PostStore.I]),
      builder: (context, _) {
        final List<Highlight> source =
            isOwn ? SocialStore.I.highlights : sampleHighlights(username);
        final List<Highlight> list =
            source.where((h) => h.items.any(srcAlive)).toList();
        if (!isOwn && list.isEmpty) return const SizedBox(height: 4);
        final int extra = isOwn ? 2 : 0;
        return SizedBox(
          height: 108,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: 12),
            itemCount: list.length + extra,
            itemBuilder: (context, i) {
              if (isOwn && i == 0) {
                return _circle(
                  child: _iconFill(Icons.add),
                  label: 'جدید',
                  ring: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const NewHighlightScreen(),
                    ),
                  ),
                );
              }
              if (isOwn && i == 1) {
                return _circle(
                  child: _iconFill(Icons.history),
                  label: 'آرشیو',
                  ring: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const StoryArchiveScreen(),
                    ),
                  ),
                );
              }
              final Highlight h = list[i - extra];
              return _circle(
                child: hlImage(_coverOf(h), w: 200, h: 300),
                label: h.title,
                onTap: () => _open(context, h),
                onLongPress: isOwn ? () => _manage(context, h) : null,
              );
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
// نمایش تمام‌صفحه‌ی هایلایت (و همین‌طور آرشیو)
// ---------------------------------------------------------------------
class HighlightViewerScreen extends StatefulWidget {
  final Highlight highlight;
  final String owner;
  final bool isOwn;
  final int startAt;
  const HighlightViewerScreen({
    super.key,
    required this.highlight,
    required this.owner,
    required this.isOwn,
    this.startAt = 0,
  });

  @override
  State<HighlightViewerScreen> createState() => _HighlightViewerScreenState();
}

class _HighlightViewerScreenState extends State<HighlightViewerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late int _i;
  bool _hold = false;

  List<String> get _items => widget.highlight.items.where(srcAlive).toList();

  @override
  void initState() {
    super.initState();
    _i = widget.startAt;
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _next();
      });
    if (_items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    } else {
      if (_i >= _items.length) _i = 0;
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _next() {
    if (!mounted) return;
    if (_i < _items.length - 1) {
      setState(() => _i++);
      _c.forward(from: 0);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _prev() {
    if (_i > 0) setState(() => _i--);
    _c.forward(from: 0);
  }

  void _setHold(bool v) {
    if (_hold == v) return;
    setState(() => _hold = v);
    if (v) {
      _c.stop();
    } else {
      _c.forward();
    }
  }

  void _removeCurrent() {
    final List<String> items = _items;
    if (items.isEmpty) return;
    final String src = items[_i];
    SocialStore.I.removeFromHighlight(widget.highlight, src);
    final List<String> left = _items;
    if (left.isEmpty) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      if (_i >= left.length) _i = left.length - 1;
    });
    _c.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> items = _items;
    if (items.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black);
    }
    final String src = items[_i.clamp(0, items.length - 1).toInt()];
    final bool cf = src.startsWith('post:') &&
        SocialStore.I.metaOf(src.substring(5)).closeFriends;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) {
              if (d.globalPosition.dx < width * 0.33) {
                _prev();
              } else {
                _next();
              }
            },
            onLongPressStart: (_) => _setHold(true),
            onLongPressEnd: (_) => _setHold(false),
            onVerticalDragEnd: (d) {
              if ((d.primaryVelocity ?? 0) > 400) {
                Navigator.of(context).maybePop();
              }
            },
            child: hlImage(src, key: ValueKey<String>(src)),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black54,
                    ],
                    stops: [0.0, 0.18, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _hold ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: AnimatedBuilder(
                        animation: _c,
                        builder: (context, _) {
                          return Row(
                            children: List<Widget>.generate(items.length, (i) {
                              final double v =
                                  i < _i ? 1.0 : (i == _i ? _c.value : 0.0);
                              return Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: v,
                                      minHeight: 2.5,
                                      backgroundColor: Colors.white30,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          CubeAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF1E1E28),
                            backgroundImage:
                                NetworkImage(avatarUrl(widget.owner)),
                            onBackgroundImageError: (_, __) {},
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.highlight.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  widget.owner,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (cf)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C853),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'دوستان نزدیک',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (widget.isOwn)
                            PopupMenuButton<String>(
                              color: const Color(0xFF262630),
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onSelected: (v) {
                                if (v == 'rm') _removeCurrent();
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem<String>(
                                  value: 'rm',
                                  child: Text('حذف از هایلایت'),
                                ),
                              ],
                            ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// ساخت / ویرایش هایلایت: مرحله ۱ انتخاب استوری‌ها، مرحله ۲ نام و کاور
// ---------------------------------------------------------------------
class NewHighlightScreen extends StatefulWidget {
  final Highlight? editing;
  final String? preselect;
  const NewHighlightScreen({super.key, this.editing, this.preselect});

  @override
  State<NewHighlightScreen> createState() => _NewHighlightScreenState();
}

class _NewHighlightScreenState extends State<NewHighlightScreen> {
  final Set<String> _sel = <String>{};
  int _step = 0;
  String? _cover;
  late final TextEditingController _title;

  @override
  void initState() {
    super.initState();
    final Highlight? h = widget.editing;
    _title = TextEditingController(text: h?.title ?? '');
    if (h != null) {
      _sel.addAll(h.items.where(srcAlive));
      _cover = h.cover;
    }
    final String? pre = widget.preselect;
    if (pre != null) _sel.add(pre);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  List<String> _ordered() {
    final List<String> arch = buildStoryArchive().map((e) => e.src).toList();
    final List<String> out = <String>[];
    for (final String s in arch) {
      if (_sel.contains(s)) out.add(s);
    }
    for (final String s in _sel) {
      if (!arch.contains(s)) out.add(s);
    }
    return out;
  }

  void _save() {
    final List<String> ordered = _ordered();
    if (ordered.isEmpty) return;
    final String t = _title.text.trim();
    final String title = t.isEmpty ? 'هایلایت' : t;
    String cover = _cover ?? ordered.first;
    if (!ordered.contains(cover)) cover = ordered.first;
    final Highlight? h = widget.editing;
    if (h == null) {
      SocialStore.I.createHighlight(title, cover, ordered);
    } else {
      SocialStore.I
          .editHighlight(h, title: title, cover: cover, items: ordered);
    }
    Navigator.of(context).pop();
  }

  Widget _pickStep() {
    final List<ArchiveItem> items = buildStoryArchive();
    return GridView.builder(
      padding: const EdgeInsets.all(3),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        childAspectRatio: 9 / 14,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final ArchiveItem it = items[i];
        final bool on = _sel.contains(it.src);
        return GestureDetector(
          onTap: () => setState(() {
            if (!_sel.remove(it.src)) _sel.add(it.src);
          }),
          child: Stack(
            fit: StackFit.expand,
            children: [
              hlImage(it.src, w: 300, h: 480),
              if (on) Container(color: const Color(0xFF00E5FF).withAlpha(50)),
              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  on ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: on ? const Color(0xFF00E5FF) : Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _nameStep() {
    final List<String> ordered = _ordered();
    final String cover =
        (_cover != null && ordered.contains(_cover)) ? _cover! : ordered.first;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00E5FF), width: 2),
            ),
            child: ClipOval(child: hlImage(cover, w: 300, h: 400)),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _title,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          maxLength: 16,
          decoration: InputDecoration(
            hintText: 'نام هایلایت',
            filled: true,
            fillColor: const Color(0xFF16161F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'کاور را انتخاب کن',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ordered.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final String s = ordered[i];
              final bool sel = s == cover;
              return GestureDetector(
                onTap: () => setState(() => _cover = s),
                child: Container(
                  width: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sel ? const Color(0xFF00E5FF) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: hlImage(s, w: 150, h: 220),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool first = _step == 0;
    final bool editing = widget.editing != null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (first) {
              Navigator.of(context).maybePop();
            } else {
              setState(() => _step = 0);
            }
          },
        ),
        title: Text(
          first
              ? 'انتخاب استوری‌ها'
              : (editing ? 'ویرایش هایلایت' : 'هایلایت جدید'),
        ),
        actions: [
          TextButton(
            onPressed: _sel.isEmpty
                ? null
                : () {
                    if (first) {
                      setState(() => _step = 1);
                    } else {
                      _save();
                    }
                  },
            child: Text(
              first ? 'بعدی' : (editing ? 'ذخیره' : 'افزودن'),
              style: TextStyle(
                color: _sel.isEmpty ? Colors.grey : const Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: first ? _pickStep() : _nameStep(),
    );
  }
}
