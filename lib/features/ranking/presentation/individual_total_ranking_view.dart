import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../core/router/app_router.dart';

// --- MODELO DE USUARIO (Idealmente en un archivo aparte pronto) ---
enum UserModality { running, ciclisme }

class UserRankingModel {
  final String id;
  final String name;
  final int points;
  final bool isCurrentUser;
  final UserModality modality;
  final String zone;

  UserRankingModel({
    required this.id,
    required this.name,
    required this.points,
    required this.modality,
    required this.zone,
    this.isCurrentUser = false,
  });
}

class IndividualTotalRanking extends StatefulWidget {
  const IndividualTotalRanking({super.key});

  @override
  State<IndividualTotalRanking> createState() => _IndividualTotalRankingState();
}

class _IndividualTotalRankingState extends State<IndividualTotalRanking> {
  UserModality _selectedModality = UserModality.running;
  String _selectedZone = 'Barcelona';

  final List<String> _zones = ['Barcelona', 'Lleida', 'Girona', 'Tarragona'];

  // --- DATOS HARDCODEADOS DE USUARIOS ---
  final List<UserRankingModel> allUsers = [
    // BARCELONA + RUNNING (Subido a 15 para probar el scroll largo)
    ...List.generate(15, (i) => UserRankingModel(
        id: 'bcn_r_u_$i',
        name: i == 4 ? 'El Teu Usuari' : 'Runner BCN $i',
        points: 3500 - (i * 150),
        modality: UserModality.running,
        zone: 'Barcelona',
        isCurrentUser: i == 4
    )),

    // GIRONA + CICLISME
    UserRankingModel(id: 'gi_c_u_1', name: 'Laura Pedals', points: 4200, modality: UserModality.ciclisme, zone: 'Girona'),
    UserRankingModel(id: 'gi_c_u_2', name: 'Marc Rodes', points: 3800, modality: UserModality.ciclisme, zone: 'Girona'),

    // LLEIDA + RUNNING
    UserRankingModel(id: 'll_r_u_1', name: 'Anna Boira', points: 2900, modality: UserModality.running, zone: 'Lleida'),

    // TARRAGONA + CICLISME
    UserRankingModel(id: 'ta_c_u_1', name: 'Joan Tàrraco', points: 3100, modality: UserModality.ciclisme, zone: 'Tarragona'),
  ];

  // Lista completa filtrada
  List<UserRankingModel> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _processUsers();
  }

  void _processUsers() {
    List<UserRankingModel> filtered = allUsers
        .where((user) => user.modality == _selectedModality && user.zone == _selectedZone)
        .toList();

    filtered.sort((a, b) => b.points.compareTo(a.points));

    setState(() {
      filteredUsers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // --- 1. BOTÓN DE IR ATRÁS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1058E5)),
                onPressed: () {
                  // Asumo que tienes una ruta para el ranking individual en tu AppRouter
                  // Si no, puedes usar Navigator.pop(context) directamente
                  Navigator.pushNamed(context, AppRouter.individualRankingRoute);
                },
              ),
            ),
            const SizedBox(height: 10),

            // --- 2. FILTROS DE DEPORTE Y ZONA (Fijos) ---
            _buildFilterBar(),
            const SizedBox(height: 24),

            // --- 3. TÍTULO DE LA LISTA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'TOTS ELS USUARIS - $_selectedZone'.toUpperCase(),
                style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.0
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- 4. LISTA COMPLETA SCROLLABLE ---
            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(
                child: Text(
                  "Encara no hi ha usuaris per aquesta zona i modalitat",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) => _buildUserCard(filteredUsers[index], index + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET QUE JUNTA LOS 3 BOTONES/SELECTS
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _modalityIconButton(Icons.directions_run, UserModality.running),
          const SizedBox(width: 16),
          _buildZoneSelector(),
          const SizedBox(width: 16),
          _modalityIconButton(Icons.directions_bike, UserModality.ciclisme),
        ],
      ),
    );
  }

  Widget _modalityIconButton(IconData icon, UserModality modality) {
    bool isSelected = _selectedModality == modality;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedModality = modality;
          _processUsers();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1058E5) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildZoneSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1058E5).withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedZone,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1058E5), size: 20),
          style: const TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold, fontSize: 14),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedZone = newValue;
                _processUsers();
              });
            }
          },
          items: _zones.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  // TARJETA DE USUARIO SIMPLIFICADA
  Widget _buildUserCard(UserRankingModel user, int rank) {
    final bool isCurrentUser = user.isCurrentUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
              border: isCurrentUser ? const Border(left: BorderSide(color: Color(0xFF1058E5), width: 5)) : null
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding ajustado
          child: Row(
            children: [
              SizedBox(
                  width: 32, // Ancho preparado para rangos > 99
                  child: Text(
                      rank.toString(),
                      style: TextStyle(color: isCurrentUser ? const Color(0xFF1058E5) : Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 18)
                  )
              ),
              // Avatar con Icono de Persona
              CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF2864FF).withOpacity(0.8),
                  child: const Icon(Icons.person, color: Colors.white, size: 20)
              ),
              const SizedBox(width: 12),
              // Nombre del usuario sin subtítulos
              Expanded(
                child: Text(
                    user.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isCurrentUser ? const Color(0xFF1058E5) : Colors.black87)
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      user.points.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isCurrentUser ? const Color(0xFF1058E5) : Colors.black87)
                  ),
                  const Text('punts', style: TextStyle(color: Colors.grey, fontSize: 10))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}