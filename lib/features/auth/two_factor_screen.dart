import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../../settings/security_api.dart';
import '../../core/services/user_session.dart';
import '../../config.dart';
import '../../core/widgets/animated_loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwoFactorScreen extends StatefulWidget {
  final String userId;

  const TwoFactorScreen({
    super.key,
    required this.userId,
  });

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final _codeController = TextEditingController();

  bool isLoading = false;
  String? error;

  late final SecurityApi api;

  @override
  void initState() {
    super.initState();
    api = SecurityApi(baseUrl);
  }

  Future<void> _verify2FA() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        error = 'Введіть код підтвердження';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await api.verify2FALogin(
        widget.userId,
        code,
      );

      if (result['success'] == true) {
        final userId = result['userId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SplashScreen(userId: userId),
          ),
        );
      } else {
        setState(() {
          error = result['message'] ?? 'Помилка 2FA';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Невірний код або сервер недоступний';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8DDD4),
        elevation: 0,
        title: const Text(
          'Двофакторна автентифікація',
          style: TextStyle(
            color: Color(0xFF5D4E37),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF5D4E37),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B6F47),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Підтвердження входу',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4E37),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Введіть 6-значний код з додатку автентифікації',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8B6F47),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F1EB),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFD4C4B0),
                    ),
                  ),
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      counterText: '',
                      labelText: 'Код підтвердження',
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.lock_clock,
                        color: Color(0xFF8B6F47),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                if (error != null) const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF8B6F47),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _verify2FA,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF8B6F47,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                15,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Підтвердити',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
