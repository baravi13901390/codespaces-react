part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// ---------------------------------------------------------------------
// آثار من + ذخیره‌شده‌ها
// ---------------------------------------------------------------------
class MyWorksScreen extends StatelessWidget {
  const MyWorksScreen({super.key});

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

  Widget _list(List<UserPost> items, String emptyText) {
    if (items.isEmpty) return _empty(emptyText);
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, i) => WorkCard2(post: items[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('آثار من'),
          bottom: const TabBar(
            indicatorColor: Color(0xFF00E5FF),
            labelColor: Color(0xFF00E5FF),
            tabs: [Tab(text: 'منتشرشده'), Tab(text: 'ذخیره‌شده')],
          ),
        ),
        body: AnimatedBuilder(
          animation: PostStore.I,
          builder: (context, _) {
            return TabBarView(
              children: [
                _list(PostStore.I.posts,
                    'هنوز اثری منتشر نکرده‌اید.\nاز دکمه + یک اثر جدید بسازید ✨'),
                _list(PostStore.I.saved, 'هنوز اثری ذخیره نکرده‌اید 🔖'),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// کارت اثر (نسخه جدید با عکس واقعی)
// ---------------------------------------------------------------------
class WorkCard2 extends StatelessWidget {
  final UserPost post;
  const WorkCard2({super.key, required this.post});

  Widget _act(IconData icon, VoidCallback onTap, {Color c = Colors.white}) {
    int? n;
    if (icon == Icons.favorite || icon == Icons.favorite_border) {
      n = post.likes;
    } else if (icon == Icons.chat_bubble_outline) {
      n = post.comments.fold<int>(0, (s, x) => s + 1 + x.replies.length);
    } else if (icon == Icons.share_outlined) {
      n = kShareCounts[post.id] ?? 0;
    } else if (icon == Icons.bookmark || icon == Icons.bookmark_border) {
      n = post.saved ? 1 : 0;
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
              kShareCounts[post.id] = (kShareCounts[post.id] ?? 0) + 1;
              PostStore.I.touch();
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

  int get _commentCount =>
      post.comments.fold<int>(0, (s, c) => s + 1 + c.replies.length);

  Widget _image() {
    final Uint8List? b = PostImages.of(post.id);
    if (b != null) {
      return Image.memory(b, fit: BoxFit.cover, width: double.infinity);
    }
    return Image.network(
      'https://picsum.photos/seed/my_work_${post.imageSeed}/600/600',
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String catTitle = talentCategories.firstWhere(
      (c) => c['id'] == post.category,
      orElse: () => talentCategories[1],
    )['title'] as String;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF14141A),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CubeAvatar(
              backgroundImage: NetworkImage(avatarUrl(kMyUsername)),
            ),
            title: Text(
              kMyUsername,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              '$catTitle • ${post.time}',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            trailing: PopupMenuButton<String>(
              color: const Color(0xFF262630),
              onSelected: (v) {
                if (v == 'del') {
                  PostImages.remove(post.id);
                  PostStore.I.remove(post);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem<String>(value: 'del', child: Text('حذف اثر')),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(typeIcon(post.type), size: 18, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    typeTitle(post.type),
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onDoubleTap: () {
              if (!post.liked) PostStore.I.toggleLike(post);
            },
            child: AspectRatio(
              aspectRatio: post.type == 'post' ? 1 : 4 / 5,
              child: _image(),
            ),
          ),
          Row(
            children: [
              _act(
                post.liked ? Icons.favorite : Icons.favorite_border,
                () => PostStore.I.toggleLike(post),
                c: post.liked ? const Color(0xFFFF0055) : Colors.white,
              ),
              _act(
                Icons.chat_bubble_outline,
                () => showCommentsSheet(
                  context,
                  post.comments,
                  onChanged: PostStore.I.touch,
                ),
              ),
              _act(Icons.share_outlined, () => shareMyPost(context, post)),
              const Spacer(),
              _act(
                post.saved ? Icons.bookmark : Icons.bookmark_border,
                () => saveWithCollections(context, post),
                c: post.saved ? const Color(0xFFFFB300) : Colors.white,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '${compactCount(post.likes)} پسند • ${compactCount(_commentCount)} نظر',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  children: richTextSpans(post.caption),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: JudgeScoreBar(workId: post.id),
          ),
        ],
      ),
    );
  }
}
