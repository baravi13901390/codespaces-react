part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const TalentLeaderboardScreen(),
    const GuildTournamentScreen(),
    const ComposeV3(initialType: 'post'),
    const ReelsFeedScreen(),
    const SearchScreen(),
    UserProfileScreen(
      username: 'baran_director',
      talentField: AppState.I.myField.isEmpty
          ? 'صنعت و هنر'
          : categoryTitleOf(AppState.I.myField),
      starsCount: 5,
      totalScore: 542000,
      isVerified: true,
      isOwnProfile: true,
    ),
  ];

  void _handleTournamentTap() {
    setState(() => _selectedIndex = 2);
    if (kMyStars == 5) {
      final bool alreadyJoined = TournamentStore.I.roomOfMe() != null;
      final CompetitionRoom room = TournamentStore.I.joinRandomRoom();
      if (!alreadyJoined) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showGuildWelcome(context, room);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF282832), width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 2) {
              _handleTournamentTap();
            } else {
              setState(() => _selectedIndex = index);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF14141A),
          selectedItemColor: const Color(0xFF00E5FF),
          unselectedItemColor: Colors.grey.shade600,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined, size: 26),
              activeIcon: Icon(Icons.dashboard, size: 26),
              label: 'فید صنف‌ها',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined, size: 26),
              activeIcon: Icon(Icons.emoji_events, size: 26),
              label: 'جدول استعدادها',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.military_tech_outlined, size: 26),
              activeIcon: Icon(Icons.military_tech, size: 26),
              label: 'مسابقات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 30),
              activeIcon: Icon(Icons.add_circle, size: 30),
              label: 'ارسال اثر',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline, size: 26),
              activeIcon: Icon(Icons.play_circle_filled, size: 26),
              label: 'ریلز داوری',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded, size: 26),
              activeIcon: Icon(Icons.search_rounded, size: 26),
              label: 'اکسپلور',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 26),
              activeIcon: Icon(Icons.person, size: 26),
              label: 'پروفایل داوری',
            ),
          ],
        ),
      ),
    );
  }
}

int kFeedShift = 0;
final Map<String, int> kShareCounts = <String, int>{};
int hallBase(String id, int mod) => 5 + (id.hashCode.abs() % mod);

class CountIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;
  final int count;
  const CountIcon(this.icon,
      {super.key, this.color, this.size, this.count = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: size),
        const SizedBox(width: 4),
        Text(
          compactCount(count),
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Baravi',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: 1.2,
                color: Color(0xFF00E5FF),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF0055).withAlpha(51),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFF0055), width: 0.8),
              ),
              child: const Text(
                'TALENT HUB',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF0055),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const SizedBox.shrink(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 1, height: 1),
            onPressed: () {
              // باز شدن صفحه جستجو و اکسپلور
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
        ],
      ),
      body: _pullWrap(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildCategoryFilter(),
          AnimatedBuilder(
            animation: AppState.I,
            builder: (context, _) => CubeStorySection(
              key: ValueKey<String>(
                  'cube_${kFeedShift}_${AppState.I.followingCount}_$_selectedCategory'),
              category: _selectedCategory,
            ),
          ),
          const Divider(height: 1, color: Color(0xFF24242F)),
          // نوار «استعداد فلان» زیر استوری‌ها
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: allTalentUsers.length,
              itemBuilder: (ctx, i) {
                final TalentUser u = allTalentUsers[i];
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ActionChip(
                    avatar: CubeAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF1E1E28),
                      backgroundImage: NetworkImage(avatarUrl(u.username)),
                      onBackgroundImageError: (_, __) {},
                    ),
                    label: Text(u.username, style: const TextStyle(fontSize: 11)),
                    backgroundColor: const Color(0xFF1C1C24),
                    onPressed: () {
                      // کلیک روی استعداد → حالت اکسپلور
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SearchScreen(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFF24242F)),
          MyFeedPosts(
              key: ValueKey<String>('my_$kFeedShift'),
              selectedCategory: _selectedCategory),
          PostList(
              key: ValueKey<String>('pl_$kFeedShift'),
              selectedCategory: _selectedCategory),
        ],
      ),
    );
  }

  Widget _pullWrap({
    required ScrollPhysics physics,
    required List<Widget> children,
  }) {
    return RefreshIndicator(
      color: const Color(0xFF00E5FF),
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (mounted) setState(() => kFeedShift++);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: children,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      children: [
        categoryChipsRow(
          selected: _selectedCategory,
          onSelected: (id) => setState(() => _selectedCategory = id),
        ),
        categorySubChipsRow(
          selected: _selectedCategory,
          onSelected: (id) => setState(() => _selectedCategory = id),
        ),
      ],
    );
  }
}
