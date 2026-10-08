part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

class CreatePostScreen extends StatefulWidget {
  final String initialType;
  const CreatePostScreen({super.key, this.initialType = 'post'});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late String _contentType;
  String _selectedCategory = 'industry';
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contentType = widget.initialType;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _getTitle() {
    switch (_contentType) {
      case 'story':
        return 'ثبت استوری جدید 📸';
      case 'reel':
        return 'ثبت ریلز جدید داوری 🎬';
      default:
        return 'ثبت اثر و پست در صنف 📝';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_getTitle()} با موفقیت ارسال شد! 🚀'),
                ),
              );
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'ارسال',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نوع محتوا:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeChip('post', 'پست عادی', Icons.image_outlined),
                const SizedBox(width: 8),
                _buildTypeChip(
                  'story',
                  'استوری مکعب',
                  Icons.view_in_ar_rounded,
                ),
                const SizedBox(width: 8),
                _buildTypeChip('reel', 'ویدیو ریلز', Icons.play_circle_outline),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'انتخاب صنف استعدادیابی:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => showAddCategoryDialog(context),
                  icon:
                      const Icon(Icons.add, size: 16, color: Color(0xFF00E5FF)),
                  label: const Text(
                    'صنف جدید',
                    style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedBuilder(
              animation: CategoryStore.I,
              builder: (context, _) {
                return DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF1E1E28),
                  items: talentCategories
                      .where((c) => c['id'] != 'all')
                      .map(
                        (c) => DropdownMenuItem<String>(
                          value: c['id'] as String,
                          child: Text(c['title'] as String),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF16161F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF16161F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2C2C3A),
                  style: BorderStyle.solid,
                ),
              ),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('انتخاب فایل از گالری شبیه‌سازی شد 🖼️'),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _contentType == 'reel'
                          ? Icons.video_call_outlined
                          : Icons.add_photo_alternate_outlined,
                      size: 44,
                      color: const Color(0xFF00E5FF),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _contentType == 'reel'
                          ? 'انتخاب ویدیو عمودی برای ریلز'
                          : 'انتخاب تصویر یا ویدیوی اثر',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'توضیحات و سوابق:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              textDirection: TextDirection.rtl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'درباره مهارت، تکنیک‌ها یا توضیحات داوری اثر خود بنویسید...',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF16161F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final bool isSelected = _contentType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _contentType = type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00E5FF).withAlpha(38)
                : const Color(0xFF16161F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00E5FF)
                  : const Color(0xFF282834),
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF00E5FF) : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF00E5FF) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
