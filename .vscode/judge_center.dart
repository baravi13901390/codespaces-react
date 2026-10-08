part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// امتیازدهی داور | اعلان‌ها | پیام‌ها
// =====================================================================
class JudgeState extends ChangeNotifier {
  JudgeState._();
  static final JudgeState I = JudgeState._();

  final Map<String, int> _scores = <String, int>{};
  int? scoreOf(String id) => _scores[id];
  bool isJudged(String id) => _scores.containsKey(id);
  int get judgedCount => _scores.length;
  double get average => _scores.isEmpty
      ? 0.0
      : _scores.values.reduce((a, b) => a + b) / _scores.length;

  void setScore(String id, int v) {
    _scores[id] = v;
    notifyListeners();
  }

  void clearScore(String id) {
    _scores.remove(id);
    notifyListeners();
  }
}

String judgeLabel(int v) {
  if (v >= 90) return 'خیره‌کننده 🔥';
  if (v >= 75) return 'عالی 👏';
  if (v >= 50) return 'خوب 👍';
  if (v >= 25) return 'نیازمند تمرین 🛠️';
  return 'ضعیف';
}

Color judgeColor(int v) {
  if (v >= 75) return const Color(0xFF00E5FF);
  if (v >= 50) return const Color(0xFFFFB300);
  return const Color(0xFFFF0055);
}

class JudgeScoreBar extends StatefulWidget {
  final String workId;
  const JudgeScoreBar({super.key, required this.workId});

  @override
  State<JudgeScoreBar> createState() => _JudgeScoreBarState();
}

class _JudgeScoreBarState extends State<JudgeScoreBar> {
  late double _value;

  bool get _judged => JudgeState.I.isJudged(widget.workId);

  @override
  void initState() {
    super.initState();
    _value = (JudgeState.I.scoreOf(widget.workId) ?? 50).toDouble();
    JudgeState.I.addListener(_onState);
  }

  @override
  void dispose() {
    JudgeState.I.removeListener(_onState);
    super.dispose();
  }

  void _onState() {
    if (mounted) setState(() {});
  }

  void _submit() {
    JudgeState.I.setScore(widget.workId, _value.round());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('نمره ${_value.round()} ثبت شد ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int v = _value.round();
    final Color c = judgeColor(v);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF282836)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: Color(0xFF00E5FF), size: 20),
              const SizedBox(width: 6),
              const Text(
                'نمره استعدادیابی شما:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              Text(
                '$v از ۱۰۰',
                style: TextStyle(
                  color: c,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: c,
              inactiveTrackColor: const Color(0xFF282836),
              thumbColor: const Color(0xFFFF0055),
              overlayColor: const Color(0x33FF0055),
              trackHeight: 4,
            ),
            child: Slider(
              value: _value,
              min: 1,
              max: 100,
              divisions: 99,
              onChanged: _judged ? null : (x) => setState(() => _value = x),
            ),
          ),
          Row(
            children: [
              Text(
                judgeLabel(v),
                style: TextStyle(color: c, fontSize: 12),
              ),
              const Spacer(),
              if (_judged)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline,
                        size: 14, color: Color(0xFF00E5FF)),
                    SizedBox(width: 4),
                    Text(
                      'ثبت شد',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'ثبت نمره',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class JudgeCenterScreen extends StatelessWidget {
  const JudgeCenterScreen({super.key});

  Widget _summary() {
    return AnimatedBuilder(
      animation: JudgeState.I,
      builder: (context, _) {
        return Container(
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
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${JudgeState.I.judgedCount}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00E5FF),
                      ),
                    ),
                    const Text(
                      'اثر داوری‌شده',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      JudgeState.I.average.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFB300),
                      ),
                    ),
                    const Text(
                      'میانگین نمرات شما',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cats =
        talentCategories.where((c) => c['id'] != 'all').toList();
    return Scaffold(
      appBar: AppBar(title: const Text('مرکز داوری ⚖️')),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: 9,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _summary(),
            );
          }
          final int k = i - 1;
          final TalentUser u = allTalentUsers[k % allTalentUsers.length];
          final String cat = cats[k % cats.length]['title'] as String;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF14141A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CubeAvatar(
                    backgroundImage: NetworkImage(avatarUrl(u.username)),
                  ),
                  title: Text(
                    u.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    cat,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  onTap: () => openUserProfile(context, u),
                ),
                ClipRRect(
                  child: Image.network(
                    'https://picsum.photos/seed/judge_work_$k/600/360',
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: JudgeScoreBar(workId: 'work_$k'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
