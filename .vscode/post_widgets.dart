part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// 1) نوار امتیازدهی محرمانه با دکمه‌ی «ثبت نمره»
// - نمره فقط روی همین دستگاه و فقط برای خود کاربر نگه‌داری/نمایش داده می‌شود
// - هیچ لیستی از «چه کسی چه نمره‌ای داده» وجود ندارد
// - بعد از ثبت، اسلایدر قفل می‌شود (یک نمره برای هر پست)
// =====================================================================

String _pwFaDigits(Object n) {
  const String en = '0123456789';
  const String fa = '۰۱۲۳۴۵۶۷۸۹';
  String s = n.toString();
  for (int i = 0; i < 10; i++) {
    s = s.replaceAll(en[i], fa[i]);
  }
  return s;
}

class PostRatingBar extends StatefulWidget {
  /// شناسه‌ی یکتای پست (برای اینکه نمره‌ی هر پست جدا ذخیره شود)
  final String postId;

  /// بعد از زدن «ثبت نمره» صدا زده می‌شود (مثلاً برای ارسال به سرور در آینده)
  final ValueChanged<int>? onSubmitted;

  final bool lockAfter;

  const PostRatingBar(
      {super.key,
      required this.postId,
      this.onSubmitted,
      this.lockAfter = true});

  @override
  State<PostRatingBar> createState() => _PostRatingBarState();
}

class _PostRatingBarState extends State<PostRatingBar> {
  double _value = 0;
  int? _submitted;
  bool _loading = true;

  String get _key => 'my_private_score_${widget.postId}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      final int? s = p.getInt(_key);
      if (!mounted) return;
      setState(() {
        _submitted = s;
        if (s != null) _value = s.toDouble();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final int score = _value.round();
    setState(() => _submitted = score);
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      await p.setInt(_key, score);
    } catch (_) {}
    widget.onSubmitted?.call(score);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('نمره‌ی شما ثبت شد ✅ (محرمانه)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool locked = widget.lockAfter && _submitted != null;
    const Color cyan = Color(0xFF00E5FF);
    final int shown = _value.round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A38), width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, size: 18, color: cyan),
              const SizedBox(width: 6),
              const Text(
                'نمره‌ی استعدادیابی شما:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${_pwFaDigits(shown)} از ۱۰۰',
                style: const TextStyle(
                  color: cyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
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
              value: _value,
              min: 0,
              max: 100,
              divisions: 100,
              label: _pwFaDigits(_value.round()),
              onChanged: (locked || _loading)
                  ? null
                  : (double v) => setState(() => _value = v),
            ),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  '۰ ـــــــ ۵۰ ـــــــ ۱۰۰ • نمره‌ی شما محرمانه است',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
              const SizedBox(width: 8),
              if (locked)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.lock_outline, size: 14, color: cyan),
                    SizedBox(width: 4),
                    Text(
                      'ثبت شد',
                      style: TextStyle(
                        color: cyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('ثبت نمره'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cyan,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 34),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// 2) انتخاب و پیش‌نمایش ویدیو (رفع ارور ImageCodecException)
// ویدیو نباید با Image.memory / Image.network نمایش داده شود.
// =====================================================================

/// ویدیو را از دستگاه انتخاب می‌کند (به‌جای pickImage)
Future<XFile?> pickVideoFromDevice() async {
  try {
    return await ImagePicker().pickVideo(source: ImageSource.gallery);
  } catch (_) {
    return null;
  }
}

/// پیش‌نمایش ویدیوی انتخاب‌شده (روی وب/کروم؛ آدرس فایل از نوع blob است)
class PickedVideoPreview extends StatefulWidget {
  final XFile file;
  const PickedVideoPreview({super.key, required this.file});

  @override
  State<PickedVideoPreview> createState() => _PickedVideoPreviewState();
}

class _PickedVideoPreviewState extends State<PickedVideoPreview> {
  VideoPlayerController? _c;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant PickedVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      _c?.dispose();
      _c = null;
      _ready = false;
      _failed = false;
      _init();
    }
  }

  Future<void> _init() async {
    final VideoPlayerController c =
        VideoPlayerController.networkUrl(Uri.parse(widget.file.path));
    _c = c;
    try {
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0.0);
      if (!mounted) return;
      setState(() => _ready = true);
      c.play();
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? c = _c;
    if (_failed) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'پیش‌نمایش این ویدیو ممکن نیست، ولی فایل انتخاب شد.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }
    if (!_ready || c == null) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF00E5FF),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          if (c.value.isPlaying) {
            c.pause();
          } else {
            c.play();
          }
        });
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: c.value.aspectRatio == 0 ? 1 : c.value.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              VideoPlayer(c),
              if (!c.value.isPlaying)
                const Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white70,
                    size: 56,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
