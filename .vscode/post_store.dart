part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// منوی + اینستاگرامی | ثبت پست واقعی | آثار من | ورود
// =====================================================================
class UserPost {
  final String id;
  final String type;
  final String category;
  final String caption;
  final String time;
  final int imageSeed;
  int likes;
  bool liked;
  bool saved;
  final List<PostComment> comments;
  UserPost({
    required this.id,
    required this.type,
    required this.category,
    required this.caption,
    required this.time,
    required this.imageSeed,
    this.likes = 0,
    this.liked = false,
    this.saved = false,
    List<PostComment>? comments,
  }) : comments = comments ?? <PostComment>[];
}

class PostStore extends ChangeNotifier {
  PostStore._();
  static final PostStore I = PostStore._();

  final List<UserPost> posts = <UserPost>[];
  int _n = 0;

  List<UserPost> get saved => posts.where((p) => p.saved).toList();

  UserPost add({
    required String type,
    required String category,
    required String caption,
    required int imageSeed,
  }) {
    _n++;
    final UserPost p = UserPost(
      id: 'mypost_$_n',
      type: type,
      category: category,
      caption: caption,
      time: nowTime(),
      imageSeed: imageSeed,
    );
    posts.insert(0, p);
    notifyListeners();
    return p;
  }

  void remove(UserPost p) {
    posts.remove(p);
    JudgeState.I.clearScore(p.id);
    notifyListeners();
  }

  void toggleLike(UserPost p) {
    p.liked = !p.liked;
    p.likes += p.liked ? 1 : -1;
    notifyListeners();
  }

  void toggleSave(UserPost p) {
    p.saved = !p.saved;
    notifyListeners();
  }

  void touch() => notifyListeners();
}

String typeTitle(String t) {
  switch (t) {
    case 'story':
      return 'استوری';
    case 'reel':
      return 'ریلز';
    default:
      return 'پست';
  }
}

IconData typeIcon(String t) {
  switch (t) {
    case 'story':
      return Icons.view_in_ar_rounded;
    case 'reel':
      return Icons.play_circle_outline;
    default:
      return Icons.grid_on_rounded;
  }
}

// ---------------------------------------------------------------------
// منوی کوچک « + » شبیه اینستاگرام
// ---------------------------------------------------------------------
Widget _createMenuRow(
  BuildContext ctx,
  BuildContext root,
  IconData icon,
  String title,
  Widget Function() page,
) {
  return InkWell(
    onTap: () {
      Navigator.pop(ctx);
      Navigator.push(root, MaterialPageRoute(builder: (_) => page()));
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Icon(icon, size: 22, color: Colors.white),
        ],
      ),
    ),
  );
}

void showCreateMenu2(BuildContext context) {
  final NavigatorState nav = Navigator.of(context);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF16161F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      Widget row(IconData icon, String title, String type) {
        return ListTile(
          leading: Icon(icon, color: const Color(0xFF00E5FF)),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          onTap: () {
            Navigator.pop(ctx);
            nav.push(
              MaterialPageRoute<void>(
                builder: (_) => type == 'works'
                    ? const MyWorksScreen()
                    : ComposeV3(initialType: type),
              ),
            );
          },
        );
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              row(Icons.play_circle_outline, 'ریلز', 'reel'),
              row(Icons.grid_on_rounded, 'پست', 'post'),
              row(Icons.view_in_ar_rounded, 'استوری مکعبی', 'story'),
              row(Icons.collections_outlined, 'آثار من', 'works'),
            ],
          ),
        ),
      );
    },
  );
}

void showCreateMenu(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black26,
    builder: (ctx) {
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 60, right: 10),
          child: Material(
            color: const Color(0xFF262630),
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _createMenuRow(ctx, context, Icons.play_circle_outline,
                      'ریلز', () => const ComposeV3(initialType: 'reel')),
                  const Divider(height: 1, color: Color(0xFF3A3A48)),
                  _createMenuRow(ctx, context, Icons.grid_on_rounded, 'پست',
                      () => const ComposeV3(initialType: 'post')),
                  const Divider(height: 1, color: Color(0xFF3A3A48)),
                  _createMenuRow(
                      ctx,
                      context,
                      Icons.view_in_ar_rounded,
                      'استوری مکعبی',
                      () => const ComposeV3(initialType: 'story')),
                  const Divider(height: 1, color: Color(0xFF3A3A48)),
                  _createMenuRow(ctx, context, Icons.collections_outlined,
                      'آثار من', () => const MyWorksScreen()),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
