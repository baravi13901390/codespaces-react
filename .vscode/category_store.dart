part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// =====================================================================
// صنف‌های استعدادیابی: یک لیست واحد و کاملاً قابل‌ویرایش.
// اولین بار که برنامه اجرا می‌شود چند صنف پایه به‌عنوان نقطه‌ی شروع
// ساخته می‌شوند، ولی از همان لحظه دقیقاً مثل بقیه قابل تغییر نام،
// حذف، و اضافه‌کردنِ زیرمجموعه هستند.
// =====================================================================
class CategoryStore extends ChangeNotifier {
  CategoryStore._();
  static final CategoryStore I = CategoryStore._();

  static const Map<String, dynamic> _allOption = {
    'id': 'all',
    'title': 'همه صنف‌ها',
    'icon': Icons.apps,
  };

  final List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];
  int _n = 0;
  SharedPreferences? _prefs;
  bool _loaded = false;

  List<Map<String, dynamic>> get all =>
      <Map<String, dynamic>>[Map<String, dynamic>.of(_allOption), ..._items];

  List<Map<String, dynamic>> get selectable =>
      List<Map<String, dynamic>>.of(_items);

  /// فقط صنف‌های اصلی (بدون والد)
  List<Map<String, dynamic>> get topLevel =>
      _items.where((c) => c['parentId'] == null).toList();

  List<Map<String, dynamic>> childrenOf(String parentId) =>
      _items.where((c) => c['parentId'] == parentId).toList();

  bool hasChildren(String id) => childrenOf(id).isNotEmpty;

  Map<String, dynamic>? _byId(String id) {
    if (id == 'all') return Map<String, dynamic>.of(_allOption);
    for (final Map<String, dynamic> c in _items) {
      if (c['id'] == id) return c;
    }
    return null;
  }

  String topParentOf(String id) {
    String cur = id;
    final Set<String> guard = <String>{};
    while (guard.add(cur)) {
      final String? parent = _byId(cur)?['parentId'] as String?;
      if (parent == null) return cur;
      cur = parent;
    }
    return id;
  }

  /// آیا صنفِ یک پست با صنفِ انتخاب‌شده مطابقت دارد؟ (با در نظر گرفتن رابطه‌ی والد/فرزند)
  bool matches(String postCategoryId, String selectedId) {
    if (selectedId == 'all') return true;
    String cur = postCategoryId;
    final Set<String> guard = <String>{};
    while (guard.add(cur)) {
      if (cur == selectedId) return true;
      final String? parent = _byId(cur)?['parentId'] as String?;
      if (parent == null) return false;
      cur = parent;
    }
    return false;
  }

  String addCategory(String title, {String? parentId, IconData? icon}) {
    _n++;
    final String id = 'cat_$_n';
    _items.add(<String, dynamic>{
      'id': id,
      'title': title,
      'icon': icon ?? Icons.auto_awesome,
      'parentId': parentId,
    });
    notifyListeners();
    _save();
    return id;
  }

  void renameCategory(String id, String newTitle) {
    final Map<String, dynamic>? c = _byId(id);
    if (c == null || id == 'all') return;
    for (final Map<String, dynamic> item in _items) {
      if (item['id'] == id) item['title'] = newTitle;
    }
    notifyListeners();
    _save();
  }

  void deleteCategory(String id) {
    if (id == 'all') return;
    _items.removeWhere((c) => c['id'] == id);
    // زیرمجموعه‌های این صنف، صنف مستقل می‌شن (نه اینکه پاک بشن)
    for (final Map<String, dynamic> c in _items) {
      if (c['parentId'] == id) c['parentId'] = null;
    }
    notifyListeners();
    _save();
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      _prefs = p;
      final String? raw = p.getString('baravi_categories_v5');
      if (raw != null) {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        for (final dynamic e in list) {
          final Map<String, dynamic> m = e as Map<String, dynamic>;
          _items.add(<String, dynamic>{
            'id': m['id'] as String,
            'title': m['title'] as String,
            'icon': Icons.auto_awesome,
            'parentId': m['parentId'] as String?,
          });
          final int n = int.tryParse((m['id'] as String).split('_').last) ?? 0;
          if (n > _n) _n = n;
        }
        return; // قبلاً یک‌بار صنف‌ها ذخیره شده بودن، دیگه seed نمی‌کنیم
      }
    } catch (_) {}

    // اولین اجرای برنامه: صنف‌های پایه رو به‌عنوان نقطه‌ی شروع می‌سازیم
    if (_items.isEmpty) {
      final String industry =
          addCategory('صنعت', icon: Icons.precision_manufacturing);
      addCategory('ماشین‌سازی', parentId: industry);
      addCategory('تراشکاری', parentId: industry);
      addCategory('جوشکاری', parentId: industry);
      addCategory('ریخته‌گری', parentId: industry);
      addCategory('نجاری و درودگری', parentId: industry);
      addCategory('آهنگری', parentId: industry);
      addCategory('مکانیک خودرو', parentId: industry);
      addCategory('نقشه‌کشی صنعتی', parentId: industry);
      addCategory('بسته‌بندی و تولید', parentId: industry);
      addCategory('تعمیرات لوازم خانگی', parentId: industry);

      final String gold = addCategory('طلا و جواهرات', icon: Icons.diamond);
      addCategory('مخراجکاری طلا', parentId: gold);
      addCategory('جواهرسازی', parentId: gold);
      addCategory('آبکاری طلا', parentId: gold);
      addCategory('طراحی جواهرات', parentId: gold);
      addCategory('گوهرشناسی و سنگ‌شناسی', parentId: gold);
      addCategory('نقره‌کاری', parentId: gold);

      final String electric =
          addCategory('برق', icon: Icons.electrical_services);
      addCategory('برق ساختمان', parentId: electric);
      addCategory('برق صنعتی', parentId: electric);
      addCategory('الکترونیک', parentId: electric);
      addCategory('مخابرات', parentId: electric);
      addCategory('رباتیک', parentId: electric);
      addCategory('برق خودرو', parentId: electric);
      addCategory('تابلوسازی برق', parentId: electric);
      final String art = addCategory('هنر و موسیقی', icon: Icons.palette);
      addCategory('نقاشی', parentId: art);
      addCategory('خوشنویسی', parentId: art);
      addCategory('مجسمه‌سازی', parentId: art);
      addCategory('موسیقی سنتی', parentId: art);
      addCategory('موسیقی پاپ و راک', parentId: art);
      addCategory('آواز', parentId: art);
      addCategory('نوازندگی سازهای زهی', parentId: art);
      addCategory('نوازندگی سازهای بادی و کوبه‌ای', parentId: art);
      addCategory('تئاتر و بازیگری', parentId: art);
      addCategory('رقص', parentId: art);
      addCategory('سینما و فیلم‌سازی', parentId: art);
      addCategory('عکاسی', parentId: art);
      addCategory('طراحی گرافیک', parentId: art);
      addCategory('سفالگری', parentId: art);
      addCategory('معرق‌کاری', parentId: art);
      final String sport =
          addCategory('ورزش و مهارت', icon: Icons.sports_soccer);
      addCategory('فوتبال', parentId: sport);
      addCategory('بسکتبال', parentId: sport);
      addCategory('والیبال', parentId: sport);
      addCategory('کشتی', parentId: sport);
      addCategory('بوکس', parentId: sport);
      addCategory('کیک‌بوکسینگ', parentId: sport);
      addCategory('جودو', parentId: sport);
      addCategory('کاراته', parentId: sport);
      addCategory('تکواندو', parentId: sport);
      addCategory('شنا', parentId: sport);
      addCategory('دومیدانی', parentId: sport);
      addCategory('وزنه‌برداری', parentId: sport);
      addCategory('ژیمناستیک', parentId: sport);
      addCategory('تنیس', parentId: sport);
      addCategory('پینگ‌پنگ', parentId: sport);
      addCategory('قایقرانی', parentId: sport);
      addCategory('دوچرخه‌سواری', parentId: sport);
      addCategory('کوهنوردی', parentId: sport);
      addCategory('اسکیت‌بورد', parentId: sport);
      addCategory('شطرنج', parentId: sport);
      final String comedy =
          addCategory('طنز و سرگرمی', icon: Icons.sentiment_very_satisfied);
      addCategory('استندآپ کمدی', parentId: comedy);
      addCategory('تقلید صدا', parentId: comedy);
      addCategory('شعبده‌بازی', parentId: comedy);
      addCategory('انیمیشن‌سازی', parentId: comedy);
      addCategory('میم‌سازی', parentId: comedy);
      addCategory('پادکست طنز', parentId: comedy);
      final String tech = addCategory('فناوری و نرم‌افزار', icon: Icons.memory);
      addCategory('برنامه‌نویسی', parentId: tech);
      addCategory('طراحی وب', parentId: tech);
      addCategory('هوش مصنوعی', parentId: tech);
      addCategory('بازی‌سازی', parentId: tech);
      addCategory('امنیت سایبری', parentId: tech);
      addCategory('شبکه و سرور', parentId: tech);
      addCategory('علم داده', parentId: tech);

      final String agri =
          addCategory('کشاورزی و دامپروری', icon: Icons.agriculture);
      addCategory('باغبانی', parentId: agri);
      addCategory('زراعت', parentId: agri);
      addCategory('دامپروری', parentId: agri);
      addCategory('پرورش طیور', parentId: agri);
      addCategory('زنبورداری', parentId: agri);
      addCategory('گلخانه‌داری', parentId: agri);
      addCategory('پرورش آبزیان', parentId: agri);

      final String build =
          addCategory('ساختمان و معماری', icon: Icons.architecture);
      addCategory('معماری', parentId: build);
      addCategory('نقشه‌کشی ساختمان', parentId: build);
      addCategory('بنایی', parentId: build);
      addCategory('نقاشی ساختمان', parentId: build);
      addCategory('تاسیسات و لوله‌کشی', parentId: build);
      addCategory('کاشی‌کاری', parentId: build);
      addCategory('سنگ‌کاری', parentId: build);
      addCategory('گچ‌کاری و کناف', parentId: build);

      final String cook =
          addCategory('آشپزی و شیرینی‌پزی', icon: Icons.restaurant);
      addCategory('آشپزی ایرانی', parentId: cook);
      addCategory('آشپزی بین‌الملل', parentId: cook);
      addCategory('شیرینی‌پزی', parentId: cook);
      addCategory('قنادی', parentId: cook);
      addCategory('باریستا و قهوه', parentId: cook);
      addCategory('کیک‌پزی و تزیین', parentId: cook);

      final String fashion =
          addCategory('مد، زیبایی و پیرایش', icon: Icons.checkroom);
      addCategory('خیاطی', parentId: fashion);
      addCategory('طراحی لباس', parentId: fashion);
      addCategory('آرایش و گریم', parentId: fashion);
      addCategory('پیرایش مردانه', parentId: fashion);
      addCategory('ناخن‌کاری', parentId: fashion);
      addCategory('مدل‌سازی مو', parentId: fashion);

      final String craft = addCategory('صنایع دستی', icon: Icons.handyman);
      addCategory('قالی‌بافی', parentId: craft);
      addCategory('گلیم‌بافی', parentId: craft);
      addCategory('چرم‌دوزی', parentId: craft);
      addCategory('نمدمالی', parentId: craft);
      addCategory('میناکاری', parentId: craft);
      addCategory('قلم‌زنی', parentId: craft);
      addCategory('خاتم‌کاری', parentId: craft);

      final String edu = addCategory('علم، آموزش و پژوهش', icon: Icons.school);
      addCategory('تدریس خصوصی', parentId: edu);
      addCategory('پژوهش علمی', parentId: edu);
      addCategory('ریاضیات', parentId: edu);
      addCategory('زبان‌های خارجی', parentId: edu);
      addCategory('رباتیک آموزشی', parentId: edu);

      final String med =
          addCategory('پزشکی و سلامت', icon: Icons.medical_services);
      addCategory('پزشکی عمومی', parentId: med);
      addCategory('پرستاری', parentId: med);
      addCategory('فیزیوتراپی', parentId: med);
      addCategory('تغذیه و رژیم', parentId: med);
      addCategory('طب سنتی', parentId: med);
      addCategory('مامایی', parentId: med);

      final String transport =
          addCategory('حمل‌ونقل و رانندگی', icon: Icons.local_shipping);
      addCategory('رانندگی حرفه‌ای', parentId: transport);
      addCategory('خلبانی', parentId: transport);
      addCategory('دریانوردی', parentId: transport);
      addCategory('راه‌آهن', parentId: transport);

      final String biz =
          addCategory('تجارت و کسب‌وکار', icon: Icons.business_center);
      addCategory('بازاریابی', parentId: biz);
      addCategory('فروش', parentId: biz);
      addCategory('حسابداری', parentId: biz);
      addCategory('مدیریت', parentId: biz);
      addCategory('کارآفرینی و استارتاپ', parentId: biz);

      final String write =
          addCategory('نویسندگی و رسانه', icon: Icons.edit_note);
      addCategory('داستان‌نویسی', parentId: write);
      addCategory('شعر', parentId: write);
      addCategory('روزنامه‌نگاری', parentId: write);
      addCategory('تولید محتوا', parentId: write);
      addCategory('ترجمه', parentId: write);

      final String mining = addCategory('معدن و استخراج', icon: Icons.terrain);
      addCategory('اکتشاف معدن', parentId: mining);
      addCategory('استخراج زغال‌سنگ', parentId: mining);
      addCategory('استخراج فلزات', parentId: mining);
      addCategory('سنگ تزئینی', parentId: mining);
      addCategory('ایمنی معدن', parentId: mining);

      final String oil =
          addCategory('نفت، گاز و پتروشیمی', icon: Icons.local_gas_station);
      addCategory('بهره‌برداری نفت و گاز', parentId: oil);
      addCategory('پالایش', parentId: oil);
      addCategory('مهندسی نفت', parentId: oil);
      addCategory('پتروشیمی', parentId: oil);
      addCategory('ایمنی و آتش‌نشانی صنعتی (HSE)', parentId: oil);

      final String law = addCategory('حقوق و قضاوت', icon: Icons.gavel);
      addCategory('وکالت', parentId: law);
      addCategory('قضاوت', parentId: law);
      addCategory('سردفتری اسناد رسمی', parentId: law);
      addCategory('مشاوره حقوقی', parentId: law);
      addCategory('حقوق بین‌الملل', parentId: law);

      final String tourism =
          addCategory('گردشگری و هتل‌داری', icon: Icons.travel_explore);
      addCategory('راهنمای تور', parentId: tourism);
      addCategory('مدیریت هتل', parentId: tourism);
      addCategory('آژانس مسافرتی', parentId: tourism);
      addCategory('تشریفات و مراسم', parentId: tourism);
      addCategory('گردشگری سلامت', parentId: tourism);

      final String finance = addCategory('امور مالی، بانکداری و بیمه',
          icon: Icons.account_balance);
      addCategory('بانکداری', parentId: finance);
      addCategory('بیمه‌گری', parentId: finance);
      addCategory('تحلیل بازار سرمایه', parentId: finance);
      addCategory('ارزیابی ریسک', parentId: finance);
      addCategory('حسابرسی', parentId: finance);

      final String env =
          addCategory('محیط‌زیست و منابع طبیعی', icon: Icons.eco);
      addCategory('محیط‌زیست', parentId: env);
      addCategory('جنگل‌داری', parentId: env);
      addCategory('مرتع‌داری', parentId: env);
      addCategory('آبخیزداری', parentId: env);
      addCategory('انرژی‌های تجدیدپذیر', parentId: env);

      final String vet = addCategory('دامپزشکی', icon: Icons.pets);
      addCategory('دامپزشکی عمومی', parentId: vet);
      addCategory('جراحی دام', parentId: vet);
      addCategory('بهداشت دام', parentId: vet);
      addCategory('پرندگان زینتی', parentId: vet);

      final String marine =
          addCategory('علوم دریایی و آبزیان', icon: Icons.sailing);
      addCategory('زیست‌شناسی دریا', parentId: marine);
      addCategory('صید و صیادی', parentId: marine);
      addCategory('کشتی‌سازی', parentId: marine);
      addCategory('غواصی حرفه‌ای', parentId: marine);

      final String media = addCategory('رسانه، تبلیغات و بازاریابی دیجیتال',
          icon: Icons.campaign);
      addCategory('تدوین ویدیو', parentId: media);
      addCategory('پادکست‌سازی', parentId: media);
      addCategory('عکاسی تبلیغاتی', parentId: media);
      addCategory('سئو (SEO)', parentId: media);
      addCategory('مدیریت شبکه‌های اجتماعی', parentId: media);

      final String textile =
          addCategory('صنایع نساجی و پوشاک', icon: Icons.dry_cleaning);
      addCategory('ریسندگی', parentId: textile);
      addCategory('بافندگی', parentId: textile);
      addCategory('رنگرزی پارچه', parentId: textile);
      addCategory('چاپ روی پارچه', parentId: textile);
      addCategory('دوخت صنعتی پوشاک', parentId: textile);

      final String aero = addCategory('هوافضا', icon: Icons.flight_takeoff);
      addCategory('مهندسی هوافضا', parentId: aero);
      addCategory('تعمیر و نگهداری هواپیما', parentId: aero);
      addCategory('مهندسی ماهواره', parentId: aero);

      final String safety = addCategory('ایمنی، امداد و آتش‌نشانی',
          icon: Icons.health_and_safety);
      addCategory('آتش‌نشانی', parentId: safety);
      addCategory('امداد و نجات', parentId: safety);
      addCategory('نگهبانی حرفه‌ای', parentId: safety);
      addCategory('ایمنی کار (HSE)', parentId: safety);

      addCategory('ریخته‌گری طلا و جواهر', parentId: gold);
      addCategory('قالب‌سازی مومی', parentId: gold);
      addCategory('سنگ‌نشانی', parentId: gold);
      addCategory('جواهرتراشی و سنگ‌تراشی', parentId: gold);
      addCategory('میناکاری جواهر', parentId: gold);
      addCategory('تعمیر و ارزیابی طلا', parentId: gold);
      addCategory('زرگری سنتی', parentId: gold);
      addCategory('حکاکی روی طلا و نقره', parentId: gold);
      addCategory('ساخت سکه و مدال', parentId: gold);
      addCategory('پرداخت و پولیش طلا', parentId: gold);

      addCategory('ابزارسازی و قالب‌سازی', parentId: industry);
      addCategory('تراشکاری CNC', parentId: industry);
      addCategory('فرزکاری', parentId: industry);
      addCategory('ورق‌کاری و پرسکاری', parentId: industry);
      addCategory('رنگ‌کاری صنعتی', parentId: industry);
      addCategory('لوله‌کشی صنعتی', parentId: industry);
      addCategory('کنترل کیفیت و اندازه‌گیری', parentId: industry);
      addCategory('آبکاری فلزات', parentId: industry);
      addCategory('عملیات حرارتی', parentId: industry);

      addCategory('سیم‌پیچی موتور', parentId: electric);
      addCategory('اتوماسیون صنعتی (PLC)', parentId: electric);
      addCategory('انرژی خورشیدی', parentId: electric);
      addCategory('دوربین مداربسته و سیستم امنیتی', parentId: electric);
      addCategory('آنتن و ماهواره', parentId: electric);

      addCategory('تذهیب و نگارگری', parentId: art);
      addCategory('نقاشی دیواری', parentId: art);
      addCategory('ساخت ساز', parentId: art);
      addCategory('آهنگسازی و تنظیم', parentId: art);
      addCategory('گویندگی و دوبله', parentId: art);
      addCategory('طراحی صحنه', parentId: art);
      addCategory('تصویرسازی', parentId: art);

      addCategory('منبت‌کاری', parentId: craft);
      addCategory('حصیربافی', parentId: craft);
      addCategory('شیشه‌گری', parentId: craft);
      addCategory('سفال و کاشی سنتی', parentId: craft);
      addCategory('پته‌دوزی و سوزن‌دوزی', parentId: craft);
      addCategory('ساخت عروسک', parentId: craft);

      addCategory('سقف کاذب', parentId: build);
      addCategory('عایق‌کاری', parentId: build);
      addCategory('پارکت‌کاری', parentId: build);
      addCategory('نصب درب و پنجره', parentId: build);
      addCategory('ساختمان‌سازی فولادی', parentId: build);

      addCategory('نان‌پزی', parentId: cook);
      addCategory('کباب و کبابی', parentId: cook);
      addCategory('سوخاری و فست‌فود', parentId: cook);
      addCategory('بستنی و دسر', parentId: cook);
      addCategory('غذاهای دریایی', parentId: cook);

      addCategory('توسعه اپلیکیشن موبایل', parentId: tech);
      addCategory('واقعیت مجازی و افزوده', parentId: tech);
      addCategory('بلاک‌چین', parentId: tech);
      addCategory('رایانش ابری', parentId: tech);
      addCategory('تست نرم‌افزار', parentId: tech);

      addCategory('بدنسازی', parentId: sport);
      addCategory('یوگا و پیلاتس', parentId: sport);
      addCategory('پارکور', parentId: sport);
      addCategory('تیراندازی', parentId: sport);
      addCategory('کمانداری', parentId: sport);
      addCategory('اسب‌سواری', parentId: sport);
      addCategory('بدمینتون', parentId: sport);
      addCategory('هندبال', parentId: sport);
      addCategory('ووشو', parentId: sport);
      addCategory('موی‌تای', parentId: sport);
      addCategory('اسنوکر و بیلیارد', parentId: sport);

      addCategory('کفاشی و چرم', parentId: fashion);
      addCategory('طراحی پارچه', parentId: fashion);

      final String heavyCar =
          addCategory('ماشین‌آلات و خودرو', icon: Icons.directions_car);
      addCategory('تعمیر موتور خودرو', parentId: heavyCar);
      addCategory('گیربکس و انتقال قدرت', parentId: heavyCar);
      addCategory('صافکاری و نقاشی خودرو', parentId: heavyCar);
      addCategory('برق و دیاگ خودرو', parentId: heavyCar);
      addCategory('لاستیک و تنظیم فرمان', parentId: heavyCar);
      addCategory('اپراتوری ماشین‌آلات سنگین', parentId: heavyCar);
      addCategory('تعمیر موتورسیکلت', parentId: heavyCar);

      final String service =
          addCategory('خدمات فنی و تعمیرات', icon: Icons.build_circle);
      addCategory('تعمیر موبایل', parentId: service);
      addCategory('تعمیر لپ‌تاپ و کامپیوتر', parentId: service);
      addCategory('تعمیر یخچال و کولر', parentId: service);
      addCategory('سرویس‌کاری موتورسیکلت', parentId: service);
      addCategory('قفل‌سازی و کلیدسازی', parentId: service);

      final String gaming = addCategory('ورزش‌های الکترونیکی و گیمینگ',
          icon: Icons.sports_esports);
      addCategory('بازی‌های تیراندازی', parentId: gaming);
      addCategory('بازی‌های استراتژی', parentId: gaming);
      addCategory('استریم و گیم‌پلی', parentId: gaming);
      addCategory('اسپیدران', parentId: gaming);

      final String home =
          addCategory('دکوراسیون و خانه‌داری', icon: Icons.chair);
      addCategory('دکوراسیون داخلی', parentId: home);
      addCategory('گل‌آرایی', parentId: home);
      addCategory('باغچه و فضای سبز', parentId: home);
      addCategory('سیسمونی و کودک', parentId: home);
    }
  }

  void _save() {
    final SharedPreferences? p = _prefs;
    if (p == null) return;
    try {
      p.setString(
        'baravi_categories_v5',
        jsonEncode(
          _items
              .map((c) => <String, dynamic>{
                    'id': c['id'],
                    'title': c['title'],
                    'parentId': c['parentId'],
                  })
              .toList(),
        ),
      );
    } catch (_) {}
  }
}

List<Map<String, dynamic>> get talentCategories => CategoryStore.I.all;

String categoryTitleOf(String id) {
  for (final Map<String, dynamic> c in CategoryStore.I.all) {
    if (c['id'] == id) return c['title'] as String;
  }
  return id;
}

void showAddCategoryDialog(BuildContext context, {String? initialParentId}) {
  final TextEditingController controller = TextEditingController();
  String? parentId = initialParentId;
  showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        title: const Text('افزودن صنف جدید'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  hintText: 'مثلاً: راه و شهرسازی، هایپرمارکت',
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'زیرمجموعه‌ی کدام صنف باشد؟',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              DropdownButton<String?>(
                value: parentId,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E1E28),
                hint: const Text(
                  'صنف کاملاً جدید (مستقل)',
                  style: TextStyle(fontSize: 12),
                ),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('صنف کاملاً جدید (مستقل)'),
                  ),
                  ...CategoryStore.I.topLevel.map(
                    (c) => DropdownMenuItem<String?>(
                      value: c['id'] as String,
                      child: Text(c['title'] as String),
                    ),
                  ),
                ],
                onChanged: (v) => setLocal(() => parentId = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              final String t = controller.text.trim();
              if (t.isEmpty) return;
              CategoryStore.I.addCategory(t, parentId: parentId);
              Navigator.pop(ctx);
            },
            child: const Text(
              'افزودن',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _renameCategoryDialog(
    BuildContext context, String id, String currentTitle) {
  final TextEditingController controller =
      TextEditingController(text: currentTitle);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E28),
      title: const Text('تغییر نام صنف'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textDirection: TextDirection.rtl,
        decoration: const InputDecoration(hintText: 'نام جدید'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('انصراف'),
        ),
        TextButton(
          onPressed: () {
            final String t = controller.text.trim();
            if (t.isNotEmpty) {
              CategoryStore.I.renameCategory(id, t);
            }
            Navigator.pop(ctx);
          },
          child: const Text(
            'ذخیره',
            style: TextStyle(
                color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

void _categoryLongPressMenu(BuildContext context, String id, String title) {
  showDarkSheet<void>(
    context,
    (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            sheetHandle(),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            sheetTile(Icons.edit_outlined, 'تغییر نام', () {
              Navigator.pop(ctx);
              _renameCategoryDialog(context, id, title);
            }),
            sheetTile(
              Icons.delete_outline,
              'حذف صنف',
              () {
                Navigator.pop(ctx);
                _confirmDeleteCategory(context, id, title);
              },
              color: const Color(0xFFFF5252),
            ),
          ],
        ),
      ),
    ),
  );
}

void _confirmDeleteCategory(BuildContext context, String id, String title) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E28),
      title: const Text('حذف صنف'),
      content: Text(
          'صنف «$title» حذف شود؟ (پست‌های داخلش جایی نمی‌رن، فقط صنفش دیگه لیست نمی‌شه)'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('انصراف'),
        ),
        TextButton(
          onPressed: () {
            CategoryStore.I.deleteCategory(id);
            Navigator.pop(ctx);
          },
          child: const Text('حذف', style: TextStyle(color: Color(0xFFFF5252))),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------
// جستجوی صنف‌ها و زیرصنف‌ها: برای وقتی که تعداد صنف‌ها خیلی زیاد است
// و اسکرول کردن لیست چیپ‌ها عملی نیست. کافیست چند حرف از نام را تایپ کنی.
// ---------------------------------------------------------------------
void showCategorySearchSheet(
  BuildContext context,
  ValueChanged<String> onSelected,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF16161F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _CategorySearchSheet(onSelected: onSelected),
  );
}

class _CategorySearchSheet extends StatefulWidget {
  final ValueChanged<String> onSelected;
  const _CategorySearchSheet({required this.onSelected});

  @override
  State<_CategorySearchSheet> createState() => _CategorySearchSheetState();
}

class _CategorySearchSheetState extends State<_CategorySearchSheet> {
  String _q = '';

  String _parentPathOf(Map<String, dynamic> c) {
    final String? parentId = c['parentId'] as String?;
    if (parentId == null) return '';
    return categoryTitleOf(parentId);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> all = CategoryStore.I.selectable;
    final String q = _q.trim();
    final List<Map<String, dynamic>> results = q.isEmpty
        ? const <Map<String, dynamic>>[]
        : all.where((c) => (c['title'] as String).contains(q)).toList();
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
      child: SizedBox(
        height: 460,
        child: Column(
          children: [
            sheetHandle(),
            TextField(
              autofocus: true,
              textDirection: TextDirection.rtl,
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                hintText: 'نام صنف یا زیرصنف را تایپ کنید...',
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
            const SizedBox(height: 8),
            Expanded(
              child: q.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'برای جستجو در همه‌ی صنف‌ها و زیرصنف‌ها تایپ کنید',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    )
                  : results.isEmpty
                      ? const Center(
                          child: Text(
                            'چیزی پیدا نشد',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, i) {
                            final Map<String, dynamic> c = results[i];
                            final String parentTitle = _parentPathOf(c);
                            return ListTile(
                              leading: Icon(
                                c['icon'] as IconData,
                                color: const Color(0xFF00E5FF),
                              ),
                              title: Text(c['title'] as String),
                              subtitle: parentTitle.isEmpty
                                  ? null
                                  : Text(
                                      parentTitle,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                              onTap: () {
                                widget.onSelected(c['id'] as String);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ردیف اول: دکمه‌ی جستجو + «همه» + صنف‌های اصلی + دکمه‌ی افزودن.
/// نگه‌داشتنِ انگشت روی هر صنفی (به‌جز «همه») منوی تغییرنام/حذف باز می‌کنه.
bool kIsAdmin = true;

/// مکعب ثابت و سبک (بدون چرخش و بدون تایمر) برای کنار اسم صنف‌ها
class StaticCube extends StatelessWidget {
  final String seedKey;
  final double size;
  const StaticCube({super.key, required this.seedKey, this.size = 22});

  Widget _face(int i) {
    return Image.network(
      'https://picsum.photos/seed/${seedKey}_$i/80',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1E1E28)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Row(
        children: [
          SizedBox(
            width: size * 0.3,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(3),
              ),
              child: _face(2),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(3),
              ),
              child: _face(1),
            ),
          ),
        ],
      ),
    );
  }
}

Widget categoryChipsRow({
  required String selected,
  required ValueChanged<String> onSelected,
  bool includeAllOption = true,
}) {
  return AnimatedBuilder(
    animation: CategoryStore.I,
    builder: (context, _) {
      final List<Map<String, dynamic>> cats = <Map<String, dynamic>>[
        if (includeAllOption)
          CategoryStore.I.all.firstWhere((c) => c['id'] == 'all'),
        ...CategoryStore.I.topLevel,
      ];
      return Container(
        height: 48,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search_rounded, color: Color(0xFF00E5FF)),
              tooltip: 'جستجوی صنف',
              onPressed: () => showCategorySearchSheet(context, onSelected),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: cats.length + (kIsAdmin ? 1 : 0),
                itemBuilder: (context, i) {
                  if (kIsAdmin && i == cats.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        avatar: const Icon(Icons.add,
                            size: 16, color: Color(0xFF00E5FF)),
                        label: const Text('افزودن صنف'),
                        backgroundColor: const Color(0xFF1C1C24),
                        labelStyle: const TextStyle(
                            color: Color(0xFF00E5FF), fontSize: 12),
                        onPressed: () => showAddCategoryDialog(context),
                      ),
                    );
                  }
                  final Map<String, dynamic> cat = cats[i];
                  final String id = cat['id'] as String;
                  final bool sel = selected == id ||
                      (id != 'all' && CategoryStore.I.matches(selected, id));
                  final bool hasKids =
                      id != 'all' && CategoryStore.I.hasChildren(id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onLongPress: !kIsAdmin
                          ? null
                          : id == 'all'
                              ? null
                              : () => _categoryLongPressMenu(
                                  context, id, cat['title'] as String),
                      child: ChoiceChip(
                        avatar: IgnorePointer(
                          child: StaticCube(
                            seedKey: 'guild_cube_$id',
                            size: 22,
                          ),
                        ),
                        label: Text(hasKids
                            ? '${cat['title']} ▾'
                            : cat['title'] as String),
                        selected: sel,
                        selectedColor: const Color(0xFF00E5FF),
                        backgroundColor: const Color(0xFF1C1C24),
                        labelStyle: TextStyle(
                          color: sel ? Colors.black : Colors.white,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (v) {
                          if (v) onSelected(id);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// ردیف دوم: زیرمجموعه‌های صنف اصلیِ فعلاً انتخاب‌شده
Widget categorySubChipsRow({
  required String selected,
  required ValueChanged<String> onSelected,
}) {
  return AnimatedBuilder(
    animation: CategoryStore.I,
    builder: (context, _) {
      if (selected == 'all' || selected.isEmpty) return const SizedBox.shrink();
      final String topId = CategoryStore.I.topParentOf(selected);
      final List<Map<String, dynamic>> kids = CategoryStore.I.childrenOf(topId);
      if (kids.isEmpty) return const SizedBox.shrink();
      return Container(
        height: 38,
        margin: const EdgeInsets.only(bottom: 6),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: kids.length + 2,
          itemBuilder: (context, i) {
            if (i == 0) {
              final bool sel = selected == topId;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: const Text('همه'),
                  selected: sel,
                  selectedColor: const Color(0xFF00E5FF),
                  backgroundColor: const Color(0xFF1C1C24),
                  labelStyle: TextStyle(
                      color: sel ? Colors.black : Colors.white70, fontSize: 11),
                  onSelected: (v) {
                    if (v) onSelected(topId);
                  },
                ),
              );
            }
            if (i == kids.length + 1) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ActionChip(
                  avatar:
                      const Icon(Icons.add, size: 14, color: Color(0xFF00E5FF)),
                  label: const Text('زیرصنف جدید'),
                  backgroundColor: const Color(0xFF1C1C24),
                  labelStyle:
                      const TextStyle(color: Color(0xFF00E5FF), fontSize: 11),
                  onPressed: () =>
                      showAddCategoryDialog(context, initialParentId: topId),
                ),
              );
            }
            final Map<String, dynamic> cat = kids[i - 1];
            final String id = cat['id'] as String;
            final bool sel = selected == id;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onLongPress: () =>
                    _categoryLongPressMenu(context, id, cat['title'] as String),
                child: ChoiceChip(
                  avatar: IgnorePointer(
                    child: StaticCube(
                      seedKey: 'guild_cube_$id',
                      size: 20,
                    ),
                  ),
                  label: Text(cat['title'] as String),
                  selected: sel,
                  selectedColor: const Color(0xFF00E5FF),
                  backgroundColor: const Color(0xFF1C1C24),
                  labelStyle: TextStyle(
                      color: sel ? Colors.black : Colors.white70, fontSize: 11),
                  onSelected: (v) {
                    if (v) onSelected(id);
                  },
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
