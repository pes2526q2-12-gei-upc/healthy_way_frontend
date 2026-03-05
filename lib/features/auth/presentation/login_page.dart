import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // <-- Import de los iconos reales

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fondo con degradado
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3EFFF), // Azul muy clarito
              Color(0xFFF4F6F9), // Blanco grisáceo
              Color(0xFFD6E4FF), // Azul suave
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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

                // 3. Formulario - Correo
                const Text('Correu electrònic', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'exemple@correu.com',
                    prefixIcon: const Icon(Icons.email_outlined),
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
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Formulario - Contraseña
                const Text('Contrasenya', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.visibility_outlined),
                      // AQUÍ: Acción para mostrar/ocultar contraseña
                      onPressed: () {
                        // Lógica para cambiar estado de obscureText
                      },
                    ),
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
                  ),
                ),

                // 5. Botón "¿Has olvidado la contraseña?"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    // AQUÍ: Acción al hacer clic en recuperar contraseña
                    onPressed: () {
                      // Ejemplo de navegación con el Router que explicamos antes:
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
                  // AQUÍ: Acción principal de Login
                  onPressed: () {
                    // Lógica para validar el formulario e iniciar sesión
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700], // Color de fondo
                    foregroundColor: Colors.white, // Color del texto
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
                  // AQUÍ: Acción para ir a la pantalla de registro
                  onPressed: () {
                    // Navegación hacia la pantalla de registro
                    // Navigator.pushNamed(context, '/register');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    backgroundColor: Colors.blue.withOpacity(0.1),
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

                // 8. Separador "O CONNECTA AMB"
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

                // 9. Botones Sociales con logos de FontAwesome
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialButton(
                      icon: FontAwesomeIcons.facebook, // LOGO OFICIAL
                      onTap: () {
                        // AQUÍ: Lógica login Facebook
                      },
                    ),
                    const SizedBox(width: 16),
                    _SocialButton(
                      icon: FontAwesomeIcons.google, // LOGO OFICIAL
                      onTap: () {
                        // AQUÍ: Lógica login Google
                      },
                    ),
                    const SizedBox(width: 16),
                    _SocialButton(
                      icon: FontAwesomeIcons.github, // LOGO OFICIAL
                      onTap: () {
                        // AQUÍ: Lógica login GitHub
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar para los botones sociales
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
        // Le damos un color gris muy oscuro al icono para que coincida con el mockup
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}