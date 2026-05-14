import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/user_service.dart';
import '../../../shared/models/activity.dart';
import '../../../shared/models/user_model.dart';
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
  bool _showActivities = true;
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = UserService().getUserProfile(context.read<AuthProvider>().currentUser!.userId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = context.watch<AuthProvider>().currentUser;
    final userId = currentUser?.userId.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 380,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  _buildBlueBackground(context),
                  Positioned(top: 60, left: 0, right: 0, child: _buildProfileInfo(context)),
                  Positioned(bottom: 10, left: 20, right: 20, child: _buildStatsCard()),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Container(
                height: 45,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: [
                    Expanded(child: GestureDetector(
                      onTap: () => setState(() => _showActivities = true),
                      child: Container(decoration: BoxDecoration(color: _showActivities ? const Color(0xFF1E65F3) : Colors.transparent, borderRadius: BorderRadius.circular(25)), alignment: Alignment.center, child: Text(l10n.activities, style: TextStyle(fontWeight: FontWeight.bold, color: _showActivities ? Colors.white : Colors.grey[600]))),
                    )),
                    Expanded(child: GestureDetector(
                      onTap: () => setState(() => _showActivities = false),
                      child: Container(decoration: BoxDecoration(color: !_showActivities ? const Color(0xFF1E65F3) : Colors.transparent, borderRadius: BorderRadius.circular(25)), alignment: Alignment.center, child: Text(l10n.routesTab, style: TextStyle(fontWeight: FontWeight.bold, color: !_showActivities ? Colors.white : Colors.grey[600]))),
                    )),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_showActivities ? l10n.myActivities : l10n.myRoutes, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
                  const SizedBox(height: 10),
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

  Widget _buildActivitiesList(int userId) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<Activity>>(
      future: UserService().getUserActivities(userId),
      builder: (BuildContext context, AsyncSnapshot<List<Activity>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Color(0xFF1E65F3))));
        if (snapshot.hasError) return Center(child: Text('${l10n.errorLoadingActivities}: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text(l10n.noActivitiesYet, style: const TextStyle(color: Colors.grey, fontSize: 16))));

        final activitats = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: activitats.length,
          itemBuilder: (context, index) {
            final activitat = activitats[index];
            return _ActivityCard(routeName: activitat.route.name, routeId: activitat.routeId, imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=600&auto=format&fit=crop', distance: activitat.distance.toDouble(), startTime: activitat.startTime, endTime: activitat.endTime, modality: activitat.modality, pace: activitat.pace.toDouble());
          },
        );
      },
    );
  }

  Widget _buildRoutesList(String userId) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<RouteModel>>(
      future: RouteService().getPublicRoutes(creator: userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Color(0xFF1E65F3))));
        if (snapshot.hasError) return Center(child: Text('${l10n.errorLoadingRoutes}: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text(l10n.noRoutesYet, style: const TextStyle(color: Colors.grey, fontSize: 16))));

        final routes = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: routes.length,
          itemBuilder: (context, index) {
            final ruta = routes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _RouteCard(id: ruta.id, title: ruta.name.isEmpty ? l10n.noNameDefined : ruta.name, distance: '${ruta.distance.toStringAsFixed(2)} km', location: ruta.location.isEmpty ? '--' : ruta.location, badgeColor: Colors.blue, teamControl: ruta.isPrivate ? l10n.privateRoute : l10n.publicRoute, onDelete: () => _confirmarBorradoRuta(ruta.id)),
            );
          },
        );
      },
    );
  }

  void _confirmarBorradoRuta(String id) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteRouteTitle),
          content: Text(l10n.confirmDeleteRoute),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await RouteService().deleteRoute(id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.routeDeletedSuccess), backgroundColor: Colors.green, duration: const Duration(seconds: 2)));
                  setState(() {});
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.deleteLabel}: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
                }
              },
              child: Text(l10n.deleteLabel, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBlueBackground(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 310,
      decoration: BoxDecoration(color: Colors.blue[700], borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))),
      child: Stack(
        children: [
          Positioned(
            top: 50, right: 20,
            child: Theme(
              data: Theme.of(context).copyWith(iconTheme: const IconThemeData(color: Colors.white)),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.settings_outlined, size: 28),
                offset: const Offset(0, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                onSelected: (String value) async {
                  if (value == 'strava') {
                    final messenger = ScaffoldMessenger.of(context);
                    final userId = context.read<AuthProvider>().currentUser!.userId;
                    UserService().importStravaRoutes(userId).then((result) => messenger.showSnackBar(SnackBar(content: Text(result), duration: const Duration(seconds: 2))));
                  } else if (value == 'logout') {
                    final authProvider = context.read<AuthProvider>();
                    Navigator.pushNamedAndRemoveUntil(context, AppRouter.loginRoute, (route) => false);
                    Future.delayed(const Duration(milliseconds: 400), () async => await authProvider.logout());
                  } else if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text(l10n.deleteAccountLabel),
                          content: Text(l10n.confirmDeleteAccount),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey))),
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
                                    Future.delayed(const Duration(milliseconds: 400), () async => await authProvider.logout());
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.deleteAccountLabel}: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 4)));
                                  }
                                }
                              },
                              child: Text(l10n.deleteLabel, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'strava', child: Row(children: [const Icon(Icons.sync, color: Colors.orange), const SizedBox(width: 12), Text(l10n.connectStrava)])),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(value: 'logout', child: Row(children: [const Icon(Icons.logout, color: Colors.black54), const SizedBox(width: 12), Text(l10n.logoutLabel)])),
                  PopupMenuItem<String>(value: 'delete', child: Row(children: [const Icon(Icons.delete_outline, color: Colors.red), const SizedBox(width: 12), Text(l10n.deleteAccountLabel, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = context.watch<AuthProvider>().currentUser!;
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const CircleAvatar(radius: 45, backgroundColor: Color(0xFF4A85F6), child: Icon(Icons.person_outline, size: 50, color: Colors.white))),
            Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle), child: const Icon(Icons.star, size: 12, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 15),
        Text(currentUser.nom, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTag(Icons.people_alt_outlined, currentUser.team ?? l10n.noTeam),
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
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [Icon(icon, color: Colors.white, size: 14), const SizedBox(width: 5), Text(text, style: const TextStyle(color: Colors.white, fontSize: 12))]),
    );
  }

  Widget _buildStatsCard() {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final user = snapshot.data!;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(l10n.kmRunning, '${user.totalRunningDistance?.toStringAsFixed(1)} km', Colors.blue, icon: Icons.directions_run),
              Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
              _buildStatColumn(l10n.kmCycling, '${user.totalCyclingDistance?.toStringAsFixed(1)} km', Colors.green, icon: Icons.directions_bike),
              Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
              _buildStatColumn(l10n.totalPoints, user.totalPoints.toString(), Colors.amber, icon: Icons.emoji_events),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor, {IconData? icon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 18, color: valueColor), const SizedBox(width: 4)],
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: valueColor)),
          ],
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String routeName;
  final int routeId;
  final String imageUrl;
  final double distance;
  final DateTime startTime;
  final DateTime endTime;
  final String modality;
  final double pace;

  const _ActivityCard({required this.routeName, required this.routeId, required this.imageUrl, required this.distance, required this.startTime, required this.endTime, required this.modality, required this.pace});

  String _calculateDuration() {
    final difference = endTime.difference(startTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    return hours > 0 ? '${hours}h ${minutes}m' : '$minutes min';
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(height: 150, color: Colors.grey[300], child: const Icon(Icons.image_not_supported, color: Colors.grey))),
                Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF1E65F3).withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)), child: Text(modality.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RouteNameRow(routeId: routeId),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _LocationRow(routeId: routeId)),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(16)), child: Text(_formatDate(endTime), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                  ]),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFEEEEEE))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(Icons.straighten, '${distance.toStringAsFixed(2)} km', l10n.distanceStat),
                      _buildStatItem(Icons.timer_outlined, _calculateDuration(), l10n.timeStat),
                      _buildStatItem(Icons.speed, '$pace min/km', l10n.paceStat),
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3142))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  final String id, title, distance, location, teamControl;
  final Color badgeColor;
  final VoidCallback onDelete;

  const _RouteCard({required this.id, required this.title, required this.distance, required this.location, required this.badgeColor, required this.teamControl, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.landscape, color: Colors.grey))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]), overflow: TextOverflow.ellipsis)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)))]),
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(width: 12), const Icon(Icons.directions_run, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(distance, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [Icon(Icons.people, size: 14, color: Colors.blue[700]), const SizedBox(width: 4), Text(teamControl, style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w500))]),
                    GestureDetector(onTap: onDelete, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.delete_outline, color: Colors.red, size: 20))),
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

class _LocationRow extends StatelessWidget {
  final int routeId;
  const _LocationRow({required this.routeId});

  Future<String> _fetchLocation(AppLocalizations l10n) async {
    if (routeId == -9) return l10n.unknownLocation;
    try {
      final routes = await RouteService().getPublicRoutes(routeId: routeId.toString());
      if (routes.isNotEmpty && routes.first.location.isNotEmpty) return routes.first.location;
      return l10n.noLocationDefined;
    } catch (e) { return l10n.errorLoadingLocation; }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<String>(
      future: _fetchLocation(l10n),
      builder: (context, snapshot) {
        final text = snapshot.connectionState == ConnectionState.done ? (snapshot.data ?? l10n.unknownFeminine) : l10n.loading;
        return Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis))]);
      },
    );
  }
}

class _RouteNameRow extends StatelessWidget {
  final int routeId;
  const _RouteNameRow({required this.routeId});

  Future<String> _fetchRouteName(AppLocalizations l10n) async {
    if (routeId == -9) return l10n.defaultActivity;
    try {
      final routes = await RouteService().getPublicRoutes(routeId: routeId.toString());
      if (routes.isNotEmpty && routes.first.name.isNotEmpty) return routes.first.name;
      return l10n.noNameDefined;
    } catch (e) { return l10n.errorLoadingName; }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<String>(
      future: _fetchRouteName(l10n),
      builder: (context, snapshot) {
        final text = snapshot.connectionState == ConnectionState.done ? (snapshot.data ?? l10n.unknown) : l10n.loading;
        return Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)), maxLines: 1, overflow: TextOverflow.ellipsis);
      },
    );
  }
}