part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// پروفایل کامل + ویرایش پروفایل + تنظیمات
// =====================================================================
void openComposeAny(BuildContext context) {
  showSnack(context, 'در حال باز کردن صفحه ثبت اثر...');
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const ComposeV3(initialType: 'post'),
    ),
  );
}

void openComposeAny2(BuildContext context) => openComposeAny(context);

class UserProfileScreen extends StatefulWidget {
  final String username;
  final String talentField;
  final int starsCount;
  final int totalScore;
  final bool isVerified;
  final bool isOwnProfile;

  const UserProfileScreen({
    super.key,
    required this.username,
    required this.talentField,
    required this.starsCount,
    required this.totalScore,
    this.isVerified = false,
    this.isOwnProfile = true,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _tab = 0;
  late String _field;
  String _bio = 'توسعه‌دهنده و فعال در حوزه ساخت و نوآوری سه‌بعدی 🎯';

  bool get _own => widget.isOwnProfile;
  bool get _following => AppState.I.isFollowing(widget.username);
  int get _seed => widget.username.hashCode.abs();
  int get _followers => 1200 + (_seed % 50000) + (_following ? 1 : 0);
  int get _followingCount =>
      _own ? 120 + AppState.I.followingCount : 80 + (_seed % 400);

  List<String> _followersList() {
    final List<String> pool = allTalentUsers
        .map((u) => u.username)
        .where((n) => n != widget.username)
        .toList();
    pool.shuffle(math.Random(_seed));
    final int count = _followers.clamp(0, pool.length).clamp(0, 30);
    return pool.take(count).toList();
  }

  List<String> _followingList() {
    if (_own) return AppState.I._followed.toList();
    final List<String> pool = allTalentUsers
        .map((u) => u.username)
        .where((n) => n != widget.username)
        .toList();
    pool.shuffle(math.Random(_seed + 1));
    final int count = _followingCount.clamp(0, pool.length).clamp(0, 30);
    return pool.take(count).toList();
  }

  void _openFollowList(String title, List<String> usernames) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FollowListScreen(title: title, usernames: usernames),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _field = widget.talentField;
    PostStore.I.addListener(_onApp);
    AppState.I.addListener(_onApp);
  }

  @override
  void dispose() {
    AppState.I.removeListener(_onApp);
    PostStore.I.removeListener(_onApp);
    super.dispose();
  }

  void _onApp() {
    if (mounted) setState(() {});
  }

  void _go(BuildContext ctx, String type) {
    Navigator.pop(ctx);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ComposeV3(initialType: type)),
    );
  }

  Widget _createTile(
    BuildContext ctx,
    Color bg,
    Color fg,
    IconData icon,
    String title,
    String sub,
    String type,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: bg,
        child: Icon(icon, color: fg),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        sub,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      onTap: () => _go(ctx, type),
    );
  }

  void _openCreationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 16),
                const Text(
                  'ایجاد محتوای جدید در باراوی',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _createTile(
                  ctx,
                  const Color(0xFF00E5FF),
                  Colors.black,
                  Icons.grid_on_rounded,
                  'ثبت پست جدید',
                  'انتشار اثر در فید اصلی و صنف‌ها',
                  'post',
                ),
                _createTile(
                  ctx,
                  const Color(0xFFFF0055),
                  Colors.white,
                  Icons.view_in_ar_rounded,
                  'ثبت استوری مکعبی',
                  'افزودن زاویه جدید به مکعب داوری ۲۴ ساعته',
                  'story',
                ),
                _createTile(
                  ctx,
                  const Color(0xFFFFB300),
                  Colors.black,
                  Icons.play_circle_fill,
                  'ثبت ریلز جدید',
                  'ویدیو تمام‌صفحه عمودی برای داوری زنده',
                  'reel',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEdit() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          username: widget.username,
          field: _field,
          bio: _bio,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _field = result['field'] ?? _field;
        _bio = result['bio'] ?? _bio;
      });
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _showImage(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: InteractiveViewer(
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label, {VoidCallback? onTap}) {
    final Widget content = Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
    if (onTap == null) {
      onTap = () {
        if (_own) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const MyWorksScreen()),
          );
        } else {
          setState(() => _tab = 0);
        }
      };
    }
    if (onTap == null) return Expanded(child: content);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InteractiveBaraviCube(
              size: 80,
              totalStories: 4,
              isProfileMode: true,
              seedKey: 'profile_cube_${widget.username}',
              rotationDuration: const Duration(seconds: 10),
            ),
            const SizedBox(width: 12),
            _stat(
                compactCount(
                    _own ? visibleGridPosts().length : 12 + _seed % 60),
                'اثر'),
            _stat(
              compactCount(_followers),
              'دنبال‌کننده',
              onTap: () => _openFollowList('دنبال‌کننده‌ها', _followersList()),
            ),
            _stat(
              compactCount(_followingCount),
              'دنبال‌شونده',
              onTap: () => _openFollowList('دنبال‌شونده‌ها', _followingList()),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              widget.username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 6),
            if (widget.username.isNotEmpty)
              tickBadges(widget.username, size: 18),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            5,
            (i) => Icon(
              Icons.star,
              size: 16,
              color: i < widget.starsCount
                  ? const Color(0xFFFFB300)
                  : Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'صنف تخصصی: ${guildPathByTitle(_field)}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(_bio, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 12),
        _scoreBar(),
        const SizedBox(height: 14),
        _actionButtons(),
      ],
    );
  }

  Widget _scoreBar() {
    final double v = (widget.totalScore / 600000).clamp(0.0, 1.0).toDouble();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF282836)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مجموع امتیاز داوری: ${formatCount(widget.totalScore)}',
            style: const TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 6,
              backgroundColor: const Color(0xFF282836),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    if (_own) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF3A3A4A)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _openEdit,
              child: const Text(
                'ویرایش پروفایل',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E2A),
                foregroundColor: const Color(0xFF00E5FF),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF00E5FF), width: 0.8),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text(
                'ثبت اثر',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () => openComposeAny2(context),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _following
                  ? const Color(0xFF2A2A36)
                  : const Color(0xFF00E5FF),
              foregroundColor: _following ? Colors.white : Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => AppState.I.toggleFollow(widget.username),
            child: Text(
              _following ? 'دنبال می‌کنید' : 'دنبال کردن',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF3A3A4A)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              openDirectMessage(
                context,
                widget.username,
                const SnackBar(
                    content: Text('پیام مستقیم در مرحله ۹ اضافه می‌شود')),
              );
            },
            child: const Text(
              'پیام',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabBar() {
    final List<IconData> icons = [
      Icons.grid_on_rounded,
      Icons.play_circle_outline,
      Icons.bookmark_border,
    ];
    return Row(
      children: List.generate(icons.length, (i) {
        final bool sel = _tab == i;
        return Expanded(
          child: InkWell(
            onTap: () => setState(() => _tab = i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: sel ? const Color(0xFF00E5FF) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Icon(
                icons[i],
                size: 24,
                color: sel ? const Color(0xFF00E5FF) : Colors.grey,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _grid(int count, String prefix, {bool reel = false}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        childAspectRatio: reel ? 9 / 14 : 1,
      ),
      itemCount: count,
      itemBuilder: (context, i) {
        final String url = reel
            ? 'https://picsum.photos/seed/${prefix}_$i/300/500'
            : 'https://picsum.photos/seed/${prefix}_$i/300/300';
        return GestureDetector(
          onTap: () => _showImage(url),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(url, fit: BoxFit.cover),
              if (reel)
                const Positioned(
                  left: 6,
                  bottom: 6,
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabContent() {
    if (_tab == 0) {
      return _own ? const MyPostsGrid() : _grid(12, '${widget.username}_post');
    }
    if (_tab == 1) return _grid(6, '${widget.username}_reel', reel: true);
    if (!_own) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            'موارد ذخیره‌شده فقط برای خود کاربر قابل مشاهده است 🔒',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }
    return const SavedInline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        actions: [
          if (_own)
            IconButton(
              icon: const Icon(
                Icons.add_box_outlined,
                size: 26,
                color: Color(0xFF00E5FF),
              ),
              onPressed: () => openComposeAny(context),
            ),
          if (_own)
            IconButton(
              icon: const Icon(Icons.settings_outlined, size: 24),
              onPressed: _openSettings,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 14),
            ProfileHighlights(username: widget.username, isOwn: _own),
            const Divider(color: Color(0xFF282836), height: 1),
            _tabBar(),
            const SizedBox(height: 4),
            _tabContent(),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String field;
  final String bio;
  const EditProfileScreen({
    super.key,
    required this.username,
    required this.field,
    required this.bio,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _field = TextEditingController(
    text: widget.field,
  );
  late final TextEditingController _bio = TextEditingController(
    text: widget.bio,
  );

  @override
  void dispose() {
    _field.dispose();
    _bio.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFF16161F),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickCubeImage(int slot, void Function() refresh) async {
    try {
      final XFile? f = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        imageQuality: 80,
      );
      if (f == null) return;
      final Uint8List b = await f.readAsBytes();
      ProfileCubeImages.I.set(widget.username, slot, b);
      refresh();
    } catch (_) {
      if (mounted) showSnack(context, 'انتخاب عکس ممکن نشد');
    }
  }

  void _openCubePicker() {
    showDarkSheet<void>(
      context,
      (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  sheetHandle(),
                  const Text(
                    'عکس‌های مکعب پروفایل (۴ عکس)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, i) {
                      final int slot = i + 1;
                      final Uint8List? b =
                          ProfileCubeImages.I.of(widget.username, slot);
                      return GestureDetector(
                        onTap: () =>
                            _pickCubeImage(slot, () => setSheetState(() {})),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF2C2C3A)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: b != null
                              ? Image.memory(b, fit: BoxFit.cover)
                              : Container(
                                  color: const Color(0xFF16161F),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: Color(0xFF00E5FF),
                                      size: 28,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
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
      appBar: AppBar(
        title: const Text('ویرایش پروفایل'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, <String, String>{
                'field': _field.text.trim(),
                'bio': _bio.text.trim(),
              });
            },
            child: const Text(
              'ذخیره',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _openCubePicker,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  InteractiveBaraviCube(
                    size: 90,
                    totalStories: 4,
                    isProfileMode: true,
                    seedKey: 'profile_cube_${widget.username}',
                    rotationDuration: const Duration(seconds: 10),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E5FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: TextEditingController(text: widget.username),
            enabled: false,
            decoration: _dec('نام کاربری (غیرقابل تغییر)'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _field,
            textDirection: TextDirection.rtl,
            enabled: false,
            decoration: _dec('صنف تخصصی (غیرقابل تغییر)'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _bio,
            textDirection: TextDirection.rtl,
            maxLines: 4,
            maxLength: 150,
            decoration: _dec('بیوگرافی'),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// صفحه‌ی لیست دنبال‌کننده‌ها / دنبال‌شونده‌ها
// ===================================================================
class FollowListScreen extends StatefulWidget {
  final String title;
  final List<String> usernames;

  const FollowListScreen({
    super.key,
    required this.title,
    required this.usernames,
  });

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  @override
  void initState() {
    super.initState();
    AppState.I.addListener(_onApp);
  }

  @override
  void dispose() {
    AppState.I.removeListener(_onApp);
    PostStore.I.removeListener(_onApp);
    super.dispose();
  }

  void _onApp() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: widget.usernames.isEmpty
          ? const Center(
              child: Text(
                'کسی یافت نشد',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          : ListView.builder(
              itemCount: widget.usernames.length,
              itemBuilder: (context, i) {
                final String name = widget.usernames[i];
                final bool following = AppState.I.isFollowing(name);
                return ListTile(
                  leading: CubeAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(avatarUrl(name)),
                  ),
                  title: Row(children: [
                    Flexible(
                      child: Text(name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(width: 4),
                    tickBadges(name, size: 13),
                  ]),
                  trailing: name == kMyUsername
                      ? null
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: following
                                ? const Color(0xFF2A2A36)
                                : const Color(0xFF00E5FF),
                            foregroundColor:
                                following ? Colors.white : Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            minimumSize: const Size(0, 32),
                          ),
                          onPressed: () => AppState.I.toggleFollow(name),
                          child: Text(
                            following ? 'دنبال می‌کنید' : 'دنبال کردن',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      starsRow(name),
                      Text(guildPathByTitle(userByName(name).field),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  onTap: () => openUserByName(context, name),
                );
              },
            ),
    );
  }
}
