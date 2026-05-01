import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthy_way_frontend/core/services/user_service.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para los campos
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variables para gestionar la visibilidad y errores
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

  // Lógica de validación antes de hacer la llamada al backend
  Future<void> _validateAndSubmit() async {
    setState(() {
      _backendError = null;

      // Validar Identifier (Email o Username)
      if (_identifierController.text.trim().isEmpty) {
        _identifierError = 'Aquest camp és obligatori';
      } else {
        _identifierError = null;
      }

      // Validar Contraseña
      if (_passwordController.text.trim().isEmpty) {
        _passwordError = 'Aquest camp és obligatori';
      } else {
        _passwordError = null;
      }
    });

    // Si hay errores locales, detenemos la ejecución
    if (_identifierError != null || _passwordError != null) {
      return;
    }

    final partialUser = await UserService().login(_identifierController.text.trim(), _passwordController.text.trim());
    final loggedUser = await UserService().getUserProfile(partialUser!.userId);
    if (!mounted) return;
    if(loggedUser != null){
      context.read<AuthProvider>().login(loggedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Inici de sessió correcte!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacementNamed(context, '/home');
    }
    else{
      setState(() {
        _backendError = 'Username o contrasenya incorrectes. Torna-ho a provar.';
      });
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
                      // 1. Logo
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.alt_route_rounded, size: 40, color: Colors.blue[700]),
                      ),
                      const SizedBox(height: 16),

                      // 2. Textos de Cabecera
                      Text(
                        'Healthy Way',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Troba el teu camí cap al benestar',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'Benvingut/da de nou!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Introdueix les teves credencials per continuar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 32),

                      // NUEVO: Mensaje de error del backend
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
                              Expanded(
                                child: Text(
                                  _backendError!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 3. Formulario - Correo / Username
                      _buildTextField(
                        label: 'Username o Correu electrònic',
                        hint: 'Introdueix el teu usuari o email',
                        icon: Icons.email_outlined,
                        controller: _identifierController,
                        errorText: _identifierError,
                      ),
                      const SizedBox(height: 16),

                      // 4. Formulario - Contraseña
                      _buildTextField(
                        label: 'Contrasenya',
                        hint: 'La teva contrasenya',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        errorText: _passwordError,
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),

                      // 5. Botón "¿Has olvidado la contraseña?"
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: const Text(
                            'Has oblidat la contrasenya?',
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 6. Botón Principal "Entrar"
                      ElevatedButton(
                        onPressed: _validateAndSubmit, // Llamamos a nuestra validación
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          shadowColor: Colors.blue.withValues(alpha: 0.5),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 7. Sección "Regístrate"
                      const Text(
                        'No tens compte\nencara?',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.blue, width: 1.5),
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Registra't",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Elementos que rellenan la parte inferior de la pantalla
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
                              child: Text(
                                'O CONNECTA AMB',
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
                            const SizedBox(width: 16),
                            _SocialButton(
                              icon: FontAwesomeIcons.google,
                              onTap: () async {
                                final success = await context.read<AuthProvider>().enterWithGoogle();
                                if (!context.mounted) return;
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Inici de sessió amb Google correcte!'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pushReplacementNamed(context, '/home');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Error en iniciar sessió amb Google. Torna-ho a provar.'),
                                      backgroundColor: Colors.redAccent,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
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

  // Widget extraído para reutilizar el diseño y lógica del campo de texto
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
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: onToggleVisibility,
            )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}