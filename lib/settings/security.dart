import 'package:flutter/material.dart';

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль змінено (заглушка)')),
      );
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Безпека та доступ')),
      body: ListView(
        children: [
          ExpansionTile(
            title: const Text('Зміна пароля'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Старий пароль',
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Введіть старий пароль'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Новий пароль',
                        ),
                        validator: (value) => value == null || value.length < 6
                            ? 'Мінімум 6 символів'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Підтвердьте новий пароль',
                        ),
                        validator: (value) =>
                            value != _newPasswordController.text
                                ? 'Паролі не співпадають'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Змінити пароль'),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              )
            ],
          ),
          const Divider(height: 1),
          ExpansionTile(
            title: const Text('Двофакторна автентифікація'),
            children: const [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Загрузка',
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          ExpansionTile(
            title: const Text('Список активних сеансів'),
            children: const [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Загрузка',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
