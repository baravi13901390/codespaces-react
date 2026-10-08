part of 'main.dart'; // ignore_for_file: unused_element, dead_code, unnecessary_null_comparison, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_constructor_name, curly_braces_in_flow_control_structures, prefer_conditional_assignment

// ---------------------------------------------------------------------
// ورود / ثبت‌نام (ظاهری)
// ---------------------------------------------------------------------
// =====================================================================
// زبان، نوع حساب (سرمایه‌گذار / کاربر عادی) و صفحه‌ی ورود جدید
// =====================================================================
class AppPrefs extends ChangeNotifier {
  AppPrefs._();
  static final AppPrefs I = AppPrefs._();

  String lang = 'fa';
  String role = '';

  Future<void> load() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      lang = p.getString('baravi_lang') ?? 'fa';
      role = p.getString('baravi_role') ?? '';
    } catch (_) {}
  }

  Future<void> setLang(String v) async {
    lang = v;
    notifyListeners();
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      await p.setString('baravi_lang', v);
    } catch (_) {}
  }

  Future<void> setRole(String v) async {
    role = v;
    notifyListeners();
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      await p.setString('baravi_role', v);
    } catch (_) {}
  }
}

const List<List<String>> kLanguages = [
  ['fa', 'فارسی'],
  ['en', 'English'],
  ['ar', 'العربية'],
  ['tr', 'Türkçe'],
  ['es', 'Español'],
  ['fr', 'Français'],
];

String tr(String id) {
  final String l = AppPrefs.I.lang;
  return _kTr[l]?[id] ?? _kTr['en']?[id] ?? id;
}

// قانون پیام: سرمایه‌گذارها پیام دریافت نمی‌کنند
bool isInvestorName(String name) {
  final int n = int.tryParse(name.split('_').last) ?? 0;
  return n % 4 == 3;
}

bool canMessageUser(String name) => !isInvestorName(name);

const Map<String, Map<String, String>> _kTr = {
  'fa': {
    'tagline': "استعدادت رو نشون بده، داوری شو",
    'username': "نام کاربری",
    'email': "ایمیل",
    'password': "رمز عبور",
    'login': "ورود",
    'signup': "ساخت حساب",
    'have_acc': "حساب دارید؟ وارد شوید",
    'no_acc': "حساب ندارید؟ ثبت‌نام کنید",
    'guest': "ورود به‌عنوان مهمان",
    'pick_guild': "صنف خود را انتخاب کنید و تخصص شما چیست؟",
    'err_login': "نام کاربری و رمز (حداقل ۴ حرف) را وارد کنید",
    'err_email': "ایمیل معتبر وارد کنید",
    'err_field': "لطفاً صنف خود را انتخاب کنید",
    'err_sub': "لطفاً تخصص (زیرصنف) خود را هم انتخاب کنید",
    'err_guest': "ابتدا ثبت‌نام کنید و صنف و تخصص خود را انتخاب کنید",
    'role_title': "نوع حساب خود را انتخاب کنید",
    'investor': "سرمایه‌گذار",
    'regular': "کاربر عادی",
    'investor_desc':
        "هیچ‌کس نمی‌تواند به شما پیام بدهد؛ فقط شما می‌توانید به دیگران پیام بدهید.",
    'regular_desc': "می‌توانید به همه به‌جز سرمایه‌گذاران پیام بدهید.",
    'continue_btn': "ادامه و ورود به برنامه",
    'pick_role_first': "یکی از دو گزینه را انتخاب کنید",
    'investor_rules_title': "قوانین حساب سرمایه‌گذار",
    'got_it': "متوجه شدم",
  },
  'en': {
    'tagline': "Show your talent, get judged",
    'username': "Username",
    'email': "Email",
    'password': "Password",
    'login': "Log in",
    'signup': "Create account",
    'have_acc': "Have an account? Log in",
    'no_acc': "No account? Sign up",
    'guest': "Continue as guest",
    'pick_guild': "Choose your field and your specialty",
    'err_login': "Enter a username and a password (min. 4 characters)",
    'err_email': "Enter a valid email",
    'err_field': "Please choose your field",
    'err_sub': "Please also choose your specialty",
    'err_guest': "Sign up first and choose your field and specialty",
    'role_title': "Choose your account type",
    'investor': "Investor",
    'regular': "Regular user",
    'investor_desc': "Nobody can message you; only you can message others.",
    'regular_desc': "You can message everyone except investors.",
    'continue_btn': "Continue to the app",
    'pick_role_first': "Please pick one of the two options",
    'investor_rules_title': "Investor account rules",
    'got_it': "Got it",
  },
  'ar': {
    'tagline': "أظهر موهبتك ودع الحكام يقيّمونك",
    'username': "اسم المستخدم",
    'email': "البريد الإلكتروني",
    'password': "كلمة المرور",
    'login': "تسجيل الدخول",
    'signup': "إنشاء حساب",
    'have_acc': "لديك حساب؟ سجّل الدخول",
    'no_acc': "ليس لديك حساب؟ سجّل الآن",
    'guest': "الدخول كضيف",
    'pick_guild': "اختر مجالك وتخصصك",
    'err_login': "أدخل اسم المستخدم وكلمة مرور (4 أحرف على الأقل)",
    'err_email': "أدخل بريدًا إلكترونيًا صالحًا",
    'err_field': "يرجى اختيار مجالك",
    'err_sub': "يرجى اختيار تخصصك أيضًا",
    'err_guest': "سجّل أولًا واختر مجالك وتخصصك",
    'role_title': "اختر نوع حسابك",
    'investor': "مستثمر",
    'regular': "مستخدم عادي",
    'investor_desc': "لا يمكن لأحد مراسلتك؛ أنت فقط من يمكنه مراسلة الآخرين.",
    'regular_desc': "يمكنك مراسلة الجميع باستثناء المستثمرين.",
    'continue_btn': "المتابعة إلى التطبيق",
    'pick_role_first': "يرجى اختيار أحد الخيارين",
    'investor_rules_title': "قواعد حساب المستثمر",
    'got_it': "فهمت",
  },
  'tr': {
    'tagline': "Yeteneğini göster, değerlendirilmeye hazır ol",
    'username': "Kullanıcı adı",
    'email': "E-posta",
    'password': "Şifre",
    'login': "Giriş yap",
    'signup': "Hesap oluştur",
    'have_acc': "Hesabın var mı? Giriş yap",
    'no_acc': "Hesabın yok mu? Kayıt ol",
    'guest': "Misafir olarak devam et",
    'pick_guild': "Alanını ve uzmanlığını seç",
    'err_login': "Kullanıcı adı ve şifre gir (en az 4 karakter)",
    'err_email': "Geçerli bir e-posta gir",
    'err_field': "Lütfen alanını seç",
    'err_sub': "Lütfen uzmanlığını da seç",
    'err_guest': "Önce kayıt ol, alanını ve uzmanlığını seç",
    'role_title': "Hesap türünü seç",
    'investor': "Yatırımcı",
    'regular': "Normal kullanıcı",
    'investor_desc':
        "Kimse sana mesaj gönderemez; sadece sen başkalarına mesaj gönderebilirsin.",
    'regular_desc': "Yatırımcılar hariç herkese mesaj gönderebilirsin.",
    'continue_btn': "Uygulamaya devam et",
    'pick_role_first': "Lütfen iki seçenekten birini seç",
    'investor_rules_title': "Yatırımcı hesabı kuralları",
    'got_it': "Anladım",
  },
  'es': {
    'tagline': "Muestra tu talento y deja que te evalúen",
    'username': "Nombre de usuario",
    'email': "Correo electrónico",
    'password': "Contraseña",
    'login': "Iniciar sesión",
    'signup': "Crear cuenta",
    'have_acc': "¿Ya tienes cuenta? Inicia sesión",
    'no_acc': "¿No tienes cuenta? Regístrate",
    'guest': "Continuar como invitado",
    'pick_guild': "Elige tu sector y tu especialidad",
    'err_login': "Introduce usuario y contraseña (mín. 4 caracteres)",
    'err_email': "Introduce un correo válido",
    'err_field': "Elige tu sector",
    'err_sub': "Elige también tu especialidad",
    'err_guest': "Regístrate primero y elige tu sector y especialidad",
    'role_title': "Elige tu tipo de cuenta",
    'investor': "Inversor",
    'regular': "Usuario normal",
    'investor_desc':
        "Nadie puede escribirte; solo tú puedes escribir a los demás.",
    'regular_desc': "Puedes escribir a todos excepto a los inversores.",
    'continue_btn': "Continuar a la app",
    'pick_role_first': "Elige una de las dos opciones",
    'investor_rules_title': "Reglas de la cuenta de inversor",
    'got_it': "Entendido",
  },
  'fr': {
    'tagline': "Montre ton talent, fais-toi évaluer",
    'username': "Nom d'utilisateur",
    'email': "E-mail",
    'password': "Mot de passe",
    'login': "Se connecter",
    'signup': "Créer un compte",
    'have_acc': "Déjà un compte ? Connecte-toi",
    'no_acc': "Pas de compte ? Inscris-toi",
    'guest': "Continuer en invité",
    'pick_guild': "Choisis ton domaine et ta spécialité",
    'err_login':
        "Saisis un nom d'utilisateur et un mot de passe (4 caractères min.)",
    'err_email': "Saisis un e-mail valide",
    'err_field': "Choisis ton domaine",
    'err_sub': "Choisis aussi ta spécialité",
    'err_guest': "Inscris-toi d'abord et choisis ton domaine et ta spécialité",
    'role_title': "Choisis ton type de compte",
    'investor': "Investisseur",
    'regular': "Utilisateur standard",
    'investor_desc':
        "Personne ne peut t'écrire ; toi seul peux écrire aux autres.",
    'regular_desc': "Tu peux écrire à tout le monde sauf aux investisseurs.",
    'continue_btn': "Continuer vers l'app",
    'pick_role_first': "Choisis l'une des deux options",
    'investor_rules_title': "Règles du compte investisseur",
    'got_it': "Compris",
  },
};

class LanguageDropdown extends StatelessWidget {
  final VoidCallback onChanged;
  const LanguageDropdown({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.language, size: 18, color: Color(0xFF00E5FF)),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: AppPrefs.I.lang,
          dropdownColor: const Color(0xFF1E1E28),
          underline: const SizedBox.shrink(),
          items: kLanguages
              .map(
                (l) => DropdownMenuItem<String>(
                  value: l[0],
                  child: Text(l[1]),
                ),
              )
              .toList(),
          onChanged: (v) async {
            if (v == null) return;
            await AppPrefs.I.setLang(v);
            onChanged();
          },
        ),
      ],
    );
  }
}

class LoginScreen2 extends StatefulWidget {
  const LoginScreen2({super.key});

  @override
  State<LoginScreen2> createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {
  bool _register = false;
  bool _hide = true;
  final TextEditingController _user = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  String? _error;
  String? _field;

  bool get _rtl => AppPrefs.I.lang == 'fa' || AppPrefs.I.lang == 'ar';

  @override
  void dispose() {
    _user.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  bool _gate() {
    String f = _field ?? '';
    if (f.isEmpty && !_register) f = AppState.I.myField;
    if (f.isNotEmpty && categoryTitleOf(f) == f) f = '';
    if (f.isEmpty) {
      setState(() => _error = _register ? 'err_field' : 'err_guest');
      return false;
    }
    if (CategoryStore.I.hasChildren(f)) {
      setState(() => _error = 'err_sub');
      return false;
    }
    AppState.I.setMyField(f);
    return true;
  }

  void _enter() {
    if (!_gate()) return;
    if (!_register && AppPrefs.I.role.isNotEmpty) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainNavigationShell()),
        (r) => false,
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RoleChoiceScreen()),
    );
  }

  void _submit() {
    if (_user.text.trim().isEmpty || _pass.text.length < 4) {
      setState(() => _error = 'err_login');
      return;
    }
    if (_register && !_email.text.contains('@')) {
      setState(() => _error = 'err_email');
      return;
    }
    _enter();
  }

  InputDecoration _dec(String id, IconData icon) {
    return InputDecoration(
      labelText: tr(id),
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: const Color(0xFF16161F),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  LanguageDropdown(
                    onChanged: () {
                      if (mounted) setState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Baravi',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00E5FF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('tagline'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 26),
                  TextField(
                    controller: _user,
                    decoration: _dec('username', Icons.person_outline),
                  ),
                  if (_register) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _dec('email', Icons.mail_outline),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment:
                          _rtl ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        tr('pick_guild'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    categoryChipsRow(
                      selected: _field ?? '',
                      includeAllOption: false,
                      onSelected: (id) => setState(() => _field = id),
                    ),
                    categorySubChipsRow(
                      selected: _field ?? '',
                      onSelected: (id) => setState(() => _field = id),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pass,
                    obscureText: _hide,
                    decoration: _dec('password', Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hide ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      tr(_error!),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFF0055),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text(
                        tr(_register ? 'signup' : 'login'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {
                      _register = !_register;
                      _error = null;
                    }),
                    child: Text(
                      tr(_register ? 'have_acc' : 'no_acc'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _enter,
                    child: Text(
                      tr('guest'),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoleChoiceScreen extends StatefulWidget {
  const RoleChoiceScreen({super.key});

  @override
  State<RoleChoiceScreen> createState() => _RoleChoiceScreenState();
}

class _RoleChoiceScreenState extends State<RoleChoiceScreen> {
  String _role = '';
  String? _error;

  void _pick(String r) {
    setState(() {
      _role = r;
      _error = null;
    });
    if (r == 'investor') {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E28),
          title: Text(tr('investor_rules_title')),
          content: Text(
            tr('investor_desc'),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                tr('got_it'),
                style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _go() async {
    if (_role.isEmpty) {
      setState(() => _error = 'pick_role_first');
      return;
    }
    await AppPrefs.I.setRole(_role);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainNavigationShell()),
      (r) => false,
    );
  }

  Widget _card(String id, IconData icon, String title, String desc) {
    final bool sel = _role == id;
    return GestureDetector(
      onTap: () => _pick(id),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16161F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel ? const Color(0xFF00E5FF) : const Color(0xFF2A2A38),
            width: sel ? 1.6 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: sel ? const Color(0xFF00E5FF) : Colors.grey,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              sel ? Icons.check_circle : Icons.radio_button_unchecked,
              color: sel ? const Color(0xFF00E5FF) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('role_title'))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  _card(
                    'investor',
                    Icons.trending_up_rounded,
                    tr('investor'),
                    tr('investor_desc'),
                  ),
                  _card(
                    'user',
                    Icons.person_outline,
                    tr('regular'),
                    tr('regular_desc'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      tr(_error!),
                      style: const TextStyle(
                        color: Color(0xFFFF0055),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _go,
                      child: Text(
                        tr('continue_btn'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _register = false;
  bool _hide = true;
  final TextEditingController _user = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  String? _error;
  String? _field;

  @override
  void dispose() {
    _user.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _enter() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
    );
  }

  void _submit() {
    if (_user.text.trim().isEmpty || _pass.text.length < 4) {
      setState(() => _error = 'نام کاربری و رمز (حداقل ۴ حرف) را وارد کنید');
      return;
    }
    if (_register && !_email.text.contains('@')) {
      setState(() => _error = 'ایمیل معتبر وارد کنید');
      return;
    }
    if (_register && _field != null) {
      AppState.I.setMyField(_field!);
    }
    _enter();
  }

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: const Color(0xFF16161F),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const Text(
                    'Baravi',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00E5FF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'استعدادت رو نشون بده، داوری شو',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _user,
                    decoration: _dec('نام کاربری', Icons.person_outline),
                  ),
                  if (_register) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _dec('ایمیل', Icons.mail_outline),
                    ),
                    const SizedBox(height: 14),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'صنف ًو زیرصنف تخصصی شما چیست؟',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 6),
                    categoryChipsRow(
                        selected: _field ?? '',
                        includeAllOption: false,
                        onSelected: (id) => setState(() => _field = id)),
                    categorySubChipsRow(
                      selected: _field ?? '',
                      onSelected: (id) => setState(() => _field = id),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pass,
                    obscureText: _hide,
                    decoration: _dec('رمز عبور', Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hide ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFFF0055),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text(
                        _register ? 'ساخت حساب' : 'ورود',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {
                      _register = !_register;
                      _error = null;
                    }),
                    child: Text(
                      _register
                          ? 'حساب دارید؟ وارد شوید'
                          : 'حساب ندارید؟ ثبت‌نام کنید',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _enter,
                    child: const Text(
                      'ورود به‌عنوان مهمان',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
