part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// استوری تمام‌صفحه (کد جدید)
// - نوار پیشرفت بالا، رد شدن خودکار بعد از ۵ ثانیه
// - تپ سمت راست = بعدی | تپ سمت چپ = قبلی
// - نگه داشتن انگشت = توقف (و مخفی شدن منو)
// - کشیدن به پایین = بستن | کشیدن چپ/راست = رفتن به هنرمند بعدی/قبلی
// - لایک، ارسال پاسخ به استوری، دکمه اشتراک
// =====================================================================
class StoryViewerScreen extends StatefulWidget {
  final int initialUserIndex;
  final int userCount;
  final String category;

  const StoryViewerScreen({
    super.key,
    required this.initialUserIndex,
    this.userCount = 8,
    this.category = 'all',
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late final PageController _pageController;
  late int _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.initialUserIndex;
    _pageController = PageController(initialPage: _currentUser);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNextUser() {
    if (_currentUser < widget.userCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _goPrevUser() {
    if (_currentUser > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.userCount,
        onPageChanged: (i) => setState(() => _currentUser = i),
        itemBuilder: (context, i) {
          return _UserStoriesPage(
            key: ValueKey('story_user_$i'),
            userIndex: i,
            category: widget.category,
            isActive: i == _currentUser,
            onNextUser: _goNextUser,
            onPrevUser: _goPrevUser,
            onClose: () => Navigator.of(context).maybePop(),
          );
        },
      ),
    );
  }
}

class _UserStoriesPage extends StatefulWidget {
  final int userIndex;
  final String category;
  final bool isActive;
  final VoidCallback onNextUser;
  final VoidCallback onPrevUser;
  final VoidCallback onClose;

  const _UserStoriesPage({
    super.key,
    required this.userIndex,
    this.category = 'all',
    required this.isActive,
    required this.onNextUser,
    required this.onPrevUser,
    required this.onClose,
  });

  @override
  State<_UserStoriesPage> createState() => _UserStoriesPageState();
}

class _UserStoriesPageState extends State<_UserStoriesPage>
    with SingleTickerProviderStateMixin {
  static const Duration _storyDuration = Duration(seconds: 5);

  late final AnimationController _progress;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocus = FocusNode();
  final Set<int> _likedStories = <int>{};

  int _storyIndex = 0;
  bool _holding = false;
  bool _hasText = false;

  int get _storyCount => 3 + (widget.userIndex % 3);
  bool get _isOwn => widget.userIndex == 0;
  String get _userName =>
      _isOwn ? kMyUsername : storyUserName(widget.category, widget.userIndex);
  String get _timeAgo => '${(widget.userIndex % 5) + 1} ساعت پیش';

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: _storyDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _goNext();
      });
    _replyFocus.addListener(_syncPlayback);
    _replyController.addListener(() {
      final bool has = _replyController.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    if (widget.isActive) _progress.forward();
  }

  @override
  void didUpdateWidget(_UserStoriesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) _syncPlayback();
  }

  @override
  void dispose() {
    _progress.dispose();
    _replyController.dispose();
    _replyFocus.dispose();
    super.dispose();
  }

  void _syncPlayback() {
    final bool shouldRun =
        widget.isActive && !_holding && !_replyFocus.hasFocus;
    if (shouldRun) {
      if (!_progress.isAnimating &&
          _progress.status != AnimationStatus.completed) {
        _progress.forward();
      }
    } else {
      _progress.stop();
    }
  }

  void _setHolding(bool value) {
    if (_holding == value) return;
    setState(() => _holding = value);
    _syncPlayback();
  }

  void _goNext() {
    if (_storyIndex < _storyCount - 1) {
      setState(() => _storyIndex++);
      _progress.forward(from: 0);
    } else {
      widget.onNextUser();
    }
  }

  void _goPrev() {
    if (_storyIndex > 0) {
      setState(() => _storyIndex--);
      _progress.forward(from: 0);
    } else if (widget.userIndex > 0) {
      widget.onPrevUser();
    } else {
      _progress.forward(from: 0);
    }
  }

  void _onTapUp(TapUpDetails details, double width) {
    if (_replyFocus.hasFocus) {
      _replyFocus.unfocus();
      return;
    }
    if (details.globalPosition.dx < width * 0.33) {
      _goPrev();
    } else {
      _goNext();
    }
  }

  void _toggleLike() {
    setState(() {
      if (_likedStories.contains(_storyIndex)) {
        _likedStories.remove(_storyIndex);
      } else {
        _likedStories.add(_storyIndex);
      }
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareStory() {
    showShareSheet(
      context,
      link:
          'https://picsum.photos/seed/story_${widget.category}_${widget.userIndex}_$_storyIndex/800/1400',
      item: SavedItem(
        id: 'story_${widget.category}_${widget.userIndex}_$_storyIndex',
        url:
            'https://picsum.photos/seed/story_${widget.category}_${widget.userIndex}_$_storyIndex/300/500',
        title: _userName,
      ),
    );
  }

  void _sendReply() {
    final String text = _replyController.text.trim();
    if (text.isEmpty) return;
    _replyController.clear();
    _replyFocus.unfocus();
    _showMessage('پاسخ شما به $_userName ارسال شد 🚀');
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final double bottomPad =
        mq.viewInsets.bottom > 0 ? mq.viewInsets.bottom : mq.padding.bottom;
    final String imageUrl =
        'https://picsum.photos/seed/story_${widget.category}_${widget.userIndex}_$_storyIndex/800/1400';
    final bool liked = _likedStories.contains(_storyIndex);

    return Stack(
      fit: StackFit.expand,
      children: [
        // تصویر استوری + ژست‌ها
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _onTapUp(d, mq.size.width),
          onDoubleTap: () {
            if (!_likedStories.contains(_storyIndex)) _toggleLike();
          },
          onLongPressStart: (_) => _setHolding(true),
          onLongPressEnd: (_) => _setHolding(false),
          onLongPressCancel: () => _setHolding(false),
          onVerticalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0) > 400) widget.onClose();
          },
          child: Image.network(
            imageUrl,
            key: ValueKey(imageUrl),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF00E5FF),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF1E1E28),
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white38,
                  size: 48,
                ),
              ),
            ),
          ),
        ),

        // سایه بالا و پایین برای خوانایی
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
                  stops: [0.0, 0.18, 0.72, 1.0],
                ),
              ),
            ),
          ),
        ),

        // نوار پیشرفت + مشخصات هنرمند
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _holding ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: AnimatedBuilder(
                      animation: _progress,
                      builder: (context, _) {
                        return Row(
                          children: List.generate(_storyCount, (i) {
                            final double value = i < _storyIndex
                                ? 1.0
                                : (i == _storyIndex ? _progress.value : 0.0);
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: value,
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
                          backgroundImage: NetworkImage(
                            avatarUrl(_userName),
                          ),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 10),
                        Text.rich(
                          TextSpan(children: <InlineSpan>[
                            TextSpan(
                              text: '$_userName ',
                              recognizer: TapGestureRecognizer()
                                ..onTap =
                                    () => openUserByName(context, _userName),
                            ),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: starsRow(
                                    _isOwn
                                        ? kMyUsername
                                        : storyUserName(
                                            widget.category, widget.userIndex),
                                    size: 9)),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: tickBadges(_isOwn
                                    ? kMyUsername
                                    : storyUserName(
                                        widget.category, widget.userIndex))),
                          ]),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeAgo,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.white,
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // نوار پایین: پاسخ / لایک / اشتراک
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedOpacity(
            opacity: _holding ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPad + 12),
              child: _isOwn
                  ? Row(
                      children: [
                        const Icon(
                          Icons.remove_red_eye_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${128 + _storyIndex * 17} بازدید',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          color: Colors.white,
                          onPressed: () => _shareStory(),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _replyController,
                            focusNode: _replyFocus,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendReply(),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'ارسال پیام به $_userName...',
                              hintStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: Colors.black26,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 11,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Colors.white54,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00E5FF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (_hasText)
                          IconButton(
                            icon: const Icon(Icons.send_rounded),
                            color: const Color(0xFF00E5FF),
                            onPressed: _sendReply,
                          )
                        else ...[
                          IconButton(
                            icon: Icon(
                              liked ? Icons.favorite : Icons.favorite_border,
                            ),
                            color:
                                liked ? const Color(0xFFFF0055) : Colors.white,
                            onPressed: _toggleLike,
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined),
                            color: Colors.white,
                            onPressed: () => _shareStory(),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
// ===================== پایان کد جدید پایان بخش =====================
