part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// جستجو و اکسپلور (کد جدید)
// - صفحه جستجو (از دکمه ذره‌بین بالای فید باز می‌شه)
// - اکسپلور: شبکه پست‌ها + فیلتر صنف‌ها
// - جستجوی افراد / هشتگ‌ها / صنف‌ها + سابقه جستجو
// - صفحه هشتگ/صنف و صفحه باز شدن پست از روی شبکه
// =====================================================================
class TalentUser {
  final String username;
  final String field;
  final int stars;
  final int score;
  const TalentUser({
    required this.username,
    required this.field,
    required this.stars,
    required this.score,
  });
}

int starsForScore(int s) => (s ~/ 100000).clamp(1, 5).toInt();

final List<TalentUser> allTalentUsers = List<TalentUser>.generate(16, (i) {
  final List<Map<String, dynamic>> cats =
      talentCategories.where((c) => c['id'] != 'all').toList();
  return TalentUser(
    username: i < 8 ? 'استعداد_${i + 1}' : 'creator_talent_${i - 8}',
    field: cats[i % cats.length]['title'] as String,
    stars: starsForScore(520000 - i * 21000),
    score: 520000 - i * 21000,
  );
});

const List<String> kFeedCaptions = [
  'تراشکاری دقیق یه قطعه ۴۰ میلی‌متری با تلرانس خیلی کم 🔧 چند ماه تمرین پشت این کار بود و امیدوارم از دیدنش لذت ببرید. نظرتون رو درباره فرآیند ساخت برام بنویسید! #تراشکاری #صنعت #استعداد_ایران',
  'اجرای زنده قطعه‌ای که هفته‌ها روش کار کردم 🎻 #موسیقی #نوازندگی #باراوی',
  'ساخت یه مدار کنترل موتور از صفر تا صد ⚡ همه مراحل رو توی آلبوم گذاشتم، ورق بزنید! #برق #الکترونیک #ساخت',
  'تمرین امروز 🎶 هر روز یه کم بهتر از دیروز #هنر #تمرین #باراوی',
];

List<String> hashtagsIn(String text) {
  final List<String> out = <String>[];
  for (final String w in text.split(RegExp(r'\s+'))) {
    if (w.length > 1 && w.startsWith('#')) out.add(w.substring(1));
  }
  return out;
}

List<String> computeTrendingHashtags() {
  final Map<String, int> count = <String, int>{};
  for (int i = 0; i < 40; i++) {
    for (final String t in hashtagsIn(kFeedCaptions[i % 4])) {
      count[t] = (count[t] ?? 0) + 1;
    }
  }
  for (final UserPost p in PostStore.I.posts) {
    for (final String t in hashtagsIn(p.caption)) {
      count[t] = (count[t] ?? 0) + 3;
    }
  }
  final List<String> keys = count.keys.toList();
  keys.sort((a, b) => count[b]!.compareTo(count[a]!));
  return keys.take(11).toList();
}

List<int> taggedPostIndexes(String tag) {
  final String t = tag.startsWith('#') ? tag.substring(1) : tag;
  final List<int> out = <int>[];
  for (int i = 0; i < 40; i++) {
    if (hashtagsIn(kFeedCaptions[i % 4]).contains(t)) out.add(i);
  }
  return out;
}

List<UserPost> taggedMyPosts(String tag) {
  final String t = tag.startsWith('#') ? tag.substring(1) : tag;
  return PostStore.I.posts
      .where((p) => p.type != 'story' && hashtagsIn(p.caption).contains(t))
      .toList();
}

class TagPostsGrid extends StatelessWidget {
  final String tag;
  const TagPostsGrid({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final List<UserPost> mine = taggedMyPosts(tag);
    final List<int> idx = taggedPostIndexes(tag);
    if (mine.isEmpty && idx.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            'هنوز اثری با این هشتگ نیست',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: mine.length + idx.length,
      itemBuilder: (context, i) {
        if (i < mine.length) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const MyWorksScreen()),
            ),
            child: myPostImage(mine[i]),
          );
        }
        final int k = idx[i - mine.length];
        return GestureDetector(
          onTap: () => openPostDetail(context, k),
          child: Image.network(
            'https://picsum.photos/seed/talent_post_${k + 20}/300/300',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: const Color(0xFF1E1E28)),
          ),
        );
      },
    );
  }
}

List<String> get trendingHashtags => computeTrendingHashtags();

const List<String> trendingHashtagsOld = [
  'تراشکاری',
  'صنعت',
  'موسیقی',
  'نوازندگی',
  'الکترونیک',
  'برق',
  'ساخت',
  'هنر',
  'تمرین',
  'باراوی',
  'استعداد_ایران',
];

String avatarUrl(String username) {
  final String seed = Uri.encodeComponent('av_$username');
  return 'https://picsum.photos/seed/$seed/200';
}

void openUserProfile(BuildContext context, TalentUser u) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => UserProfileScreen(
        username: u.username,
        talentField: u.field,
        starsCount: u.stars,
        totalScore: u.score,
        isVerified: u.stars == 5,
        isOwnProfile: false,
      ),
    ),
  );
}

void openPostDetail(BuildContext context, int postIndex) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => PostDetailScreen(postIndex: postIndex)),
  );
}

class UserTile extends StatelessWidget {
  final TalentUser user;
  final VoidCallback? onOpen;
  const UserTile({super.key, required this.user, this.onOpen});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.I,
      builder: (context, _) {
        final bool following = AppState.I.isFollowing(user.username);
        return ListTile(
          onTap: () {
            onOpen?.call();
            openUserProfile(context, user);
          },
          leading: CubeAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF1E1E28),
            backgroundImage: NetworkImage(avatarUrl(user.username)),
            onBackgroundImageError: (_, __) {},
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  user.username,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              tickBadges(user.username),
              if (false) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Color(0xFF00E5FF), size: 14),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              starsRow(user.username),
              Text(guildPathByTitle(user.field),
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          trailing: SizedBox(
            height: 30,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: following
                    ? const Color(0xFF22222E)
                    : const Color(0xFF00E5FF),
                foregroundColor: following ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => AppState.I.toggleFollow(user.username),
              child: Text(
                following ? 'دنبال می‌کنید' : 'دنبال کردن',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PostGrid extends StatelessWidget {
  final int count;
  final int offset;
  const PostGrid({super.key, required this.count, this.offset = 0});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: count,
      itemBuilder: (context, i) {
        final int idx = offset + i;
        return GestureDetector(
          onTap: () => openPostDetail(context, idx),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://picsum.photos/seed/talent_post_${idx + 20}/300/300',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: const Color(0xFF1E1E28)),
              ),
              if (idx % 2 == 0)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    Icons.collections_rounded,
                    size: 16,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                  ),
                ),
              if (idx % 5 == 2)
                const Positioned(
                  bottom: 6,
                  left: 6,
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 20,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class PostDetailScreen extends StatelessWidget {
  final int postIndex;
  const PostDetailScreen({super.key, required this.postIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پست')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          TalentPostCard(
            postIndex: postIndex,
            categoryName:
                postIndex % 2 == 0 ? 'صنعت و تراشکاری' : 'موسیقی و نوازندگی',
            authorName: 'استعداد_${(postIndex % 8) + 1}',
            stars: ((postIndex % 4) + 2).clamp(1, 5),
          ),
        ],
      ),
    );
  }
}

class TopicScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const TopicScreen({super.key, required this.title, this.icon = Icons.tag});

  @override
  Widget build(BuildContext context) {
    final String key = 'topic:$title';
    final bool isTag = title.startsWith('#');
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CubeAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFF22222E),
                  child: Icon(icon, color: const Color(0xFF00E5FF), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatCount(isTag ? taggedPostIndexes(title).length + taggedMyPosts(title).length : 900 + title.length * 613)} اثر',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: AppState.I,
                        builder: (context, _) {
                          final bool on = AppState.I.isFollowing(key);
                          return SizedBox(
                            height: 30,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: on
                                    ? const Color(0xFF22222E)
                                    : const Color(0xFF00E5FF),
                                foregroundColor:
                                    on ? Colors.white : Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => AppState.I.toggleFollow(key),
                              child: Text(
                                on ? 'دنبال می‌کنید' : 'دنبال کردن',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF24242F)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'برترین آثار',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          isTag
              ? TagPostsGrid(tag: title)
              : PostGrid(count: 18, offset: title.length % 9),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  String _query = '';
  String _exploreCat = 'all';

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    AppState.I.addListener(_refresh);
  }

  @override
  void dispose() {
    AppState.I.removeListener(_refresh);
    _focus.removeListener(_refresh);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _submit(String q) {
    final String t = q.trim();
    if (t.isEmpty) return;
    AppState.I.addSearch(t);
    _focus.unfocus();
  }

  void _openTopic(String title, IconData icon) {
    _focus.unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TopicScreen(title: title, icon: icon),
      ),
    );
  }

  Widget _empty() => const Center(
        child: Text(
          'نتیجه‌ای یافت نشد',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );

  Widget _exploreOld() {
    final int idx = talentCategories.indexWhere((c) => c['id'] == _exploreCat);
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        categoryChipsRow(
          selected: _exploreCat,
          onSelected: (id) => setState(() => _exploreCat = id),
        ),
        categorySubChipsRow(
          selected: _exploreCat,
          onSelected: (id) => setState(() => _exploreCat = id),
        ),
        PostGrid(count: 30, offset: (idx < 0 ? 0 : idx) * 7),
      ],
    );
  }

  Widget _recent() {
    final List<String> history = AppState.I.searchHistory;
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        if (history.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                const Text(
                  'جستجوهای اخیر',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Spacer(),
                TextButton(
                  onPressed: AppState.I.clearSearchHistory,
                  child: const Text(
                    'پاک کردن همه',
                    style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ...history.map(
          (h) => ListTile(
            dense: true,
            leading: const CubeAvatar(
              radius: 18,
              backgroundColor: Color(0xFF22222E),
              child: Icon(Icons.history, size: 18, color: Colors.grey),
            ),
            title: Text(h, style: const TextStyle(fontSize: 13)),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              onPressed: () => AppState.I.removeSearch(h),
            ),
            onTap: () {
              _controller.text = h;
              setState(() => _query = h);
              _focus.unfocus();
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'پیشنهاد برای شما',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        ...allTalentUsers.take(5).map(
              (u) => UserTile(
                user: u,
                onOpen: () => AppState.I.addSearch(u.username),
              ),
            ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'هشتگ‌های پرطرفدار',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 0,
            children: trendingHashtags
                .map(
                  (t) => ActionChip(
                    backgroundColor: const Color(0xFF1C1C24),
                    label: Text(
                      '#$t',
                      style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () {
                      AppState.I.addSearch('#$t');
                      _openTopic('#$t', Icons.tag);
                    },
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _results(String q) {
    final String lq = q.toLowerCase();
    final String bare = lq.startsWith('#') ? lq.substring(1) : lq;
    final List<TalentUser> users = allTalentUsers
        .where(
          (u) => u.username.toLowerCase().contains(lq) || u.field.contains(q),
        )
        .toList();
    final List<String> tags =
        trendingHashtags.where((t) => t.toLowerCase().contains(bare)).toList();
    final List<Map<String, dynamic>> cats = talentCategories
        .where((c) => c['id'] != 'all' && (c['title'] as String).contains(q))
        .toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Color(0xFF00E5FF),
            labelColor: Color(0xFF00E5FF),
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'افراد'),
              Tab(text: 'هشتگ‌ها'),
              Tab(text: 'صنف‌ها'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                users.isEmpty
                    ? _empty()
                    : ListView(
                        children: users
                            .map(
                              (u) => UserTile(
                                user: u,
                                onOpen: () => AppState.I.addSearch(u.username),
                              ),
                            )
                            .toList(),
                      ),
                tags.isEmpty
                    ? _empty()
                    : ListView(
                        children: tags
                            .map(
                              (t) => ListTile(
                                leading: const CubeAvatar(
                                  backgroundColor: Color(0xFF22222E),
                                  child: Text(
                                    '#',
                                    style: TextStyle(
                                      color: Color(0xFF00E5FF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '#$t',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                subtitle: Text(
                                  '${formatCount(1200 + t.length * 371)} اثر',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                onTap: () {
                                  AppState.I.addSearch('#$t');
                                  _openTopic('#$t', Icons.tag);
                                },
                              ),
                            )
                            .toList(),
                      ),
                cats.isEmpty
                    ? _empty()
                    : ListView(
                        children: cats
                            .map(
                              (c) => ListTile(
                                leading: CubeAvatar(
                                  backgroundColor: const Color(0xFF22222E),
                                  child: Icon(
                                    c['icon'] as IconData,
                                    color: const Color(0xFF00E5FF),
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  c['title'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                onTap: () => _openTopic(
                                  c['title'] as String,
                                  c['icon'] as IconData,
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String q = _query.trim();
    Widget body;
    if (q.isNotEmpty) {
      body = _results(q);
    } else if (_focus.hasFocus) {
      body = _recent();
    } else {
      body = const ExploreFeedBody();
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 12),
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            textDirection: TextDirection.rtl,
            textInputAction: TextInputAction.search,
            onChanged: (v) => setState(() => _query = v),
            onSubmitted: _submit,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'جستجوی افراد، هشتگ و صنف...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: Colors.grey,
              ),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: const Color(0xFF22222E),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}
// ===================== پایان کد جدید پایان بخش =====================
