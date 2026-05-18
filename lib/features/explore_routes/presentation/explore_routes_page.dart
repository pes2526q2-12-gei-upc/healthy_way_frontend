import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:healthy_way_frontend/shared/models/route_model.dart';
import 'package:provider/provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/route_service.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/providers/tracking_provider.dart';

class ExploreRoutesScreen extends StatefulWidget {
  const ExploreRoutesScreen({super.key});

  @override
  State<ExploreRoutesScreen> createState() => _ExploreRoutesScreenState();
}

class _ExploreRoutesScreenState extends State<ExploreRoutesScreen> {
  final Color _primaryBlue = const Color(0xFF1E6AFB);
  final Color _inactiveFilterTextColor = const Color(0xFF71717A);
  final Color _backgroundGray = const Color(0xFFF1F5F9);
  final Color _darkSelectedBlue = const Color(0xFF0C5AE1);

  final TextEditingController _routeNameController = TextEditingController();
  final TextEditingController _creatorController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minDistController = TextEditingController();
  final TextEditingController _maxDistController = TextEditingController();

  @override
  void dispose() {
    _routeNameController.dispose();
    _creatorController.dispose();
    _locationController.dispose();
    _minDistController.dispose();
    _maxDistController.dispose();
    super.dispose();
  }

  List<RouteModel> _routes = [];
  bool _isLoading = true;

  void _restablecerFiltros() {
    _routeNameController.clear();
    _creatorController.clear();
    _locationController.clear();
    _minDistController.clear();
    _maxDistController.clear();
    Navigator.pop(context);
    loadData();
  }

  void _mostrarMenuFiltros() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.filterRoutes, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(controller: _creatorController, decoration: InputDecoration(labelText: l10n.creator, prefixIcon: const Icon(Icons.person))),
                TextField(controller: _locationController, decoration: InputDecoration(labelText: l10n.location, prefixIcon: const Icon(Icons.location_city))),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _minDistController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.minDist))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: _maxDistController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.maxDist))),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent), padding: const EdgeInsets.symmetric(vertical: 14)), onPressed: _restablecerFiltros, child: Text(l10n.reset))),
                    const SizedBox(width: 15),
                    Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C5AE1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)), onPressed: () { Navigator.pop(context); loadData(); }, child: Text(l10n.apply))),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> loadData() async {
    try {
      String? rName = _routeNameController.text.isNotEmpty ? _routeNameController.text : null;
      String? creator = _creatorController.text.isNotEmpty ? _creatorController.text : null;
      String? loc = _locationController.text.isNotEmpty ? _locationController.text : null;
      double? minD = double.tryParse(_minDistController.text);
      double? maxD = double.tryParse(_maxDistController.text);

      List<RouteModel> rutasObtenidas = await RouteService().getPublicRoutes(name: rName, creator: creator, location: loc, minDistance: minD, maxDistance: maxD);
      setState(() { _routes = rutasObtenidas; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; });
      debugPrint('ERROR AL CARGAR DATOS: $e');
    }
  }

  _ExploreRoutesScreenState() { loadData(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundGray,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  AppBar _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pushNamed(context, AppRouter.mapRoute)),
      title: Text(l10n.exploreRoutes, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: Stack(children: [
            const Icon(Icons.notifications_outlined, color: Colors.black, size: 28),
            Positioned(right: 0, top: 0, child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Text(' ', style: TextStyle(fontSize: 8)))),
          ]),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(color: Colors.white, padding: const EdgeInsets.only(bottom: 20), child: Column(children: [_buildSearchBar()])),
        const SizedBox(height: 16),
        _buildRouteListHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_isLoading) ...[const SizedBox(height: 50), const Center(child: CircularProgressIndicator(color: Color(0xFF1E6AFB)))]
                else if (_routes.isEmpty) ...[const SizedBox(height: 50), Text(l10n.noRoutesFound, style: TextStyle(color: _inactiveFilterTextColor, fontSize: 14))]
                else ...[for (RouteModel ruta in _routes) _buildSingleRouteCard(ruta), const SizedBox(height: 100)],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _routeNameController,
              onChanged: (_) => loadData(),
              decoration: InputDecoration(
                hintText: l10n.searchRoutesByName,
                hintStyle: TextStyle(color: _inactiveFilterTextColor.withValues(alpha: 0.6)),
                prefixIcon: Icon(Icons.search, color: _inactiveFilterTextColor.withValues(alpha: 0.6)),
                filled: true, fillColor: _backgroundGray,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(color: _backgroundGray, borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: Icon(Icons.tune, color: _inactiveFilterTextColor), onPressed: _mostrarMenuFiltros),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteListHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.publicRoutes, style: const TextStyle(color: Color(0xFF1E6AFB), fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          Text(l10n.results(_routes.length), style: TextStyle(color: _inactiveFilterTextColor, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSingleRouteCard(RouteModel ruta) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: _darkSelectedBlue),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                Container(width: 100, height: 100, color: _backgroundGray, child: const Icon(Icons.image, color: Color(0xFF94A3B8), size: 40)),
                                Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(12)))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text(ruta.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)), Icon(Icons.favorite_outline, color: _inactiveFilterTextColor, size: 24)]),
                                const SizedBox(height: 4),
                                Row(children: [Icon(Icons.location_on_outlined, color: _inactiveFilterTextColor, size: 16), const SizedBox(width: 4), Text(ruta.location, style: TextStyle(color: _inactiveFilterTextColor))]),
                                const SizedBox(height: 12),
                                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [_buildInfoPill(Icons.directions_run, '${ruta.distance} km'), const SizedBox(width: 8), _buildInfoPill(Icons.trending_up, '${ruta.elevationGain} m')])),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildDifficultyBadge(ruta.distance, ruta.elevationGain),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              context.read<TrackingProvider>().setSelectedRoute(ruta);
                              Navigator.pushNamed(context, AppRouter.routeView);
                            },
                            child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle), child: Icon(Icons.chevron_right_rounded, color: _primaryBlue, size: 24)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: _backgroundGray, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [Icon(icon, size: 16, color: _inactiveFilterTextColor), const SizedBox(width: 6), Text(label, style: TextStyle(color: _inactiveFilterTextColor, fontSize: 13))]),
    );
  }

  Widget _buildDifficultyBadge(double distance, double elevationGain) {
    final l10n = AppLocalizations.of(context)!;
    String label;
    Color color;

    if (distance < 5 && elevationGain < 100) { label = l10n.easy; color = const Color(0xFF22C55E); }
    else if (distance < 10 && elevationGain < 300) { label = l10n.moderate; color = const Color(0xFFEAB308); }
    else if (distance < 20 && elevationGain < 600) { label = l10n.hard; color = const Color(0xFFF97316); }
    else { label = l10n.veryHard; color = const Color(0xFFEF4444); }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.fitness_center, color: color, size: 16), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold))]),
    );
  }
}