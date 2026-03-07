import 'package:flutter/material.dart';

// Este archivo podría llamarse 'explore_routes_screen.dart' dentro de tu feature de 'routes'.

// --- MAIN PER FER DEBUGGING ---
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ExploreRoutesScreen(),
  ));
}
// ------------------------------------------

class ExploreRoutesScreen extends StatefulWidget {
  const ExploreRoutesScreen({Key? key}) : super(key: key);

  @override
  State<ExploreRoutesScreen> createState() => _ExploreRoutesScreenState();
}

class _ExploreRoutesScreenState extends State<ExploreRoutesScreen> {
  // Índice para la barra de navegación inferior, se puede quitar si ya tenéis la lógica.
  int _selectedIndex = 1; // Selecciona 'Mapes' por defecto

  // Paleta de colores personalizada basada en el diseño
  final Color _primaryBlue = const Color(0xFF1E6AFB);
  final Color _activeFilterColor = const Color(0xFF1E6AFB);
  final Color _inactiveFilterTextColor = const Color(0xFF71717A);
  final Color _backgroundGray = const Color(0xFFF1F5F9);
  final Color _greenAQI = const Color(0xFF32A852);
  final Color _darkSelectedBlue = const Color(0xFF0C5AE1);

  // Datos de ejemplo para la única ruta
  final Map<String, dynamic> _sampleRoute = {
    'title': "Ruta Vall d'Hebron",
    'location': 'Barcelona, Horta',
    'rating': 4.8,
    'distance_km': 5.2,
    'difficulty': 'Mitjana',
    'aqi_label': 'Excel·lent',
    'aqi_value': 25,
    'image_url': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Vall_d%27Hebron_view.jpg/640px-Vall_d%27Hebron_view.jpg',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundGray,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- COMPONENTES DE LA PANTALLA ---

  // AppBar personalizada
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0, // Sin sombra
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          // Navegar hacia atrás
        },
      ),
      title: const Text(
        'Explorar Rutes',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.black, size: 28),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
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

  // Cuerpo principal
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- NUEVO BLOQUE BLANCO ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 20), // Espacio inferior antes del gris
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildCategoryTabs(),
              ],
            ),
          ),
          // --- FIN BLOQUE BLANCO ---

          const SizedBox(height: 8), // Separación sutil entre el bloque blanco y el encabezado
          _buildRouteListHeader(),
          _buildSingleRouteCard(),

          // Si quieres que haya mucho espacio gris al final para que no choque
          // con la barra de abajo, puedes añadir un:
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Barra de búsqueda con filtros
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: _backgroundGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.tune, color: _inactiveFilterTextColor),
              onPressed: () {
                // Abrir filtros avanzados
              },
            ),
          ),
        ],
      ),
    );
  }

  // Pestañas de categoría (filtros rápidos)
  Widget _buildCategoryTabs() {
    final List<Map<String, dynamic>> _tabs = [
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
        itemCount: _tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final bool isSelected = tab['selected'];
          return ChoiceChip(
            label: Text(tab['name']),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : _inactiveFilterTextColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            selected: isSelected,
            selectedColor: _darkSelectedBlue,
            backgroundColor: _backgroundGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (bool selected) {
              // Actualizar estado de selección aquí
            },
          );
        },
      ),
    );
  }

  // Encabezado de la sección de rutas
  Widget _buildRouteListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'RUTES PÚBLIQUES',
            style: TextStyle(
              color: Color(0xFF1E6AFB), // Azul de la sección
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          Text(
            '1 resultat', // Actualizado a 1
            style: TextStyle(color: _inactiveFilterTextColor, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // La tarjeta única de ruta (el componente clave)
  Widget _buildSingleRouteCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        clipBehavior: Clip.antiAlias, // Asegura que la línea azul no se salga de las esquinas redondeadas
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: IntrinsicHeight( // <--- PASO 1: Hace que el Row sepa qué altura tiene el contenido
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch, // <--- PASO 2: Estira la línea azul verticalmente
            children: [
              // --- LA LÍNEA AZUL LATERAL ---
              Container(
                width: 5, // Grosor de la línea
                color: _darkSelectedBlue,
              ),

              // --- EL CONTENIDO ORIGINAL (Envuelto en Expanded) ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen y datos principales
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagen de la ruta
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                Image.network(
                                  _sampleRoute['image_url'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star, color: Color(0xFFFFB800), size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          _sampleRoute['rating'].toString(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Título, Ubicación e Info (Km y Dificultad)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _sampleRoute['title'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(Icons.favorite_outline, color: _inactiveFilterTextColor, size: 24),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, color: _inactiveFilterTextColor, size: 16),
                                    const SizedBox(width: 4),
                                    Text(_sampleRoute['location'], style: TextStyle(color: _inactiveFilterTextColor)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Distancia y Dificultad
                                Row(
                                  children: [
                                    _buildInfoPill(Icons.directions_run, '${_sampleRoute['distance_km']} km'),
                                    const SizedBox(width: 8),
                                    _buildInfoPill(Icons.trending_up, _sampleRoute['difficulty']),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE2E8F0)), // Línea separadora
                      const SizedBox(height: 16),
                      // Índice de salud
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEBF6EC), // Fondo verde muy claro
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.air, color: _greenAQI),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ÍNDEX DE SALUT',
                                style: TextStyle(color: _inactiveFilterTextColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${_sampleRoute['aqi_label']} (AQI ${_sampleRoute['aqi_value']})',
                                style: TextStyle(color: _greenAQI, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Botón de detalle estilizado como ">"
                          Container(
                            padding: const EdgeInsets.all(8), // Un poco más de aire
                            decoration: const BoxDecoration(
                              color: Color(0xFFE2E8F0), // El gris azulado que querías
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded, // El icono ">"
                              color: _primaryBlue,
                              size: 24,
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

  // Pequeña 'píldora' de información (Km, Dificultad)
  Widget _buildInfoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _inactiveFilterTextColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: _inactiveFilterTextColor, fontSize: 13)),
        ],
      ),
    );
  }

  // Barra de navegación inferior (será reemplazada por el usuario)
  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(icon: Icons.home_rounded, label: 'Inici', onTap: () {}),
          _BottomNavItem(icon: Icons.map_outlined, label: 'Mapes', isActive: true, onTap: () {}),
          Container(
            width: 56, // Tamaño fijo para que sea un círculo perfecto
            height: 56,
            decoration: BoxDecoration(
              color: _darkSelectedBlue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3), // Contorno blanco
              boxShadow: [
                BoxShadow(
                  color: _darkSelectedBlue.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4), // Sombra hacia abajo
                ),
              ],
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
          ),
          _BottomNavItem(icon: Icons.people_outline, label: 'Social', onTap: () {}),
          _BottomNavItem(icon: Icons.person_outline, label: 'Perfil', onTap: () {}),
        ],
      ),
    );
  }

  // Ítem individual de la barra de navegación
  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? _primaryBlue : _inactiveFilterTextColor),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? _primaryBlue : _inactiveFilterTextColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Botón central flotante (se puede integrar en un Stack si se prefiere)
  @override
  Widget? get floatingActionButton {
    return FloatingActionButton(
      onPressed: () {
        // Lógica para iniciar ruta
      },
      backgroundColor: _darkSelectedBlue,
      child: const Icon(Icons.play_arrow_outlined, color: Colors.white, size: 30),
    );
  }

  @override
  FloatingActionButtonLocation? get floatingActionButtonLocation {
    return FloatingActionButtonLocation.centerDocked;
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({required this.icon, required this.label, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.blue[700] : Colors.grey, size: 28),
          Text(label, style: TextStyle(color: isActive ? Colors.blue[700] : Colors.grey, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}