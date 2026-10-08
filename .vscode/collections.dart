part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// مجموعه‌های ذخیره (Collections) شبیه اینستاگرام
// =====================================================================
class SavedItem {
  final String id;
  final String url;
  final String title;
  const SavedItem({required this.id, required this.url, required this.title});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'url': url,
        'title': title,
      };

  static SavedItem fromJson(Map<String, dynamic> m) => SavedItem(
        id: m['id'] as String,
        url: m['url'] as String,
        title: m['title'] as String,
      );
}

class SavedCollection {
  final String id;
  String name;
  final List<SavedItem> items;
  SavedCollection({
    required this.id,
    required this.name,
    List<SavedItem>? items,
  }) : items = items ?? <SavedItem>[];
}

class CollectionStore extends ChangeNotifier {
  CollectionStore._();
  static final CollectionStore I = CollectionStore._();

  final List<SavedCollection> collections = <SavedCollection>[];
  final List<SavedItem> allSaved = <SavedItem>[];
  int _n = 0;
  bool _listening = false;

  bool isSaved(String id) => allSaved.any((x) => x.id == id);

  bool inCollection(SavedCollection c, String id) =>
      c.items.any((x) => x.id == id);

  void saveItem(SavedItem it) {
    if (!isSaved(it.id)) allSaved.insert(0, it);
    notifyListeners();
  }

  void unsave(String id) {
    allSaved.removeWhere((x) => x.id == id);
    for (final SavedCollection c in collections) {
      c.items.removeWhere((x) => x.id == id);
    }
    for (final UserPost p in PostStore.I.posts) {
      if (p.id == id && p.saved) {
        p.saved = false;
        PostStore.I.touch();
      }
    }
    notifyListeners();
  }

  SavedCollection createCollection(String name) {
    _n++;
    final SavedCollection c = SavedCollection(id: 'col_$_n', name: name);
    collections.add(c);
    notifyListeners();
    return c;
  }

  void rename(SavedCollection c, String name) {
    c.name = name;
    notifyListeners();
  }

  void deleteCollection(SavedCollection c) {
    collections.remove(c);
    notifyListeners();
  }

  void toggleInCollection(SavedCollection c, SavedItem it) {
    if (inCollection(c, it.id)) {
      c.items.removeWhere((x) => x.id == it.id);
    } else {
      c.items.insert(0, it);
      if (!isSaved(it.id)) allSaved.insert(0, it);
    }
    notifyListeners();
  }

  Future<void> load() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      final String? raw = p.getString('baravi_collections');
      if (raw != null) {
        final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
        _n = (m['n'] as num).toInt();
        for (final dynamic e in m['all'] as List<dynamic>) {
          allSaved.add(SavedItem.fromJson(e as Map<String, dynamic>));
        }
        for (final dynamic e in m['cols'] as List<dynamic>) {
          final Map<String, dynamic> cm = e as Map<String, dynamic>;
          collections.add(
            SavedCollection(
              id: cm['id'] as String,
              name: cm['name'] as String,
              items: (cm['items'] as List<dynamic>)
                  .map((x) => SavedItem.fromJson(x as Map<String, dynamic>))
                  .toList(),
            ),
          );
        }
      }
    } catch (_) {}
    if (!_listening) {
      _listening = true;
      addListener(_save);
    }
  }

  void _save() {
    final SharedPreferences? p = Persist._p;
    if (p == null) return;
    try {
      p.setString(
        'baravi_collections',
        jsonEncode(<String, dynamic>{
          'n': _n,
          'all': allSaved.map((x) => x.toJson()).toList(),
          'cols': collections
              .map(
                (c) => <String, dynamic>{
                  'id': c.id,
                  'name': c.name,
                  'items': c.items.map((x) => x.toJson()).toList(),
                },
              )
              .toList(),
        }),
      );
    } catch (_) {}
  }
}

Widget savedThumb(String url) {
  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      color: const Color(0xFF1E1E28),
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    ),
  );
}

Future<String?> askCollectionName(BuildContext context, {String initial = ''}) {
  final TextEditingController c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E28),
      title: const Text('نام مجموعه'),
      content: TextField(
        controller: c,
        autofocus: true,
        textDirection: TextDirection.rtl,
        decoration: const InputDecoration(hintText: 'مثلاً: موسیقی‌ها'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('انصراف'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, c.text.trim()),
          child: const Text(
            'تأیید',
            style: TextStyle(color: Color(0xFF00E5FF)),
          ),
        ),
      ],
    ),
  );
}

// پنجره انتخاب مجموعه بعد از ذخیره
void showCollectionPicker(BuildContext context, SavedItem item) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF16161F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return AnimatedBuilder(
        animation: CollectionStore.I,
        builder: (_, __) {
          final List<SavedCollection> cols = CollectionStore.I.collections;
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.7,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                      'ذخیره شد ✅',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'می‌خواهید در یک مجموعه قرار بگیرد؟',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final SavedCollection c in cols)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: SizedBox(
                                width: 44,
                                height: 44,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: c.items.isEmpty
                                      ? Container(
                                          color: const Color(0xFF1E1E28),
                                          child: const Icon(
                                            Icons.folder_open,
                                            size: 22,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : savedThumb(c.items.first.url),
                                ),
                              ),
                              title: Text(c.name),
                              subtitle: Text(
                                '${c.items.length} مورد',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              trailing: Icon(
                                CollectionStore.I.inCollection(c, item.id)
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color:
                                    CollectionStore.I.inCollection(c, item.id)
                                        ? const Color(0xFF00E5FF)
                                        : Colors.grey,
                              ),
                              onTap: () =>
                                  CollectionStore.I.toggleInCollection(c, item),
                            ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF00E5FF),
                              child: Icon(Icons.add, color: Colors.black),
                            ),
                            title: const Text('مجموعه جدید'),
                            onTap: () async {
                              final String? n = await askCollectionName(ctx);
                              if (n != null && n.isNotEmpty) {
                                final SavedCollection c =
                                    CollectionStore.I.createCollection(n);
                                CollectionStore.I.toggleInCollection(c, item);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('تمام'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

// ذخیره از فید و ریلز
void feedSaveHook(
  BuildContext context,
  String id,
  String url,
  String title,
  bool saved,
) {
  final SavedItem item = SavedItem(id: id, url: url, title: title);
  if (saved) {
    CollectionStore.I.saveItem(item);
    showCollectionPicker(context, item);
  } else {
    CollectionStore.I.unsave(id);
  }
}

// ذخیره از آثار من
void saveWithCollections(BuildContext context, UserPost post) {
  final SavedItem item = SavedItem(
    id: post.id,
    url: 'https://picsum.photos/seed/my_work_${post.imageSeed}/300/300',
    title: post.caption.isEmpty ? typeTitle(post.type) : post.caption,
  );
  PostStore.I.toggleSave(post);
  if (post.saved) {
    CollectionStore.I.saveItem(item);
    showCollectionPicker(context, item);
  } else {
    CollectionStore.I.unsave(post.id);
  }
}

void manageCollection(
  BuildContext context,
  SavedCollection c, {
  bool closeScreen = false,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF16161F),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('تغییر نام'),
            onTap: () async {
              Navigator.pop(ctx);
              final String? n =
                  await askCollectionName(context, initial: c.name);
              if (n != null && n.isNotEmpty) CollectionStore.I.rename(c, n);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Color(0xFFFF0055)),
            title: const Text(
              'حذف مجموعه',
              style: TextStyle(color: Color(0xFFFF0055)),
            ),
            onTap: () {
              Navigator.pop(ctx);
              CollectionStore.I.deleteCollection(c);
              if (closeScreen && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------
// صفحه ذخیره‌شده‌ها (لیست مجموعه‌ها)
// ---------------------------------------------------------------------
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  Future<void> _create(BuildContext context) async {
    final String? n = await askCollectionName(context);
    if (n != null && n.isNotEmpty) CollectionStore.I.createCollection(n);
  }

  Widget _cover(List<SavedItem> items) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        color: const Color(0xFF16161F),
        child: items.isEmpty
            ? const Icon(Icons.folder_open, size: 40, color: Colors.grey)
            : items.length < 4
                ? savedThumb(items.first.url)
                : GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    children:
                        items.take(4).map((x) => savedThumb(x.url)).toList(),
                  ),
      ),
    );
  }

  Widget _tile(
    String title,
    List<SavedItem> items,
    VoidCallback onTap, {
    VoidCallback? onLong,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLong,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _cover(items)),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            '${items.length} مورد',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ذخیره‌شده‌ها'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF00E5FF)),
            onPressed: () => _create(context),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: CollectionStore.I,
        builder: (context, _) {
          final List<SavedCollection> cols = CollectionStore.I.collections;
          return GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemCount: cols.length + 2,
            itemBuilder: (context, i) {
              if (i == 0) {
                return _tile(
                  'همه‌ی ذخیره‌ها',
                  CollectionStore.I.allSaved,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CollectionScreen()),
                  ),
                );
              }
              if (i == cols.length + 1) {
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _create(context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00E5FF)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Color(0xFF00E5FF), size: 34),
                        SizedBox(height: 4),
                        Text(
                          'مجموعه جدید',
                          style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final SavedCollection c = cols[i - 1];
              return _tile(
                c.name,
                c.items,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CollectionScreen(col: c)),
                ),
                onLong: () => manageCollection(context, c),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------
// داخل یک مجموعه (col = null یعنی «همه‌ی ذخیره‌ها»)
// ---------------------------------------------------------------------
class CollectionScreen extends StatelessWidget {
  final SavedCollection? col;
  const CollectionScreen({super.key, this.col});

  void _show(BuildContext context, SavedItem it) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: InteractiveViewer(
            child: Image.network(it.url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, SavedItem it) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        title: Text(col == null ? 'حذف از ذخیره‌ها' : 'حذف از مجموعه'),
        content: const Text('این مورد حذف شود؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (col == null) {
                CollectionStore.I.unsave(it.id);
              } else {
                CollectionStore.I.toggleInCollection(col!, it);
              }
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CollectionStore.I,
      builder: (context, _) {
        final List<SavedItem> items =
            col == null ? CollectionStore.I.allSaved : col!.items;
        return Scaffold(
          appBar: AppBar(
            title: Text(col?.name ?? 'همه‌ی ذخیره‌ها'),
            actions: [
              if (col != null)
                IconButton(
                  icon: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Color(0xFF00E5FF),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddToCollectionScreen(col: col!),
                    ),
                  ),
                ),
              if (col != null)
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () =>
                      manageCollection(context, col!, closeScreen: true),
                ),
            ],
          ),
          body: items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'اینجا هنوز چیزی نیست.\nآثار را با دکمه ذخیره (🔖) اضافه کنید.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(3),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final SavedItem it = items[i];
                    return GestureDetector(
                      onTap: () => _show(context, it),
                      onLongPress: () => _confirmRemove(context, it),
                      child: savedThumb(it.url),
                    );
                  },
                ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
// افزودن آثار به یک مجموعه
// ---------------------------------------------------------------------
class AddToCollectionScreen extends StatelessWidget {
  final SavedCollection col;
  const AddToCollectionScreen({super.key, required this.col});

  List<SavedItem> _candidates() {
    final List<SavedItem> l = <SavedItem>[];
    for (final UserPost p in PostStore.I.posts) {
      l.add(
        SavedItem(
          id: p.id,
          url: 'https://picsum.photos/seed/my_work_${p.imageSeed}/300/300',
          title: p.caption.isEmpty ? typeTitle(p.type) : p.caption,
        ),
      );
    }
    for (int i = 0; i < 24; i++) {
      l.add(
        SavedItem(
          id: 'explore_$i',
          url: 'https://picsum.photos/seed/explore_pick_$i/300/300',
          title: 'اثر ${i + 1}',
        ),
      );
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    final List<SavedItem> list = _candidates();
    return Scaffold(
      appBar: AppBar(
        title: Text('افزودن به «${col.name}»'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'تمام',
              style: TextStyle(color: Color(0xFF00E5FF)),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: CollectionStore.I,
        builder: (context, _) {
          return GridView.builder(
            padding: const EdgeInsets.all(3),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
            ),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final SavedItem it = list[i];
              final bool on = CollectionStore.I.inCollection(col, it.id);
              return GestureDetector(
                onTap: () => CollectionStore.I.toggleInCollection(col, it),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    savedThumb(it.url),
                    if (on) Container(color: const Color(0x8800E5FF)),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Icon(
                        on ? Icons.check_circle : Icons.circle_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------
// بخش‌های داخل پروفایل: آثار من و ذخیره‌شده‌ها
// ---------------------------------------------------------------------
class MyPostsGrid extends StatelessWidget {
  const MyPostsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PostStore.I,
      builder: (context, _) {
        final List<UserPost> posts = visibleGridPosts();
        if (posts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text(
                'هنوز اثری منتشر نکرده‌اید.\nبا دکمه + اولین اثرتان را بسازید ✨',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
          itemCount: posts.length,
          itemBuilder: (context, i) {
            final UserPost p = posts[i];
            final Uint8List? b = PostImages.of(p.id);
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyWorksScreen()),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  b != null
                      ? Image.memory(b, fit: BoxFit.cover)
                      : savedThumb(
                          'https://picsum.photos/seed/my_work_${p.imageSeed}/300/300',
                        ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child:
                        Icon(typeIcon(p.type), size: 16, color: Colors.white),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class SavedInline extends StatelessWidget {
  const SavedInline({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CollectionStore.I,
      builder: (context, _) {
        final List<SavedItem> items = CollectionStore.I.allSaved;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedScreen()),
                ),
                icon: const Icon(Icons.folder_copy_outlined, size: 18),
                label: Text(
                  'مجموعه‌ها (${CollectionStore.I.collections.length})',
                ),
              ),
            ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'هنوز چیزی ذخیره نکرده‌اید 🔖',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) => savedThumb(items[i].url),
              ),
          ],
        );
      },
    );
  }
}
