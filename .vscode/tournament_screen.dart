part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// مسابقات باراوی (نسخه‌ی اتاق صنفی)
// - هر صنف اصلی با تمام زیرمجموعه‌هایش فقط یک اتاق دارد
// - فقط کاربران پنج‌ستاره وارد مسابقه می‌شوند
// - هر شرکت‌کننده یک فیلم در اتاق می‌گذارد؛ مردم فیلم‌ها را می‌بینند
//   و نمره می‌دهند؛ نمره‌ها را هیچ‌کس نمی‌بیند
// - لایک، نظر، اشتراک، ذخیره و مکعب در همه‌جا رعایت شده است
// - وقتی زمان تمام شود، برندگان بالای صفحه نمایش داده می‌شوند
//   و به اتاق بعدی می‌روند تا برسیم به اتاق نهایی و برترین‌ها
// =====================================================================

const int kMyStars = 3;
const int kRoomSize = 20;
const int kPrelimRooms = 20;
const int kFinalSize = 10;
Duration kRoomDuration = const Duration(seconds: 2);
Duration kUploadDuration = const Duration(seconds: 2);

const List<String> kEntryVideoUrls = <String>[
  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
];

/// فقط یک ویدیوی روی صفحه پخش می‌شود
final ValueNotifier<String?> _kActiveEntry = ValueNotifier<String?>(null);

const int kBlueTickFollowers = 2000000;

int followersOf(String name) => 1200 + (name.hashCode.abs() % 50000);

Widget tickBadges(String username, {double size = 14, bool red = true}) {
  final List<Widget> l = <Widget>[];
  if (isInvestorName(username)) {
    l.add(SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.verified, size: size, color: Colors.white),
          Icon(Icons.check, size: size * 0.6, color: Colors.black),
        ],
      ),
    ));
  }
  if (followersOf(username) >= kBlueTickFollowers ||
      username.codeUnits.fold<int>(0, (a, b) => a + b) % 3 == 0) {
    l.add(Icon(Icons.verified, size: size, color: const Color(0xFF00E5FF)));
  }
  if (red && TournamentStore.I.champions.contains(username)) {
    l.add(Icon(Icons.verified, size: size, color: const Color(0xFFFF1744)));
  }
  return Row(mainAxisSize: MainAxisSize.min, children: l);
}

String _tmDigits(Object n) {
  const String en = '0123456789';
  const String fa = '۰۱۲۳۴۵۶۷۸۹';
  String s = n.toString();
  for (int i = 0; i < 10; i++) {
    s = s.replaceAll(en[i], fa[i]);
  }
  return s;
}

// ---------------------------------------------------------------------
// مدل‌ها
// ---------------------------------------------------------------------
class CompetitionEntry {
  final String id;
  final String username;
  final int seat;
  final bool isMe;
  final String videoUrl;
  final double crowd;
  XFile? file;
  double? myScore;
  bool liked = false;
  bool saved = false;
  int likes;
  int shares = 0;
  int views;
  final List<PostComment> comments;

  CompetitionEntry({
    required this.id,
    required this.username,
    required this.seat,
    required this.videoUrl,
    required this.crowd,
    this.isMe = false,
    this.file,
    this.likes = 0,
    this.views = 0,
    List<PostComment>? comments,
  }) : comments = comments ?? <PostComment>[];

  bool get hasVideo => !isMe || file != null;
  double get total => crowd + (myScore ?? 0);
}

CompetitionEntry _makeEntry({
  required String roomId,
  required String username,
  required int seat,
  bool isMe = false,
  XFile? file,
}) {
  final math.Random r =
      math.Random((username.hashCode ^ roomId.hashCode) & 0x7fffffff);
  return CompetitionEntry(
    id: '${roomId}_$seat',
    username: username,
    seat: seat,
    isMe: isMe,
    file: file,
    videoUrl: kEntryVideoUrls[seat % kEntryVideoUrls.length],
    crowd: 3000 + r.nextInt(6000).toDouble(),
    likes: 20 + r.nextInt(400),
    views: 200 + r.nextInt(3000),
    comments: seedComments(seat),
  );
}

class CompetitionRoom {
  final String id;
  final String title;
  final int stageIndex;
  final String categoryId;
  final bool isFinal;
  final bool isChampions;
  final List<CompetitionEntry> entries;
  DateTime? endsAt;
  bool finished;
  List<CompetitionEntry> winners = <CompetitionEntry>[];

  CompetitionRoom({
    required this.id,
    required this.title,
    required this.stageIndex,
    required this.categoryId,
    required this.entries,
    this.isFinal = false,
    this.isChampions = false,
    this.finished = false,
  });

  String get stageLabel {
    if (isChampions) return 'برترین‌ها 🏆';
    if (isFinal) return 'اتاق نهایی';
    if (stageIndex == 0) return 'دور مقدماتی';
    return 'مرحله ${_tmDigits(stageIndex + 1)}';
  }

  DateTime? uploadEndsAt;
  int roomNo = 1;

  bool get inUpload => uploadEndsAt != null && endsAt == null && !finished;

  String get uploadClock {
    final DateTime? u = uploadEndsAt;
    if (u == null) return '00:00';
    Duration d = u.difference(DateTime.now());
    if (d.isNegative) d = Duration.zero;
    final String mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final String ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return mm + ':' + ss;
  }

  void beginUpload(Duration d) {
    if (finished || endsAt != null || uploadEndsAt != null) return;
    uploadEndsAt = DateTime.now().add(d);
    kUpStamp = DateTime.now();
  }

  bool get started => endsAt != null;

  bool get timeUp => endsAt != null && !DateTime.now().isBefore(endsAt!);

  Duration get remaining {
    final DateTime? e = endsAt;
    if (e == null) return kRoomDuration;
    final Duration d = e.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  void start() {
    if (finished || endsAt != null) return;
    endsAt = DateTime.now().add(voteFor(stageIndex));
    kVoteStamp = DateTime.now();
  }

  CompetitionEntry? get me {
    for (final CompetitionEntry e in entries) {
      if (e.isMe) return e;
    }
    return null;
  }

  bool get advancedMe => winners.any((e) => e.isMe);

  /// رتبه‌بندی نهایی (فقط کسانی که فیلم گذاشته‌اند)
  List<CompetitionEntry> get ranked {
    final List<CompetitionEntry> l = entries.where((e) => e.hasVideo).toList();
    l.sort((a, b) => b.total.compareTo(a.total));
    return l;
  }

  void placeMe(String username) {
    final int idx = math.Random().nextInt(entries.length);
    entries[idx] = _makeEntry(
      roomId: id,
      username: username,
      seat: idx + 1,
      isMe: true,
    );
  }
}

/// صنف اصلی یک صنف (زیرمجموعه‌ها به اتاق صنف اصلی خودشان می‌روند)
String tournamentRootCategory(String id) {
  String cur = id;
  for (int guard = 0; guard < 10; guard++) {
    Map<String, dynamic>? found;
    for (final Map<String, dynamic> c in CategoryStore.I.all) {
      if (c['id'] == cur) found = c;
    }
    final String? p = found?['parentId'] as String?;
    if (p == null) return cur;
    cur = p;
  }
  return cur;
}

// ---------------------------------------------------------------------
// حافظه‌ی مسابقات
// ---------------------------------------------------------------------
class TournamentStore extends ChangeNotifier {
  TournamentStore._();
  static final TournamentStore I = TournamentStore._();

  final Set<String> champions = <String>{};
  final Map<String, List<CompetitionRoom>> _rooms =
      <String, List<CompetitionRoom>>{};

  /// اتاق‌ها در roomsOfCategory ساخته می‌شوند (صنف جدید = اتاق جدید)
  void ensureBuilt() {}

  List<CompetitionRoom> stageReps(String cid) {
    final List<CompetitionRoom> all = roomsOfCategory(cid);
    final Map<int, CompetitionRoom> m = <int, CompetitionRoom>{};
    for (final CompetitionRoom r in all) {
      final CompetitionRoom? cur = m[r.stageIndex];
      if (cur == null || (cur.me == null && r.me != null)) {
        m[r.stageIndex] = r;
      }
    }
    final List<int> keys = m.keys.toList()..sort();
    return keys.map((k) => m[k]!).toList();
  }

  List<CompetitionRoom> roomsOfCategory(String cid) {
    if (!_rooms.containsKey(cid) &&
        cid != 'all' &&
        !CategoryStore.I.hasChildren(cid) &&
        categoryTitleOf(cid) != cid) {
      final int ci =
          CategoryStore.I.selectable.indexWhere((c) => c['id'] == cid);
      final String t = categoryTitleOf(cid);
      _rooms[cid] = List<CompetitionRoom>.generate(kPrelimRooms, (r) {
        final String roomId = 'room_${cid}_${r + 1}';
        return CompetitionRoom(
          id: roomId,
          title: 'اتاق ${_tmDigits(r + 1)} — دور مقدماتی — $t',
          stageIndex: 0,
          categoryId: cid,
          entries: List<CompetitionEntry>.generate(
            kRoomSize,
            (i) => _makeEntry(
              roomId: roomId,
              username: 'استعداد_${ci + 1}_${r * kRoomSize + i + 1}',
              seat: i + 1,
            ),
          ),
        )..roomNo = r + 1;
      });
    }
    return List<CompetitionRoom>.of(_rooms[cid] ?? <CompetitionRoom>[]);
  }

  List<CompetitionRoom> _roomsOfCategoryOld(String cid) {
    if (!_rooms.containsKey(cid) &&
        cid != 'all' &&
        !CategoryStore.I.hasChildren(cid) &&
        categoryTitleOf(cid) != cid) {
      final String roomId = 'room_$cid';
      final int ci =
          CategoryStore.I.selectable.indexWhere((c) => c['id'] == cid);
      _rooms[cid] = <CompetitionRoom>[
        CompetitionRoom(
          id: roomId,
          title: 'اتاق مقدماتی — ${categoryTitleOf(cid)}',
          stageIndex: 0,
          categoryId: cid,
          entries: List<CompetitionEntry>.generate(
            kRoomSize,
            (i) => _makeEntry(
              roomId: roomId,
              username: 'استعداد_${ci + 1}_${i + 1}',
              seat: i + 1,
            ),
          ),
        ),
      ];
    }
    return List<CompetitionRoom>.of(_rooms[cid] ?? <CompetitionRoom>[]);
  }

  CompetitionRoom? roomOfMe() {
    for (final List<CompetitionRoom> list in _rooms.values) {
      for (final CompetitionRoom r in list) {
        if (r.me != null) return r;
      }
    }
    return null;
  }

  /// وارد اتاق مقدماتی صنف خودت می‌شوی
  CompetitionRoom joinRandomRoom() {
    final CompetitionRoom? existing = roomOfMe();
    if (existing != null) return existing;
    String cid = AppState.I.myField;
    if (cid.isEmpty || CategoryStore.I.hasChildren(cid)) {
      cid = CategoryStore.I.selectable
          .where((c) => !CategoryStore.I.hasChildren(c['id'] as String))
          .first['id'] as String;
    }
    final List<CompetitionRoom> rs =
        roomsOfCategory(cid).where((r) => r.stageIndex == 0).toList();
    final CompetitionRoom target = rs[math.Random().nextInt(rs.length)];
    target.placeMe(kMyUsername);
    notifyListeners();
    return target;
  }

  CompetitionRoom _joinRandomRoomOld() {
    final CompetitionRoom? existing = roomOfMe();
    if (existing != null) return existing;
    String cid = AppState.I.myField;
    if (cid.isEmpty || CategoryStore.I.hasChildren(cid)) {
      cid = CategoryStore.I.selectable
          .where((c) => !CategoryStore.I.hasChildren(c['id'] as String))
          .first['id'] as String;
    }
    final CompetitionRoom target = roomsOfCategory(cid).first;
    target.placeMe(kMyUsername);
    notifyListeners();
    return target;
  }

  void attachVideo(CompetitionEntry e, XFile f) {
    e.file = f;
    notifyListeners();
  }

  void submitScore(CompetitionEntry e, int score) {
    e.myScore = score.toDouble();
    notifyListeners();
  }

  void likeEntry(CompetitionEntry e) {
    e.liked = !e.liked;
    e.likes += e.liked ? 1 : -1;
    notifyListeners();
  }

  void bumpViews(CompetitionEntry e) {
    e.views++;
    notifyListeners();
  }

  void shareEntry(CompetitionEntry e) {
    e.shares++;
    notifyListeners();
  }

  void toggleSave(CompetitionEntry e) {
    e.saved = !e.saved;
    if (e.saved) {
      CollectionStore.I.saveItem(
        SavedItem(
          id: e.id,
          url: avatarUrl(e.username),
          title: 'فیلم ${e.username}',
        ),
      );
    } else {
      CollectionStore.I.unsave(e.id);
    }
    notifyListeners();
  }

  void touch() => notifyListeners();

  bool commentsOpen(String cid) {
    final List<CompetitionRoom> r = _rooms[cid] ?? <CompetitionRoom>[];
    return r.isNotEmpty && r.last.isChampions;
  }

  List<CompetitionRoom> get championRooms =>
      _rooms.values.expand((l) => l).where((r) => r.isChampions).toList();

  bool guildDone(String cid) {
    final List<Map<String, dynamic>> kids = CategoryStore.I.childrenOf(cid);
    if (kids.isEmpty) {
      final List<CompetitionRoom> r = _rooms[cid] ?? <CompetitionRoom>[];
      return r.isNotEmpty && r.last.isChampions;
    }
    return kids.every((k) {
      final List<CompetitionRoom> r =
          _rooms[k['id'] as String] ?? <CompetitionRoom>[];
      return r.isNotEmpty && r.last.isChampions;
    });
  }

  /// شروع همزمان همه‌ی اتاق‌ها (فقط ادمین)
  Timer? _autoClose;

  void _phaseTick() {
    final DateTime now = DateTime.now();
    for (final List<CompetitionRoom> l
        in List<List<CompetitionRoom>>.of(_rooms.values)) {
      for (final CompetitionRoom r in List<CompetitionRoom>.of(l)) {
        if (r.finished || r.isChampions) continue;
        if (r.endsAt == null &&
            r.uploadEndsAt == null &&
            r.stageIndex > 0 &&
            r.me == null &&
            false) {
          r.beginUpload(upFor(r.stageIndex));
        }
        final DateTime? u = r.uploadEndsAt;
        if (r.endsAt == null && u != null && !now.isBefore(u)) {
          r.endsAt = now.add(voteFor(r.stageIndex));
          kVoteStamp = now;
          notifyListeners();
        }
      }
    }
  }

  void _watch() {
    _autoClose ??= Timer.periodic(const Duration(seconds: 1), (_) {
      _phaseTick();
      for (final List<CompetitionRoom> l
          in List<List<CompetitionRoom>>.of(_rooms.values)) {
        for (final CompetitionRoom r in List<CompetitionRoom>.of(l)) {
          if (r.started && !r.finished && !r.isChampions && r.timeUp) {
            closeRoom(r);
          }
        }
      }
    });
  }

  bool get stageRunning => _rooms.values.expand((l) => l).any((r) =>
      !r.finished && !r.isChampions && (r.started || r.uploadEndsAt != null));

  int startAll() {
    _watch();
    for (final Map<String, dynamic> c in CategoryStore.I.selectable) {
      roomsOfCategory(c['id'] as String);
    }
    if (stageRunning) return -2;
    int? st;
    for (final List<CompetitionRoom> l in _rooms.values) {
      for (final CompetitionRoom r in l) {
        if (r.finished ||
            r.isChampions ||
            r.started ||
            r.uploadEndsAt != null) {
          continue;
        }
        if (st == null || r.stageIndex < st) st = r.stageIndex;
      }
    }
    if (st == null) return 0;
    kVoteStamp = null;
    int n = 0;
    for (final List<CompetitionRoom> l in _rooms.values) {
      bool any = false;
      for (final CompetitionRoom r in l) {
        if (r.stageIndex != st ||
            r.isChampions ||
            r.finished ||
            r.started ||
            r.uploadEndsAt != null) {
          continue;
        }
        r.beginUpload(upFor(r.stageIndex));
        any = true;
      }
      if (any) n++;
    }
    notifyListeners();
    return n;
  }

  int _startAllV1() {
    _watch();
    for (final Map<String, dynamic> c in CategoryStore.I.selectable) {
      roomsOfCategory(c['id'] as String);
    }
    int n = 0;
    for (final List<CompetitionRoom> list in _rooms.values) {
      bool any = false;
      for (final CompetitionRoom r in list) {
        if (r.isChampions ||
            r.finished ||
            r.started ||
            r.uploadEndsAt != null) {
          continue;
        }
        r.beginUpload(upFor(r.stageIndex));
        any = true;
      }
      if (any) n++;
    }
    notifyListeners();
    return n;
  }

  int _startAllOld() {
    _watch();
    int n = 0;
    for (final Map<String, dynamic> c in CategoryStore.I.selectable) {
      roomsOfCategory(c['id'] as String);
    }
    for (final List<CompetitionRoom> list in _rooms.values) {
      if (list.isEmpty) continue;
      final CompetitionRoom r = list.last;
      if (!r.finished && !r.started) {
        r.beginUpload(upFor(r.stageIndex));
        n++;
      }
    }
    notifyListeners();
    return n;
  }

  /// پایان زمان اتاق: برندگان مشخص می‌شوند و اتاق بعدی ساخته می‌شود
  void closeRoom(CompetitionRoom room) {
    if (room.finished) return;
    room.finished = true;
    final List<CompetitionEntry> ranked = room.ranked;
    for (final CompetitionEntry se in ranked) {
      _sumScores[se.username] = (_sumScores[se.username] ?? 0) + se.total;
    }
    final String cid = room.categoryId;
    final String catTitle = categoryTitleOf(cid);
    final List<CompetitionRoom> list =
        _rooms.putIfAbsent(cid, () => <CompetitionRoom>[]);
    if (room.isChampions) {
      notifyListeners();
      return;
    }
    if (room.isFinal) {
      final List<CompetitionEntry> top = _topWithMe(room, ranked);
      champions.addAll(top.map((e) => e.username));
      room.winners = ranked.take(3).toList();
      if (!list.any((r) => r.isChampions)) {
        list.add(
          CompetitionRoom(
            id: 'champions_$cid',
            title: 'برترین‌های $catTitle 🏆',
            stageIndex: room.stageIndex + 1,
            categoryId: cid,
            entries: top,
            isFinal: true,
            isChampions: true,
            finished: true,
          )..winners = ranked.take(3).toList(),
        );
      }
      notifyListeners();
      return;
    }
    final List<CompetitionRoom> stage =
        list.where((r) => r.stageIndex == room.stageIndex).toList();
    final int n = ranked.length;
    final int adv =
        stage.length == 1 ? math.min(n, kFinalSize) : (n / 2).ceil();
    room.winners = ranked.take(adv).toList();
    if (!stage.every((r) => r.finished) ||
        list.any((r) => r.stageIndex > room.stageIndex)) {
      notifyListeners();
      return;
    }
    final List<CompetitionEntry> pool = <CompetitionEntry>[];
    for (final CompetitionRoom r in stage) {
      pool.addAll(r.winners);
    }
    if (pool.isEmpty) {
      notifyListeners();
      return;
    }
    final int nextStage = room.stageIndex + 1;
    final bool nextIsFinal = pool.length <= kFinalSize;
    final int roomCount = nextIsFinal ? 1 : (pool.length / kRoomSize).ceil();
    final int per = (pool.length / roomCount).ceil();
    for (int k = 0; k < roomCount; k++) {
      final int s = k * per;
      if (s >= pool.length) break;
      final int e = math.min(s + per, pool.length);
      final String nextId = 'stage${nextStage}_${cid}_${k + 1}';
      final List<CompetitionEntry> es = <CompetitionEntry>[];
      for (int i = s; i < e; i++) {
        final CompetitionEntry w = pool[i];
        es.add(
          _makeEntry(
            roomId: nextId,
            username: w.username,
            seat: i - s + 1,
            isMe: w.isMe,
          ),
        );
      }
      list.add(
        CompetitionRoom(
          id: nextId,
          title: nextIsFinal
              ? 'اتاق نهایی — $catTitle'
              : 'اتاق ${_tmDigits(k + 1)} — مرحله ${_tmDigits(nextStage + 1)} — $catTitle',
          stageIndex: nextStage,
          categoryId: cid,
          entries: es,
          isFinal: nextIsFinal,
        )..roomNo = k + 1,
      );
    }
    notifyListeners();
  }

  void _closeRoomOld(CompetitionRoom room) {
    if (room.finished) return;
    room.finished = true;
    final List<CompetitionEntry> ranked = room.ranked;
    for (final CompetitionEntry se in ranked) {
      _sumScores[se.username] = (_sumScores[se.username] ?? 0) + se.total;
    }
    final String cid = room.categoryId;
    final String catTitle = categoryTitleOf(cid);
    final List<CompetitionRoom> list =
        _rooms.putIfAbsent(cid, () => <CompetitionRoom>[]);
    final bool nextExists = list.any((r) => r.stageIndex > room.stageIndex);
    if (room.isChampions || ranked.isEmpty || nextExists) {
      notifyListeners();
      return;
    }
    if (room.isFinal) {
      champions.addAll(_topWithMe(room, ranked).map((e) => e.username));
      room.winners = ranked.take(3).toList();
      list.add(
        CompetitionRoom(
          id: 'champions_$cid',
          title: 'برترین‌های $catTitle 🏆',
          stageIndex: room.stageIndex + 1,
          categoryId: cid,
          entries: _topWithMe(room, ranked),
          isFinal: true,
          isChampions: true,
          finished: true,
        )..winners = ranked.take(3).toList(),
      );
      notifyListeners();
      return;
    }
    final int n = ranked.length;
    final int adv = math.min(n, math.max(kFinalSize, (n / 2).ceil()));
    room.winners = ranked.take(adv).toList();
    final int nextStage = room.stageIndex + 1;
    final bool nextIsFinal = adv <= kFinalSize;
    final String nextId = 'stage${nextStage}_$cid';
    final List<CompetitionEntry> nextEntries = <CompetitionEntry>[];
    for (int i = 0; i < room.winners.length; i++) {
      final CompetitionEntry w = room.winners[i];
      nextEntries.add(
        _makeEntry(
          roomId: nextId,
          username: w.username,
          seat: i + 1,
          isMe: w.isMe,
        ),
      );
    }
    list.add(
      CompetitionRoom(
        id: nextId,
        title: nextIsFinal
            ? 'اتاق نهایی — $catTitle'
            : '$catTitle — مرحله ${_tmDigits(nextStage + 1)}',
        stageIndex: nextStage,
        categoryId: cid,
        entries: nextEntries,
        isFinal: nextIsFinal,
      ),
    );
    notifyListeners();
  }
}

void showGuildWelcome(BuildContext context, CompetitionRoom room) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E28),
      title: const Text('به مسابقات باراوی خوش آمدید 🏆'),
      content: const Text(
        'مسابقات فقط بین کاربران پنج‌ستاره برگزار می‌شود و هر صنف، با همه‌ی زیرمجموعه‌هایش، یک اتاق جدا دارد. پنج‌ستاره‌ها یک ماه وقت دارند فیلم‌های خاص خودشان را برای مسابقات آماده کنند (هر فیلم حداکثر یک دقیقه).\n\n'
        'هر شرکت‌کننده یک فیلم در اتاق صنف خودش می‌گذارد. مردم وارد اتاق می‌شوند، فیلم‌ها را می‌بینند و از ۱ تا ۱۰۰ نمره می‌دهند. '
        'نمره‌ها محرمانه است و هیچ‌کس آن‌ها را نمی‌بیند.\n\n'
        'وقتی زمان اتاق تمام شود، برندگان بالای صفحه اعلام می‌شوند و به اتاق بعدی می‌روند، '
        'تا برسیم به اتاق نهایی و برترین‌های آن صنف.',
        style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.7),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'متوجه شدم',
            style: TextStyle(
              color: Color(0xFF00E5FF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------
// صفحه‌ی فهرست اتاق‌های صنفی
// ---------------------------------------------------------------------
class GuildTournamentScreen extends StatelessWidget {
  const GuildTournamentScreen({super.key});

  Widget _adminBar0(BuildContext context) {
    if (!kIsAdmin) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF0055),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: const Size(0, 34),
          ),
          onPressed: () {
            final int n = TournamentStore.I.startAll();
            showSnack(
              context,
              n == 0
                  ? 'اتاقی برای شروع وجود ندارد'
                  : n < 0
                      ? 'این مرحله هنوز تمام نشده؛ بعد از پایان آپلود و رأی‌گیری دوباره بزن'
                      : 'مرحله برای ${_tmDigits(n)} صنف شروع شد 🚀',
            );
          },
          icon: const Icon(Icons.play_arrow_rounded, size: 18),
          label: const Text(
            'شروع مسابقات / مرحله‌ی بعد',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _adminBarOld(BuildContext context) {
    if (!kIsAdmin) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF0055),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
          onPressed: () {
            final int n = TournamentStore.I.startAll();
            showSnack(
              context,
              n == 0
                  ? 'اتاقی برای شروع وجود ندارد'
                  : n < 0
                      ? 'این مرحله هنوز تمام نشده؛ بعد از پایان آپلود و رأی‌گیری دوباره بزن'
                      : 'مرحله برای ${_tmDigits(n)} صنف شروع شد 🚀',
            );
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text(
            'شروع همزمان مسابقات همه‌ی صنف‌ها',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _banner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF12303A), Color(0xFF1E1228)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00E5FF), width: 0.6),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Color(0xFFFFB300), size: 34),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'ویژه‌ی پنج‌ستاره‌ها: فیلم‌های خاص خودتان را برای مسابقات آماده کنید؛ یک ماه وقت دارید. هر فیلم حداکثر یک دقیقه است. نمره‌ها تا پایان زمان محرمانه می‌ماند.',
              style:
                  TextStyle(color: Colors.white70, fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مسابقات باراوی 🏆')),
      body: AnimatedBuilder(
        animation: Listenable.merge(
          <Listenable>[TournamentStore.I, CategoryStore.I],
        ),
        builder: (context, _) {
          TournamentStore.I.ensureBuilt();
          return ListView(
            padding: const EdgeInsets.all(14),
            children: <Widget>[
              const GuildPicker(),
              const SizedBox(height: 10),
              _adminBar0(context),
              const TwoClocks(),
              _banner(),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------
// صفحه‌ی یک اتاق: فیلم‌ها، نمره‌دهی محرمانه، برندگان بالای صفحه
// ---------------------------------------------------------------------
class GuildHubScreen extends StatelessWidget {
  final String categoryId;
  const GuildHubScreen({super.key, required this.categoryId});

  String _status(CompetitionRoom r) {
    if (r.isChampions) return 'برترین‌ها اعلام شدند';
    if (r.finished) return 'پایان‌یافته';
    if (r.started) return 'در حال برگزاری';
    return 'منتظر شروع';
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF12303A), Color(0xFF1E1228)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00E5FF), width: 0.6),
      ),
      child: Text(
        'همه‌ی زیرصنف‌های ${categoryTitleOf(categoryId)} در این اتاق هستند. زیرصنف خودت را بزن تا وارد دور مقدماتی همان زیرصنف شوی و تا پایان فقط با هم‌رشته‌ای‌هایت رقابت کنی.',
        style:
            const TextStyle(color: Colors.white70, fontSize: 12, height: 1.7),
      ),
    );
  }

  Widget _subCard(BuildContext context, Map<String, dynamic> c) {
    final String sid = c['id'] as String;
    final List<CompetitionRoom> rooms = TournamentStore.I.roomsOfCategory(sid);
    if (rooms.isEmpty) return const SizedBox.shrink();
    final CompetitionRoom cur = rooms.last;
    final bool mine = AppState.I.myField == sid;
    final bool done = cur.isChampions;
    void open() {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => GuildRoomScreen(room: cur),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done
              ? const Color(0xFFFF1744)
              : (mine ? const Color(0xFF00E5FF) : const Color(0xFF2A2A38)),
          width: (done || mine) ? 1.4 : 0.8,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: open,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 62,
                height: 62,
                child: Center(
                  child: InteractiveBaraviCube(
                    size: 50,
                    totalStories: 4,
                    isProfileMode: true,
                    seedKey: 'guild_cube_$sid',
                    rotationDuration: const Duration(seconds: 7),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مسابقات ${c['title']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cur.stageLabel} • ${_status(cur)}',
                      style: TextStyle(
                        color: mine ? const Color(0xFF00E5FF) : Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_tmDigits(cur.entries.length)} شرکت‌کننده',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    if (mine)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x2200E5FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'زیرصنف شما',
                          style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              done
                  ? const Icon(Icons.verified,
                      size: 22, color: Color(0xFFFF1744))
                  : const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مسابقات ${categoryTitleOf(categoryId)}')),
      body: AnimatedBuilder(
        animation: Listenable.merge(
          <Listenable>[TournamentStore.I, CategoryStore.I],
        ),
        builder: (context, _) {
          final List<Map<String, dynamic>> subs =
              CategoryStore.I.childrenOf(categoryId);
          subs.sort(
            (a, b) =>
                (AppState.I.myField == b['id'] ? 1 : 0) -
                (AppState.I.myField == a['id'] ? 1 : 0),
          );
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: subs.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) return _header();
              return _subCard(context, subs[i - 1]);
            },
          );
        },
      ),
    );
  }
}

class GuildRoomScreen extends StatefulWidget {
  final CompetitionRoom room;
  const GuildRoomScreen({super.key, required this.room});

  @override
  State<GuildRoomScreen> createState() => _GuildRoomScreenState();
}

class _GuildRoomScreenState extends State<GuildRoomScreen> {
  Timer? _ticker;
  String _q = '';
  final TextEditingController _qc = TextEditingController();

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
      child: TextField(
        controller: _qc,
        textDirection: TextDirection.rtl,
        onChanged: (v) => setState(() => _q = v),
        decoration: InputDecoration(
          hintText: 'جستجوی نام شرکت‌کننده در این اتاق...',
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _q.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _qc.clear();
                    setState(() => _q = '');
                  },
                ),
          isDense: true,
          filled: true,
          fillColor: const Color(0xFF22222E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  late CompetitionRoom _room = widget.room;

  @override
  void initState() {
    super.initState();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _qc.dispose();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    final CompetitionRoom r = _room;
    final List<CompetitionRoom> rs =
        TournamentStore.I.roomsOfCategory(r.categoryId);
    if (rs.isNotEmpty &&
        rs.last.isChampions &&
        rs.last.me != null &&
        _kCelebrated.add(rs.last.id)) {
      showCelebration(context);
    }
    if (r.started && !r.finished && !r.isChampions && r.timeUp) {
      TournamentStore.I.closeRoom(r);
      showSnack(context, 'زمان این اتاق تمام شد؛ برندگان اعلام شدند 🏆');
    }
    setState(() {});
  }

  void _openRoom(CompetitionRoom r) {
    if (r.me != null &&
        !r.finished &&
        !r.started &&
        r.uploadEndsAt == null &&
        r.stageIndex > 0 &&
        false) {
      r.beginUpload(upFor(r.stageIndex));
      showSnack(context,
          '${_tmDigits(upFor(r.stageIndex).inSeconds)} ثانیه وقت دارید فیلمتان را آپلود کنید 🎬');
    }
    _kActiveEntry.value = null;
    setState(() => _room = r);
  }

  Future<void> _upload(CompetitionEntry me) async {
    if (_room.started || _room.finished) {
      showSnack(context, 'مهلت آپلود فیلم تمام شده است');
      return;
    }
    if (kMyStars < 5) {
      showSnack(
          context, 'فقط کاربران پنج‌ستاره می‌توانند در مسابقات فیلم بگذارند');
      return;
    }
    final bool? five = kMyStars >= 5
        ? true
        : await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E28),
              title: const Text('تأیید پنج‌ستاره بودن'),
              content: const Text(
                'آیا شما کاربر پنج‌ستاره هستید؟ فقط پنج‌ستاره‌ها می‌توانند فیلم بگذارند و داشتن تیک آبی به‌تنهایی کافی نیست.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('خیر'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'بله، پنج‌ستاره هستم',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
    if (five != true || !mounted) return;
    if (kMyStars < 5) {
      showSnack(context, 'شما پنج‌ستاره نیستید و نمی‌توانید فیلم بگذارید');
      return;
    }
    final XFile? f = await pickVideoFromDevice();
    if (f == null || !mounted) return;
    final VideoPlayerController probe =
        VideoPlayerController.networkUrl(Uri.parse(f.path));
    try {
      await probe.initialize();
      final int secs = probe.value.duration.inSeconds;
      await probe.dispose();
      if (!mounted) return;
      if (secs > 60) {
        showSnack(context, 'فیلم باید حداکثر یک دقیقه باشد');
        return;
      }
    } catch (_) {
      await probe.dispose();
    }
    if (!mounted) return;
    TournamentStore.I.attachVideo(me, f);
    showSnack(context, 'فیلم شما در اتاق قرار گرفت 🎬');
  }

  Widget _stageChips(List<CompetitionRoom> rooms) {
    return const SizedBox.shrink();
  }

  Widget _stageChipsOld(List<CompetitionRoom> rooms) {
    if (rooms.length <= 1) return const SizedBox.shrink();
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: rooms.map((r) {
          final bool sel = identical(r, _room);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(r.stageLabel),
              selected: sel,
              selectedColor: const Color(0xFF00E5FF),
              backgroundColor: const Color(0xFF1C1C24),
              labelStyle: TextStyle(
                color: sel ? Colors.black : Colors.white70,
                fontSize: 12,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) => _openRoom(r),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _statusPanel(CompetitionRoom room) {
    final Duration rem = room.remaining;
    final String mm = (rem.inMinutes % 60).toString().padLeft(2, '0');
    final String ss = (rem.inSeconds % 60).toString().padLeft(2, '0');
    final double progress = room.finished
        ? 1.0
        : (1.0 - rem.inMilliseconds / voteFor(room.stageIndex).inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();
    final int withVideo = room.entries.where((e) => e.hasVideo).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF12303A), Color(0xFF1E1228)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00E5FF), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room.title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            '${_tmDigits(room.entries.length)} شرکت‌کننده • ${_tmDigits(withVideo)} فیلم در اتاق',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 12),
          if (room.isChampions)
            const Text(
              'برترین‌های این صنف مشخص شدند 🏆',
              style: TextStyle(
                color: Color(0xFFFFB300),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            )
          else if (room.inUpload)
            Row(
              children: [
                const Icon(Icons.upload_rounded,
                    size: 16, color: Color(0xFFFFB300)),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'مهلت آپلود فیلم؛ بعد از پایان زمان، رأی‌گیری خودکار شروع می‌شود',
                    style: TextStyle(
                        color: Color(0xFFFFB300),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                Text(
                  _tmDigits(room.uploadClock),
                  style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.w900,
                      fontSize: 22),
                ),
              ],
            )
          else if (!room.started)
            const Text(
              'منتظر شروع مسابقات توسط مدیر؛ تا آن زمان فیلم خود را آماده و آپلود کنید ⏳',
              style: TextStyle(
                color: Color(0xFFFFB300),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            )
          else if (room.finished)
            const Text(
              'رأی‌گیری بسته شد ✅',
              style: TextStyle(
                color: Color(0xFF00C853),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.fiber_manual_record,
                    size: 12, color: Color(0xFFFF0055)),
                const SizedBox(width: 6),
                const Text(
                  'رأی‌گیری زنده',
                  style: TextStyle(
                    color: Color(0xFFFF0055),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  _tmDigits('$mm:$ss'),
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFF282836),
              valueColor: AlwaysStoppedAnimation<Color>(
                room.finished
                    ? const Color(0xFF00C853)
                    : const Color(0xFF00E5FF),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.lock_outline, size: 13, color: Colors.grey),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'نمره‌ها محرمانه است و هیچ‌کس نمی‌تواند آن‌ها را ببیند.',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _winnersPanel(CompetitionRoom room) {
    final List<CompetitionEntry> list =
        room.isChampions ? room.entries : room.winners;
    if (list.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A2A08), Color(0xFF1E1228)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB300), width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room.isChampions
                ? '🏆 برترین‌های این صنف'
                : '🏆 برندگان این اتاق (${_tmDigits(list.length)} نفر به اتاق بعدی رفتند)',
            style: const TextStyle(
              color: Color(0xFFFFB300),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 128,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              itemBuilder: (context, i) => _winnerTile(i, list[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _winnerTile(int i, CompetitionEntry e) {
    final bool top = i < 3;
    void open() => openUserByName(context, e.username);
    return Container(
      width: 86,
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: top ? const Color(0xFFFFB300) : const Color(0xFF2A2A38),
          width: top ? 1.4 : 0.8,
        ),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              InteractiveBaraviCube(
                size: top ? 50 : 44,
                totalStories: 4,
                isProfileMode: true,
                seedKey: 'comp_${e.username}',
                rotationDuration: const Duration(seconds: 8),
              ),
              Positioned(
                left: -4,
                bottom: -4,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor:
                      top ? const Color(0xFFFFB300) : const Color(0xFF2A2A38),
                  child: Text(
                    _tmDigits(i + 1),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: top ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: open,
            child: Text(
              e.isMe ? '${e.username} (شما)' : e.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: e.isMe ? const Color(0xFF00E5FF) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            TournamentStore.I.commentsOpen(_room.categoryId)
                ? _tmDigits((_sumScores[e.username] ?? e.total).round())
                : '🔒',
            style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFFFB300),
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _myNextPanel(CompetitionRoom room) {
    final List<CompetitionRoom> rooms =
        TournamentStore.I.stageReps(room.categoryId);
    final int idx = rooms.indexWhere((r) => identical(r, room));
    final CompetitionRoom? next =
        (idx >= 0 && idx + 1 < rooms.length) ? rooms[idx + 1] : null;
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00C853)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'تبریک! شما صعود کردید 🎉 با زدن دکمه به مرحله‌ی بعد بروید و فیلم بگذارید.',
              style: TextStyle(
                  color: Color(0xFF00C853),
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          if (next != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black),
              onPressed: () => _openRoom(next),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text('رفتن به ${next.stageLabel}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _myPanel(CompetitionRoom room) {
    if (!room.finished || room.me == null) return const SizedBox.shrink();
    if (room.advancedMe) return _myNextPanel(room);
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A38)),
      ),
      child: const Text(
        'این بار به اتاق بعدی نرسیدید؛ به تلاش ادامه بده 💪',
        style: TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _hallButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB300),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const ChampionsHall2()),
          ),
          icon: const Icon(Icons.emoji_events),
          label: const Text('رفتن به تالار برترین‌های صنف‌ها',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TournamentStore.I,
      builder: (context, _) {
        final CompetitionRoom room = _room;
        final List<CompetitionRoom> rooms =
            TournamentStore.I.stageReps(room.categoryId);
        final List<CompetitionEntry> shown = room.finished
            ? room.ranked
            : List<CompetitionEntry>.of(room.entries);
        final String q = _q.trim();
        final List<CompetitionEntry> view = <CompetitionEntry>[
          ...shown.where((e) => e.isMe),
          ...shown.where((e) => !e.isMe),
        ].where((e) => q.isEmpty || e.username.contains(q)).toList();
        final List<Widget> headers = <Widget>[
          _searchBox(),
          _stageChips(rooms),
          _statusPanel(room),
          if (room.finished) _winnersPanel(room),
          if (room.isChampions) _hallButton(),
          _myPanel(room),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Text(
              room.isChampions ? 'فیلم برترین‌ها' : 'فیلم‌های این اتاق',
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ];
        return Scaffold(
          appBar: AppBar(
            title: Text('مسابقات ${categoryTitleOf(room.categoryId)}'),
          ),
          body: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: headers.length + view.length,
            itemBuilder: (context, i) {
              if (i < headers.length) return headers[i];
              final CompetitionEntry e = view[i - headers.length];
              return EntryCard(
                key: ValueKey<String>(e.id),
                room: room,
                entry: e,
                onNext: () {
                  final int ix = rooms.indexWhere((r) => identical(r, room));
                  if (ix < 0 || ix + 1 >= rooms.length) return;
                  if (e.isMe || kMyStars < 5) {
                    _openRoom(rooms[ix + 1]);
                  } else {
                    showSnack(
                        context, 'فقط خود شخص می‌تواند به مرحله بعد برود');
                  }
                },
                onUpload: () {
                  if (e.isMe) {
                    _upload(e);
                  } else {
                    showSnack(
                        context, 'فقط خود شخص می‌تواند فیلم خودش را آپلود کند');
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
// کارت فیلم هر شرکت‌کننده: مکعب، فیلم، لایک، نظر، اشتراک، ذخیره، نمره
// ---------------------------------------------------------------------
class EntryCard extends StatefulWidget {
  final CompetitionRoom room;
  final CompetitionEntry entry;
  final VoidCallback? onUpload;
  final VoidCallback? onNext;
  const EntryCard(
      {super.key,
      required this.room,
      required this.entry,
      this.onUpload,
      this.onNext});

  @override
  State<EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<EntryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heart;
  VideoPlayerController? _vc;
  bool _ready = false;
  bool _failed = false;

  CompetitionEntry get _e => widget.entry;

  @override
  void initState() {
    super.initState();
    _heart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _kActiveEntry.addListener(_onActive);
  }

  @override
  void dispose() {
    _kActiveEntry.removeListener(_onActive);
    _vc?.dispose();
    _heart.dispose();
    super.dispose();
  }

  void _onActive() {
    if (_kActiveEntry.value != _e.id && _vc != null) _release();
  }

  void _release() {
    _vc?.dispose();
    _vc = null;
    if (mounted) {
      setState(() {
        _ready = false;
      });
    }
  }

  Future<void> _toggle() async {
    final VideoPlayerController? c = _vc;
    if (c == null) {
      _kActiveEntry.value = _e.id;
      await _init();
      return;
    }
    if (!_ready) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
    setState(() {});
  }

  Future<void> _init() async {
    final XFile? f = _e.file;
    final VideoPlayerController c = VideoPlayerController.networkUrl(
      Uri.parse(f != null ? f.path : _e.videoUrl),
    );
    setState(() {
      _vc = c;
      _failed = false;
    });
    try {
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(kReelsMuted ? 0.0 : 1.0);
      if (!mounted || _vc != c) return;
      TournamentStore.I.bumpViews(_e);
      setState(() => _ready = true);
      c.play();
    } catch (_) {
      if (!mounted) return;
      c.dispose();
      setState(() {
        _vc = null;
        _ready = false;
        _failed = true;
      });
    }
  }

  void _likeDouble() {
    if (!_e.liked) TournamentStore.I.likeEntry(_e);
    _heart.forward(from: 0);
  }

  void _openComments() {
    if (!TournamentStore.I.commentsOpen(widget.room.categoryId)) {
      showSnack(
        context,
        'برای محرمانه ماندن نمره‌ها، نظرها تا پایان آخرین مسابقه بسته است. بعد از پایان مسابقه می‌توانید به اتاق‌ها برگردید و برای فیلم‌ها نظر بگذارید.',
      );
      return;
    }
    showCommentsSheet(
      context,
      _e.comments,
      onChanged: () => TournamentStore.I.touch(),
    );
    TournamentStore.I.bumpViews(_e);
  }

  void _share() {
    showShareSheet(
      context,
      link: _e.videoUrl,
      item: SavedItem(
        id: _e.id,
        url: avatarUrl(_e.username),
        title: 'فیلم ${_e.username}',
      ),
      onSaved: () {
        if (!_e.saved) {
          _e.saved = true;
          TournamentStore.I.touch();
        }
      },
    );
    TournamentStore.I.shareEntry(_e);
  }

  void _save() {
    TournamentStore.I.toggleSave(_e);
    if (_e.saved) {
      showCollectionPicker(
        context,
        SavedItem(
          id: _e.id,
          url: avatarUrl(_e.username),
          title: 'فیلم ${_e.username}',
        ),
      );
    }
  }

  Widget _header() {
    final bool canUpload = !widget.room.started &&
        !widget.room.finished &&
        !widget.room.isChampions;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          InteractiveBaraviCube(
            size: 40,
            totalStories: 4,
            isProfileMode: true,
            seedKey: 'comp_${_e.username}',
            rotationDuration: const Duration(seconds: 6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openUserByName(context, _e.username),
                        child: Text(
                          _e.isMe ? '${_e.username} (شما)' : _e.username,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _e.isMe
                                ? const Color(0xFF00E5FF)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    tickBadges(_e.username, red: widget.room.isChampions),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22222E),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'شماره ${_tmDigits(_e.seat)}',
                        style: const TextStyle(
                            color: Color(0xFF00E5FF), fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      children: List<Widget>.generate(
                        5,
                        (i) => Icon(Icons.star,
                            size: 12,
                            color: i < starsOfName(_e.username)
                                ? const Color(0xFFFFB300)
                                : Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  guildPath(widget.room.categoryId),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          if (widget.onNext != null &&
              widget.room.finished &&
              !widget.room.isChampions &&
              widget.room.winners.any((w) => w.username == _e.username))
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 32),
              ),
              onPressed: widget.onNext,
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('رفتن به مرحله بعد',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          if (widget.room.isChampions)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 32),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const ChampionsHall2()),
              ),
              icon: const Icon(Icons.emoji_events, size: 16),
              label: const Text('تالار برترین‌ها',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          if (canUpload)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 32),
              ),
              onPressed: widget.onUpload,
              icon: const Icon(Icons.video_call_outlined, size: 16),
              label: Text(
                _e.isMe && _e.file != null ? 'تغییر فیلم' : 'آپلود فیلم',
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _media() {
    if (!_e.hasVideo) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: const Color(0xFF0B0B0F),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam_off_outlined,
                    color: Colors.white24, size: 56),
                SizedBox(height: 8),
                Text('هنوز فیلمی آپلود نشده',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }
    final VideoPlayerController? c = _vc;
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        onDoubleTap: _likeDouble,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _e.file != null
                ? Container(
                    color: const Color(0xFF0B0B0F),
                    child: const Center(
                      child: Icon(Icons.videocam_rounded,
                          color: Colors.white24, size: 64),
                    ),
                  )
                : Image.network(
                    'https://picsum.photos/seed/${_e.id}/600/600',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFF1E1E28)),
                  ),
            if (c != null && _ready && c.value.size.width > 0)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: c.value.size.width,
                    height: c.value.size.height,
                    child: VideoPlayer(c),
                  ),
                ),
              ),
            if (c != null && !_ready && !_failed)
              const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF00E5FF),
                  ),
                ),
              ),
            if (c != null && _ready)
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: c,
                builder: (context, v, _) {
                  if (v.isPlaying) return const SizedBox.shrink();
                  return const Center(
                    child: Icon(Icons.play_circle_fill,
                        color: Colors.white70, size: 62),
                  );
                },
              )
            else if (c == null)
              Center(
                child: _failed
                    ? const Text(
                        'پخش این فیلم ممکن نشد',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      )
                    : const Icon(Icons.play_circle_fill,
                        color: Colors.white70, size: 62),
              ),
            IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation: _heart,
                  builder: (context, _) {
                    final double v = _heart.value;
                    if (v == 0.0 || v == 1.0) return const SizedBox.shrink();
                    return Opacity(
                      opacity: (1.0 - v).clamp(0.0, 1.0).toDouble(),
                      child: Transform.scale(
                        scale: 0.6 + v * 0.8,
                        child: const Icon(Icons.favorite,
                            color: Colors.white, size: 90),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _act(IconData icon, VoidCallback onTap, {Color c = Colors.white}) {
    int? n;
    if (icon == Icons.favorite || icon == Icons.favorite_border) {
      n = _e.likes;
    } else if (icon == Icons.chat_bubble_outline) {
      n = _e.comments.fold<int>(0, (s, x) => s + 1 + x.replies.length);
    } else if (icon == Icons.share_outlined) {
      n = _e.shares;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
          icon: Icon(icon, color: c, size: 25),
          onPressed: onTap,
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
      icon: Icon(icon, color: c, size: 25),
      onPressed: onTap,
    );
  }

  static const List<String> _seatWords = [
    'یک',
    'دو',
    'سه',
    'چهار',
    'پنج',
    'شش',
    'هفت',
    'هشت',
    'نه',
    'ده',
    'یازده',
    'دوازده',
    'سیزده',
    'چهارده',
    'پانزده',
    'شانزده',
    'هفده',
    'هجده',
    'نوزده',
    'بیست',
  ];

  Widget _seatBadge() {
    final String w = (_e.seat >= 1 && _e.seat <= _seatWords.length)
        ? _seatWords[_e.seat - 1]
        : _tmDigits(_e.seat);
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xCC000000),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF00E5FF)),
        ),
        child: Text(
          'شماره $w',
          style: const TextStyle(
            color: Color(0xFF00E5FF),
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _actions() {
    return Row(
      children: [
        _act(
          _e.liked ? Icons.favorite : Icons.favorite_border,
          () => TournamentStore.I.likeEntry(_e),
          c: _e.liked ? const Color(0xFFFF0055) : Colors.white,
        ),
        _act(Icons.chat_bubble_outline, _openComments),
        _act(Icons.share_outlined, _share),
        const Spacer(),
        const Icon(Icons.visibility_outlined, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          compactCount(_e.views),
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _actionsOld() {
    return Row(
      children: [
        _act(
          _e.liked ? Icons.favorite : Icons.favorite_border,
          () => TournamentStore.I.likeEntry(_e),
          c: _e.liked ? const Color(0xFFFF0055) : Colors.white,
        ),
        _act(Icons.chat_bubble_outline, _openComments),
        _act(Icons.share_outlined, _share),
        const Spacer(),
        const Icon(Icons.visibility_outlined, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          compactCount(_e.views),
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        _act(
          _e.saved ? Icons.bookmark : Icons.bookmark_border,
          _save,
          c: _e.saved ? const Color(0xFFFFB300) : Colors.white,
        ),
      ],
    );
  }

  Widget _info() {
    final int comments =
        _e.comments.fold<int>(0, (s, c) => s + 1 + c.replies.length);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${compactCount(_e.likes)} پسند • ${compactCount(_e.shares)} اشتراک',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _openComments,
            child: Text(
              TournamentStore.I.commentsOpen(widget.room.categoryId)
                  ? 'مشاهده همه ${_tmDigits(comments)} نظر'
                  : 'نظرها تا پایان آخرین مسابقه بسته است 🔒',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rating() {
    if (widget.room.finished) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_lockedBar(), _ratingText(), _votesBtn()],
      );
    }
    return _ratingText();
  }

  Widget _votesBtn() {
    if (!TournamentStore.I.commentsOpen(widget.room.categoryId)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: OutlinedButton.icon(
        onPressed: _showVotes,
        icon: const Icon(Icons.list_alt_rounded, size: 16),
        label: const Text('دیدن نمره‌ی تک‌تک افراد',
            style: TextStyle(fontSize: 12)),
      ),
    );
  }

  Future<void> _showVotes() async {
    int? mine;
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      mine = p.getInt('my_private_score_run${kRunId}_${_e.username}');
    } catch (_) {}
    final int? mem = kMyVotes[_e.username];
    final double? ms = mem != null
        ? mem.toDouble()
        : (mine != null ? mine.toDouble() : _e.myScore);
    final math.Random r = math.Random(_e.id.hashCode & 0x7fffffff);
    final List<MapEntry<String, int>> rows = <MapEntry<String, int>>[];
    for (final TalentUser u in allTalentUsers) {
      if (u.username == _e.username || u.username == kMyUsername) continue;
      rows.add(MapEntry<String, int>(u.username, 1 + r.nextInt(100)));
    }
    if (ms != null) {
      rows.insert(0, MapEntry<String, int>(kMyUsername, ms.round()));
    }
    if (!mounted) return;
    showDarkSheet<void>(
      context,
      (ctx) => SafeArea(
        child: SizedBox(
          height: 460,
          child: Column(
            children: [
              const SizedBox(height: 12),
              sheetHandle(),
              Text('نمره‌های داده‌شده به ${_e.username}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (c, i) {
                    final String n = rows[i].key;
                    return ListTile(
                      dense: true,
                      onTap: () {
                        Navigator.pop(ctx);
                        openUserByName(context, n);
                      },
                      leading: CubeAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF1E1E28),
                        backgroundImage: NetworkImage(avatarUrl(n)),
                        onBackgroundImageError: (_, __) {},
                      ),
                      title: Row(children: [
                        Flexible(
                          child: Text(n == kMyUsername ? '$n (شما)' : n,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: 4),
                        tickBadges(n, size: 13),
                      ]),
                      subtitle: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: starsRow(n),
                      ),
                      trailing: Text(
                        '${_tmDigits(rows[i].value)} از ۱۰۰',
                        style: TextStyle(
                            color: judgeColor(rows[i].value),
                            fontWeight: FontWeight.w900,
                            fontSize: 14),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// نوار قفل‌شده‌ی مرحله‌های تمام‌شده؛ نمره‌ی من فقط برای خودم دیده می‌شود
  Widget _lockedBar() {
    final int? mem = kMyVotes[_e.username];
    final double? s = mem != null ? mem.toDouble() : _e.myScore;
    final double v = (s ?? 0).clamp(0, 100).toDouble();
    const Color cyan = Color(0xFF00E5FF);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A38), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, size: 18, color: cyan),
              const SizedBox(width: 6),
              const Text('نمره‌ی استعدادیابی شما:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                s == null ? '—' : '${_tmDigits(v.round())} از ۱۰۰',
                style: const TextStyle(
                    color: cyan, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              disabledActiveTrackColor: cyan,
              disabledInactiveTrackColor: const Color(0xFF2A2A38),
              disabledThumbColor: cyan,
            ),
            child: Slider(value: v, min: 0, max: 100, onChanged: null),
          ),
          Row(
            children: [
              const Icon(Icons.lock_outline, size: 14, color: cyan),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  s == null
                      ? 'قفل شد؛ شما به این فیلم نمره‌ای ندادید'
                      : 'قفل شد؛ شما ${_tmDigits(v.round())} امتیاز دادید و قابل تغییر نیست (فقط شما می‌بینید)',
                  style: const TextStyle(
                      color: cyan, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingText() {
    if (widget.room.finished) {
      if (!TournamentStore.I.commentsOpen(widget.room.categoryId)) {
        return const Padding(
            padding: EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Text('نمره‌ها بعد از پایان کل مسابقه نمایش داده می‌شود 🔒',
                style: TextStyle(color: Colors.grey, fontSize: 11)));
      }
      final bool ch = widget.room.isChampions;
      final double v = _sumScores[_e.username] ?? _e.total;
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Text(
          ch
              ? 'جمع نمرات همه‌ی مرحله‌ها: ${_tmDigits(v.round())}'
              : 'نمره‌ی این مرحله: ${_tmDigits(_e.total.round())}  •  جمع نمرات تا اینجا: ${_tmDigits(v.round())}',
          style: const TextStyle(
              color: Color(0xFFFFB300),
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
      );
    }
    if (_e.isMe || (kMyStars >= 5 && !kTestRate)) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Text(
          'شرکت‌کننده‌های پنج‌ستاره نمی‌توانند نمره بدهند؛ فقط مردم رأی می‌دهند.',
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
      );
    }
    if (!widget.room.started) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Text(
          'رأی‌گیری پس از شروع مسابقات باز می‌شود.',
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
      );
    }
    if (widget.room.timeUp) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Text(
          'رأی‌گیری این اتاق بسته شده است.',
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
      );
    }
    return MyScoreBar(
      entryId: _e.username,
      onSubmitted: (s) {
        kMyVotes[_e.username] = s;
        TournamentStore.I.submitScore(_e, s);
        SharedPreferences.getInstance()
            .then((p) => p.setString('baravi_myvotes', jsonEncode(kMyVotes)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: const Color(0xFF14141A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          Stack(
            children: [
              _media(),
              Positioned(top: 10, right: 10, child: _seatBadge()),
            ],
          ),
          _actions(),
          _info(),
          _rating(),
        ],
      ),
    );
  }
}

// ---------- نام صنف و زیرصنف (مثلاً: صنعت › تراشکاری) ----------
String guildPath(String catId) {
  final String? p = CategoryStore.I._byId(catId)?['parentId'] as String?;
  final String t = categoryTitleOf(catId);
  return p == null ? t : '${categoryTitleOf(p)} › $t';
}

String guildPathByTitle(String title) {
  final String? id = catIdByTitle(title);
  return id == null ? title : guildPath(id);
}

// ---------- جشن و منور ----------
final Set<String> _kCelebrated = <String>{};

void showCelebration(BuildContext context, {int kind = 1}) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'بستن',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, a, b) => _Confetti(kind: kind),
  );
}

class _Confetti extends StatefulWidget {
  final int kind;
  const _Confetti({this.kind = 1});
  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed && mounted) {
            Navigator.of(context).maybePop();
          }
        })
        ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _FxPainter(_c, widget.kind)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                widget.kind == 0
                    ? '⭐⭐⭐⭐⭐\nتبریک! شما پنج‌ستاره شدید'
                    : (widget.kind == 2
                        ? '🎉 تبریک!\nتیک آبی شما فعال شد 🔵'
                        : '🎉 تبریک!\nتیک قرمز شما فعال شد 🔴'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(blurRadius: 12, color: Colors.black)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FxPainter extends CustomPainter {
  final Animation<double> a;
  final int kind;
  _FxPainter(this.a, this.kind) : super(repaint: a);
  List<Color> get _cols => kind == 0 ? _yel : (kind == 2 ? _blu : _red);
  static const List<Color> _yel = [
    Color(0xFFFFD600),
    Color(0xFFFFB300),
    Color(0xFFFFF176),
    Colors.white,
  ];
  static const List<Color> _blu = [
    Color(0xFF00E5FF),
    Color(0xFF2979FF),
    Color(0xFF80D8FF),
    Colors.white,
  ];
  static const List<Color> _red = [
    Color(0xFFFF1744),
    Color(0xFFD50000),
    Color(0xFFFF5252),
    Colors.white,
  ];

  @override
  void paint(Canvas canvas, Size s) {
    final double t = a.value;
    final math.Random r = math.Random(11);
    final Paint p = Paint();
    for (int i = 0; i < 70; i++) {
      final double x = r.nextDouble() * s.width;
      final double sp = 0.6 + r.nextDouble();
      final double ph = r.nextDouble();
      final double y = ((t * sp + ph) % 1.0) * (s.height + 40) - 20;
      p.color = _cols[i % _cols.length];
      canvas.save();
      canvas.translate(x + math.sin(t * 6 + i) * 12, y);
      canvas.rotate(t * 8 + i);
      canvas.drawRect(const Rect.fromLTWH(-4, -2, 8, 4), p);
      canvas.restore();
    }
    for (int k = 0; k < 5; k++) {
      final double st = t * 2.2 - k * 0.35;
      if (st < 0 || st > 1) continue;
      final Offset c =
          Offset(s.width * (0.15 + 0.17 * k), s.height * (0.2 + 0.1 * (k % 3)));
      final double d = 90 * Curves.easeOut.transform(st);
      for (int j = 0; j < 20; j++) {
        final double ang = j * 2 * math.pi / 20;
        p.color = _cols[(j + k) % _cols.length]
            .withAlpha((255 * (1 - st)).round().clamp(0, 255));
        canvas.drawCircle(
            c + Offset(math.cos(ang) * d, math.sin(ang) * d), 3, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ---------- تالار برترین‌های همه‌ی صنف‌ها (بدون عکس و فیلم؛ لایک و نظر باز) ----------
final Set<String> _hallLiked = <String>{};
final Map<String, List<PostComment>> _hallComments =
    <String, List<PostComment>>{};

class ChampionsHallScreen extends StatefulWidget {
  const ChampionsHallScreen({super.key});
  @override
  State<ChampionsHallScreen> createState() => _ChampionsHallScreenState();
}

class _ChampionsHallScreenState extends State<ChampionsHallScreen> {
  Widget _row(CompetitionRoom room, int i) {
    final CompetitionEntry e = room.entries[i];
    final String id = '${room.id}_${e.username}';
    final bool liked = _hallLiked.contains(id);
    final List<PostComment> cm =
        _hallComments.putIfAbsent(id, () => seedComments(e.seat));
    final int total = cm.fold<int>(0, (s, c) => s + 1 + c.replies.length);
    final bool top = i < 3;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: top ? const Color(0xFFFFB300) : const Color(0xFF2A2A38),
          width: top ? 1.2 : 0.8,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor:
                top ? const Color(0xFFFFB300) : const Color(0xFF2A2A38),
            child: Text(
              _tmDigits(i + 1),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: top ? Colors.black : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InteractiveBaraviCube(
            size: 40,
            totalStories: 4,
            isProfileMode: true,
            seedKey: 'comp_${e.username}',
            rotationDuration: const Duration(seconds: 6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openUserByName(context, e.username),
                        child: Text(
                          e.isMe ? '${e.username} (شما)' : e.username,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color:
                                e.isMe ? const Color(0xFF00E5FF) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    tickBadges(e.username),
                    const SizedBox(width: 4),
                    starsRow(e.username, size: 11),
                  ],
                ),
                Text(
                  guildPath(room.categoryId),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            icon: CountIcon(
              liked ? Icons.favorite : Icons.favorite_border,
              count: hallBase(id, 90) + (liked ? 1 : 0),
              color: liked ? const Color(0xFFFF0055) : Colors.white,
              size: 22,
            ),
            onPressed: () => setState(() {
              if (!_hallLiked.remove(id)) _hallLiked.add(id);
            }),
          ),
          GestureDetector(
            onTap: () => showCommentsSheet(
              context,
              cm,
              onChanged: () {
                if (mounted) setState(() {});
              },
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 22),
                const SizedBox(width: 4),
                Text(_tmDigits(total), style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<CompetitionRoom> rooms = TournamentStore.I.championRooms;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تالار برترین‌ها 🏆'),
        actions: [
          IconButton(
            icon: const SizedBox.shrink(),
            onPressed: () => showCelebration(context),
          ),
        ],
      ),
      body: rooms.isEmpty
          ? const Center(
              child: Text('هنوز مسابقه‌ی هیچ صنفی تمام نشده است',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final CompetitionRoom room in rooms) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
                    child: Text(
                      '🏆 ${guildPath(room.categoryId)}',
                      style: const TextStyle(
                        color: Color(0xFFFFB300),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  for (int i = 0; i < room.entries.length; i++) _row(room, i),
                ],
              ],
            ),
    );
  }
}

List<CompetitionEntry> _topWithMe(
    CompetitionRoom room, List<CompetitionEntry> ranked) {
  final List<CompetitionEntry> l = ranked.take(kFinalSize).toList();
  final CompetitionEntry? me = room.me;
  if (me != null) {
    l.removeWhere((e) => e.isMe);
    l.insert(0, me);
    if (l.length > kFinalSize) l.removeLast();
  }
  return l;
}

class ChampionsHall2 extends StatefulWidget {
  const ChampionsHall2({super.key});
  @override
  State<ChampionsHall2> createState() => _ChampionsHall2State();
}

class _ChampionsHall2State extends State<ChampionsHall2> {
  String? _top;
  String? _sub;

  Widget _chip(String title, bool sel, VoidCallback onTap,
      {Color color = const Color(0xFFFFB300)}) {
    return ChoiceChip(
      label: Text(title),
      selected: sel,
      selectedColor: color,
      backgroundColor: const Color(0xFF1C1C24),
      labelStyle: TextStyle(
        color: sel ? Colors.black : Colors.white,
        fontSize: 12,
        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: color),
      onSelected: (_) => onTap(),
    );
  }

  Widget _row(CompetitionRoom room, int i) {
    final CompetitionEntry e = room.entries[i];
    final String id = '${room.id}_${e.username}';
    final bool liked = _hallLiked.contains(id);
    final List<PostComment> cm =
        _hallComments.putIfAbsent(id, () => seedComments(e.seat));
    final int total = cm.fold<int>(0, (s, c) => s + 1 + c.replies.length);
    final bool top = i < 3;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: top ? const Color(0xFFFFB300) : const Color(0xFF2A2A38),
          width: top ? 1.2 : 0.8,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor:
                top ? const Color(0xFFFFB300) : const Color(0xFF2A2A38),
            child: Text(
              _tmDigits(i + 1),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: top ? Colors.black : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InteractiveBaraviCube(
            size: 40,
            totalStories: 4,
            isProfileMode: true,
            seedKey: 'comp_${e.username}',
            rotationDuration: const Duration(seconds: 6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openUserByName(context, e.username),
                        child: Text(
                          e.isMe ? '${e.username} (شما)' : e.username,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color:
                                e.isMe ? const Color(0xFF00E5FF) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    tickBadges(e.username),
                    const SizedBox(width: 4),
                    starsRow(e.username, size: 11),
                  ],
                ),
                Text(
                  guildPath(room.categoryId),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            icon: CountIcon(
              liked ? Icons.favorite : Icons.favorite_border,
              count: hallBase(id, 90) + (liked ? 1 : 0),
              color: liked ? const Color(0xFFFF0055) : Colors.white,
              size: 22,
            ),
            onPressed: () => setState(() {
              if (!_hallLiked.remove(id)) _hallLiked.add(id);
            }),
          ),
          GestureDetector(
            onTap: () => showCommentsSheet(
              context,
              cm,
              onChanged: () {
                if (mounted) setState(() {});
              },
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 22),
                const SizedBox(width: 4),
                Text(_tmDigits(total), style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تالار برترین‌ها 🏆'),
        actions: [
          IconButton(
            icon: const SizedBox.shrink(),
            onPressed: null,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation:
            Listenable.merge(<Listenable>[TournamentStore.I, CategoryStore.I]),
        builder: (context, _) {
          final List<Map<String, dynamic>> tops = CategoryStore.I.topLevel;
          final List<CompetitionRoom> rooms = TournamentStore.I.championRooms;
          final List<Map<String, dynamic>> kids = _top == null
              ? <Map<String, dynamic>>[]
              : CategoryStore.I.childrenOf(_top!);
          final String? leaf = kids.isEmpty ? _top : _sub;
          CompetitionRoom? room;
          if (leaf != null) {
            for (final CompetitionRoom r in rooms) {
              if (r.categoryId == leaf) room = r;
            }
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: tops.map((c) {
                  final String id = c['id'] as String;
                  return _chip(c['title'] as String, _top == id, () {
                    setState(() {
                      _top = _top == id ? null : id;
                      _sub = null;
                    });
                  });
                }).toList(),
              ),
              if (kids.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: kids.map((c) {
                    final String id = c['id'] as String;
                    return _chip(c['title'] as String, _sub == id,
                        color: const Color(0xFF00E5FF), () {
                      setState(() => _sub = _sub == id ? null : id);
                    });
                  }).toList(),
                ),
              ],
              if (leaf != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
                  child: Text(
                    '🏆 ${guildPath(leaf)}',
                    style: const TextStyle(
                      color: Color(0xFFFFB300),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (room == null)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('مسابقه‌ی این صنف هنوز تمام نشده است',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                else
                  for (int i = 0; i < room.entries.length; i++) _row(room, i),
              ],
            ],
          );
        },
      ),
    );
  }
}

bool kTestRate = false;

DateTime? kUpStamp;
DateTime? kVoteStamp;

String stampText(DateTime? d) {
  if (d == null) return '';
  String p2(int n) => n.toString().padLeft(2, '0');
  final List<int> gdm = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
  final int gy2 = d.month > 2 ? d.year + 1 : d.year;
  int days = 355666 +
      (365 * d.year) +
      ((gy2 + 3) ~/ 4) -
      ((gy2 + 99) ~/ 100) +
      ((gy2 + 399) ~/ 400) +
      d.day +
      gdm[d.month - 1];
  int jy = -1595 + (33 * (days ~/ 12053));
  days %= 12053;
  jy += 4 * (days ~/ 1461);
  days %= 1461;
  if (days > 365) {
    jy += (days - 1) ~/ 365;
    days = (days - 1) % 365;
  }
  int jm;
  int jd;
  if (days < 186) {
    jm = 1 + (days ~/ 31);
    jd = 1 + (days % 31);
  } else {
    jm = 7 + ((days - 186) ~/ 30);
    jd = 1 + ((days - 186) % 30);
  }
  return '\n${_tmDigits(jy)}/${_tmDigits(p2(jm))}/${_tmDigits(p2(jd))}  ${_tmDigits(p2(d.hour))}:${_tmDigits(p2(d.minute))}';
}

class TwoClocks extends StatefulWidget {
  const TwoClocks({super.key});

  @override
  State<TwoClocks> createState() => _TwoClocksState();
}

class _TwoClocksState extends State<TwoClocks> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  String _clock(Duration d) {
    final Duration x = d.isNegative ? Duration.zero : d;
    final String mm = x.inMinutes.toString().padLeft(2, '0');
    final String ss = (x.inSeconds % 60).toString().padLeft(2, '0');
    return _tmDigits('$mm:$ss');
  }

  Widget _face(String label, String time, bool on) {
    final Color c = on ? const Color(0xFF00E5FF) : Colors.white38;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: on ? const Color(0xFF00E5FF) : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              time,
              style: TextStyle(
                color: c,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    Duration? up;
    Duration? vote;
    for (final List<CompetitionRoom> l in TournamentStore.I._rooms.values) {
      for (final CompetitionRoom r in l) {
        if (r.finished || r.isChampions) continue;
        if (r.inUpload) {
          final Duration d = r.uploadEndsAt!.difference(now);
          if (up == null || d < up) up = d;
        }
        if (r.started) {
          final Duration d = r.remaining;
          if (vote == null || d < vote) vote = d;
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _face('آپلود فیلم${stampText(kUpStamp)}', _clock(up ?? upFor(0)),
              up != null),
          Container(width: 1, height: 44, color: const Color(0xFF2A2A38)),
          _face('رأی‌گیری${stampText(kVoteStamp)}', _clock(vote ?? voteFor(0)),
              vote != null),
        ],
      ),
    );
  }
}

class StageRoomsScreen extends StatefulWidget {
  final String categoryId;
  const StageRoomsScreen({super.key, required this.categoryId});

  @override
  State<StageRoomsScreen> createState() => _StageRoomsScreenState();
}

class _StageRoomsScreenState extends State<StageRoomsScreen> {
  Timer? _t;
  int? _stage;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  String _status(CompetitionRoom r) {
    if (r.isChampions) return 'برترین‌ها اعلام شدند 🏆';
    if (r.finished) return 'پایان‌یافته';
    if (r.started) return 'رأی‌گیری زنده 🔴';
    if (r.inUpload) return 'مهلت آپلود فیلم';
    return 'منتظر شروع';
  }

  void _openRoom(CompetitionRoom r) {
    if (r.me != null &&
        !r.finished &&
        !r.started &&
        r.uploadEndsAt == null &&
        r.stageIndex > 0 &&
        false) {
      r.beginUpload(upFor(r.stageIndex));
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => GuildRoomScreen(room: r)),
    );
  }

  Widget _tile(CompetitionRoom r) {
    final bool mine = r.me != null;
    final String sub = '${_tmDigits(r.entries.length)} نفر • ${_status(r)}';
    final String extra = mine ? ' • شما اینجا هستید' : '';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mine ? const Color(0xFF00E5FF) : const Color(0xFF2A2A38),
          width: mine ? 1.4 : 0.8,
        ),
      ),
      child: ListTile(
        onTap: () => _openRoom(r),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF00E5FF),
          child: Text(
            _tmDigits(r.roomNo),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          r.isChampions ? 'برترین‌ها' : 'اتاق ${_tmDigits(r.roomNo)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          sub + extra,
          style: TextStyle(
            color: mine ? const Color(0xFF00E5FF) : Colors.grey,
            fontSize: 11,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String cid = widget.categoryId;
    return AnimatedBuilder(
      animation: TournamentStore.I,
      builder: (context, _) {
        final List<CompetitionRoom> all =
            TournamentStore.I.roomsOfCategory(cid);
        if (all.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('مسابقات ${categoryTitleOf(cid)}')),
            body: const Center(child: Text('اتاقی وجود ندارد')),
          );
        }
        final List<int> stages = all.map((r) => r.stageIndex).toSet().toList()
          ..sort();
        int def = stages.last;
        for (final int s in stages) {
          if (all.any((r) => r.stageIndex == s && !r.finished)) {
            def = s;
            break;
          }
        }
        final int cur =
            (_stage != null && stages.contains(_stage)) ? _stage! : def;
        final int pos = stages.indexOf(cur);
        final bool hasNext = pos + 1 < stages.length;
        String lab(int s) =>
            all.firstWhere((r) => r.stageIndex == s).stageLabel;
        final List<CompetitionRoom> rooms =
            all.where((r) => r.stageIndex == cur).toList();
        return Scaffold(
          appBar: AppBar(title: Text('مسابقات ${categoryTitleOf(cid)}')),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: stages.map((s) {
                    final bool sel = s == cur;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(lab(s)),
                        selected: sel,
                        selectedColor: const Color(0xFF00E5FF),
                        backgroundColor: const Color(0xFF1C1C24),
                        labelStyle: TextStyle(
                          color: sel ? Colors.black : Colors.white70,
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) => setState(() => _stage = s),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (hasNext)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(0, 36),
                      ),
                      onPressed: () => setState(() => _stage = stages[pos + 1]),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: Text(
                        'رفتن به ${lab(stages[pos + 1])}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              const TwoClocks(),
              for (final CompetitionRoom r in rooms) _tile(r),
            ],
          ),
        );
      },
    );
  }
}

/// نمره‌هایی که خودم داده‌ام (کلید: شناسه‌ی فیلم). فقط خودم می‌بینم.
final Map<String, int> kMyVotes = <String, int>{};
final int kRunId = DateTime.now().millisecondsSinceEpoch; // بعد از تست false کن
final Map<String, double> _sumScores = <String, double>{};
List<int> kUpMin = <int>[1, 1, 1, 1, 1];
List<int> kVoteMin = <int>[1, 1, 1, 1, 1];
Duration upFor(int s) => const Duration(seconds: 2);
Duration voteFor(int s) => const Duration(seconds: 2);

// ---------- کرنومتر مرحله‌ها ----------
class TimerPanel extends StatefulWidget {
  const TimerPanel({super.key});
  @override
  State<TimerPanel> createState() => _TimerPanelState();
}

class _TimerPanelState extends State<TimerPanel> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  String _clock(Duration d) {
    final Duration x = d.isNegative ? Duration.zero : d;
    final String mm = x.inMinutes.toString().padLeft(2, '0');
    final String ss = (x.inSeconds % 60).toString().padLeft(2, '0');
    return _tmDigits('$mm:$ss');
  }

  List<CompetitionRoom> _at(int s) => TournamentStore.I._rooms.values
      .expand((l) => l)
      .where((r) => r.stageIndex == s && !r.isChampions)
      .toList();

  Widget _box(String label, String time, int st) {
    final Color fg = st == 1
        ? const Color(0xFF00E5FF)
        : (st == 2 ? Colors.white24 : Colors.white70);
    final Color cell =
        st == 1 ? const Color(0xFF062A30) : const Color(0xFF0B0B0F);
    final List<Widget> cells = <Widget>[];
    for (final String ch in time.split('')) {
      if (ch == ':') {
        cells.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(':',
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w900, fontSize: 18)),
        ));
      } else {
        cells.add(Container(
          width: 20,
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cell,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                color: st == 1
                    ? const Color(0xFF00E5FF)
                    : const Color(0xFF2A2A38)),
          ),
          child: Text(ch,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w900, fontSize: 17)),
        ));
      }
    }
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF16161F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color:
                  st == 1 ? const Color(0xFF00E5FF) : const Color(0xFF2A2A38)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: fg, fontSize: 10)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.ltr,
                children: cells,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _edit(int s) {
    final TextEditingController a = TextEditingController(text: '${kUpMin[s]}');
    final TextEditingController b =
        TextEditingController(text: '${kVoteMin[s]}');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        title: Text('زمان مرحله ${_tmDigits(s + 1)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: a,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'آپلود فیلم (دقیقه)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: b,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'رأی‌گیری (دقیقه)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              final int x = int.tryParse(a.text.trim()) ?? 1;
              final int y = int.tryParse(b.text.trim()) ?? 1;
              kUpMin[s] = x < 1 ? 1 : x;
              kVoteMin[s] = y < 1 ? 1 : y;
              Navigator.pop(ctx);
              setState(() {});
            },
            child:
                const Text('ذخیره', style: TextStyle(color: Color(0xFF00E5FF))),
          ),
        ],
      ),
    );
  }

  Widget _stage(int s) {
    final List<CompetitionRoom> rs = _at(s);
    CompetitionRoom? upR;
    CompetitionRoom? voteR;
    for (final CompetitionRoom r in rs) {
      if (r.inUpload) upR = r;
      if (r.started && !r.finished) voteR = r;
    }
    final bool anyFin = rs.any((r) => r.finished);
    final bool anyStart = rs.any((r) => r.started);
    int up = 0;
    int vote = 0;
    String upT = _clock(upFor(s));
    String voteT = _clock(voteFor(s));
    if (anyStart || anyFin) {
      up = 2;
    } else if (upR != null) {
      up = 1;
      upT = _clock(upR.uploadEndsAt!.difference(DateTime.now()));
    }
    if (anyFin) {
      vote = 2;
    } else if (voteR != null) {
      vote = 1;
      voteT = _clock(voteR.remaining);
    }
    return GestureDetector(
      onTap: kIsAdmin ? () => _edit(s) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 54,
              child: Text('مرحله ${_tmDigits(s + 1)}',
                  style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ),
            _box('آپلود', upT, up),
            _box('رأی‌گیری', voteT, vote),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'زمان‌بندی مرحله‌ها (برای تغییر زمان، روی هر مرحله بزن)',
            style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 11,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          for (int s = 0; s < 5; s++) _stage(s),
        ],
      ),
    );
  }
}

// ---------- انتخاب صنف و زیرصنف به‌صورت افقی ----------
class GuildPicker extends StatefulWidget {
  const GuildPicker({super.key});
  @override
  State<GuildPicker> createState() => _GuildPickerState();
}

class _GuildPickerState extends State<GuildPicker> {
  String? _top;

  bool _mine(String id) =>
      AppState.I.myField.isNotEmpty &&
      tournamentRootCategory(AppState.I.myField) == id;

  void _open(String cid) {
    final List<CompetitionRoom> rs = TournamentStore.I.roomsOfCategory(cid);
    if (rs.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => StageRoomsScreen(categoryId: cid),
      ),
    );
  }

  void _openOld(String cid) {
    final List<CompetitionRoom> rs = TournamentStore.I.roomsOfCategory(cid);
    if (rs.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => GuildRoomScreen(room: rs.last)),
    );
  }

  Widget _chip(String title, bool sel, bool mine, Color color, VoidCallback f) {
    return ChoiceChip(
      label: Text(mine ? '⭐ $title' : title),
      selected: sel,
      selectedColor: color,
      backgroundColor: const Color(0xFF1C1C24),
      side: BorderSide(
        color: mine ? Colors.white : color,
        width: mine ? 2 : 1,
      ),
      labelStyle: TextStyle(
        color: sel ? Colors.black : Colors.white,
        fontSize: 12,
        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => f(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge(<Listenable>[TournamentStore.I, CategoryStore.I]),
      builder: (context, _) {
        final List<Map<String, dynamic>> tops =
            List<Map<String, dynamic>>.of(CategoryStore.I.topLevel);
        tops.sort((a, b) =>
            (_mine(b['id'] as String) ? 1 : 0) -
            (_mine(a['id'] as String) ? 1 : 0));
        final List<Map<String, dynamic>> kids = _top == null
            ? <Map<String, dynamic>>[]
            : CategoryStore.I.childrenOf(_top!);
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF16161F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A38)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'صنف خودت را بزن، بعد زیرصنفت را انتخاب کن تا وارد مسابقه شوی',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: tops.map((c) {
                  final String id = c['id'] as String;
                  return _chip(
                    c['title'] as String,
                    _top == id,
                    _mine(id),
                    const Color(0xFFFFB300),
                    () {
                      if (CategoryStore.I.hasChildren(id)) {
                        setState(() => _top = _top == id ? null : id);
                      } else {
                        _open(id);
                      }
                    },
                  );
                }).toList(),
              ),
              if (kids.isNotEmpty) ...[
                const Divider(height: 18, color: Color(0xFF2A2A38)),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: kids.map((c) {
                    final String id = c['id'] as String;
                    return _chip(
                      c['title'] as String,
                      false,
                      AppState.I.myField == id,
                      const Color(0xFF00E5FF),
                      () => _open(id),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ---------- نوار نمره‌ی من در رأی‌گیری زنده ----------
// پیش‌فرض ۵۰؛ بعد از «ثبت نمره» قفل می‌شود و عدد در kMyVotes می‌ماند
// تا با برگشت به مرحله‌ی قبل هم فقط خودم نمره‌ام را ببینم.
class MyScoreBar extends StatefulWidget {
  final String entryId;
  final ValueChanged<int> onSubmitted;
  const MyScoreBar({
    super.key,
    required this.entryId,
    required this.onSubmitted,
  });

  @override
  State<MyScoreBar> createState() => _MyScoreBarState();
}

class _MyScoreBarState extends State<MyScoreBar> {
  double _v = 50;

  @override
  Widget build(BuildContext context) {
    const Color cyan = Color(0xFF00E5FF);
    final int? locked = kMyVotes[widget.entryId];
    final double shown = locked != null ? locked.toDouble() : _v;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A38), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, size: 18, color: cyan),
              const SizedBox(width: 6),
              const Text('نمره‌ی استعدادیابی شما:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                '${_tmDigits(shown.round())} از ۱۰۰',
                style: const TextStyle(
                    color: cyan, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: cyan,
              inactiveTrackColor: const Color(0xFF2A2A38),
              thumbColor: const Color(0xFFFF0055),
              disabledActiveTrackColor: cyan,
              disabledInactiveTrackColor: const Color(0xFF2A2A38),
              disabledThumbColor: cyan,
            ),
            child: Slider(
              value: shown,
              min: 0,
              max: 100,
              divisions: 100,
              label: _tmDigits(shown.round()),
              onChanged: locked != null ? null : (x) => setState(() => _v = x),
            ),
          ),
          if (locked != null)
            const Row(
              children: [
                Icon(Icons.lock_outline, size: 14, color: cyan),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'قفل شد؛ نمره‌ی شما ثبت شده و فقط خودتان آن را می‌بینید',
                    style: TextStyle(
                        color: cyan, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyan,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  widget.onSubmitted(_v.round());
                  setState(() {});
                  showSnack(context, 'نمره‌ی شما ثبت شد ✅ (محرمانه)');
                },
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('ثبت نمره (قفل می‌شود)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

int starsOfName(String n) {
  for (final TalentUser t in allTalentUsers) {
    if (t.username == n) return t.stars;
  }
  if (n == kMyUsername) return kMyStars;
  return _compStars(n);
}

Widget starsRow(String n, {double size = 10}) {
  final int s = starsOfName(n);
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List<Widget>.generate(
      5,
      (i) => Icon(
        Icons.star,
        size: size,
        color: i < s ? const Color(0xFFFFB300) : Colors.grey.shade800,
      ),
    ),
  );
}
