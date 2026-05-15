import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'security_api.dart';
import '../../core/services/user_session.dart';
import '../../config.dart';
import 'dart:typed_data';

// ─── Theme constants ──────────────────────────────────────────────────────────

const _brown900 = Color(0xFF3E2723);
const _brown700 = Color(0xFF5D4037);
const _brown500 = Color(0xFF8D6E63);
const _brown100 = Color(0xFFEFEBE9);
const _brown50 = Color(0xFFF9F6F4);

const _green700 = Color(0xFF2E7D32);
const _green50 = Color(0xFFE8F5E9);
const _amber700 = Color(0xFFE65100);
const _red700 = Color(0xFFC62828);
const _red100 = Color(0xFFFFEBEE);
const _red200 = Color(0xFFEF9A9A);

const _textPrimary = Color(0xFF1A1A1A);
const _textSecondary = Color(0xFF757575);
const _border = Color(0xFFE0E0E0);
const _surface = Color(0xFFFFFFFF);
const _bgPage = Color(0xFFF5F5F5);

// ─── Main screen ─────────────────────────────────────────────────────────────

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  final SecurityApi api = SecurityApi(baseUrl);

  bool? _is2FAEnabled;
  bool _loading2FA = true;
  String? _userId;

  // Fake sessions — replace with real API call
  final List<_Session> _sessions = const [
    _Session(
        icon: Icons.phone_iphone,
        name: 'iPhone 15 Pro',
        location: 'Київ, Україна',
        time: 'зараз',
        isCurrent: true),
    _Session(
        icon: Icons.laptop_mac,
        name: 'MacBook Pro',
        location: 'Львів, Україна',
        time: '2 год тому',
        isCurrent: false),
    _Session(
        icon: Icons.tablet_mac,
        name: 'iPad Air',
        location: 'Варшава, Польща',
        time: '3 дні тому',
        isCurrent: false),
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userId = await UserSession.getUserId();
    await _load2FAStatus();
  }

  Future<void> _load2FAStatus() async {
    if (_userId == null) return;
    final status = await api.get2FAStatus(_userId!);
    setState(() {
      _is2FAEnabled = status;
      _loading2FA = false;
    });
  }

  Future<void> _enable2FA() async {
    if (_userId == null) return;
    final Uint8List qr = await api.setup2FA(_userId!);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Скануйте QR-код'),
        content: Image.memory(qr),
      ),
    );
    await _load2FAStatus();
  }

  Future<void> _disable2FA() async {
    if (_userId == null) return;
    await api.disable2FA(_userId!);
    await _load2FAStatus();
    if (!mounted) return;
    _showSnack('2FA вимкнено', isError: true);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _showSnack('Пароль успішно змінено');
    }
  }

  void _showSnack(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? _red700 : _green700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _lightTheme(),
      child: Scaffold(
        backgroundColor: _bgPage,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(
                  icon: Icons.lock_outline_rounded, label: 'Зміна пароля'),
              const SizedBox(height: 10),
              _buildPasswordCard(),
              const SizedBox(height: 24),
              _SectionLabel(
                  icon: Icons.shield_outlined,
                  label: 'Двофакторна автентифікація'),
              const SizedBox(height: 10),
              _build2FACard(),
              const SizedBox(height: 24),
              _SectionLabel(
                  icon: Icons.devices_rounded, label: 'Активні сеанси'),
              const SizedBox(height: 10),
              _buildSessionsCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _brown900,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: const BackButton(color: Colors.white),
      title: const Text(
        'Безпека та доступ',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 0.1,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(height: 0.5, color: Colors.white12),
      ),
    );
  }

  // ─── Password card ────────────────────────────────────────────────────────

  Widget _buildPasswordCard() {
    return _Card(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _PasswordField(
              controller: _oldPasswordController,
              label: 'Поточний пароль',
              showText: _showOld,
              onToggle: () => setState(() => _showOld = !_showOld),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Введіть поточний пароль' : null,
              isLast: false,
            ),
            _PasswordField(
              controller: _newPasswordController,
              label: 'Новий пароль',
              showText: _showNew,
              onToggle: () => setState(() => _showNew = !_showNew),
              validator: (v) =>
                  (v == null || v.length < 8) ? 'Мінімум 8 символів' : null,
              isLast: false,
            ),
            _PasswordField(
              controller: _confirmPasswordController,
              label: 'Підтвердження пароля',
              showText: _showConfirm,
              onToggle: () => setState(() => _showConfirm = !_showConfirm),
              validator: (v) => v != _newPasswordController.text
                  ? 'Паролі не збігаються'
                  : null,
              isLast: true,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _PrimaryButton(
                label: 'Зберегти пароль',
                icon: Icons.lock_rounded,
                onPressed: _submitForm,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── 2FA card ─────────────────────────────────────────────────────────────

  Widget _build2FACard() {
    return _Card(
      child: _loading2FA
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CupertinoActivityIndicator()),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _is2FAEnabled == true
                              ? _green50
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _is2FAEnabled == true
                                    ? _green700
                                    : _amber700,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _is2FAEnabled == true ? 'Увімкнено' : 'Вимкнено',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _is2FAEnabled == true
                                    ? _green700
                                    : _amber700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      CupertinoSwitch(
                        value: _is2FAEnabled == true,
                        activeColor: _brown700,
                        onChanged: (v) => v ? _enable2FA() : _disable2FA(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _is2FAEnabled == true
                        ? 'Застосунок автентифікатора активний. Код змінюється кожні 30 секунд.'
                        : 'Двофакторна автентифікація вимкнена. Рекомендуємо увімкнути для захисту акаунту.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _is2FAEnabled == true
                      ? _OutlineButton(
                          label: 'Показати QR-код',
                          icon: Icons.qr_code_rounded,
                          color: _brown700,
                          borderColor: _brown500,
                          onPressed: _enable2FA,
                        )
                      : _PrimaryButton(
                          label: 'Увімкнути 2FA',
                          icon: Icons.shield_rounded,
                          onPressed: _enable2FA,
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  // ─── Sessions card ────────────────────────────────────────────────────────

  Widget _buildSessionsCard() {
    return _Card(
      child: Column(
        children: _sessions.asMap().entries.map((e) {
          final isLast = e.key == _sessions.length - 1;
          return _SessionTile(session: e.value, isLast: isLast);
        }).toList(),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _brown500),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _brown500,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: child,
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.showText,
    required this.onToggle,
    required this.validator,
    required this.isLast,
  });

  final TextEditingController controller;
  final String label;
  final bool showText;
  final VoidCallback onToggle;
  final String? Function(String?) validator;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
              letterSpacing: 0.4,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: !showText,
          validator: validator,
          style: const TextStyle(fontSize: 15, color: _textPrimary),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(
                showText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: _textSecondary,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
        if (!isLast)
          const Divider(
              height: 0.5,
              thickness: 0.5,
              color: _border,
              indent: 16,
              endIndent: 0),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _brown700,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _Session {
  const _Session({
    required this.icon,
    required this.name,
    required this.location,
    required this.time,
    required this.isCurrent,
  });

  final IconData icon;
  final String name;
  final String location;
  final String time;
  final bool isCurrent;
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.isLast});

  final _Session session;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _brown100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(session.icon, color: _brown500, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${session.location} · ${session.time}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (session.isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _green50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Цей пристрій',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _green700,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Вийти',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _red700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 0.5,
            thickness: 0.5,
            color: _border,
            indent: 68,
            endIndent: 0,
          ),
      ],
    );
  }
}

// ─── Light theme ──────────────────────────────────────────────────────────────

ThemeData _lightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _brown700,
      onPrimary: Colors.white,
      surface: _surface,
      onSurface: _textPrimary,
      surfaceContainerHighest: _bgPage,
    ),
    scaffoldBackgroundColor: _bgPage,
    appBarTheme: const AppBarTheme(
      backgroundColor: _brown900,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      filled: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _brown700,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
  );
}
