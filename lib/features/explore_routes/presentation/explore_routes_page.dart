import 'package:flutter/material.dart';
import 'package:healthy_way_frontend/shared/models/RouteModel.dart';
// IMPORTA AQUÍ TU WIDGET COMPARTIDO (ajusta la ruta si es necesario)
import '../../../core/router/app_router.dart';
import '../../../core/services/route_service.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ExploreRoutesScreen(),
  ));
}

class ExploreRoutesScreen extends StatefulWidget {
  const ExploreRoutesScreen({super.key});

  @override
  State<ExploreRoutesScreen> createState() => _ExploreRoutesScreenState();
}

class _ExploreRoutesScreenState extends State<ExploreRoutesScreen> {
  // Colores
  final Color _primaryBlue = const Color(0xFF1E6AFB);
  final Color _inactiveFilterTextColor = const Color(0xFF71717A);
  final Color _backgroundGray = const Color(0xFFF1F5F9);
  final Color _greenAQI = const Color(0xFF32A852);
  final Color _darkSelectedBlue = const Color(0xFF0C5AE1);

  List<RouteModel> _routes = [];
  bool _isLoading = true;

  Future<void> loadData() async {

  // Les dades es carregaran des del backend
    try {
  // Pedimos los datos al servicio
      final rutasObtenidas = await RouteService().getRoutes();
// Una vez llegan, actualizamos la pantalla de forma segura
      setState(() {
        _routes = rutasObtenidas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('🚨 ERROR AL CARGAR DATOS: $e');
    }
  }

  _ExploreRoutesScreenState() {
    loadData();
  }

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
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pushNamed(context, AppRouter.mapRoute)
      ),
      title: const Text('Explorar Rutes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.black, size: 28),
              Positioned(
                right: 0, top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text(' ', style: TextStyle(fontSize: 8)),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildCategoryTabs(),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildRouteListHeader(),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if(_isLoading) ...[
                  const SizedBox(height: 50),
                  //Centramos el indicador de carga
                  const Center(child: CircularProgressIndicator(color: Color(0xFF1E6AFB))),
                ] else if (_routes.isEmpty) ...[
                  const SizedBox(height: 50),
                  Text('No s\'han trobat rutes. Prova a ajustar els filtres o la cerca.', style: TextStyle(color: _inactiveFilterTextColor, fontSize: 14)),
                ] else ...[
                  for (RouteModel ruta in _routes) _buildSingleRouteCard(ruta),
                  const SizedBox(height: 100),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca rutes, zones...',
                hintStyle: TextStyle(color: _inactiveFilterTextColor.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: _inactiveFilterTextColor.withOpacity(0.6)),
                filled: true,
                fillColor: _backgroundGray,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(color: _backgroundGray, borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: Icon(Icons.tune, color: _inactiveFilterTextColor), onPressed: () {}),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final List<Map<String, dynamic>> tabs = [
      {'name': 'Totes', 'selected': true},
      {'name': 'Històriques', 'selected': false},
      {'name': 'Comunitat', 'selected': false},
      {'name': 'Esport', 'selected': false},
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final bool isSelected = tab['selected'];
          return ChoiceChip(
            label: Text(tab['name']),
            labelStyle: TextStyle(color: isSelected ? Colors.white : _inactiveFilterTextColor, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
            selected: isSelected,
            selectedColor: _darkSelectedBlue,
            backgroundColor: _backgroundGray,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onSelected: (bool selected) {},
          );
        },
      ),
    );
  }

  Widget _buildRouteListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('RUTES PÚBLIQUES', style: TextStyle(color: Color(0xFF1E6AFB), fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          Text("${_routes.length.toString()} resultats", style: TextStyle(color: _inactiveFilterTextColor, fontSize: 13)),
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
                                // Utilizamos una imagen hardcodeada por ahora, pero aquí se debería cargar la imagen real de la ruta (ruta.imageUrl)
                                Container(width: 100, height: 100, color: _backgroundGray, child: const Icon(Icons.image, color: Color(0xFF94A3B8), size: 40)),
                                //Image.network(, width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 100, height: 100, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey))),
                                Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.star, color: Color(0xFFFFB800), size: 14), const SizedBox(width: 4), Text('4.8', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))],))),
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
                                Row(children: [_buildInfoPill(Icons.directions_run, '${ruta.distance} km'), const SizedBox(width: 8), _buildInfoPill(Icons.trending_up, 'Medium')]),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFEBF6EC), shape: BoxShape.circle), child: Icon(Icons.air, color: _greenAQI)),
                          const SizedBox(width: 12),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ÍNDEX DE SALUT', style: TextStyle(color: _inactiveFilterTextColor, fontSize: 11, fontWeight: FontWeight.bold)), Text('Bueno (AQI 25)', style: TextStyle(color: _greenAQI, fontWeight: FontWeight.bold, fontSize: 14))]),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRouter.routeView);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2E8F0),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: _primaryBlue,
                                size: 24,
                              ),
                            ),
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
}