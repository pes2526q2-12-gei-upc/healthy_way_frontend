import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/route_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/location_provider.dart';
import '../../../shared/providers/tracking_provider.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../core/services/route_service.dart';
import '../../../core/services/location_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    iniciaGPS();
  }

  Future<void> iniciaGPS() async {
    LocationService().startTracking();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LocationProvider>().fetchLocationName(context.read<AuthProvider>().currentUser?.userId ?? 0);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- CABECERA AZUL ---
            Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 24, backgroundColor: Colors.white.withValues(alpha: 0.2), child: const Icon(Icons.person, color: Colors.white)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.welcomeBackShort, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              Text(context.watch<AuthProvider>().currentUser?.nom ?? l10n.unknown, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tarjeta Calidad del Aire
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            final locProvider = context.watch<LocationProvider>();
                            final score = locProvider.weatherScore;

                            String aqiText = l10n.unknown;
                            Color aqiColor = Colors.grey;

                            if (score >= 0 && score <= 25) { aqiText = l10n.excellent; aqiColor = Colors.greenAccent; }
                            else if (score > 25 && score <= 50) { aqiText = l10n.good; aqiColor = Colors.yellowAccent; }
                            else if (score > 50 && score <= 75) { aqiText = l10n.moderate_air; aqiColor = Colors.orangeAccent; }
                            else if (score > 75) { aqiText = l10n.bad; aqiColor = Colors.redAccent; }

                            if (locProvider.isLoading) {
                              return const SizedBox(height: 32, width: 32, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
                            }

                            return Row(
                              children: [
                                Icon(Icons.air, color: aqiColor, size: 32),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.airQualityLong, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        Text('$aqiText ', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                        Text(score >= 0 ? '(AQI $score)' : l10n.noDataParens, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(context.watch<LocationProvider>().placeName, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis, maxLines: 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- CONTENIDO PRINCIPAL ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CONQUESTA: no tocar, hardcodeado por ahora ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [Icon(Icons.flag_outlined, color: Colors.blue[800]), const SizedBox(width: 8), Text('La Conquesta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]))]),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('3r', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900])), const Text('Posició global', style: TextStyle(fontSize: 10, color: Colors.grey))]),
                          ],
                        ),
                        const Text('Equip "Los Gambas"', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 16),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Territori capturat (Setmana)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text('65%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[800]))]),
                        const SizedBox(height: 8),
                        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: 0.65, minHeight: 12, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!))),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(children: [const Text('Punts totals', style: TextStyle(fontSize: 12, color: Colors.grey)), Text('12.4k', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]))]),
                            Container(width: 1, height: 30, color: Colors.grey[300]),
                            const Column(children: [Text('Arees noves', style: TextStyle(fontSize: 12, color: Colors.grey)), Text('+4', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green))]),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- RUTES RECOMANADES ---
                  Text(l10n.recommendedRoutes, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                  const SizedBox(height: 12),

                  FutureBuilder<List<RouteModel>>(
                    future: RouteService().getRecommendedRoutes(context.watch<LocationProvider>().currentLocation, 100),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text(l10n.errorLoadingRecommended));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text(l10n.noRecommendedRoutes));
                      } else {
                        final routes = snapshot.data!;
                        return Column(
                          children: routes.map((route) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _RouteCard(route: route),
                          )).toList(),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final RouteModel route;

  const _RouteCard({required this.route});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double score = route.points;
    if (score > 0 && score <= 1.0) {
      score = score * 100;
    }
    String badgeText = l10n.unknown;
    Color badgeColor = Colors.grey;

    if (score >= 0 && score <= 25) {
      badgeText = l10n.excellent;
      badgeColor = Colors.green;
    } else if (score > 25 && score <= 50) {
      badgeText = l10n.good;
      badgeColor = Colors.amber;
    } else if (score > 50 && score <= 75) {
      badgeText = l10n.moderate_air;
      badgeColor = Colors.orange;
    } else if (score > 75) {
      badgeText = l10n.bad;
      badgeColor = Colors.red;
    }

    final _primaryBlue = Colors.blue[700]!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)
            )
          ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.blue.withValues(alpha: 0.1),
                  child: Icon(Icons.map_outlined, color: _primaryBlue, size: 32)
              )
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                          route.name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.air, size: 12, color: badgeColor),
                          const SizedBox(width: 4),
                          Text(
                              badgeText.toUpperCase(),
                              style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                    children: [
                      const Icon(Icons.directions_run, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${route.distance} km', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 12),

                      const Icon(Icons.trending_up, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${route.elevationGain} m', style: const TextStyle(fontSize: 12, color: Colors.grey))
                    ]
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: _primaryBlue),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              route.location,
                              style: TextStyle(fontSize: 12, color: _primaryBlue, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    GestureDetector(
                      onTap: () {
                        context.read<TrackingProvider>().setSelectedRoute(route);
                        Navigator.pushNamed(context, AppRouter.routeView);
                      },
                      child: Icon(
                          Icons.chevron_right_rounded,
                          color: _primaryBlue,
                          size: 20
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