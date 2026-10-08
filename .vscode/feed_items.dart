part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

const List<List<String>> feedKinds = [
  ['all', 'همه'],
  ['photo', 'عکس'],
  ['short', 'فیلم کوتاه'],
  ['long', 'فیلم بلند'],
];

class FeedItem {
  final String id;
  final String user;
  final String categoryId;
  final String kind; // photo | short | long
  final String image;
  const FeedItem({
    required this.id,
    required this.user,
    required this.categoryId,
    required this.kind,
    required this.image,
  });
  String get thumb => 'https://picsum.photos/seed/$id/300/300';
}

/// محتوای رندوم؛ فقط از صنف/زیرصنف انتخابی (یا همه‌ی صنف‌ها)، هر بار از یک شخص دیگر
List<FeedItem> buildFeedItems({
  String category = 'all',
  String kind = 'all',
  int count = 40,
  int seed = 0,
}) {
  final List<Map<String, dynamic>> pool = CategoryStore.I.selectable
      .where((c) =>
          category == 'all' ||
          category.isEmpty ||
          CategoryStore.I.matches(c['id'] as String, category))
      .toList();
  if (pool.isEmpty) return <FeedItem>[];
  final math.Random r = math.Random(seed * 131 + category.hashCode);
  const List<String> kinds = ['photo', 'short', 'long'];
  final List<FeedItem> out = <FeedItem>[];
  String last = '';
  for (int i = 0; i < count; i++) {
    final Map<String, dynamic> c = pool[r.nextInt(pool.length)];
    String user = last;
    for (int g = 0; g < 6 && user == last; g++) {
      user = 'استعداد_${1 + r.nextInt(60)}';
    }
    last = user;
    final String id = 'fi_${seed}_${category}_$i';
    out.add(FeedItem(
      id: id,
      user: user,
      categoryId: c['id'] as String,
      kind: kind == 'all' ? kinds[r.nextInt(3)] : kind,
      image: 'https://picsum.photos/seed/$id/600/900',
    ));
  }
  return out;
}

// ---------------- ریلز: فیلتر صنف / زیرصنف / نوع محتوا ----------------
class ReelsFeedScreen extends StatefulWidget {
  const ReelsFeedScreen({super.key});
  @override
  State<ReelsFeedScreen> createState() => _ReelsFeedScreenState();
}

class _ReelsFeedScreenState extends State<ReelsFeedScreen> {
  final PageController _pc = PageController();
  int _page = 0;
  int _seed = 0;
  String _cat = 'all';
  String _kind = 'all';
  late List<FeedItem> _items = buildFeedItems(category: _cat, kind: _kind);

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _reload() {
    _seed++;
    setState(() {
      _items = buildFeedItems(category: _cat, kind: _kind, seed: _seed);
      _page = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pc.hasClients) _pc.jumpToPage(0);
    });
  }

  void _go(int d) {
    final int t = _page + d;
    if (t < 0 || t >= _items.length) return;
    _pc.animateToPage(t,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _openFilter() {
    showDarkSheet<void>(
      context,
      (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void pickCat(String id) {
            _cat = id;
            _reload();
            setSheet(() {});
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sheetHandle(),
                  const Text('نوع محتوا',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: feedKinds.map((k) {
                      final bool on = _kind == k[0];
                      return ChoiceChip(
                        label: Text(k[1]),
                        selected: on,
                        selectedColor: const Color(0xFF00E5FF),
                        backgroundColor: const Color(0xFF1C1C24),
                        labelStyle: TextStyle(
                            color: on ? Colors.black : Colors.white,
                            fontSize: 12),
                        onSelected: (_) {
                          _kind = k[0];
                          _reload();
                          setSheet(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('صنف و زیرصنف',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  categoryChipsRow(selected: _cat, onSelected: pickCat),
                  categorySubChipsRow(selected: _cat, onSelected: pickCat),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_items.isEmpty)
            const Center(
              child: Text('محتوایی پیدا نشد',
                  style: TextStyle(color: Colors.white70)),
            )
          else
            PageView.builder(
              controller: _pc,
              scrollDirection: Axis.vertical,
              itemCount: _items.length,
              onPageChanged: (i) {
                setState(() => _page = i);
                if (i >= _items.length - 3) {
                  setState(() => _items.addAll(buildFeedItems(
                      category: _cat,
                      kind: _kind,
                      count: 20,
                      seed: 1000 + _items.length)));
                }
              },
              itemBuilder: (context, i) => ReelItem(
                key: ValueKey<String>(_items[i].id),
                index: i,
                item: _items[i],
                isActive: i == _page,
                followMainTab: true,
                showHeader: false,
                onPrev: i > 0 ? () => _go(-1) : null,
                onNext: i < _items.length - 1 ? () => _go(1) : null,
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Text('ریلز',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(width: 10),
                    ActionChip(
                      avatar: const Icon(Icons.tune,
                          size: 16, color: Color(0xFF00E5FF)),
                      label: Text(
                        '${_cat == 'all' ? 'همه صنف‌ها' : categoryTitleOf(_cat)} • ${feedKinds.firstWhere((k) => k[0] == _kind)[1]}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      backgroundColor: Colors.black54,
                      onPressed: _openFilter,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.photo_camera_outlined,
                          color: Colors.white, size: 26),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ComposeV3(initialType: 'reel'),
                        ),
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

// ---------------- اکسپلور: شبکه‌ی عکس/فیلم صنف انتخابی ----------------
class ExploreFeedBody extends StatefulWidget {
  const ExploreFeedBody({super.key});
  @override
  State<ExploreFeedBody> createState() => _ExploreFeedBodyState();
}

class _ExploreFeedBodyState extends State<ExploreFeedBody> {
  String _cat = 'all';

  @override
  Widget build(BuildContext context) {
    final List<FeedItem> items =
        buildFeedItems(category: _cat, count: 45, seed: 7);
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        categoryChipsRow(
            selected: _cat, onSelected: (id) => setState(() => _cat = id)),
        categorySubChipsRow(
            selected: _cat, onSelected: (id) => setState(() => _cat = id)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final FeedItem it = items[i];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      FeedPagerScreen(items: items, startAt: i, category: _cat),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(it.thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: const Color(0xFF1E1E28))),
                  if (it.kind != 'photo')
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Icon(
                        it.kind == 'long'
                            ? Icons.movie_outlined
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                        shadows: const [
                          Shadow(blurRadius: 6, color: Colors.black54)
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// با کلیک روی یک مورد باز می‌شود؛ کشیدن به بالا = مورد بعدی از یک شخص دیگر (همان صنف)
class FeedPagerScreen extends StatefulWidget {
  final List<FeedItem> items;
  final int startAt;
  final String category;
  const FeedPagerScreen({
    super.key,
    required this.items,
    required this.startAt,
    required this.category,
  });
  @override
  State<FeedPagerScreen> createState() => _FeedPagerScreenState();
}

class _FeedPagerScreenState extends State<FeedPagerScreen> {
  final PageController _pc = PageController();
  late final List<FeedItem> _items =
      List<FeedItem>.of(widget.items.skip(widget.startAt));
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _go(int d) {
    final int t = _page + d;
    if (t < 0 || t >= _items.length) return;
    _pc.animateToPage(t,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pc,
            scrollDirection: Axis.vertical,
            itemCount: _items.length,
            onPageChanged: (i) {
              setState(() => _page = i);
              if (i >= _items.length - 3) {
                setState(() => _items.addAll(buildFeedItems(
                    category: widget.category,
                    count: 20,
                    seed: 2000 + _items.length)));
              }
            },
            itemBuilder: (context, i) => ReelItem(
              key: ValueKey<String>(_items[i].id),
              index: i,
              item: _items[i],
              isActive: i == _page,
              showHeader: false,
              onPrev: i > 0 ? () => _go(-1) : null,
              onNext: i < _items.length - 1 ? () => _go(1) : null,
            ),
          ),
          Positioned(
            top: 0,
            left: 4,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
