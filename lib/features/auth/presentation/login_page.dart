import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthy_way_frontend/core/services/user_service.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../shared/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _identifierError;
  String? _passwordError;
  String? _backendError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _backendError = null;
      _identifierError = _identifierController.text.trim().isEmpty ? l10n.requiredField : null;
      _passwordError = _passwordController.text.trim().isEmpty ? l10n.requiredField : null;
    });

    if (_identifierError != null || _passwordError != null) return;

    final partialUser = await UserService().login(_identifierController.text.trim(), _passwordController.text.trim());
    final loggedUser = await UserService().getUserProfile(partialUser!.userId);
    if (!mounted) return;
    if (loggedUser != null) {
      context.read<AuthProvider>().login(loggedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginSuccess), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() { _backendError = l10n.loginError; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3EFFF), Color(0xFFF4F6F9), Color(0xFFD6E4FF)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLanguageButton(context, 'CA', const Locale('ca')),
                          const SizedBox(width: 8),
                          _buildLanguageButton(context, 'ES', const Locale('es')),
                          const SizedBox(width: 8),
                          _buildLanguageButton(context, 'EN', const Locale('en')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.alt_route_rounded, size: 40, color: Colors.blue[700]),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.appTitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[800])),
                      const SizedBox(height: 8),
                      Text(l10n.appTagline, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
                      const SizedBox(height: 32),
                      Text(l10n.welcomeBackLong, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(l10n.enterCredentials, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                      const SizedBox(height: 32),

                      if (_backendError != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_backendError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
                            ],
                          ),
                        ),

                      _buildTextField(label: l10n.usernameOrEmail, hint: l10n.usernameOrEmailHint, icon: Icons.email_outlined, controller: _identifierController, errorText: _identifierError),
                      const SizedBox(height: 16),
                      _buildTextField(label: l10n.password, hint: l10n.passwordHint, icon: Icons.lock_outline, isPassword: true, controller: _passwordController, errorText: _passwordError, obscureText: _obscurePassword, onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword)),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(l10n.forgotPassword, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: _validateAndSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                          shadowColor: Colors.blue.withValues(alpha: 0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.loginButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(l10n.noAccount, textAlign: TextAlign.center, style: const TextStyle(color: Colors.blueGrey)),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.blue, width: 1.5),
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.registerLink, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, left: 24.0, right: 24.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade400)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(l10n.connectWith, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade400)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 16),
                            _SocialButton(
                              icon: FontAwesomeIcons.google,
                              onTap: () async {
                                final success = await context.read<AuthProvider>().enterWithGoogle();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? l10n.googleLoginSuccess : l10n.googleLoginError),
                                    backgroundColor: success ? Colors.green : Colors.redAccent,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                if (success) Navigator.pushReplacementNamed(context, '/home');
                              },
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: Icon(icon),
            suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: onToggleVisibility) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade400, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageButton(BuildContext context, String label, Locale locale) {
    final current = context.watch<LanguageProvider>().locale;
    final isSelected = current?.languageCode == locale.languageCode;

    return GestureDetector(
      onTap: () => context.read<LanguageProvider>().setLocale(locale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue[700]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue[700],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}