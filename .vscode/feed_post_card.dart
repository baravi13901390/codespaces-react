part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

class PostList extends StatelessWidget {
  final String selectedCategory;
  const PostList({super.key, required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    final int catIndex =
        talentCategories.indexWhere((c) => c['id'] == selectedCategory);
    final int base = ((catIndex < 0 ? 0 : catIndex) + kFeedShift * 3) * 4;
    final String catTitle = talentCategories.firstWhere(
      (c) => c['id'] == selectedCategory,
      orElse: () => talentCategories[1],
    )['title'] as String;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        final int idx = base + index;
        return TalentPostCard(
          key: ValueKey<int>(idx),
          postIndex: idx,
          categoryName: selectedCategory == 'all'
              ? (index % 2 == 0 ? 'صنعت و تراشکاری' : 'موسیقی و نوازندگی')
              : catTitle,
          authorName: 'استعداد_${idx + 1}',
          stars: (idx % 5) + 1,
        );
      },
    );
  }
}

class TalentPostCard extends StatefulWidget {
  final int postIndex;
  final String categoryName;
  final String authorName;
  final int stars;

  const TalentPostCard({
    super.key,
    required this.postIndex,
    required this.categoryName,
    required this.authorName,
    required this.stars,
  });

  @override
  State<TalentPostCard> createState() => _TalentPostCardState();
}

class _TalentPostCardState extends State<TalentPostCard>
    with SingleTickerProviderStateMixin {
  // ===================================================================
  // بخش جدید پست‌ها:
  // دابل‌تپ لایک، شمارنده لایک، کپشن + هشتگ + «بیشتر»، آلبوم چندعکسی،
  // ذخیره، فالو، منوی سه‌نقطه (ذخیره/کپی لینک/فالو/علاقه‌ای ندارم/گزارش)،
  // زمان انتشار
  // ===================================================================
  late final AnimationController _heartController;
  late final PageController _mediaController;
  int _mediaPage = 0;
  bool _isSaved = false;
  bool get _isFollowing => AppState.I.isFollowing(widget.authorName); //
  bool _isHidden = false;
  bool _captionExpanded = false;

  static const List<String> _captions = [
    'تراشکاری دقیق یه قطعه ۴۰ میلی‌متری با تلرانس خیلی کم 🔧 چند ماه تمرین پشت این کار بود و امیدوارم از دیدنش لذت ببرید. نظرتون رو درباره فرآیند ساخت برام بنویسید! #تراشکاری #صنعت #استعداد_ایران',
    'اجرای زنده قطعه‌ای که هفته‌ها روش کار کردم 🎻 #موسیقی #نوازندگی #باراوی',
    'ساخت یه مدار کنترل موتور از صفر تا صد ⚡ همه مراحل رو توی آلبوم گذاشتم، ورق بزنید! #برق #الکترونیک #ساخت',
    'تمرین امروز 🎶 هر روز یه کم بهتر از دیروز #هنر #تمرین #باراوی',
  ];
  static const List<String> _times = [
    '۲ ساعت پیش',
    '۵ ساعت پیش',
    'دیروز',
    '۳ روز پیش',
  ];

  int get _mediaCount =>
      widget.postIndex % 2 == 0 ? ((widget.postIndex ~/ 2) % 8) + 3 : 1;
  int get _baseLikes => 1240 + widget.postIndex * 317;
  int get _shareCount =>
      12 +
      (widget.postIndex * 5) % 60 +
      (kShareCounts['feed_${widget.postIndex}'] ?? 0);
  int get _saveCount => 30 + (widget.postIndex * 11) % 120 + (_isSaved ? 1 : 0);
  Widget _cnt(int n) => Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Text(
          compactCount(n),
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      );
  int get _likesCount => _baseLikes + (_isLiked ? 1 : 0);
  String get _caption => _captions[widget.postIndex % _captions.length];
  String get _timeAgo => _times[widget.postIndex % _times.length];
  String get _followLabel => _isFollowing ? 'دنبال می‌کنید' : 'دنبال کردن';
  int get _commentCount =>
      _comments.fold<int>(0, (sum, c) => sum + 1 + c.replies.length);

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _mediaController = PageController();
    AppState.I.addListener(_onAppState);
    SocialStore.I.addListener(_onAppState); //
  }

  @override
  void dispose() {
    AppState.I.removeListener(_onAppState);
    SocialStore.I.removeListener(_onAppState); //
    _heartController.dispose();
    _mediaController.dispose();
    super.dispose();
  }

  void _openViewer(int count) {
    List<Widget> imgs(int p, int c) => List<Widget>.generate(c, (i) {
          final String seed =
              i == 0 ? 'talent_post_${p + 20}' : 'talent_post_${p + 20}_$i';
          return Image.network(
            'https://picsum.photos/seed/$seed/800/800',
            fit: BoxFit.contain,
          );
        });
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PostPhotoViewerScreen(
          images: imgs(widget.postIndex, count),
          initialIndex: _mediaPage,
          nextPost: (s) => s <= 5 ? imgs(widget.postIndex + s, 3) : null,
        ),
      ),
    );
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _onAppState() {
    if (mounted) setState(() {});
  }

  void _toggleFollow() {
    AppState.I.toggleFollow(widget.authorName);
    _showSnack(
      _isFollowing
          ? 'شما ${widget.authorName} را دنبال کردید ✅'
          : 'دنبال کردن ${widget.authorName} لغو شد',
    );
  }

  void _toggleSave() {
    setState(() => _isSaved = !_isSaved);
    feedSaveHook(
        context,
        'feed_${widget.postIndex}',
        'https://picsum.photos/seed/talent_post_${widget.postIndex}/300/300',
        widget.authorName,
        _isSaved);
    _showSnack(
      _isSaved
          ? 'در لیست ذخیره‌شده‌ها قرار گرفت! ⭐️'
          : 'از لیست ذخیره‌شده‌ها حذف شد',
    );
  }

  List<InlineSpan> _captionSpans(String text) {
    final List<InlineSpan> spans = [];
    final List<String> words = text.split(' ');
    for (int i = 0; i < words.length; i++) {
      final String w = words[i];
      final bool special = w.startsWith('#') || w.startsWith('@');
      spans.add(
        TextSpan(
          text: i == words.length - 1 ? w : '$w ',
          style: special ? const TextStyle(color: Color(0xFF00E5FF)) : null,
        ),
      );
    }
    return spans;
  }

  Widget _buildMedia() {
    final int count = _mediaCount;
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapUp: (details) {
              _openViewer(count);
              return;
              final double half = constraints.maxWidth / 2;
              if (details.localPosition.dx < half) {
                if (_mediaPage > 0) {
                  _mediaController.previousPage(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                  );
                }
              } else {
                if (_mediaPage < count - 1) {
                  _mediaController.nextPage(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                  );
                }
              }
            },
            onDoubleTap: () {
              setState(() => _isLiked = true);
              _heartController.forward(from: 0);
            },
            onLongPress: () {
              final int count = _mediaCount;
              final List<Widget> images = List<Widget>.generate(count, (i) {
                final String seed = i == 0
                    ? 'talent_post_${widget.postIndex + 20}'
                    : 'talent_post_${widget.postIndex + 20}_$i';
                return Image.network(
                  'https://picsum.photos/seed/$seed/800/800',
                  fit: BoxFit.contain,
                );
              });
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PostPhotoViewerScreen(
                    images: images,
                    initialIndex: _mediaPage,
                  ),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _mediaController,
                  itemCount: count,
                  onPageChanged: (i) => setState(() => _mediaPage = i),
                  itemBuilder: (context, i) {
                    final String seed = i == 0
                        ? 'talent_post_${widget.postIndex + 20}'
                        : 'talent_post_${widget.postIndex + 20}_$i';
                    return Image.network(
                      'https://picsum.photos/seed/$seed/800/800',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF1E1E28),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white38,
                            size: 40,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (count > 1)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_mediaPage + 1}/$count',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                IgnorePointer(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _heartController,
                      builder: (context, _) {
                        final double t = _heartController.value;
                        if (_heartController.isDismissed || t >= 1.0) {
                          return const SizedBox.shrink();
                        }
                        final double scale = t < 0.3
                            ? Curves.easeOutBack.transform(t / 0.3)
                            : 1.0;
                        final double opacity =
                            t < 0.7 ? 1.0 : 1.0 - ((t - 0.7) / 0.3);
                        return Opacity(
                          opacity: opacity.clamp(0.0, 1.0).toDouble(),
                          child: Transform.scale(
                            scale: scale,
                            child: const Icon(
                              Icons.favorite,
                              size: 96,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 24, color: Colors.black54),
                              ],
                            ),
                          ),
                        );
                      },
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

  Widget _buildDots() {
    if (_mediaCount <= 1) return const SizedBox.shrink();
    return FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _mediaCount,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _mediaPage
                    ? const Color(0xFF00E5FF)
                    : Colors.grey.shade700,
              ),
            ),
          ),
        ));
  }

  Widget _buildPostInfo() {
    final bool longCaption = _caption.length > 90;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatCount(_likesCount)} پسند',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              if (longCaption) {
                setState(() => _captionExpanded = !_captionExpanded);
              }
            },
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Colors.white70,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '${widget.authorName} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ..._captionSpans(_caption),
                ],
              ),
              maxLines: (_captionExpanded || !longCaption) ? null : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (longCaption && !_captionExpanded)
            GestureDetector(
              onTap: () => setState(() => _captionExpanded = true),
              child: const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  'بیشتر',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _showCommentsModal,
            child: Text(
              'مشاهده همه $_commentCount نظر',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _timeAgo,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenPlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: const Color(0xFF14141A),
      child: Row(
        children: [
          const Icon(
            Icons.visibility_off_outlined,
            color: Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'این پست دیگر به شما نمایش داده نمی‌شود.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () {
              SocialStore.I.unhidePost('feed_${widget.postIndex}');
              setState(() => _isHidden = false);
            },
            child: const Text(
              'لغو',
              style: TextStyle(color: Color(0xFF00E5FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showPostMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                _menuTile(
                  icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  label: _isSaved ? 'حذف از ذخیره‌شده‌ها' : 'ذخیره اثر',
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleSave();
                  },
                ),
                _menuTile(
                  icon: Icons.link,
                  label: 'کپی لینک',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSnack('لینک اثر با موفقیت کپی شد! 🔗');
                  },
                ),
                _menuTile(
                  icon: _isFollowing
                      ? Icons.person_remove_alt_1_outlined
                      : Icons.person_add_alt_1_outlined,
                  label: _isFollowing
                      ? 'لغو دنبال کردن ${widget.authorName}'
                      : 'دنبال کردن ${widget.authorName}',
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleFollow();
                  },
                ),
                _menuTile(
                  icon: Icons.visibility_off_outlined,
                  label: 'علاقه‌ای ندارم',
                  onTap: () {
                    Navigator.pop(ctx);
                    SocialStore.I.hidePost(
                        'feed_${widget.postIndex}', widget.authorName);
                    setState(() => _isHidden = true);
                  },
                ),
                _menuTile(
                  icon: Icons.flag_outlined,
                  label: 'گزارش',
                  color: const Color(0xFFFF5252),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showReportSheet();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReportSheet() {
    const List<String> reasons = [
      'اسپم یا تبلیغات مزاحم',
      'محتوای نامناسب',
      'نقض حق کپی‌رایت',
      'اطلاعات نادرست',
      'خشونت یا آزار',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'چرا این پست را گزارش می‌کنید؟',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                ...reasons.map(
                  (r) => _menuTile(
                    icon: Icons.chevron_left_rounded,
                    label: r,
                    onTap: () {
                      Navigator.pop(ctx);
                      _showSnack('گزارش شما ثبت شد. ممنون از همکاری‌تان 🙏');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // ===================== پایان بخش جدید پایان بخش =====================

  bool _isLiked = false;

  // نظرات حالا مدل دارن (پاسخ / لایک / حذف)
  late final List<PostComment> _comments = seedComments(widget.postIndex);

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          username: widget.authorName,
          talentField: widget.categoryName,
          starsCount: widget.stars,
          totalScore: 350000 + (widget.postIndex * 32000),
          isVerified: widget.stars == 5,
        ),
      ),
    );
  }

  // پنجره نظرات به کد مشترک منتقل شد
  void _showCommentsModal() {
    showCommentsSheet(
      context,
      _comments,
      onChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  // پنجره اشتراک‌گذاری به کد مشترک منتقل شد (ظاهرش همون قبلیه)
  void _showShareModal() {
    kShareCounts['feed_${widget.postIndex}'] =
        (kShareCounts['feed_${widget.postIndex}'] ?? 0) + 1;
    setState(() {});
    showShareSheet(context,
        link:
            'https://picsum.photos/seed/talent_post_${widget.postIndex + 20}/800/800',
        item: SavedItem(
            id: 'feed_${widget.postIndex}',
            url:
                'https://picsum.photos/seed/talent_post_${widget.postIndex + 20}/300/300',
            title: widget.authorName),
        onSaved: () => setState(() => _isSaved =
            true)); /*
 context,
 link:
 'https://picsum.photos/seed/talent_post_${widget.postIndex + 20}/800/800',
 item: SavedItem(
 id: 'feed_${widget.postIndex}',
 url:
 'https://picsum.photos/seed/talent_post_${widget.postIndex + 20}/300/300',
 title: widget.authorName,
 ),
 onSaved: () => setState(() => _isSaved = true),
*/
  }

  @override
  Widget build(BuildContext context) {
    if (_isHidden || SocialStore.I.isHidden('feed_${widget.postIndex}')) {
      return _buildHiddenPlaceholder(); //
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF14141A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _navigateToProfile,
                  child: InteractiveBaraviCube(
                    size: 40,
                    totalStories: 4,
                    isProfileMode: true,
                    seedKey: 'talent_user_${widget.postIndex}',
                    rotationDuration: const Duration(seconds: 5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.deferToChild,
                    onTap: _navigateToProfile,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            tickBadges(widget.authorName),
                            if (false)
                              const Icon(
                                Icons.verified,
                                color: Color(0xFF00E5FF),
                                size: 15,
                              ),
                            // دنبال کردن کنار اسم (مثل اینستاگرام)
                            const SizedBox(width: 8),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _toggleFollow,
                              child: Text(
                                '• $_followLabel',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _isFollowing
                                      ? Colors.grey
                                      : const Color(0xFF00E5FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22222E),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.categoryName,
                                style: const TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  size: 12,
                                  color: i < widget.stars
                                      ? const Color(0xFFFFB300)
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: _showPostMenu, //
                ),
              ],
            ),
          ),
          _buildMedia(), // آلبوم + دابل‌تپ لایک
          PostRatingBar(
              postId: 'feed_${widget.postIndex}'), // نمره محرمانه + دکمه ثبت
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? const Color(0xFFFF0055) : Colors.white,
                    size: 24,
                  ),
                  onPressed: () => setState(() => _isLiked = !_isLiked),
                ),
                _cnt(_likesCount),
                SizedBox(),
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: _showCommentsModal,
                ),
                _cnt(_commentCount),
                SizedBox(),
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: _showShareModal,
                ),
                _cnt(_shareCount),
                SizedBox(),
                // نقطه‌های آلبوم + دکمه ذخیره
                Expanded(child: _buildDots()),
                IconButton(
                  icon: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isSaved ? const Color(0xFFFFB300) : Colors.white,
                    size: 24,
                  ),
                  onPressed: _toggleSave,
                ),
                _cnt(_saveCount),
                SizedBox(),
              ],
            ),
          ),
          _buildPostInfo(), // لایک‌ها + کپشن + نظرات + زمان
          const Divider(height: 1, color: Color(0xFF252533)),
        ],
      ),
    );
  }
}
