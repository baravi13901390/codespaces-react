part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// ---------------------------------------------------------------------
// پیام‌های مستقیم
// ---------------------------------------------------------------------
// =====================================================================
// Talent Showcase: search card, proposals with a monthly quota,
// investor inbox, top talents and private candidates list
// =====================================================================
const Map<String, Map<String, String>> _kTs = {
  'fa': {
    'showcase_title': 'ویترین استعداد',
    'dm_investor':
        'به سرمایه‌گذار نمی‌شود پیام داد. از بخش ویترین استعداد پیشنهاد بفرستید.',
    'sc_quota': 'پیشنهادهای باقی‌مانده این ماه: ',
    'sc_investors': 'سرمایه‌گذاران',
    'sc_looking': 'به‌دنبال صنف: ',
    'sc_min_stars': 'حداقل ستاره: ',
    'sc_send': 'ارسال پیشنهاد',
    'sc_no_match': 'با کارت این سرمایه‌گذار جور نیستید',
    'sc_sent': 'ارسال شد',
    'sc_write': 'پیشنهاد کوتاه خود را بنویسید (حداکثر ۲۰۰ حرف)',
    'sc_submit': 'ارسال',
    'sc_quota_over': 'سهمیه‌ی این ماه تمام شده است',
    'sc_empty_text': 'متن پیشنهاد را بنویسید',
    'sc_my_props': 'پیشنهادهای من',
    'sc_none_sent': 'هنوز پیشنهادی نفرستاده‌اید',
    'sc_reviewing': 'در حال بررسی',
    'sc_expired': 'منقضی شد',
    'sc_accepted': 'پذیرفته شد؛ گفتگو را شروع کنید',
    'sc_verified': 'سرمایه‌گذار تأییدشده',
    'sc_tab_card': 'کارت جستجو',
    'sc_tab_inbox': 'صندوق',
    'sc_tab_show': 'ویترین',
    'sc_tab_cand': 'نامزدها',
    'sc_card_hint':
        'صنفی که دنبالش هستید را انتخاب کنید. فقط استعدادهای همان صنف می‌توانند برایتان پیشنهاد بفرستند.',
    'sc_card_first': 'ابتدا کارت جستجوی خود را بسازید',
    'sc_inbox_empty': 'پیشنهاد تازه‌ای ندارید',
    'sc_accept': 'قبول و گفتگو',
    'sc_later': 'بعداً',
    'sc_no': 'نه',
    'sc_later_label': 'در انتظار',
    'sc_silent_note':
        'رد کردن بی‌صداست؛ استعداد فقط «در حال بررسی» می‌بیند و پس از ۷ روز خودکار منقضی می‌شود.',
    'sc_showcase_info': 'برترین استعدادها بر اساس امتیاز',
    'sc_save_cand': 'ذخیره در نامزدها',
    'sc_remove_cand': 'حذف از نامزدها',
    'sc_cand_empty': 'هنوز نامزدی ذخیره نکرده‌اید',
    'sc_note': 'یادداشت خصوصی',
    'sc_note_hint': 'فقط شما این یادداشت را می‌بینید',
    'sc_save': 'ذخیره',
    'sc_points': 'امتیاز',
    'demo_p1':
        'سلام، من چند سال است در این حوزه کار می‌کنم و نمونه‌کارهایم را در پروفایلم گذاشته‌ام. خوشحال می‌شوم صحبت کنیم.',
    'demo_p2':
        'پروژه‌ای در دست دارم که برای توسعه به حمایت نیاز دارد. اگر وقت دارید، توضیح کامل می‌دهم.',
    'demo_p3':
        'در مسابقات باراوی به مرحله‌ی بالا رسیدم و دوست دارم درباره‌ی همکاری صحبت کنیم.',
    'demo_p4': 'آثار من را دیده‌اید؟ یک طرح عملی برای تولید و فروش دارم.',
  },
  'en': {
    'showcase_title': 'Talent Showcase',
    'dm_investor':
        'Investors cannot receive messages. Send a proposal from the Talent Showcase instead.',
    'sc_quota': 'Proposals left this month: ',
    'sc_investors': 'Investors',
    'sc_looking': 'Looking for field: ',
    'sc_min_stars': 'Minimum stars: ',
    'sc_send': 'Send proposal',
    'sc_no_match': 'You do not match this investor card',
    'sc_sent': 'Sent',
    'sc_write': 'Write your short proposal (max 200 characters)',
    'sc_submit': 'Submit',
    'sc_quota_over': 'You have used this month quota',
    'sc_empty_text': 'Write your proposal text',
    'sc_my_props': 'My proposals',
    'sc_none_sent': 'You have not sent any proposals yet',
    'sc_reviewing': 'Under review',
    'sc_expired': 'Expired',
    'sc_accepted': 'Accepted - start the chat',
    'sc_verified': 'Verified investor',
    'sc_tab_card': 'Search card',
    'sc_tab_inbox': 'Inbox',
    'sc_tab_show': 'Showcase',
    'sc_tab_cand': 'Candidates',
    'sc_card_hint':
        'Choose the field you are looking for. Only talents of that field can send you proposals.',
    'sc_card_first': 'Create your search card first',
    'sc_inbox_empty': 'No new proposals',
    'sc_accept': 'Accept and chat',
    'sc_later': 'Later',
    'sc_no': 'No',
    'sc_later_label': 'Waiting',
    'sc_silent_note':
        'Declining is silent. The talent only sees Under review and it expires automatically after 7 days.',
    'sc_showcase_info': 'Top talents by score',
    'sc_save_cand': 'Save as candidate',
    'sc_remove_cand': 'Remove from candidates',
    'sc_cand_empty': 'No candidates saved yet',
    'sc_note': 'Private note',
    'sc_note_hint': 'Only you can see this note',
    'sc_save': 'Save',
    'sc_points': 'points',
    'demo_p1':
        'Hello, I have worked in this field for several years and my portfolio is on my profile. I would be glad to talk.',
    'demo_p2':
        'I have a project that needs support to grow. If you have time, I can explain everything.',
    'demo_p3':
        'I reached a high stage in the Baravi competitions and would like to discuss working together.',
    'demo_p4':
        'Have you seen my works? I have a practical plan for production and sales.',
  },
};

String ts(String id) {
  final Map<String, String>? m = _kTs[AppPrefs.I.lang];
  return m?[id] ?? _kTs['en']![id] ?? id;
}

TextDirection _scDir() {
  final String l = AppPrefs.I.lang;
  return (l == 'fa' || l == 'ar') ? TextDirection.rtl : TextDirection.ltr;
}

class InvestorCard {
  final String field;
  final int minStars;
  const InvestorCard(this.field, this.minStars);
}

InvestorCard investorCardOf(String name) {
  final List<Map<String, dynamic>> roots = CategoryStore.I.topLevel;
  final int h = name.codeUnits.fold<int>(0, (a, b) => a + b);
  final String field =
      roots.isEmpty ? '' : roots[h % roots.length]['id'] as String;
  return InvestorCard(field, 3 + h % 3);
}

String? catIdByTitle(String title) {
  for (final Map<String, dynamic> c in CategoryStore.I.selectable) {
    if (c['title'] == title) return c['id'] as String;
  }
  return null;
}

bool fieldMatches(String catId, String cardField) {
  if (cardField.isEmpty || catId.isEmpty) return false;
  return CategoryStore.I.matches(catId, cardField);
}

class ShowcaseProposal {
  final String id;
  final String from;
  final String to;
  final String text;
  final int stars;
  final DateTime at;
  String status;
  ShowcaseProposal({
    required this.id,
    required this.from,
    required this.to,
    required this.text,
    required this.stars,
    required this.at,
    this.status = 'pending',
  });

  bool get old => DateTime.now().difference(at).inDays >= 7;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'from': from,
        'to': to,
        'text': text,
        'stars': stars,
        'at': at.millisecondsSinceEpoch,
        'st': status,
      };

  static ShowcaseProposal fromJson(Map<String, dynamic> m) => ShowcaseProposal(
        id: m['id'] as String,
        from: m['from'] as String,
        to: m['to'] as String,
        text: m['text'] as String,
        stars: (m['stars'] as num).toInt(),
        at: DateTime.fromMillisecondsSinceEpoch((m['at'] as num).toInt()),
        status: (m['st'] as String?) ?? 'pending',
      );
}

class ShowcaseStore extends ChangeNotifier {
  ShowcaseStore._();
  static final ShowcaseStore I = ShowcaseStore._();
  static const int quota = 3;

  final List<ShowcaseProposal> sent = <ShowcaseProposal>[];
  final List<ShowcaseProposal> inbox = <ShowcaseProposal>[];
  final Map<String, String> candidates = <String, String>{};
  String cardField = '';
  int cardMin = 4;
  int _n = 0;
  bool _loaded = false;
  SharedPreferences? _prefs;

  int get usedThisMonth {
    final DateTime now = DateTime.now();
    return sent
        .where((p) => p.at.year == now.year && p.at.month == now.month)
        .length;
  }

  int get left => math.max(0, quota - usedThisMonth);

  Future<void> ensure() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      _prefs = p;
      final String? raw = p.getString('baravi_showcase');
      if (raw != null) {
        final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
        _n = (m['n'] as num?)?.toInt() ?? 0;
        cardField = (m['cf'] as String?) ?? '';
        cardMin = (m['cm'] as num?)?.toInt() ?? 4;
        for (final dynamic e in (m['sent'] as List<dynamic>?) ?? <dynamic>[]) {
          sent.add(ShowcaseProposal.fromJson(e as Map<String, dynamic>));
        }
        for (final dynamic e in (m['inbox'] as List<dynamic>?) ?? <dynamic>[]) {
          inbox.add(ShowcaseProposal.fromJson(e as Map<String, dynamic>));
        }
        final Map<String, dynamic> c =
            (m['cand'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        c.forEach((k, v) => candidates[k] = v as String);
      }
    } catch (_) {}
    _seedInbox();
    notifyListeners();
  }

  void _seedInbox() {
    if (inbox.isNotEmpty) return;
    final List<TalentUser> pool = allTalentUsers
        .where((u) => !isInvestorName(u.username))
        .take(10)
        .toList();
    for (int i = 0; i < pool.length; i++) {
      _n++;
      inbox.add(
        ShowcaseProposal(
          id: 'pr_$_n',
          from: pool[i].username,
          to: kMyUsername,
          text: ts('demo_p${(i % 4) + 1}'),
          stars: pool[i].stars,
          at: DateTime.now().subtract(Duration(hours: i * 3 + 1)),
        ),
      );
    }
  }

  void _save() {
    final SharedPreferences? p = _prefs;
    if (p == null) return;
    try {
      p.setString(
        'baravi_showcase',
        jsonEncode(<String, dynamic>{
          'n': _n,
          'cf': cardField,
          'cm': cardMin,
          'sent': sent.map((e) => e.toJson()).toList(),
          'inbox': inbox.map((e) => e.toJson()).toList(),
          'cand': candidates,
        }),
      );
    } catch (_) {}
  }

  void _changed() {
    notifyListeners();
    _save();
  }

  bool alreadySentTo(String investor) => sent.any((p) => p.to == investor);

  String? sendProposal(String to, String text) {
    final String t = text.trim();
    if (t.isEmpty) return 'sc_empty_text';
    if (left <= 0) return 'sc_quota_over';
    _n++;
    sent.insert(
      0,
      ShowcaseProposal(
        id: 'pr_$_n',
        from: kMyUsername,
        to: to,
        text: t.length > 200 ? t.substring(0, 200) : t,
        stars: kMyStars,
        at: DateTime.now(),
      ),
    );
    _changed();
    return null;
  }

  void setCard(String field, int min) {
    cardField = field;
    cardMin = min;
    _changed();
  }

  void decide(ShowcaseProposal p, String status) {
    p.status = status;
    _changed();
  }

  void toggleCandidate(String user) {
    if (candidates.containsKey(user)) {
      candidates.remove(user);
    } else {
      candidates[user] = '';
    }
    _changed();
  }

  void setNote(String user, String note) {
    candidates[user] = note;
    _changed();
  }
}

Widget _scStars(int n) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List<Widget>.generate(
      5,
      (i) => Icon(
        Icons.star,
        size: 12,
        color: i < n ? const Color(0xFFFFB300) : Colors.grey.shade800,
      ),
    ),
  );
}

Widget _scTitle(String t) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(2, 14, 2, 6),
    child: Text(
      t,
      style: const TextStyle(
        color: Color(0xFF00E5FF),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

BoxDecoration _scBox() {
  return BoxDecoration(
    color: const Color(0xFF16161F),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFF2A2A38), width: 0.8),
  );
}

class ShowcaseHome extends StatelessWidget {
  const ShowcaseHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPrefs.I.role == 'investor'
        ? const InvestorSideScreen()
        : const TalentSideScreen();
  }
}

class TalentSideScreen extends StatefulWidget {
  const TalentSideScreen({super.key});

  @override
  State<TalentSideScreen> createState() => _TalentSideScreenState();
}

class _TalentSideScreenState extends State<TalentSideScreen> {
  @override
  void initState() {
    super.initState();
    ShowcaseStore.I.ensure();
  }

  void _openSend(String investor) {
    final TextEditingController c = TextEditingController();
    showDarkSheet<void>(context, (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            sheetHandle(),
            Text(
              ts('sc_write'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: c,
              maxLength: 200,
              maxLines: 5,
              textDirection: _scDir(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E28),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
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
                onPressed: () {
                  final String? err =
                      ShowcaseStore.I.sendProposal(investor, c.text);
                  if (err != null) {
                    showSnack(context, ts(err));
                    return;
                  }
                  Navigator.pop(ctx);
                },
                child: Text(
                  ts('sc_submit'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _investorTile(TalentUser u) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => openUserByName(context, u.username),
      child: _investorTile0(u),
    );
  }

  Widget _investorTile0(TalentUser u) {
    final InvestorCard card = investorCardOf(u.username);
    final bool match = fieldMatches(AppState.I.myField, card.field) &&
        kMyStars >= card.minStars;
    final bool done = ShowcaseStore.I.alreadySentTo(u.username);
    Widget action;
    if (done) {
      action = Text(
        ts('sc_sent'),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      );
    } else if (match) {
      action = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5FF),
            foregroundColor: Colors.black,
          ),
          onPressed: () => _openSend(u.username),
          child: Text(
            ts('sc_send'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      );
    } else {
      action = Text(
        ts('sc_no_match'),
        style: const TextStyle(color: Color(0xFFFF5252), fontSize: 11),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: _scBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CubeAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF1E1E28),
                backgroundImage: NetworkImage(avatarUrl(u.username)),
                onBackgroundImageError: (_, __) {},
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
                            u.username,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        tickBadges(u.username, size: 15),
                      ],
                    ),
                    Text(
                      ts('sc_verified'),
                      style: const TextStyle(
                        color: Color(0xFFFFB300),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ts('sc_looking') + categoryTitleOf(card.field),
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Text(
            ts('sc_min_stars') + card.minStars.toString(),
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          action,
        ],
      ),
    );
  }

  Widget _sentTile(ShowcaseProposal p) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => openUserByName(context, p.to),
      child: _sentTile0(p),
    );
  }

  Widget _sentTile0(ShowcaseProposal p) {
    String label;
    Color col;
    if (p.status == 'accepted') {
      label = ts('sc_accepted');
      col = const Color(0xFF00C853);
    } else if (p.old) {
      label = ts('sc_expired');
      col = Colors.grey;
    } else {
      label = ts('sc_reviewing');
      col = const Color(0xFFFFB300);
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: _scBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.to,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            p.text,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: col,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (p.status == 'accepted')
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ChatScreen(user: userByName(p.to)),
                ),
              ),
              child: Text(
                ts('sc_accepted'),
                style: const TextStyle(color: Color(0xFF00E5FF)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ts('showcase_title'))),
      body: AnimatedBuilder(
        animation: ShowcaseStore.I,
        builder: (context, _) {
          final ShowcaseStore s = ShowcaseStore.I;
          final List<TalentUser> investors =
              allTalentUsers.where((u) => isInvestorName(u.username)).toList();
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: _scBox(),
                child: Text(
                  ts('sc_quota') +
                      s.left.toString() +
                      ' / ' +
                      ShowcaseStore.quota.toString(),
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              _scTitle(ts('sc_investors')),
              ...investors.map(_investorTile),
              _scTitle(ts('sc_my_props')),
              if (s.sent.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    ts('sc_none_sent'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ...s.sent.map(_sentTile),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class InvestorSideScreen extends StatefulWidget {
  const InvestorSideScreen({super.key});

  @override
  State<InvestorSideScreen> createState() => _InvestorSideScreenState();
}

class _InvestorSideScreenState extends State<InvestorSideScreen> {
  @override
  void initState() {
    super.initState();
    ShowcaseStore.I.ensure();
  }

  Widget _cardTab(ShowcaseStore s) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Text(
          ts('sc_card_hint'),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        categoryChipsRow(
          selected: s.cardField,
          includeAllOption: false,
          onSelected: (id) =>
              s.setCard(CategoryStore.I.topParentOf(id), s.cardMin),
        ),
        const SizedBox(height: 10),
        Text(
          ts('sc_min_stars'),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Row(
          children: List<Widget>.generate(5, (i) {
            final int n = i + 1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(n.toString()),
                selected: s.cardMin == n,
                selectedColor: const Color(0xFF00E5FF),
                backgroundColor: const Color(0xFF1C1C24),
                labelStyle: TextStyle(
                  color: s.cardMin == n ? Colors.black : Colors.white70,
                ),
                onSelected: (_) => s.setCard(s.cardField, n),
              ),
            );
          }),
        ),
        if (s.cardField.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.all(12),
            decoration: _scBox(),
            child: Text(
              ts('sc_looking') +
                  categoryTitleOf(s.cardField) +
                  ' | ' +
                  ts('sc_min_stars') +
                  s.cardMin.toString(),
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 14),
        Text(
          ts('sc_silent_note'),
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }

  Widget _centerText(String t) {
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

  Widget _inboxTile(ShowcaseStore s, ShowcaseProposal p) {
    final TalentUser u = userByName(p.from);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: _scBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CubeAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1E1E28),
                backgroundImage: NetworkImage(avatarUrl(p.from)),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => openUserByName(context, p.from),
                      child: Text(
                        p.from,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                    _scStars(p.stars),
                    Text(
                      guildPathByTitle(u.field),
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (p.status == 'later')
                Text(
                  ts('sc_later_label'),
                  style:
                      const TextStyle(color: Color(0xFFFFB300), fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            p.text,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    s.decide(p, 'accepted');
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ChatScreen(user: u),
                      ),
                    );
                  },
                  child: Text(
                    ts('sc_accept'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () => s.decide(p, 'later'),
                  child: Text(
                    ts('sc_later'),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 2,
                child: TextButton(
                  onPressed: () => s.decide(p, 'declined'),
                  child: Text(
                    ts('sc_no'),
                    style: const TextStyle(
                      color: Color(0xFFFF5252),
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inboxTab(ShowcaseStore s) {
    if (s.cardField.isEmpty) return _centerText(ts('sc_card_first'));
    final List<ShowcaseProposal> list = s.inbox.where((p) {
      if (p.status != 'pending' && p.status != 'later') return false;
      final String? cid = catIdByTitle(userByName(p.from).field);
      return cid != null &&
          fieldMatches(cid, s.cardField) &&
          p.stars >= s.cardMin;
    }).toList();
    list.sort((a, b) => b.stars.compareTo(a.stars));
    if (list.isEmpty) return _centerText(ts('sc_inbox_empty'));
    return ListView(
      padding: const EdgeInsets.all(14),
      children: list.map((p) => _inboxTile(s, p)).toList(),
    );
  }

  Widget _showTab(ShowcaseStore s) {
    final List<TalentUser> list = allTalentUsers.where((u) {
      if (isInvestorName(u.username)) return false;
      if (s.cardField.isEmpty) return true;
      final String? cid = catIdByTitle(u.field);
      return cid != null && fieldMatches(cid, s.cardField);
    }).toList();
    list.sort((a, b) => b.score.compareTo(a.score));
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _scTitle(ts('sc_showcase_info')),
        ...List<Widget>.generate(list.length, (i) {
          final TalentUser u = list[i];
          final bool saved = s.candidates.containsKey(u.username);
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: _scBox(),
            child: Row(
              children: [
                CubeAvatar(
                  radius: 14,
                  backgroundColor:
                      i < 3 ? const Color(0xFFFFB300) : const Color(0xFF2A2A38),
                  child: Text(
                    (i + 1).toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: i < 3 ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CubeAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF1E1E28),
                  backgroundImage: NetworkImage(avatarUrl(u.username)),
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => openUserProfile(context, u),
                        child: Text(
                          u.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      _scStars(u.stars),
                      Text(
                        guildPathByTitle(u.field) +
                            ' | ' +
                            formatCount(u.score) +
                            ' ' +
                            ts('sc_points'),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: saved ? ts('sc_remove_cand') : ts('sc_save_cand'),
                  icon: Icon(
                    saved ? Icons.bookmark : Icons.bookmark_border,
                    color: saved ? const Color(0xFFFFB300) : Colors.white,
                  ),
                  onPressed: () => s.toggleCandidate(u.username),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _editNote(ShowcaseStore s, String user) {
    final TextEditingController c =
        TextEditingController(text: s.candidates[user] ?? '');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        title: Text(ts('sc_note')),
        content: TextField(
          controller: c,
          maxLines: 4,
          autofocus: true,
          textDirection: _scDir(),
          decoration: InputDecoration(hintText: ts('sc_note_hint')),
        ),
        actions: [
          TextButton(
            onPressed: () {
              s.setNote(user, c.text.trim());
              Navigator.pop(ctx);
            },
            child: Text(
              ts('sc_save'),
              style: const TextStyle(color: Color(0xFF00E5FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _candTab(ShowcaseStore s) {
    if (s.candidates.isEmpty) return _centerText(ts('sc_cand_empty'));
    final List<MapEntry<String, String>> list = s.candidates.entries.toList();
    return ListView(
      padding: const EdgeInsets.all(14),
      children: list.map((e) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(10),
          decoration: _scBox(),
          child: Row(
            children: [
              CubeAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1E1E28),
                backgroundImage: NetworkImage(avatarUrl(e.key)),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => openUserByName(context, e.key),
                      child: Text(
                        e.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                    Text(
                      e.value.isEmpty ? ts('sc_note_hint') : e.value,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _editNote(s, e.key),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Color(0xFFFF5252),
                ),
                onPressed: () => s.toggleCandidate(e.key),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(ts('showcase_title')),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: const Color(0xFF00E5FF),
            labelColor: const Color(0xFF00E5FF),
            tabs: [
              Tab(text: ts('sc_tab_card')),
              Tab(text: ts('sc_tab_inbox')),
              Tab(text: ts('sc_tab_show')),
              Tab(text: ts('sc_tab_cand')),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: ShowcaseStore.I,
          builder: (context, _) {
            final ShowcaseStore s = ShowcaseStore.I;
            return TabBarView(
              children: [_cardTab(s), _inboxTab(s), _showTab(s), _candTab(s)],
            );
          },
        ),
      ),
    );
  }
}

void openDirectMessage(BuildContext context, String name, [Object? ignored]) {
  if (name == kMyUsername) return;
  if (isInvestorName(name)) {
    showSnack(context, ts('dm_investor'));
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChatScreen(user: userByName(name)),
    ),
  );
}

class ChatMessage {
  final String text;
  final bool mine;
  final String time;
  ChatMessage({required this.text, required this.mine, required this.time});
}

final Map<String, List<ChatMessage>> _chatStore = <String, List<ChatMessage>>{};

List<ChatMessage> chatOf(String user) {
  return _chatStore.putIfAbsent(
    user,
    () => <ChatMessage>[
      ChatMessage(
          text: 'سلام! اثرت رو دیدم، عالی بود 👏', mine: false, time: '۱۰:۲۰'),
      ChatMessage(text: 'ممنون، لطف داری 🙏', mine: true, time: '۱۰:۲۲'),
    ],
  );
}

String nowTime() {
  final DateTime t = DateTime.now();
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    final List<TalentUser> users = allTalentUsers
        .where((u) => canMessageUser(u.username))
        .take(10)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('پیام‌ها 💬')),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, i) {
          final TalentUser u = users[i];
          final ChatMessage last = chatOf(u.username).last;
          return ListTile(
            leading: CubeAvatar(
              radius: 24,
              backgroundImage: NetworkImage(avatarUrl(u.username)),
            ),
            title: Text(
              u.username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              '${last.mine ? 'شما: ' : ''}${last.text}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Text(
              last.time,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen(user: u)),
              );
              if (mounted) setState(() {});
            },
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final TalentUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _c = TextEditingController();
  final ScrollController _sc = ScrollController();
  Timer? _timer;
  bool _typing = false;

  static const List<String> _replies = [
    'ممنون از پیامت! 🌟',
    'حتماً، بیا با هم یه پروژه بزنیم 🔧',
    'عالیه! منتظر اثر بعدیت هستم 🎬',
    'نمره‌ات رو دیدم، تبریک 👏',
  ];

  List<ChatMessage> get _msgs => chatOf(widget.user.username);

  @override
  void initState() {
    super.initState();
    _down();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    _sc.dispose();
    super.dispose();
  }

  void _down() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sc.hasClients) {
        _sc.animateTo(
          _sc.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final String t = _c.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _msgs.add(ChatMessage(text: t, mine: true, time: nowTime()));
      _typing = true;
    });
    _c.clear();
    _down();
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _msgs.add(
          ChatMessage(
            text: _replies[_msgs.length % _replies.length],
            mine: false,
            time: nowTime(),
          ),
        );
      });
      _down();
    });
  }

  Widget _bubble(ChatMessage m) {
    return Align(
      alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: m.mine ? const Color(0xFF00B8CC) : const Color(0xFF22222E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              m.text,
              style: TextStyle(
                color: m.mine ? Colors.black : Colors.white,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              m.time,
              style: TextStyle(
                color: m.mine ? Colors.black54 : Colors.grey,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ChatMessage> list = _msgs;
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => openUserProfile(context, widget.user),
          child: Row(
            children: [
              CubeAvatar(
                radius: 16,
                backgroundImage: NetworkImage(avatarUrl(widget.user.username)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.user.username,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _sc,
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, i) => _bubble(list[i]),
            ),
          ),
          if (_typing)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'در حال نوشتن...',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
            ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              color: const Color(0xFF14141A),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _c,
                      textDirection: TextDirection.rtl,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'پیام بنویسید...',
                        hintStyle:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1E1E28),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CubeAvatar(
                    backgroundColor: const Color(0xFF00E5FF),
                    child: IconButton(
                      icon:
                          const Icon(Icons.send, color: Colors.black, size: 20),
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
