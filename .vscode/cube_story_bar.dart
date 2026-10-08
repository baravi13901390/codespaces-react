part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

const bool kFillStories = true;

String storyCubeSeed(String name) {
  if (name == kMyUsername) return 'profile_cube_$kMyUsername';
  for (final TalentUser u in allTalentUsers) {
    if (u.username == name) {
      final String? cid = catIdByTitle(u.field);
      if (cid != null) return 'guild_cube_$cid';
    }
  }
  return 'profile_cube_$name';
}

List<String> storyUsersFor(String category) {
  final List<String> out = _storyFollowed(category);
  if (kFillStories) {
    final List<TalentUser> pool = List<TalentUser>.of(allTalentUsers);
    pool.shuffle(math.Random(kFeedShift * 7919 + 13));
    for (final TalentUser u in pool) {
      if (out.length >= 8) break;
      if (out.contains(u.username)) continue;
      if (category != 'all' && category.isNotEmpty) {
        final String? cid = catIdByTitle(u.field);
        if (cid == null || !CategoryStore.I.matches(cid, category)) continue;
      }
      out.add(u.username);
    }
  }
  return out;
}

List<String> _storyUsersForOld(String category) {
  final List<String> out = _storyFollowed(category);
  if (kFillStories) {
    for (final TalentUser u in allTalentUsers) {
      if (out.length >= 8) break;
      if (out.contains(u.username)) continue;
      if (category != 'all' && category.isNotEmpty) {
        final String? cid = catIdByTitle(u.field);
        if (cid == null || !CategoryStore.I.matches(cid, category)) continue;
      }
      out.add(u.username);
    }
  }
  return out;
}

List<String> _storyFollowed(String category) {
  final List<String> out = <String>[kMyUsername];
  for (final String n in AppState.I._followed) {
    if (n == kMyUsername || n.startsWith('topic:') || n.startsWith('#')) {
      continue;
    }
    if (category == 'all' || category.isEmpty) {
      out.add(n);
    } else {
      String f = '';
      for (final TalentUser u in allTalentUsers) {
        if (u.username == n) f = u.field;
      }
      final String? cid = catIdByTitle(f);
      if (cid != null && CategoryStore.I.matches(cid, category)) out.add(n);
    }
  }
  return out;
}

String storyUserName(String category, int index) {
  final List<String> l = storyUsersFor(category);
  if (index < 0 || index >= l.length) return kMyUsername;
  return l[index];
}

String _storyUserNameOld(String category, int index) {
  if (index == 0) return kMyUsername;
  if (category == 'all' || category.isEmpty) return 'استعداد_$index';
  return 'استعداد_${100 + (category.hashCode.abs() % 800) * 8 + index}';
}

class CubeStorySection extends StatefulWidget {
  final String category;
  const CubeStorySection({super.key, this.category = 'all'});

  @override
  State<CubeStorySection> createState() => _CubeStorySectionState();
}

class _CubeStorySectionState extends State<CubeStorySection> {
  int? _activeStoryIndex;
  Timer? _autoCollapseTimer;

  void _setActiveStory(int? index) {
    _autoCollapseTimer?.cancel();
    setState(() => _activeStoryIndex = index);
    if (index != null) {
      _autoCollapseTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _activeStoryIndex = null);
      });
    }
  }

  void _onCubeInteraction(bool interacting) {
    _autoCollapseTimer?.cancel();
    if (!interacting && _activeStoryIndex != null) {
      _autoCollapseTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _activeStoryIndex = null);
      });
    }
  }

  @override
  void dispose() {
    _autoCollapseTimer?.cancel();
    super.dispose();
  }

  void _openStoryViewer(int index) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => StoryViewerScreen(
            initialUserIndex: index,
            userCount: storyUsersFor(widget.category).length,
            category: widget.category),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: storyUsersFor(widget.category).length,
        itemBuilder: (context, index) {
          final bool isCurrentZoomed = _activeStoryIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onLongPress: () => _openStoryViewer(index),
                  child: InteractiveBaraviCube(
                    size: 68,
                    totalStories: 4,
                    isProfileMode: false,
                    seedKey:
                        storyCubeSeed(storyUserName(widget.category, index)),
                    isZoomed: isCurrentZoomed,
                    rotationDuration: const Duration(seconds: 5),
                    onInteractionChanged:
                        isCurrentZoomed ? _onCubeInteraction : null,
                    onTap: () => _openStoryViewer(index),
                  ),
                ),
                const SizedBox(height: 4),
                starsRow(storyUserName(widget.category, index)),
                tickBadges(storyUserName(widget.category, index), size: 12),
                const SizedBox(height: 4),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => openUserByName(
                      context, storyUserName(widget.category, index)),
                  child: SizedBox(
                    width: 72,
                    child: Text(
                      storyUserName(widget.category, index),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isCurrentZoomed
                            ? const Color(0xFF00E5FF)
                            : Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class UserCube extends StatelessWidget {
  final String name;
  final double size;
  const UserCube({super.key, required this.name, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return InteractiveBaraviCube(
      size: size,
      totalStories: 4,
      isProfileMode: true,
      seedKey: 'profile_cube_$name',
      rotationDuration: const Duration(seconds: 6),
    );
  }
}

class CubeAvatar extends StatelessWidget {
  final double? radius;
  final ImageProvider? backgroundImage;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final ImageErrorListener? onBackgroundImageError;
  final Widget? child;
  const CubeAvatar({
    super.key,
    this.radius,
    this.backgroundImage,
    this.backgroundColor,
    this.foregroundColor,
    this.onBackgroundImageError,
    this.child,
  });

  String? _name() {
    final ImageProvider? b = backgroundImage;
    if (b is NetworkImage) {
      const String k = '/seed/av_';
      final int i = b.url.indexOf(k);
      if (i < 0) return null;
      String rest = b.url.substring(i + k.length);
      final int j = rest.indexOf('/');
      if (j >= 0) rest = rest.substring(0, j);
      return Uri.decodeComponent(rest);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String? n = _name();
    final double r = radius ?? 20;
    if (n == null) {
      return CircleAvatar.new(
        radius: radius,
        backgroundImage: backgroundImage,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        onBackgroundImageError: onBackgroundImageError,
        child: child,
      );
    }
    return SizedBox(
      width: r * 2,
      height: r * 2,
      child: Center(child: UserCube(name: n, size: r * 1.9)),
    );
  }
}

class InteractiveBaraviCube extends StatefulWidget {
  final double size;
  final int totalStories;
  final bool isProfileMode;
  final String seedKey;
  final bool? isZoomed;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onInteractionChanged;
  final Duration rotationDuration;

  const InteractiveBaraviCube({
    super.key,
    required this.size,
    this.totalStories = 4,
    this.isProfileMode = false,
    required this.seedKey,
    this.isZoomed,
    this.onTap,
    this.onInteractionChanged,
    this.rotationDuration = const Duration(seconds: 5),
  });

  @override
  State<InteractiveBaraviCube> createState() => _InteractiveBaraviCubeState();
}

class _InteractiveBaraviCubeState extends State<InteractiveBaraviCube>
    with TickerProviderStateMixin {
  late AnimationController _autoRotateController;
  late AnimationController _zoomController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _depthOffsetAnimation;

  double _manualAngle = 0.0;
  Timer? _resumeTimer;
  Timer? _autoUnzoomTimer;
  Timer? _tapWaitTimer;
  DateTime? _lastTapDownTime;
  bool _isInteracting = false;
  bool _internalZoomed = false;

  bool get _isCurrentlyZoomed => widget.isZoomed ?? _internalZoomed;

  @override
  void initState() {
    super.initState();
    final double totalSec = widget.rotationDuration.inMilliseconds / 1000.0;

    _autoRotateController =
        AnimationController(vsync: this, duration: widget.rotationDuration)
          ..addListener(() {
            if (!_isInteracting && !_isCurrentlyZoomed) {
              setState(() {
                _manualAngle += (2 * math.pi) / (totalSec * 60);
              });
            }
          });

    _autoRotateController.repeat();

    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    // با یک کلیک روی مکعبِ پروفایل، فقط یه‌کم جلو میاد (نه بزرگِ کامل)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.isProfileMode ? 1.18 : 2.0,
    ).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeOutBack),
    );

    _depthOffsetAnimation = Tween<double>(
      begin: 0.0,
      end: widget.isProfileMode ? 14.0 : 35.0,
    ).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeOutCubic),
    );

    if (widget.isZoomed == true) {
      _zoomController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(InteractiveBaraviCube oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isZoomed != null && widget.isZoomed != oldWidget.isZoomed) {
      _handleZoomStateChange(widget.isZoomed!);
    }
  }

  void _handleZoomStateChange(bool targetZoom) {
    _resumeTimer?.cancel();
    setState(() {
      _isInteracting = targetZoom;
    });

    if (targetZoom) {
      _zoomController.forward();
    } else {
      _zoomController.reverse().then((_) {
        _resumeTimer = Timer(const Duration(milliseconds: 3000), () {
          if (mounted && !_isCurrentlyZoomed) {
            setState(() => _isInteracting = false);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _autoRotateController.dispose();
    _zoomController.dispose();
    _resumeTimer?.cancel();
    _autoUnzoomTimer?.cancel();
    _tapWaitTimer?.cancel();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _resumeTimer?.cancel();
    setState(() => _isInteracting = true);
    widget.onInteractionChanged?.call(true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _manualAngle -= details.delta.dx * 0.016;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final double velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity.abs() > 150) {
      setState(() {
        _manualAngle -= (velocity * 0.0014);
      });
    }

    widget.onInteractionChanged?.call(false);
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted && !_isCurrentlyZoomed) {
        setState(() => _isInteracting = false);
      }
    });
  }

  // پیدا کردن وجهی که الان دقیقاً روبروی دوربینه
  int _currentFrontFaceIndex() {
    const double faceSpan = math.pi / 2;
    double best = -2;
    int bestFace = 1;
    for (int i = 0; i < 4; i++) {
      final double totalFaceAngle = _manualAngle + i * faceSpan;
      final double normalizedAngle = totalFaceAngle % (2 * math.pi);
      final double facingVector = math.cos(normalizedAngle);
      if (facingVector > best) {
        best = facingVector;
        bestFace = (i % 4) + 1;
      }
    }
    return bestFace;
  }

  // تشخیص دستیِ یک‌کلیک/دوکلیک با فرصت ۴۵۰ میلی‌ثانیه
  // (چون تشخیص پیش‌فرض فلاتر با موس گاهی خیلی سخت‌گیرانه‌ست)
  void _onTapDown(TapDownDetails details) {
    final DateTime now = DateTime.now();
    final bool isDouble = _lastTapDownTime != null &&
        now.difference(_lastTapDownTime!) < const Duration(milliseconds: 450);

    if (isDouble) {
      _tapWaitTimer?.cancel();
      _lastTapDownTime = null;
      _runDoubleTapAction();
    } else {
      _lastTapDownTime = now;
      _tapWaitTimer?.cancel();
      _tapWaitTimer = Timer(const Duration(milliseconds: 450), () {
        _lastTapDownTime = null;
        _runSingleTapAction();
      });
    }
  }

  void _runSingleTapAction() {
    if (!mounted) return;
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    if (!widget.isProfileMode) return;
    setState(() {
      _internalZoomed = !_internalZoomed;
    });
    _handleZoomStateChange(_internalZoomed);
    _autoUnzoomTimer?.cancel();
    if (_internalZoomed) {
      _autoUnzoomTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _internalZoomed) {
          setState(() => _internalZoomed = false);
          _handleZoomStateChange(false);
        }
      });
    }
  }

  void _runDoubleTapAction() {
    if (!mounted) return;
    if (widget.onTap != null) return;
    if (!widget.isProfileMode) return;
    _autoUnzoomTimer?.cancel();
    showFaceZoomOverlay(context, widget.seedKey, _currentFrontFaceIndex());
  }

  @override
  Widget build(BuildContext context) {
    final double half = widget.size / 2.0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _zoomController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: widget.size * 0.95,
                    height: widget.size * 0.95,
                    color: const Color(0xFF09090C),
                  ),
                  ..._generateFaces(half),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _generateFaces(double half) {
    const double faceSpan = math.pi / 2;
    final int baseCycle = (_manualAngle / (2 * math.pi)).floor();
    List<_FaceEntry> faceEntries = [];

    for (int i = 0; i < 4; i++) {
      final double faceAngleOffset = i * faceSpan;
      final double totalFaceAngle = _manualAngle + faceAngleOffset;

      final double normalizedAngle = totalFaceAngle % (2 * math.pi);
      final double facingVector = math.cos(normalizedAngle);

      if (facingVector <= -0.15) continue;

      int storyIndex;
      if (widget.isProfileMode) {
        storyIndex = (i % 4) + 1;
      } else {
        int calculated = (baseCycle * 4) + i + 1;
        storyIndex = ((calculated - 1) % widget.totalStories) + 1;
      }

      faceEntries.add(
        _FaceEntry(
          depth: facingVector,
          widget: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..translate(0.0, 0.0, _depthOffsetAnimation.value)
              ..rotateY(totalFaceAngle)
              ..translate(0.0, 0.0, half),
            alignment: Alignment.center,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F14),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isCurrentlyZoomed
                      ? const Color(0xFF00E5FF)
                      : const Color(0xFF2C2C38),
                  width: _isCurrentlyZoomed ? 1.5 : 0.8,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    cubeFaceImage(widget.seedKey, storyIndex),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(179),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$storyIndex',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    faceEntries.sort((a, b) => a.depth.compareTo(b.depth));
    return faceEntries.map((e) => e.widget).toList();
  }
}

class _FaceEntry {
  final double depth;
  final Widget widget;
  _FaceEntry({required this.depth, required this.widget});
}

Widget cubeFaceImage(
  String seedKey,
  int storyIndex, {
  BoxFit fit = BoxFit.cover,
}) {
  String? username;
  const String prefix = 'profile_cube_';
  if (seedKey.startsWith(prefix)) {
    username = seedKey.substring(prefix.length);
  }
  final Uint8List? custom =
      username != null ? ProfileCubeImages.I.of(username, storyIndex) : null;
  if (custom != null) {
    return Image.memory(custom, fit: fit);
  }
  return Image.network(
    'https://picsum.photos/seed/${seedKey}_$storyIndex/200',
    fit: fit,
    errorBuilder: (context, error, stackTrace) => Container(
      color: const Color(0xFF1E1E28),
      child: Center(
        child: Text(
          '$storyIndex',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}

// =====================================================================
// نمایش بزرگِ یک وجه از مکعب پروفایل، وسط صفحه (با دابل‌کلیک باز می‌شه).
// کل عکس معلومه (BoxFit.contain، نه بریده‌شده).
// کلیک‌نگه‌دار روی عکس + کشیدن به راست = زوم بیشتر، به چپ = زوم کمتر.
// تپ روی پس‌زمینه یا خود عکس = بسته می‌شه.
// =====================================================================
Future<void> showFaceZoomOverlay(
  BuildContext context,
  String seedKey,
  int storyIndex,
) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'بستن',
    barrierColor: Colors.black87,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, anim2) {
      return _FaceZoomView(seedKey: seedKey, storyIndex: storyIndex);
    },
    transitionBuilder: (ctx, anim, anim2, child) {
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: child,
        ),
      );
    },
  );
}

class _FaceZoomView extends StatefulWidget {
  final String seedKey;
  final int storyIndex;
  const _FaceZoomView({required this.seedKey, required this.storyIndex});

  @override
  State<_FaceZoomView> createState() => _FaceZoomViewState();
}

class _FaceZoomViewState extends State<_FaceZoomView> {
  double _zoom = 1.0;
  static const double _minZoom = 1.0;
  static const double _maxZoom = 2.6;

  void _onDrag(DragUpdateDetails d) {
    setState(() {
      // کشیدن به راست (delta.dx مثبت) = زوم بیشتر
      // کشیدن به چپ (delta.dx منفی) = زوم کمتر
      _zoom = (_zoom + d.delta.dx * 0.01).clamp(_minZoom, _maxZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            onPanUpdate: _onDrag,
            child: Container(
              width: screen.width * 0.9,
              height: screen.height * 0.55,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0B0F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00E5FF), width: 1.4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Transform.scale(
                  scale: _zoom,
                  child: cubeFaceImage(
                    widget.seedKey,
                    widget.storyIndex,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
