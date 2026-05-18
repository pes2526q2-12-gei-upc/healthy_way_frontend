import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '/core/services/user_service.dart';
import '/core/router/app_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _usernameError;
  String? _emailError;
  String? _confirmPasswordError;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasSubmittedForm = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      final password = _passwordController.text;
      setState(() {
        _hasMinLength = password.length >= 8;
        _hasUppercase = password.contains(RegExp(r'[A-Z]'));
        _hasLowercase = password.contains(RegExp(r'[a-z]'));
        _hasNumber = password.contains(RegExp(r'[0-9]'));
        _hasSpecialChar = password.contains(RegExp(r'[!@#\$&*~_.,\-]'));
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isPasswordSecure => _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;
  bool get _showRequirements => (_passwordController.text.isNotEmpty || _hasSubmittedForm) && !_isPasswordSecure;

  Future<void> _validateAndSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _hasSubmittedForm = true;
      _nameError = _nameController.text.trim().isEmpty ? l10n.requiredField : null;
      _usernameError = _usernameController.text.trim().isEmpty ? l10n.requiredField : null;
      if (_emailController.text.trim().isEmpty) {
        _emailError = l10n.requiredField;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
        _emailError = l10n.invalidEmail;
      } else {
        _emailError = null;
      }
      _confirmPasswordError = _passwordController.text != _confirmPasswordController.text ? l10n.passwordsDontMatch : null;
    });

    if (_nameError != null || _usernameError != null || _emailError != null || _confirmPasswordError != null) return;
    if (!_isPasswordSecure) return;

    bool b = await UserService().crearUsuari(_nameController.text.trim(), _usernameController.text.trim(), _emailController.text.trim(), _passwordController.text);

    if (b) {
      final loginSuccess = await UserService().login(_emailController.text.trim(), _passwordController.text);
      if (!mounted) return;
      if (loginSuccess == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.registerAfterLoginError), backgroundColor: Colors.redAccent));
        return;
      }
      context.read<AuthProvider>().login(loginSuccess);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.registerSuccess), backgroundColor: Colors.green));
      Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE3EFFF), Color(0xFFF4F6F9), Color(0xFFD6E4FF)]),
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
                      Align(alignment: Alignment.center, child: CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person_add_alt_1_rounded, size: 40, color: Colors.blue[700]))),
                      const SizedBox(height: 16),
                      Text(l10n.createAccount, textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[800])),
                      const SizedBox(height: 8),
                      Text(l10n.joinToday, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
                      const SizedBox(height: 32),

                      _buildTextField(label: l10n.name, hint: l10n.nameHint, icon: Icons.person_outline, controller: _nameController, errorText: _nameError),
                      const SizedBox(height: 16),
                      _buildTextField(label: l10n.username, hint: l10n.usernameHint, icon: Icons.alternate_email, controller: _usernameController, errorText: _usernameError),
                      const SizedBox(height: 16),
                      _buildTextField(label: l10n.emailLabel, hint: l10n.emailHint, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, controller: _emailController, errorText: _emailError),
                      const SizedBox(height: 16),
                      _buildTextField(label: l10n.password, hint: l10n.passwordHintSecure, icon: Icons.lock_outline, isPassword: true, controller: _passwordController, obscureText: _obscurePassword, onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword)),
                      const SizedBox(height: 8),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.hardEdge,
                        child: _showRequirements
                            ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5))),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.passwordRequirements, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                _buildRequirementRow(l10n.passwordMinLength, _hasMinLength),
                                _buildRequirementRow(l10n.passwordUppercase, _hasUppercase),
                                _buildRequirementRow(l10n.passwordLowercase, _hasLowercase),
                                _buildRequirementRow(l10n.passwordNumber, _hasNumber),
                                _buildRequirementRow(l10n.passwordSpecialChar, _hasSpecialChar),
                              ],
                            ),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),

                      _buildTextField(label: l10n.repeatPassword, hint: l10n.repeatPasswordHint, icon: Icons.lock_outline, isPassword: true, controller: _confirmPasswordController, obscureText: _obscureConfirmPassword, errorText: _confirmPasswordError, onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: _validateAndSubmit,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 5, shadowColor: Colors.blue.withValues(alpha: 0.5)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(l10n.registerSubmit, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(l10n.registerWith, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))),
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
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? l10n.googleLoginSuccess : l10n.googleLoginError), backgroundColor: success ? Colors.green : Colors.redAccent, duration: const Duration(seconds: 2)));
                              if (success) Navigator.pushReplacementNamed(context, '/home');
                            },
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.alreadyAccount, style: const TextStyle(color: Colors.blueGrey)),
                        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.signIn, style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold))),
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

  Widget _buildRequirementRow(String text, bool isMet) {
    return Row(
      children: [
        Icon(isMet ? Icons.check_circle : Icons.circle_outlined, color: isMet ? Colors.green : Colors.grey, size: 16),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 12, color: isMet ? Colors.green[700] : Colors.grey[600], decoration: isMet ? TextDecoration.lineThrough : null)),
      ],
    );
  }

  Widget _buildTextField({required String label, required String hint, required IconData icon, bool isPassword = false, TextInputType keyboardType = TextInputType.text, TextEditingController? controller, bool obscureText = false, VoidCallback? onToggleVisibility, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint, errorText: errorText, prefixIcon: Icon(icon),
            suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: onToggleVisibility) : null,
            filled: true, fillColor: Colors.white,
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
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SocialButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(50), child: Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]), child: Icon(icon, color: Colors.black87)));
  }
}