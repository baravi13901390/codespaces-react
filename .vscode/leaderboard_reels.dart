part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// ریلز واقعی با video_player
// - نگه‌داشتن سمت راست = ۲ برابر سرعت جلو
// - نگه‌داشتن سمت چپ = ۲ برابر سرعت عقب
// - دکمه‌ی پلی/پاز وسط پایین + پرش ۱۰ ثانیه جلو و عقب
// - تپ روی ویدیو = پلی/پاز | دابل‌تپ = لایک
// - فقط ریلزِ روی صفحه پخش می‌شود و وقتی از تب ریلز بیرون بروی متوقف می‌شود
// =====================================================================

/// شماره‌ی تب «ریلز» در نوار پایین (اگر تب‌ها را جابه‌جا کردی این عدد را عوض کن)
const int kReelsTabIndex = 4;

/// تب فعلی نوار پایین؛ MainNavigationShell مقدارش را به‌روز می‌کند
final ValueNotifier<int> kMainTabIndex = ValueNotifier<int>(0);

/// وضعیت صدای ریلز‌ها (پیش‌فرض بی‌صدا، چون مرورگر پخش خودکار با صدا را قبول نمی‌کند)
bool kReelsMuted = true;

class TalentLeaderboardScreen extends StatefulWidget {
  const TalentLeaderboardScreen({super.key});

  @override
  State<TalentLeaderboardScreen> createState() =>
      _TalentLeaderboardScreenState();
}

class _TalentLeaderboardScreenState extends State<TalentLeaderboardScreen> {
  String _cat = 'all';
  String _q = '';

  List<TalentUser> _ranked() {
    List<TalentUser> list;
    if (_cat == 'all') {
      list = List<TalentUser>.of(allTalentUsers);
    } else {
      list = allTalentUsers.where((u) {
        final Map<String, dynamic>? cat = talentCategories
            .cast<Map<String, dynamic>?>()
            .firstWhere((c) => c?['title'] == u.field, orElse: () => null);
        if (cat == null) return false;
        return CategoryStore.I.matches(cat['id'] as String, _cat);
      }).toList();
    }
    if (_q.trim().isNotEmpty) {
      list = list
          .where(
              (u) => u.username.toLowerCase().contains(_q.trim().toLowerCase()))
          .toList();
    }
    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  Widget _catBar() {
    return Column(
      children: [
        categoryChipsRow(
          selected: _cat,
          onSelected: (id) => setState(() => _cat = id),
        ),
        categorySubChipsRow(
          selected: _cat,
          onSelected: (id) => setState(() => _cat = id),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<TalentUser> ranked = _ranked();
    return Scaffold(
      appBar: AppBar(title: const Text('جدول رتبه بندی استعدادها')),
      body: Column(
        children: [
          _catBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              textDirection: TextDirection.rtl,
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                hintText: 'جستجوی نام کاربر...',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFF22222E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ranked.isEmpty
                ? const Center(
                    child: Text(
                      'کسی در این صنف نیست',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: ranked.length,
                    itemBuilder: (context, index) {
                      final TalentUser u = ranked[index];
                      final int rank = index + 1;
                      return Card(
                        color: const Color(0xFF16161F),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: rank == 1
                                ? const Color(0xFFFFB300)
                                : const Color(0xFF2A2A38),
                            width: rank == 1 ? 1.2 : 0.8,
                          ),
                        ),
                        child: ListTile(
                          onTap: null,
                          leading: SizedBox(
                            width: 46,
                            height: 46,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                InteractiveBaraviCube(
                                  size: 46,
                                  totalStories: 4,
                                  isProfileMode: true,
                                  seedKey: 'leaderboard_cube_${u.username}',
                                  rotationDuration: const Duration(seconds: 6),
                                ),
                                Positioned(
                                  right: -4,
                                  bottom: -4,
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor: rank == 1
                                        ? const Color(0xFFFFB300)
                                        : const Color(0xFF222230),
                                    foregroundColor:
                                        rank == 1 ? Colors.black : Colors.white,
                                    child: Text(
                                      '$rank',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Row(
                            children: [
                              Text.rich(
                                TextSpan(
                                    text: u.username,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap =
                                          () => openUserProfile(context, u)),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              tickBadges(u.username),
                              if (false)
                                const Icon(
                                  Icons.verified,
                                  color: Color(0xFF00E5FF),
                                  size: 14,
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                guildPathByTitle(u.field),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white70),
                              ),
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (s) => Icon(
                                      Icons.star,
                                      size: 11,
                                      color: s < u.stars
                                          ? const Color(0xFFFFB300)
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${u.score} امتیاز',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF00E5FF),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// صفحه‌ی ریلز: حالا می‌داند کدام ریلز روی صفحه است تا فقط همان پخش شود
// ---------------------------------------------------------------------
class TalentReelsScreen extends StatefulWidget {
  const TalentReelsScreen({super.key});

  @override
  State<TalentReelsScreen> createState() => _TalentReelsScreenState();
}

class _TalentReelsScreenState extends State<TalentReelsScreen> {
  final PageController _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final int t = _page + delta;
    if (t < 0 || t > 3) return;
    _pc.animateToPage(
      t,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pc,
        scrollDirection: Axis.vertical,
        itemCount: 4,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (context, index) => ReelItem(
          key: ValueKey('reel_$index'),
          index: index,
          isActive: index == _page,
          followMainTab: true,
          onPrev: index > 0 ? () => _go(-1) : null,
          onNext: index < 3 ? () => _go(1) : null,
        ),
      ),
    );
  }
}

class ReelItem extends StatefulWidget {
  final int index;
  final bool showHeader;

  /// آیا این ریلز همان ریلزی است که الان روی صفحه است؟
  final bool isActive;

  /// اگر true باشد، فقط وقتی تب «ریلز» نوار پایین باز است پخش می‌شود
  final bool followMainTab;
  final FeedItem? item;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const ReelItem({
    super.key,
    required this.index,
    this.showHeader = true,
    this.isActive = true,
    this.followMainTab = false,
    this.item,
    this.onPrev,
    this.onNext,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> with TickerProviderStateMixin {
  static const List<String> _captions = [
    'لحظه‌ای از کارگاه: ساخت یه قطعه از صفر تا صد 🔧 #ساخت #صنعت',
    'اجرای آزاد امشب 🎸 #موسیقی #اجرا',
    'مدار جدید تست شد ⚡ جواب داد! #برق #الکترونیک',
    'پشت صحنه آخرین پروژه 🎬 #هنر #باراوی',
  ];
  static const List<String> _songs = [
    'صدای کارگاه — اصلی',
    'ملودی شب — استعداد_2',
    'بیت الکترونیک — DJ برق',
    'آرامش — باراوی',
  ];

  // ویدیوهای نمونه (تا وقتی آپلود ویدیوی واقعی اضافه شود)
  static const List<String> _videoUrls = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ];

  late final AnimationController _progress;
  late final AnimationController _heart;
  late final AnimationController _flash;
  late final List<PostComment> _comments = seedComments(100 + widget.index);

  VideoPlayerController? _video;
  bool _ready = false;
  bool _failed = false;

  bool _paused = false;
  bool _liked = false;
  bool _saved = false;

  // ۰ = هیچ، ۱ = جلو ۲×، -۱ = عقب ۲×
  int _holdSide = 0;
  Timer? _rewindTimer;
  Duration _rewindPos = Duration.zero;

  bool _controlsVisible = false;
  Timer? _hideTimer;

  String get _creator => widget.item?.user ?? 'creator_talent_${widget.index}';
  String get _itemId => widget.item?.id ?? 'reel_${widget.index}';
  String get _posterUrl =>
      widget.item?.image ??
      'https://picsum.photos/seed/talent_reel_${widget.index}/600/1000';
  String get _link => widget.item?.kind == 'photo'
      ? _posterUrl
      : _videoUrls[widget.index % _videoUrls.length];
  bool get _following => AppState.I.isFollowing(_creator);
  int get _likeCount => 8400 + widget.index * 1300 + (_liked ? 1 : 0);
  int get _commentCount =>
      _comments.fold<int>(0, (sum, c) => sum + 1 + c.replies.length);

  bool get _shouldRun =>
      widget.isActive &&
      (!widget.followMainTab || kMainTabIndex.value == kReelsTabIndex);

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _heart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _flash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    AppState.I.addListener(_onApp);
    kMainTabIndex.addListener(_onTab);
    _ensureVideo();
    _apply();
  }

  @override
  void didUpdateWidget(covariant ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _ensureVideo();
      } else {
        // از صفحه رفت بیرون: از اول شروع شود
        final VideoPlayerController? v = _video;
        if (v != null && _ready) v.seekTo(Duration.zero);
        _holdEnd();
        setState(() {
          _paused = false;
          _controlsVisible = false;
        });
      }
      _apply();
    }
  }

  @override
  void dispose() {
    kMainTabIndex.removeListener(_onTab);
    AppState.I.removeListener(_onApp);
    _rewindTimer?.cancel();
    _hideTimer?.cancel();
    _video?.dispose();
    _progress.dispose();
    _heart.dispose();
    _flash.dispose();
    super.dispose();
  }

  void _onApp() {
    if (mounted) setState(() {});
  }

  void _onTab() {
    if (!mounted) return;
    _ensureVideo();
    _apply();
  }

  // ---------------- ویدیو ----------------
  void _ensureVideo() {
    if (_video != null ||
        _failed ||
        !_shouldRun ||
        widget.item?.kind == 'photo') return;
    _initVideo();
  }

  Future<void> _initVideo() async {
    final VideoPlayerController c = VideoPlayerController.networkUrl(
      Uri.parse(_videoUrls[widget.index % _videoUrls.length]),
    );
    _video = c;
    try {
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(kReelsMuted ? 0.0 : 1.0);
      if (!mounted) return;
      setState(() => _ready = true);
      _apply();
    } catch (_) {
      if (!mounted) return;
      c.dispose();
      setState(() {
        _video = null;
        _ready = false;
        _failed = true;
      });
    }
  }

  /// وضعیت پخش را با شرایط فعلی هماهنگ می‌کند
  void _apply() {
    final bool run = _shouldRun && !_paused && _holdSide == 0;
    final VideoPlayerController? v = _video;
    if (v != null && _ready) {
      if (run) {
        v.play();
      } else {
        v.pause();
      }
    }
    if (run) {
      if (!_progress.isAnimating) _progress.repeat();
    } else {
      _progress.stop();
    }
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    _flash.forward(from: 0);
    _apply();
    _pokeControls();
  }

  void _pokeControls() {
    setState(() => _controlsVisible = true);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _skip(int seconds) {
    final VideoPlayerController? v = _video;
    if (v == null || !_ready) return;
    Duration target = v.value.position + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > v.value.duration) target = v.value.duration;
    v.seekTo(target);
    _pokeControls();
  }

  void _holdStart(bool right) {
    final VideoPlayerController? v = _video;
    if (v == null || !_ready) return;
    _rewindTimer?.cancel();
    setState(() => _holdSide = right ? 1 : -1);
    if (right) {
      v.setPlaybackSpeed(2.0);
      v.play();
    } else {
      v.pause();
      _rewindPos = v.value.position;
      _rewindTimer = Timer.periodic(
        const Duration(milliseconds: 120),
        (_) => _rewindTick(),
      );
    }
  }

  // ویدیو مستقیم عقب پخش نمی‌شود؛ پس هر ۱۲۰ میلی‌ثانیه ۲۴۰ میلی‌ثانیه برمی‌گردیم عقب (= ۲×)
  void _rewindTick() {
    final VideoPlayerController? v = _video;
    if (v == null || !mounted) return;
    _rewindPos -= const Duration(milliseconds: 240);
    if (_rewindPos <= Duration.zero) {
      _rewindPos = Duration.zero;
      _rewindTimer?.cancel();
    }
    v.seekTo(_rewindPos);
  }

  void _holdEnd() {
    if (_holdSide == 0) return;
    _rewindTimer?.cancel();
    if (mounted) setState(() => _holdSide = 0);
    final VideoPlayerController? v = _video;
    if (v != null && _ready) v.setPlaybackSpeed(1.0);
    _apply();
  }

  void _toggleMute() {
    setState(() => kReelsMuted = !kReelsMuted);
    _video?.setVolume(kReelsMuted ? 0.0 : 1.0);
  }

  // ---------------- سایر کارها ----------------
  void _likeDouble() {
    if (!_liked) setState(() => _liked = true);
    _heart.forward(from: 0);
  }

  void _openComments() {
    showCommentsSheet(
      context,
      _comments,
      onChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          username: _creator,
          talentField: 'هنر و خلاقیت دیجیتال',
          starsCount: 5,
          totalScore: 490000,
          isVerified: true,
        ),
      ),
    );
  }

  Widget _side(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color color = Colors.white,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: color,
            shadows: const [Shadow(blurRadius: 8, color: Colors.black54)],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoLayer() {
    final VideoPlayerController? v = _video;
    if (v == null || !_ready) return const SizedBox.shrink();
    final Size s = v.value.size;
    if (s.width == 0 || s.height == 0) return const SizedBox.shrink();
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: s.width,
          height: s.height,
          child: VideoPlayer(v),
        ),
      ),
    );
  }

  Widget _ctrlBtn(IconData icon, VoidCallback onTap, {double size = 30}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  /// دکمه‌های وسط پایین: ۱۰ ثانیه عقب | پلی/پاز | ۱۰ ثانیه جلو
  Widget _controls() {
    final bool show = (_controlsVisible || _paused) && _holdSide == 0;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 200,
      child: IgnorePointer(
        ignoring: !show,
        child: AnimatedOpacity(
          opacity: show ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ctrlBtn(Icons.replay_10_rounded, () => _skip(-10)),
              const SizedBox(width: 22),
              _ctrlBtn(
                _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                _togglePause,
                size: 42,
              ),
              const SizedBox(width: 22),
              _ctrlBtn(Icons.forward_10_rounded, () => _skip(10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barBtn(IconData icon, VoidCallback? onTap, {double size = 26}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: onTap == null ? Colors.white30 : Colors.white,
          size: size,
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _barBtn(Icons.skip_previous_rounded, widget.onPrev),
          const SizedBox(width: 14),
          _barBtn(Icons.replay_10_rounded, () => _skip(-10)),
          const SizedBox(width: 14),
          _barBtn(
            _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            _togglePause,
            size: 34,
          ),
          const SizedBox(width: 14),
          _barBtn(Icons.forward_10_rounded, () => _skip(10)),
          const SizedBox(width: 14),
          _barBtn(Icons.skip_next_rounded, widget.onNext),
        ],
      ),
    );
  }

  Widget _holdBadge() {
    return Positioned(
      top: 90,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _holdSide > 0
                      ? Icons.fast_forward_rounded
                      : Icons.fast_rewind_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 6),
                const Text(
                  '۲×',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _progressBar() {
    final VideoPlayerController? v = _video;
    if (v != null && _ready) {
      return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: v,
        builder: (context, val, _) {
          final int total = val.duration.inMilliseconds;
          final double f = total <= 0
              ? 0.0
              : (val.position.inMilliseconds / total)
                  .clamp(0.0, 1.0)
                  .toDouble();
          return LinearProgressIndicator(
            value: f,
            minHeight: 2.5,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          );
        },
      );
    }
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => LinearProgressIndicator(
        value: _progress.value,
        minHeight: 2.5,
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int index = widget.index;
    return Stack(
      fit: StackFit.expand,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _togglePause,
              onDoubleTap: _likeDouble,
              onLongPressStart: (d) =>
                  _holdStart(d.localPosition.dx > box.maxWidth / 2),
              onLongPressEnd: (_) => _holdEnd(),
              onLongPressCancel: _holdEnd,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // عکس پوستر (تا وقتی ویدیو آماده شود یا اگر ویدیو باز نشد)
                  Image.network(
                    _posterUrl,
                    fit: BoxFit.cover,
                  ),
                  _videoLayer(),
                  if (_video != null && !_ready && !_failed)
                    const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        IgnorePointer(
          child: Center(
            child: AnimatedBuilder(
              animation: _flash,
              builder: (context, _) {
                if (_flash.isDismissed) return const SizedBox.shrink();
                return Opacity(
                  opacity: (1.0 - _flash.value).clamp(0.0, 1.0).toDouble(),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _paused ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        IgnorePointer(
          child: Center(
            child: AnimatedBuilder(
              animation: _heart,
              builder: (context, _) {
                final double t = _heart.value;
                if (_heart.isDismissed || t >= 1.0) {
                  return const SizedBox.shrink();
                }
                final double scale =
                    t < 0.3 ? Curves.easeOutBack.transform(t / 0.3) : 1.0;
                final double opacity = t < 0.7 ? 1.0 : 1.0 - ((t - 0.7) / 0.3);
                return Opacity(
                  opacity: opacity.clamp(0.0, 1.0).toDouble(),
                  child: Transform.scale(
                    scale: scale,
                    child: const Icon(
                      Icons.favorite,
                      size: 110,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 24, color: Colors.black54)],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.showHeader)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    const Text(
                      'ریلز',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const ComposeV3(initialType: 'reel'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_holdSide != 0) _holdBadge(),
        if (widget.item?.kind != 'photo') _bottomBar(),
        Positioned(
          right: 10,
          bottom: 84,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _side(
                kReelsMuted
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                kReelsMuted ? 'بی‌صدا' : 'صدا',
                _toggleMute,
              ),
              const SizedBox(height: 18),
              _side(
                _liked ? Icons.favorite : Icons.favorite_border,
                compactCount(_likeCount),
                () => setState(() => _liked = !_liked),
                color: _liked ? const Color(0xFFFF0055) : Colors.white,
              ),
              const SizedBox(height: 18),
              _side(
                Icons.chat_bubble_outline,
                compactCount(_commentCount),
                _openComments,
              ),
              const SizedBox(height: 18),
              _side(
                Icons.share_outlined,
                'اشتراک',
                () => showShareSheet(
                  context,
                  link: _link,
                  item:
                      SavedItem(id: _itemId, url: _posterUrl, title: _creator),
                  onSaved: () => setState(() => _saved = true),
                ),
              ),
              const SizedBox(height: 18),
              _side(
                _saved ? Icons.bookmark : Icons.bookmark_border,
                'ذخیره',
                () {
                  setState(() => _saved = !_saved);
                  feedSaveHook(context, _itemId, _posterUrl, _creator, _saved);
                },
                color: _saved ? const Color(0xFFFFB300) : Colors.white,
              ),
              const SizedBox(height: 18),
              RotationTransition(
                turns: _progress,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E1E28),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 76,
          left: 16,
          right: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _openProfile,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InteractiveBaraviCube(
                          size: 32,
                          totalStories: 4,
                          isProfileMode: true,
                          seedKey: 'reel_user_$index',
                          rotationDuration: const Duration(seconds: 5),
                        ),
                        const SizedBox(width: 8),
                        Text.rich(
                          TextSpan(children: <InlineSpan>[
                            TextSpan(text: '@$_creator '),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: tickBadges(_creator)),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: starsRow(_creator, size: 9)),
                          ]),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => AppState.I.toggleFollow(_creator),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _following ? Colors.white24 : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        _following ? 'دنبال می‌کنید' : 'دنبال کردن',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  children: richTextSpans(_captions[index % _captions.length]),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.music_note, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _songs[index % _songs.length],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'نمایش زنده توانمندی و هنرآفرینی در بستر باراوی 🚀 به این اثر از ۱ تا ۱۰۰ نمره دهید!',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _progressBar(),
        ),
      ],
    );
  }
}
