part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
//
// - آرشیو (استوری‌ها + پست‌های بایگانی‌شده)
// - نمایش آثار خودت در فید اصلی با ظاهر اینستاگرامی
// =====================================================================
class StoryArchiveScreen extends StatelessWidget {
  const StoryArchiveScreen({super.key});

  Widget _empty(String t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          t,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  void _view(BuildContext context, List<ArchiveItem> items, int index) {
    final Highlight tmp = Highlight(
      id: 'archive_tmp',
      title: 'آرشیو استوری',
      cover: items[index].src,
      items: items.map((e) => e.src).toList(),
    );
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => HighlightViewerScreen(
          highlight: tmp,
          owner: kMyUsername,
          isOwn: false,
          startAt: index,
        ),
      ),
    );
  }

  void _storyMenu(BuildContext context, ArchiveItem it) {
    showDarkSheet<void>(
      context,
      (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              sheetHandle(),
              sheetTile(Icons.auto_awesome_outlined, 'افزودن به هایلایت', () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => NewHighlightScreen(preselect: it.src),
                  ),
                );
              }),
              sheetTile(
                Icons.delete_outline,
                'حذف از آرشیو',
                () {
                  Navigator.pop(ctx);
                  if (it.isPost) {
                    final UserPost? p = findMyPost(it.src.substring(5));
                    if (p != null) {
                      PostImages.remove(p.id);
                      PostStore.I.remove(p);
                    }
                  } else {
                    SocialStore.I.deleteArchiveSeed(it.src);
                  }
                  showSnack(context, 'از آرشیو حذف شد');
                },
                color: const Color(0xFFFF5252),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storiesTab(BuildContext context) {
    final List<ArchiveItem> items = buildStoryArchive();
    if (items.isEmpty) return _empty('آرشیو استوری خالی است');
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
        return GestureDetector(
          onTap: () => _view(context, items, i),
          onLongPress: () => _storyMenu(context, it),
          child: Stack(
            fit: StackFit.expand,
            children: [
              hlImage(it.src, w: 300, h: 480),
              Positioned(
                left: 6,
                bottom: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    it.label,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
              if (it.closeFriends)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Color(0xFF00C853),
                    child: Icon(Icons.star, size: 11, color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _postsTab(BuildContext context) {
    final List<UserPost> list = PostStore.I.posts
        .where((p) => p.type != 'story' && SocialStore.I.metaOf(p.id).archived)
        .toList();
    if (list.isEmpty) {
      return _empty(
        'هنوز پستی بایگانی نکرده‌اید.\nاز منوی سه‌نقطه‌ی هر پست می‌توانید آن را بایگانی کنید.',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(3),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final UserPost p = list[i];
        return GestureDetector(
          onTap: () {
            showDarkSheet<void>(
              context,
              (ctx) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      sheetHandle(),
                      sheetTile(
                        Icons.unarchive_outlined,
                        'نمایش دوباره در پروفایل و فید',
                        () {
                          Navigator.pop(ctx);
                          SocialStore.I
                              .updateMeta(p.id, (m) => m.archived = false);
                          PostStore.I.touch();
                          showSnack(context, 'پست دوباره نمایش داده می‌شود');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: myPostImage(p),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('آرشیو'),
          bottom: const TabBar(
            indicatorColor: Color(0xFF00E5FF),
            labelColor: Color(0xFF00E5FF),
            tabs: [Tab(text: 'استوری‌ها'), Tab(text: 'پست‌ها')],
          ),
        ),
        body: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[SocialStore.I, PostStore.I]),
          builder: (context, _) {
            return TabBarView(
              children: [_storiesTab(context), _postsTab(context)],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// آثار خودت در فید اصلی (بالای پست‌های بقیه)
// ---------------------------------------------------------------------
class MyFeedPosts extends StatelessWidget {
  final String selectedCategory;
  const MyFeedPosts({super.key, required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[PostStore.I, SocialStore.I]),
      builder: (context, _) {
        final List<UserPost> list = PostStore.I.posts.where((p) {
          if (p.type == 'story') return false;
          if (SocialStore.I.metaOf(p.id).archived) return false;
          return selectedCategory == 'all' ||
              CategoryStore.I.matches(p.category, selectedCategory);
        }).toList();
        return Column(
          children: list
              .map((p) => FeedPostCard(key: ValueKey<String>(p.id), post: p))
              .toList(),
        );
      },
    );
  }
}

class FeedPostCard extends StatefulWidget {
  final UserPost post;
  const FeedPostCard({super.key, required this.post});

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heart;
  bool _showTags = false;
  bool _more = false;

  UserPost get _p => widget.post;
  PostMeta get _meta => SocialStore.I.metaOf(_p.id);

  @override
  void initState() {
    super.initState();
    _heart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _heart.dispose();
    super.dispose();
  }

  void _like() {
    if (!_p.liked) PostStore.I.toggleLike(_p);
    _heart.forward(from: 0);
  }

  void _openComments() {
    if (_meta.commentsOff) {
      showSnack(context, 'نظرات این پست بسته شده است');
      return;
    }
    showCommentsSheet(context, _p.comments, onChanged: PostStore.I.touch);
  }

  Future<void> _editTags() async {
    final List<TagEntry>? r = await Navigator.of(context).push<List<TagEntry>>(
      MaterialPageRoute<List<TagEntry>>(
        builder: (_) => TagPeopleScreen(
          image: myPostImage(_p),
          initial: _meta.tags,
        ),
      ),
    );
    if (r != null) {
      SocialStore.I.updateMeta(_p.id, (m) => m.tags = r);
    }
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        title: const Text('حذف اثر'),
        content: const Text('این اثر برای همیشه حذف می‌شود. مطمئنی؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              PostImages.remove(_p.id);
              PostStore.I.remove(_p);
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Color(0xFFFF0055)),
            ),
          ),
        ],
      ),
    );
  }

  void _menu() {
    final PostMeta m = _meta;
    showDarkSheet<void>(
      context,
      (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              sheetHandle(),
              sheetTile(
                _p.saved ? Icons.bookmark : Icons.bookmark_border,
                _p.saved ? 'حذف از ذخیره‌شده‌ها' : 'ذخیره اثر',
                () {
                  Navigator.pop(ctx);
                  saveWithCollections(context, _p);
                },
              ),
              sheetTile(Icons.person_add_alt_1_outlined, 'تگ کردن آدم‌ها', () {
                Navigator.pop(ctx);
                _editTags();
              }),
              sheetTile(
                Icons.favorite_border,
                m.hideLikes ? 'نمایش تعداد پسند' : 'مخفی کردن تعداد پسند',
                () {
                  Navigator.pop(ctx);
                  SocialStore.I
                      .updateMeta(_p.id, (x) => x.hideLikes = !x.hideLikes);
                },
              ),
              sheetTile(
                Icons.comments_disabled_outlined,
                m.commentsOff ? 'روشن کردن نظرات' : 'خاموش کردن نظرات',
                () {
                  Navigator.pop(ctx);
                  SocialStore.I
                      .updateMeta(_p.id, (x) => x.commentsOff = !x.commentsOff);
                },
              ),
              sheetTile(Icons.archive_outlined, 'بایگانی', () {
                Navigator.pop(ctx);
                SocialStore.I.updateMeta(_p.id, (x) => x.archived = true);
                PostStore.I.touch();
                showSnack(context, 'پست به آرشیو رفت');
              }),
              sheetTile(
                Icons.delete_outline,
                'حذف اثر',
                () {
                  Navigator.pop(ctx);
                  _confirmDelete();
                },
                color: const Color(0xFFFF5252),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(String cat) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 8),
        child: Row(children: [
          InteractiveBaraviCube(
              size: 40,
              totalStories: 4,
              isProfileMode: true,
              seedKey: 'profile_cube_$kMyUsername',
              rotationDuration: const Duration(seconds: 5)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Flexible(
                      child: Text(kMyUsername,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13))),
                  const SizedBox(width: 4),
                  tickBadges(kMyUsername, size: 14)
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                          color: const Color(0xFF22222E),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(cat,
                          style: const TextStyle(
                              color: Color(0xFF00E5FF), fontSize: 10))),
                  const SizedBox(width: 6),
                  Row(
                      children: List.generate(
                          5,
                          (i) => const Icon(Icons.star,
                              size: 12, color: Color(0xFFFFB300)))),
                  const SizedBox(width: 6),
                  Text(_p.time,
                      style: const TextStyle(color: Colors.grey, fontSize: 10))
                ])
              ])),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: _menu)
        ]));
  }

  Widget _headerOld(String cat) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFFFF0055)],
              ),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF1E1E28),
              backgroundImage: NetworkImage(avatarUrl(kMyUsername)),
              onBackgroundImageError: (_, __) {},
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        kMyUsername,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF00E5FF),
                      size: 14,
                    ),
                  ],
                ),
                Text(
                  '$cat • ${_p.time}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: _menu),
        ],
      ),
    );
  }

  List<Widget> _tagLabels(double w, double h) {
    return _meta.tags.map((t) {
      final double left = (t.x * w - 45).clamp(2.0, w - 100).toDouble();
      final double top = (t.y * h + 6).clamp(2.0, h - 30).toDouble();
      return Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          onTap: () => openUserByName(context, t.user),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              t.user,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _heartOverlay() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _heart,
        builder: (context, _) {
          final double v = _heart.value;
          if (v == 0.0 || v == 1.0) return const SizedBox.shrink();
          return Opacity(
            opacity: (1.0 - v).clamp(0.0, 1.0).toDouble(),
            child: Transform.scale(
              scale: 0.6 + v * 0.8,
              child: const Icon(Icons.favorite, color: Colors.white, size: 90),
            ),
          );
        },
      ),
    );
  }

  Widget _media() {
    final bool reel = _p.type == 'reel';
    final bool hasTags = _meta.tags.isNotEmpty;
    return AspectRatio(
      aspectRatio: reel ? 4 / 5 : 1,
      child: LayoutBuilder(
        builder: (context, c) {
          return GestureDetector(
            onDoubleTap: _like,
            onLongPress: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PostPhotoViewerScreen(
                  images: [myPostImage(_p, fit: BoxFit.contain)],
                ),
              ),
            ),
            onTap:
                hasTags ? () => setState(() => _showTags = !_showTags) : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                myPostImage(_p),
                if (reel)
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white70,
                      size: 54,
                    ),
                  ),
                if (hasTags)
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (_showTags && hasTags)
                  ..._tagLabels(c.maxWidth, c.maxHeight),
                Center(child: _heartOverlay()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _act(IconData icon, VoidCallback onTap, {Color c = Colors.white}) {
    int? n;
    if (icon == Icons.favorite || icon == Icons.favorite_border) {
      n = _p.likes;
    } else if (icon == Icons.chat_bubble_outline) {
      n = _p.comments.fold<int>(0, (s, x) => s + 1 + x.replies.length);
    } else if (icon == Icons.share_outlined) {
      n = kShareCounts[_p.id] ?? 0;
    } else if (icon == Icons.bookmark || icon == Icons.bookmark_border) {
      n = _p.saved ? 1 : 0;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
          icon: Icon(icon, color: c, size: 26),
          onPressed: () {
            if (icon == Icons.share_outlined) {
              setState(
                  () => kShareCounts[_p.id] = (kShareCounts[_p.id] ?? 0) + 1);
            }
            onTap();
          },
        ),
        if (n != null)
          Text(
            compactCount(n),
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _actOld(IconData icon, VoidCallback onTap, {Color c = Colors.white}) {
    return IconButton(
      icon: Icon(icon, color: c, size: 26),
      onPressed: onTap,
    );
  }

  Widget _actions() {
    return Row(
      children: [
        _act(
          _p.liked ? Icons.favorite : Icons.favorite_border,
          () => PostStore.I.toggleLike(_p),
          c: _p.liked ? const Color(0xFFFF0055) : Colors.white,
        ),
        _act(Icons.chat_bubble_outline, _openComments),
        _act(Icons.share_outlined, () => shareMyPost(context, _p)),
        /*
 context,
 link:
 'https://picsum.photos/seed/talent_post_${widget.postIndex + 20}/800/800',
 item: SavedItem(
 id: 'fee_act(Icons.share_outlined, () => shareMyPost(context, _p)),d_${widget.postIndex}',
 url:
 'https://picsum.photos/seed/talent_post_${widget.postIndex + 20}/300/300',
 title: widget.authorName,
 ),
 onSaved: () => setState(() => _isSaved = true),
*/
        const Spacer(),
        _act(
          _p.saved ? Icons.bookmark : Icons.bookmark_border,
          () => saveWithCollections(context, _p),
          c: _p.saved ? const Color(0xFFFFB300) : Colors.white,
        ),
      ],
    );
  }

  Widget _info() {
    final PostMeta m = _meta;
    final int comments =
        _p.comments.fold<int>(0, (s, c) => s + 1 + c.replies.length);
    final String commentText = m.commentsOff
        ? 'نظرات این پست بسته شده است'
        : (comments == 0
            ? 'اولین نظر را بنویس...'
            : 'مشاهده همه $comments نظر');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m.hideLikes
                ? 'تعداد پسند مخفی است'
                : '${compactCount(_p.likes)} پسند',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          if (m.tags.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'با ${m.tags.map((t) => t.user).join('، ')}',
              style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
            ),
          ],
          if (_p.caption.isNotEmpty) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _more = !_more),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  children: <InlineSpan>[
                    TextSpan(
                      text: '$kMyUsername ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...richTextSpans(_p.caption),
                  ],
                ),
                maxLines: _more ? null : 2,
                overflow: _more ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _openComments,
            child: Text(
              commentText,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String cat = talentCategories.firstWhere(
      (c) => c['id'] == _p.category,
      orElse: () => talentCategories[1],
    )['title'] as String;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: const Color(0xFF0F0F12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(cat),
          _media(),
          _actions(),
          _info(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: JudgeScoreBar(workId: _p.id),
          ),
        ],
      ),
    );
  }
}
