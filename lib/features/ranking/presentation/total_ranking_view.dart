import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../core/router/app_router.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TotalRanking(), // Pantalla de prueba
  ));
}

// --- MODELO (Idealmente esto ya estará en un archivo aparte pronto) ---
enum TeamModality { running, ciclisme }

class Pair<A, B> {
  final A first;
  final B second;

  Pair(this.first, this.second);
}

class TeamRankingModel {
  final String id;
  final String name;
  final int zones;
  final bool isUserTeam;
  final List<Pair <TeamModality, int>> modalityPoints;
  final String zone;

  TeamRankingModel({
    required this.id,
    required this.name,
    required this.zones,
    required this.modalityPoints,
    required this.zone,
    this.isUserTeam = false,
  });
}

class TotalRanking extends StatefulWidget {
  const TotalRanking({super.key});

  @override
  State<TotalRanking> createState() => _TotalRankingState();
}

class _TotalRankingState extends State<TotalRanking> {
  TeamModality _selectedModality = TeamModality.running;
  String _selectedZone = 'Barcelona';

  final List<String> _zones = ['Barcelona', 'Lleida', 'Girona', 'Tarragona'];

  // --- DATOS HARDCODEADOS ---
  final List<TeamRankingModel> allTeams = [
    ...List.generate(15, (i) => TeamRankingModel( // He subido a 15 para que veas el scroll largo
        id: 'EquipBcn$i',
        name: i == 5 ? 'Tu Equipo BCN' : 'EquipBcn$i',
        modalityPoints: {Pair(TeamModality.running, 2000 - (i * 100)), Pair(TeamModality.ciclisme, 1500 - (i * 80))}.toList(),
        zones: 15 - i,
        zone: 'Barcelona',
        isUserTeam: i == 5
    )),
    TeamRankingModel(id: 'gi_c_1', name: 'Girona Wheels', zones: 20, modalityPoints: {Pair(TeamModality.ciclisme, 2500)}.toList(), zone: 'Girona'),
    TeamRankingModel(id: 'gi_c_2', name: 'Costa Brava Bikes', zones: 12, modalityPoints: {Pair(TeamModality.ciclisme, 2100)}.toList(), zone: 'Girona'),
    TeamRankingModel(id: 'll_r_1', name: 'Boira Runners', zones: 5, modalityPoints: {Pair(TeamModality.running, 1800)}.toList(), zone: 'Lleida'),
    TeamRankingModel(id: 'ta_c_1', name: 'Tàrraco Cyclists', zones: 8, modalityPoints: {Pair(TeamModality.ciclisme, 1900)}.toList(), zone: 'Tarragona'),
  ];

  // Ya no es un top10, es la lista completa filtrada
  List<TeamRankingModel> filteredTeams = [];

  @override
  void initState() {
    super.initState();
    _processTeams();
  }

  bool isModalityPoints(TeamRankingModel team, TeamModality modality) {
    return team.modalityPoints.any((pair) => pair.first == modality);
  }

  void _processTeams() {
    List<TeamRankingModel> filtered = allTeams
        .where((team) => isModalityPoints(team, _selectedModality) && team.zone == _selectedZone)
        .toList();

    // Ordenamos por puntos de la modalidad seleccionada (si no tiene puntos para esa modalidad, se queda abajo)
    filtered.sort((a, b) {
      int pointsA = a.modalityPoints.firstWhere((pair) => pair.first == _selectedModality, orElse: () => Pair(_selectedModality, 0)).second;
      int pointsB = b.modalityPoints.firstWhere((pair) => pair.first == _selectedModality, orElse: () => Pair(_selectedModality, 0)).second;
      return pointsB.compareTo(pointsA); // Orden descendente
    });

    setState(() {
      // Quitamos el .take(10) para cogerlos todos absolutamente
      filteredTeams = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      // Usamos SafeArea para que el botón de atrás no se esconda bajo la barra de estado del móvil
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
                onPressed: () => Navigator.pushNamed(context, AppRouter.rankingRoute),
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
                'TOTS ELS EQUIPS - $_selectedZone'.toUpperCase(),
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
              child: filteredTeams.isEmpty
                  ? const Center(
                child: Text(
                  "No hi ha equips per aquesta zona i modalitat",
                  style: TextStyle(color: Colors.grey),
                ),
              )
              // Al usar ListView.builder directamente en el Expanded,
              // la lista hace scroll de forma independiente a los filtros.
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                itemCount: filteredTeams.length,
                itemBuilder: (context, index) => _buildTeamCard(filteredTeams[index].name, filteredTeams[index].zones, filteredTeams[index].isUserTeam,
                    index + 1, filteredTeams[index].modalityPoints.firstWhere((pair) => pair.first == _selectedModality).second),
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
          _modalityIconButton(Icons.directions_run, TeamModality.running),
          const SizedBox(width: 16),
          _buildZoneSelector(),
          const SizedBox(width: 16),
          _modalityIconButton(Icons.directions_bike, TeamModality.ciclisme),
        ],
      ),
    );
  }

  Widget _modalityIconButton(IconData icon, TeamModality modality) {
    bool isSelected = _selectedModality == modality;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedModality = modality;
          _processTeams();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1058E5) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))
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
        border: Border.all(color: const Color(0xFF1058E5).withValues(alpha: 0.3)),
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
                _processTeams();
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

  Widget _buildTeamCard(String name, int zones, bool isUser, int rank, int points) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
              border: isUser ? const Border(left: BorderSide(color: Color(0xFF1058E5), width: 5)) : null
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                  width: 32, // Un poco más ancho por si se llega a rangos de 100+
                  child: Text(
                      rank.toString(),
                      style: TextStyle(color: isUser ? const Color(0xFF1058E5) : Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 18)
                  )
              ),
              CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF2864FF).withValues(alpha: 0.8),
                  child: Icon(_selectedModality == TeamModality.running ? Icons.directions_run : Icons.directions_bike, color: Colors.white, size: 18)
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isUser ? const Color(0xFF1058E5) : Colors.black87)
                    ),
                    const SizedBox(height: 2),
                    Text(
                        '$zones zones conquerides',
                        style: const TextStyle(color: Colors.grey, fontSize: 11)
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      points.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isUser ? const Color(0xFF1058E5) : Colors.black87)
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