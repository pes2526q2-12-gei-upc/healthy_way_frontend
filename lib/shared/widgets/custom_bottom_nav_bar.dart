import 'package:flutter/material.dart';
import '../../core/router/app_router.dart';
import '../providers/tracking_provider.dart';
import 'package:provider/provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5), // Sombrilla suave hacia arriba
          ),
        ],
      ),
      // SafeArea evita que la barra se superponga con la línea de inicio de los iPhone
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center, // 🔥 Esto alinea todo en el centro verticalmente
            children: [
              _BottomNavItem(
                icon: Icons.home_rounded,
                label: 'Inici',
                isActive: currentIndex == 0,
                onTap: () {
                  if (currentIndex != 0) Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
                },
              ),
              _BottomNavItem(
                icon: Icons.map_outlined,
                label: 'Mapes',
                isActive: currentIndex == 1,
                onTap: () {
                  if (currentIndex != 1) Navigator.pushReplacementNamed(context, AppRouter.mapRoute);
                },
              ),

              // 🔥 AQUÍ ESTÁ EL BOTÓN PLAY REUTILIZABLE 🔥
              GestureDetector(
                onTap: () {
                  // Acción central (Iniciar ruta, etc.)
                  final trackingProvider = context.read<TrackingProvider>();
                  bool activeRoute = trackingProvider.routeIsSelected;
                  if (!activeRoute) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('No hi ha cap ruta seleccionada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          content: const Text('Vols crear una nova ruta o explorar rutes existents?'),
                          actionsAlignment: MainAxisAlignment.center,
                          actionsOverflowButtonSpacing: 10,
                          actionsOverflowDirection: VerticalDirection.down,
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0C5AE1), // Tu color azul
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Tanca el diàleg
                                Navigator.pushNamed(context, AppRouter.exploreRoute); // Navega a explorar rutes
                              },
                              child: const Text('Explorar Rutes'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0C5AE1), // Tu color azul
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Tanca el diàleg
                                Navigator.pushNamed(context, AppRouter.runningRoute); // Navega a crear ruta
                              },
                              child: const Text('Crear Ruta'),
                            ),
                            ElevatedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Tanca el diàleg
                              },
                              child: const Text('Cancel·lar'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  else Navigator.pushNamed(context, AppRouter.runningRoute);
                },
                child: Container(
                  width: 56, // Tamaño estándar del botón
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                ),
              ),

              _BottomNavItem(
                icon: Icons.people_outline,
                label: 'Social',
                isActive: currentIndex == 2,
                onTap: () {},
              ),
              _BottomNavItem(
                icon: Icons.person_outline,
                label: 'Perfil',
                isActive: currentIndex == 3,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 60, // Fijamos un ancho para que todos ocupen lo mismo
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.blue[700] : Colors.grey, size: 28),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.blue[700] : Colors.grey,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}