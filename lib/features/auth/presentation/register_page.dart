import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/Auth_provider.dart';
import '/core/services/user_service.dart';
import '/core/router/app_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores para todos los campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Variables para guardar los mensajes de error
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

  bool get _isPasswordSecure =>
      _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;

  bool get _showRequirements =>
      (_passwordController.text.isNotEmpty || _hasSubmittedForm) && !_isPasswordSecure;

  // Lógica de validación al pulsar el botón
  Future<void> _validateAndSubmit() async {
    setState(() {
      _hasSubmittedForm = true;

      // Validar Nombre
      if (_nameController.text.trim().isEmpty) {
        _nameError = 'Aquest camp és obligatori';
      } else {
        _nameError = null;
      }

      // Validar Nom d'usuari
      if (_usernameController.text.trim().isEmpty) {
        _usernameError = 'Aquest camp és obligatori';
      } else {
        _usernameError = null;
      }

      // Validar Email
      if (_emailController.text.trim().isEmpty) {
        _emailError = 'Aquest camp és obligatori';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
        _emailError = 'Introdueix un correu electrònic vàlid';
      } else {
        _emailError = null;
      }

      // Validar contraseñas coincidentes
      if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = 'Les contrasenyes no coincideixen';
      } else {
        _confirmPasswordError = null;
      }
    });

    // Comprobar si hay algún error en los campos de texto
    bool hasTextErrors = _nameError != null || _usernameError != null || _emailError != null || _confirmPasswordError != null;

    if (hasTextErrors) {
      return;
    }

    if (!_isPasswordSecure) {
      return;
    }

    bool b = await UserService().crearUsuari(
      _nameController.text.trim(),
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if(b) {
      final loginSuccess = await UserService().login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if(!mounted) return;

      if (loginSuccess == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al iniciar sesión después del registro.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      context.read<AuthProvider>().login(loginSuccess);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registre correcte!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person_add_alt_1_rounded, size: 40, color: Colors.blue[700]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Crea un compte',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Uneix-te a Healthy Way avui mateix!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 32),

                      _buildTextField(
                        label: 'Nom',
                        hint: 'El teu nom complet',
                        icon: Icons.person_outline,
                        controller: _nameController,
                        errorText: _nameError,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'Nom d\'usuari',
                        hint: 'El nom que vols que es mostri a Healthy Way',
                        icon: Icons.alternate_email,
                        controller: _usernameController,
                        errorText: _usernameError,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'Correu electrònic',
                        hint: 'exemple@correu.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        errorText: _emailError,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'Contrasenya',
                        hint: 'La teva contrasenya segura',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                          ),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('La contrasenya ha de contenir:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                _buildRequirementRow('Mínim 8 caràcters', _hasMinLength),
                                _buildRequirementRow('Una lletra majúscula', _hasUppercase),
                                _buildRequirementRow('Una lletra minúscula', _hasLowercase),
                                _buildRequirementRow('Un número', _hasNumber),
                                _buildRequirementRow('Un caràcter especial (!@#\$&*)', _hasSpecialChar),
                              ],
                            ),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),

                      _buildTextField(
                        label: 'Repeteix la contrasenya',
                        hint: 'Torna a escriure la contrasenya',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        errorText: _confirmPasswordError,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: _validateAndSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          shadowColor: Colors.blue.withOpacity(0.5),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Registrar-se', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "O REGISTRA'T AMB",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialButton(icon: FontAwesomeIcons.facebook, onTap: () {}),
                          const SizedBox(width: 16),
                          _SocialButton(icon: FontAwesomeIcons.google, onTap: () {}),
                          const SizedBox(width: 16),
                          _SocialButton(icon: FontAwesomeIcons.github, onTap: () {}),
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
                        const Text('Ja tens un compte?', style: TextStyle(color: Colors.blueGrey)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Inicia sessió', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
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

  Widget _buildRequirementRow(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          color: isMet ? Colors.green : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? Colors.green[700] : Colors.grey[600],
            decoration: isMet ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: Icon(icon),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: onToggleVisibility,
            )
                : null,
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
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}