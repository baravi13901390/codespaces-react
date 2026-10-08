part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// ===== ابزار کمکی: جدا کردن سه‌رقم‌های عدد (مثلاً 1,240) =====
String formatCount(int n) {
  final String s = n.toString();
  final StringBuffer buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
// ===== پایان ابزار کمکی پایان بخش =====

// =====================================================================
// نظرات (کد جدید)
// - مدل نظر با پاسخ‌های تو در تو
// - پنجره نظرات: پاسخ به نظر، لایک نظر، حذف نظر خودت
// - این پنجره برای پست‌ها و ریلز مشترکه
// =====================================================================
const String kMyUsername = 'baran_director';

class PostComment {
  final String author;
  final String text;
  final String time;
  final bool isMine;
  bool liked;
  int likes;
  bool showReplies;
  final List<PostComment> replies;

  PostComment({
    required this.author,
    required this.text,
    this.time = 'الان',
    this.isMine = false,
    this.liked = false,
    this.likes = 0,
    this.showReplies = false,
    List<PostComment>? replies,
  }) : replies = replies ?? <PostComment>[];
}

List<InlineSpan> richTextSpans(String text) {
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

List<PostComment> seedComments(int seed) {
  return [
    PostComment(
      author: 'داور_${seed + 1}',
      text: 'واقعاً کار بی‌نظیری بود! تسلط بالایی داری 👏',
      time: '۱ ساعت پیش',
      likes: 12,
      replies: [
        PostComment(
          author: 'استعداد_${seed + 1}',
          text: '@داور_${seed + 1} ممنون از لطفت 🙏',
          time: '۵۰ دقیقه پیش',
          likes: 3,
        ),
      ],
    ),
    PostComment(
      author: 'داور_${seed + 2}',
      text: 'کیفیت اجرای قطعه عالی بود، نمره من ۱۰۰!',
      time: '۲ ساعت پیش',
      likes: 5,
    ),
  ];
}

Future<void> showCommentsSheet(
  BuildContext context,
  List<PostComment> comments, {
  VoidCallback? onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF16161F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => CommentsSheet(comments: comments, onChanged: onChanged),
  );
}

class CommentsSheet extends StatefulWidget {
  final List<PostComment> comments;
  final VoidCallback? onChanged;
  const CommentsSheet({super.key, required this.comments, this.onChanged});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _input = TextEditingController();
  final FocusNode _focus = FocusNode();
  PostComment? _replyTarget;
  PostComment? _replyParent;

  int get _total =>
      widget.comments.fold<int>(0, (sum, c) => sum + 1 + c.replies.length);

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    widget.onChanged?.call();
  }

  void _startReply(PostComment target, PostComment parent) {
    setState(() {
      _replyTarget = target;
      _replyParent = parent;
    });
    _input.text = '@${target.author} ';
    _input.selection = TextSelection.collapsed(offset: _input.text.length);
    _focus.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyTarget = null;
      _replyParent = null;
    });
    _input.clear();
  }

  void _send() {
    final String text = _input.text.trim();
    if (text.isEmpty) return;
    final PostComment c = PostComment(
      author: kMyUsername,
      text: text,
      isMine: true,
    );
    if (_replyParent != null) {
      _replyParent!.replies.add(c);
      _replyParent!.showReplies = true;
    } else {
      widget.comments.add(c);
    }
    _input.clear();
    _replyTarget = null;
    _replyParent = null;
    _changed();
  }

  Future<void> _confirmDelete(PostComment c, List<PostComment> owner) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        title: const Text(
          'حذف نظر',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'این نظر برای همیشه حذف می‌شود. مطمئنید؟',
          style: TextStyle(fontSize: 13, color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dctx, true),
            child: const Text(
              'حذف',
              style: TextStyle(color: Color(0xFFFF5252)),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      owner.remove(c);
      _changed();
    }
  }

  Widget _tile(
    PostComment c, {
    required PostComment parent,
    required List<PostComment> owner,
    bool isReply = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 6, bottom: 6, left: isReply ? 12 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 11 : 14,
            backgroundColor: const Color(0xFF242432),
            child: Icon(
              Icons.person,
              size: isReply ? 13 : 16,
              color: const Color(0xFF00E5FF),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F2B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.author,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color:
                              c.isMine ? const Color(0xFF00E5FF) : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          children: richTextSpans(c.text),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: Row(
                    children: [
                      Text(
                        c.time,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _startReply(c, parent),
                        child: const Text(
                          'پاسخ',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (c.likes > 0) ...[
                        const SizedBox(width: 12),
                        Text(
                          '${c.likes} پسند',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      if (c.isMine) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _confirmDelete(c, owner),
                          child: const Text(
                            'حذف',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFF5252),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isReply && c.replies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => c.showReplies = !c.showReplies),
                      child: Text(
                        c.showReplies
                            ? 'پنهان کردن پاسخ‌ها'
                            : 'مشاهده ${c.replies.length} پاسخ',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF00E5FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (!isReply && c.showReplies)
                  ...c.replies.map(
                    (r) => _tile(r, parent: c, owner: c.replies, isReply: true),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                c.liked = !c.liked;
                c.likes += c.liked ? 1 : -1;
              });
              widget.onChanged?.call();
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 10),
              child: Icon(
                c.liked ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: c.liked ? const Color(0xFFFF0055) : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SizedBox(
        height: 460,
        child: Column(
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
            Text(
              'نظرات داوران و کاربران ($_total)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const Divider(color: Color(0xFF282836), height: 20),
            Expanded(
              child: widget.comments.isEmpty
                  ? const Center(
                      child: Text(
                        'هنوز نظری ثبت نشده است. اولین نظر را شما بنویسید!',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.comments.length,
                      itemBuilder: (ctx, i) => _tile(
                        widget.comments[i],
                        parent: widget.comments[i],
                        owner: widget.comments,
                      ),
                    ),
            ),
            if (_replyTarget != null)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F2B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'در حال پاسخ به ${_replyTarget!.author}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      focusNode: _focus,
                      textDirection: TextDirection.rtl,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'نظر داوری خود را بنویسید...',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF22222E),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.send_rounded, size: 20),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ===================== پایان کد جدید پایان بخش =====================

// =====================================================================
// کدهای مشترک جدید: عدد فشرده، وضعیت کل برنامه، پنجره اشتراک‌گذاری
// =====================================================================
String compactCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

/// وضعیت مشترک برنامه (بین همه صفحه‌ها هماهنگ می‌مونه).
/// در قدم‌های بعدی چیزای بیشتری بهش اضافه می‌شه.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState I = AppState._();

  final Set<String> _followed = <String>{};
  bool isFollowing(String username) => _followed.contains(username);
  int get followingCount => _followed.length;
  void toggleFollow(String username) {
    if (!_followed.remove(username)) _followed.add(username);
    notifyListeners();
  }

  // سابقه جستجو
  final List<String> searchHistory = <String>[];
  void addSearch(String q) {
    searchHistory.remove(q);
    searchHistory.insert(0, q);
    if (searchHistory.length > 10) searchHistory.removeLast();
    notifyListeners();
  }

  void removeSearch(String q) {
    searchHistory.remove(q);
    notifyListeners();
  }

  void clearSearchHistory() {
    searchHistory.clear();
    notifyListeners();
  }

  // [بند ۵] صنف تخصصی کاربر (انتخاب‌شده موقع ثبت‌نام)
  String myField = '';
  void setMyField(String id) {
    myField = id;
    notifyListeners();
  }
}

Widget _shareActionItem({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withAlpha(51),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    ),
  );
}

/// همون پنجره اشتراک‌گذاری قبلی (ظاهر بدون تغییر) که حالا برای پست و ریلز مشترکه
void showShareSheetOld(BuildContext context, {VoidCallback? onSaved}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16161F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext ctx) {
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
                'اشتراک‌گذاری اثر استعدادیابی',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _shareActionItem(
                    icon: Icons.link,
                    label: 'کپی لینک',
                    color: const Color(0xFF00E5FF),
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لینک اثر با موفقیت کپی شد! 🔗'),
                        ),
                      );
                    },
                  ),
                  _shareActionItem(
                    icon: Icons.send,
                    label: 'ارسال مستقیم',
                    color: const Color(0xFFFF0055),
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('به لیست مخاطبان ارسال شد! 🚀'),
                        ),
                      );
                    },
                  ),
                  _shareActionItem(
                    icon: Icons.bookmark_border,
                    label: 'ذخیره اثر',
                    color: const Color(0xFFFFB300),
                    onTap: () {
                      Navigator.pop(ctx);
                      onSaved?.call();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('در لیست ذخیره‌شده‌ها قرار گرفت! ⭐️'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ===================== پایان کدهای مشترک پایان بخش =====================
// ---------------------------------------------------------------------
// نمایش تمام‌صفحه‌ی عکس یک پست با دبل‌کلیک: زوم + تپ راست/چپ برای جلو/عقب
// ---------------------------------------------------------------------
class PostPhotoViewerScreen extends StatefulWidget {
  final List<Widget> images;
  final List<Widget>? Function(int step)? nextPost;
  final int initialIndex;
  const PostPhotoViewerScreen({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.nextPost,
  });

  @override
  State<PostPhotoViewerScreen> createState() => _PostPhotoViewerScreenState();
}

class _PostPhotoViewerScreenState extends State<PostPhotoViewerScreen> {
  late int _index;
  late List<Widget> _images = widget.images;
  int _step = 0;

  void _swipeUpNext() {
    final List<Widget>? l = widget.nextPost?.call(_step + 1);
    if (l == null || l.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پست بعدی‌ای نیست')),
      );
      return;
    }
    setState(() {
      _step++;
      _images = l;
      _index = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _goNext() {
    if (_index < _images.length - 1) {
      setState(() => _index++);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _goPrev() {
    if (_index > 0) setState(() => _index--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) {
              final double w = MediaQuery.of(context).size.width;
              if (d.globalPosition.dx < w * 0.33) {
                _goPrev();
              } else {
                _goNext();
              }
            },
            onVerticalDragEnd: (d) {
              if ((d.primaryVelocity ?? 0) < -400) {
                _swipeUpNext();
              }
              if ((d.primaryVelocity ?? 0) > 400) {
                Navigator.of(context).maybePop();
              }
            },
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(child: _images[_index]),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: List<Widget>.generate(_images.length, (i) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i <= _index ? Colors.white : Colors.white30,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
