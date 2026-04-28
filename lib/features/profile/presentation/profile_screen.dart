import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/user_service.dart';
import '../../../shared/models/activity.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/location_provider.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/models/route_model.dart';
import '../../../core/services/route_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variable para controlar qué pestaña se está mostrando
  bool _showActivities = true;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final userId = currentUser?.userId.toString() ?? ''; // Aseguramos que sea String

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER Y ESTADÍSTICAS ---
            SizedBox(
              height: 380,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  _buildBlueBackground(context),
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: _buildProfileInfo(context),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 20,
                    right: 20,
                    child: _buildStatsCard(),
                  ),
                ],
              ),
            ),

            // --- SELECTOR DE PESTAÑAS (Actividades / Rutas) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showActivities = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _showActivities ? const Color(0xFF1E65F3) : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Activitats',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _showActivities ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showActivities = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_showActivities ? const Color(0xFF1E65F3) : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Rutes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !_showActivities ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- SECCIÓN: LISTA DINÁMICA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _showActivities ? 'Les meves activitats' : 'Les meves rutes',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Veure tot',
                          style: TextStyle(
                            color: Color(0xFF1E65F3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Lógica condicional
                  _showActivities ? _buildActivitiesList(int.tryParse(userId) ?? 0) : _buildRoutesList(userId),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- BUILDER DE ACTIVIDADES ---
  Widget _buildActivitiesList(int userId) {
    return FutureBuilder<List<Activity>>(
      future: UserService().getUserActivities(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Color(0xFF1E65F3))));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al carregar activitats: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Encara no has fet cap activitat. Anima't!", style: TextStyle(color: Colors.grey, fontSize: 16))));
        }

        final activitats = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activitats.length,
          itemBuilder: (context, index) {
            final activitat = activitats[index];
            return _ActivityCard(
              routeName: activitat.route.name,
              location: activitat.route.location,
              imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=600&auto=format&fit=crop',
              distance: activitat.distance.toDouble(),
              startTime: activitat.startTime,
              endTime: activitat.endTime,
              modality: activitat.modality,
              pace: activitat.pace.toDouble(),
            );
          },
        );
      },
    );
  }

  // --- BUILDER DE RUTAS ---
  // --- BUILDER DE RUTAS ---
  Widget _buildRoutesList(String userId) {
    return FutureBuilder<List<RouteModel>>(
      future: RouteService().getPublicRoutes(creator: userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Color(0xFF1E65F3))));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al carregar rutes: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Encara no has creat cap ruta.", style: TextStyle(color: Colors.grey, fontSize: 16))));
        }

        final routes = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final ruta = routes[index];

            Color badgeColor = Colors.blue;
            if (ruta.modality.toLowerCase() == 'cycling') {
              badgeColor = Colors.green;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _RouteCard(
                id: ruta.id, // <-- Pasamos el ID
                title: ruta.name.isEmpty ? 'Ruta sense nom' : ruta.name,
                distance: '${ruta.distance.toStringAsFixed(2)} km',
                location: ruta.location.isEmpty ? '--' : ruta.location,
                badgeText: ruta.modality.isEmpty ? 'RUTA' : ruta.modality.toUpperCase(),
                badgeColor: badgeColor,
                teamControl: ruta.isPrivate ? 'Ruta Privada' : 'Ruta Pública',
                onDelete: () => _confirmarBorradoRuta(ruta.id), // <-- Nueva función
              ),
            );
          },
        );
      },
    );
  }

  // --- LÓGICA DE BORRADO ---
  void _confirmarBorradoRuta(String id) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar Ruta'),
          content: const Text('Estàs segur que vols eliminar aquesta ruta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel·lar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                // Aquí llamas a tu función
                await RouteService().deleteRoute(id);

                // Refrescamos la pantalla
                setState(() {});
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- MÉTODOS DE LA PANTALLA PRINCIPAL ---

  Widget _buildBlueBackground(BuildContext context) {
    return Container(
      height: 310,
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            right: 20,
            child: Theme(
              // Forzamos el color del icono principal a blanco
              data: Theme.of(context).copyWith(
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.settings_outlined, size: 28),
                offset: const Offset(0, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                onSelected: (String value) async {
                  if (value == 'strava') {
                    final messenger = ScaffoldMessenger.of(context);
                    final userId = context.read<AuthProvider>().currentUser!.userId;

                    UserService().importStravaRoutes(userId).then((result) {
                      messenger.showSnackBar(
                        SnackBar(
                            content: Text(result),
                            duration: const Duration(seconds: 2),
                        ),
                      );
                    });
                  }
                  else if (value == 'logout') {
                    final authProvider = context.read<AuthProvider>();
                    Navigator.pushNamedAndRemoveUntil(context, AppRouter.loginRoute, (route) => false);
                    Future.delayed(const Duration(milliseconds: 400), () async {
                      await authProvider.logout();
                    });
                  }
                  else if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Eliminar Compte'),
                          content: const Text('Estàs segur que vols eliminar el teu compte? Aquesta acció no es pot desfer i perdràs totes les teves dades i rutes.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              child: const Text('Cancel·lar', style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(dialogContext);

                                final authProvider = context.read<AuthProvider>();
                                final user = authProvider.currentUser;

                                if (user != null) {
                                  try {
                                    await UserService().eliminarUsuari(user.userId);
                                    if (!context.mounted) return;
                                    Navigator.pushNamedAndRemoveUntil(context, AppRouter.loginRoute, (route) => false);
                                    Future.delayed(const Duration(milliseconds: 400), () async {
                                      await authProvider.logout();
                                    });
                                  }
                                  catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error al eliminar el compte: $e'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  // 1. Conectar amb Strava
                  const PopupMenuItem<String>(
                    value: 'strava',
                    child: Row(
                      children: [
                        Icon(Icons.sync, color: Colors.orange),
                        SizedBox(width: 12),
                        Text('Conectar amb Strava'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  // 2. Tancar Sessió
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.black54),
                        SizedBox(width: 12),
                        Text('Tancar Sessió'),
                      ],
                    ),
                  ),
                  // 3. Eliminar Compte
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Eliminar Compte',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser!;
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xFF4A85F6),
                child: Icon(Icons.person_outline, size: 50, color: Colors.white),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, size: 12, color: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 15),

        Text(
          currentUser.nom,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTag(Icons.people_alt_outlined, currentUser.team ?? 'Sense Equip'),
            const SizedBox(width: 10),
            _buildTag(Icons.location_on_outlined, context.watch<LocationProvider>().placeName),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('NIVELL', '12', Colors.blue),
          Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
          _buildStatColumn('VOLTA AL MÓN', '3.4%', Colors.green, icon: Icons.public),
          Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
          _buildStatColumn('PUNTS', '2.450', Colors.amber),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor, {IconData? icon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: valueColor),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- CARD DE ACTIVIDAD ---
class _ActivityCard extends StatelessWidget {
  final String routeName;
  final String location;
  final String imageUrl;
  final double distance;
  final DateTime startTime;
  final DateTime endTime;
  final String modality;
  final double pace;

  const _ActivityCard({
    required this.routeName,
    required this.location,
    required this.imageUrl,
    required this.distance,
    required this.startTime,
    required this.endTime,
    required this.modality,
    required this.pace,
  });

  String _calculateDuration() {
    final difference = endTime.difference(startTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E65F3).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      modality.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(Icons.straighten, '${distance.toStringAsFixed(2)} km', 'Distància'),
                      _buildStatItem(Icons.timer_outlined, _calculateDuration(), 'Temps'),
                      _buildStatItem(Icons.speed, '$pace min/km', 'Ritme'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1E65F3), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// --- CARD DE RUTA ---
// --- CARD DE RUTA ---
class _RouteCard extends StatelessWidget {
  final String id; // <-- Añadido
  final String title;
  final String distance;
  final String location;
  final String badgeText;
  final Color badgeColor;
  final String teamControl;
  final VoidCallback onDelete; // <-- Añadido

  const _RouteCard({
    required this.id,
    required this.title,
    required this.distance,
    required this.location,
    required this.badgeText,
    required this.badgeColor,
    required this.teamControl,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.landscape, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]), overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 12),
                    const Icon(Icons.directions_run, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(distance, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Para empujar el botón a la derecha
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, size: 14, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text(teamControl, style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w500)),
                      ],
                    ),
                    // BOTÓN DE BORRAR
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}