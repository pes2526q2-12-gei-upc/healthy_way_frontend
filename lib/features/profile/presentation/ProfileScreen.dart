import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/route_service.dart';
import '../../../core/services/user_service.dart';
import '../../../shared/models/RouteModel.dart';
import '../../../shared/models/Activity.dart';
import '../../../shared/providers/Auth_provider.dart';
import '../../../shared/providers/location_provider.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildBlueBackground(),
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

            // --- SECCIÓN: LES MEVES RUTES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Les meves rutes',
                        style: TextStyle(
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

                  // AQUÍ EMPIEZA LA MAGIA DE LAS LLAMADAS AL SERVIDOR
                  FutureBuilder<List<Activity>>(
                    future: UserService().getUserActivities(context.read<AuthProvider>().currentUser!.userId),
                    builder: (context, snapshot) {

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(color: Color(0xFF1E65F3)),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error al carregar activitats: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'Encara no has fet cap ruta. Anima\'t!',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        );
                      }

                      final activitats = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activitats.length,
                        itemBuilder: (context, index) {
                          final activitat = activitats[index];

                          // 2. Por cada actividad, conseguimos los detalles de su ruta
                          return FutureBuilder<RouteModel>(
                            future: RouteService().getRouteById(activitat.route.id),
                            builder: (context, routeSnapshot) {

                              if (routeSnapshot.connectionState == ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: Center(child: CircularProgressIndicator(color: Colors.grey)),
                                );
                              }

                              if (routeSnapshot.hasError || !routeSnapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final rutaDatos = routeSnapshot.data!;

                              // 3. Juntamos la info de ambos modelos en tu ActivityCard
                              return _ActivityCard(
                                routeName: rutaDatos.name,
                                location: rutaDatos.location,
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
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE LA PANTALLA PRINCIPAL ---

  Widget _buildBlueBackground() {
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
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
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
          context.watch<AuthProvider>().currentUser!.nom,
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
            _buildTag(Icons.people_alt_outlined, context.watch<AuthProvider>().currentUser!.team ?? 'Sense Equip'),
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
        color: Colors.white.withOpacity(0.15),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('NIVELL', '12', Colors.blue),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
          _buildStatColumn('VOLTA AL MÓN', '3.4%', Colors.green, icon: Icons.public),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
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
    return '${minutes} min';
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
            color: Colors.black.withOpacity(0.05),
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
                      color: const Color(0xFF1E65F3).withOpacity(0.9),
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