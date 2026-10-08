part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

void shareMyPost(BuildContext context, UserPost p) {
  showShareSheet(
    context,
    link: 'https://baravi.app/p/${p.id}',
    item: SavedItem(
      id: p.id,
      url: 'https://picsum.photos/seed/my_work_${p.imageSeed}/300/300',
      title: p.caption.isEmpty ? typeTitle(p.type) : p.caption,
    ),
    onSaved: () {
      if (!p.saved) PostStore.I.toggleSave(p);
    },
  );
}

/// شیر واحد برای همه‌ی بلوک‌ها: کپی لینک واقعی / ارسال به مخاطب / ذخیره با مجموعه‌ها
void showShareSheet(
  BuildContext context, {
  VoidCallback? onSaved,
  String? link,
  SavedItem? item,
}) {
  final String url = link ?? item?.url ?? 'https://baravi.app';
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF16161F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sheetHandle(),
            const Text('اشتراک‌گذاری اثر استعدادیابی',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _shareActionItem(
                  icon: Icons.view_in_ar_rounded,
                  label: 'استوری',
                  color: const Color(0xFF00C853),
                  onTap: () {
                    Navigator.pop(ctx);
                    repostItem(context, 'story', url, item);
                  },
                ),
                _shareActionItem(
                  icon: Icons.grid_on_rounded,
                  label: 'پست',
                  color: const Color(0xFF9C6BFF),
                  onTap: () {
                    Navigator.pop(ctx);
                    repostItem(context, 'post', url, item);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _shareActionItem(
                  icon: Icons.link,
                  label: 'کپی لینک',
                  color: const Color(0xFF00E5FF),
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: url));
                    showSnack(context, 'لینک کپی شد 🔗');
                  },
                ),
                _shareActionItem(
                  icon: Icons.send,
                  label: 'ارسال مستقیم',
                  color: const Color(0xFFFF0055),
                  onTap: () {
                    Navigator.pop(ctx);
                    showSendToUsersSheet(context, url);
                  },
                ),
                _shareActionItem(
                  icon: Icons.bookmark_border,
                  label: 'ذخیره اثر',
                  color: const Color(0xFFFFB300),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (item != null) {
                      CollectionStore.I.saveItem(item);
                      onSaved?.call();
                      showCollectionPicker(context, item);
                    } else {
                      onSaved?.call();
                      showSnack(context, 'در لیست ذخیره‌شده‌ها قرار گرفت! ⭐️');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void repostItem(
    BuildContext context, String type, String link, SavedItem? item) {
  final String who2 = item?.title ?? '';
  String img = item?.url ?? link;
  img = img
      .replaceAll('/300/300', '/800/800')
      .replaceAll('/300/500', '/800/1400');
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ComposeV3(
        initialType: type,
        initialUrl: img.endsWith('.mp4') ? null : img,
        initialCaption: who2.isEmpty ? '' : 'بازنشر از @$who2 ',
      ),
    ),
  );
}

void repostItemOld(
    BuildContext context, String type, String link, SavedItem? item) {
  final String who = item?.title ?? '';
  final String cat = AppState.I.myField.isNotEmpty
      ? AppState.I.myField
      : (CategoryStore.I.topLevel.isEmpty
          ? 'all'
          : CategoryStore.I.topLevel.first['id'] as String);
  PostStore.I.add(
    type: type,
    category: cat,
    caption: who.isEmpty ? '' : 'بازنشر از $who',
    imageSeed: (item?.id ?? link).hashCode.abs() % 11,
  );
  showSnack(
      context,
      type == 'story'
          ? 'در استوری شما قرار گرفت 🚀'
          : 'در پست‌های شما منتشر شد 🚀');
}

/// لیست مخاطبین (سرمایه‌گذارها پیام نمی‌گیرند)
void showSendToUsersSheet(BuildContext context, String link) {
  final Set<String> sel = <String>{};
  String q = '';
  showDarkSheet<void>(
    context,
    (ctx) => StatefulBuilder(
      builder: (ctx, setS) {
        final List<String> users = knownUsernames()
            .where((u) =>
                canMessageUser(u) &&
                (q.isEmpty || u.toLowerCase().contains(q.toLowerCase())))
            .toList();
        return Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 12),
          child: SizedBox(
            height: 470,
            child: Column(
              children: [
                sheetHandle(),
                TextField(
                  textDirection: TextDirection.rtl,
                  onChanged: (v) => setS(() => q = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'جستجوی مخاطب...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFF1E1E28),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (c, i) {
                      final String u = users[i];
                      final bool on = sel.contains(u);
                      return ListTile(
                        onTap: () => setS(() {
                          if (!sel.remove(u)) sel.add(u);
                        }),
                        leading: CubeAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF1E1E28),
                          backgroundImage: NetworkImage(avatarUrl(u)),
                          onBackgroundImageError: (_, __) {},
                        ),
                        title: Row(children: [
                          Flexible(
                            child: Text(u,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 4),
                          tickBadges(u, size: 13),
                        ]),
                        subtitle: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: starsRow(u),
                        ),
                        trailing: Icon(
                          on
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: on ? const Color(0xFF00E5FF) : Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: sel.isEmpty
                        ? null
                        : () {
                            for (final String u in sel) {
                              chatOf(u).add(ChatMessage(
                                  text: link, mine: true, time: nowTime()));
                            }
                            Navigator.pop(ctx);
                            showSnack(
                                context, 'برای ${sel.length} نفر ارسال شد 🚀');
                          },
                    child: Text(sel.isEmpty
                        ? 'مخاطب را انتخاب کنید'
                        : 'ارسال (${sel.length})'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
