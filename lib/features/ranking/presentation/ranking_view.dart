import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_comunity_bar.dart';
import '../../../core/router/app_router.dart';

// --- MODELO ACTUALIZADO ---
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

class Ranking extends StatefulWidget {
  const Ranking({super.key});

  @override
  State<Ranking> createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  TeamModality _selectedModality = TeamModality.running;
  String _selectedZone = 'Barcelona'; // Zona por defecto

  final List<String> _zones = ['Barcelona', 'Lleida', 'Girona', 'Tarragona'];

  // --- DATOS HARDCODEADOS PARA PRUEBAS ---
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

  List<TeamRankingModel> filteredTop10 = [];
  List<TeamRankingModel> podiumTeams = [];

  @override
  void initState() {
    super.initState();
    _processTeams();
  }

  bool isModalityPoints(TeamRankingModel team, TeamModality modality) {
    return team.modalityPoints.any((pair) => pair.first == modality);
  }

  void _processTeams() {
    // FILTRADO DOBLE: Modalidad AND Zona
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
      filteredTop10 = filtered.take(10).toList();
      podiumTeams = filtered.take(3).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: Column(
        children: [
          const CommunityHeader(selectedIndex: 0),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildToggleSwitch(context), // Equips / Individual
                  const SizedBox(height: 20),

                  // --- FILTROS DE DEPORTE Y ZONA ---
                  _buildFilterBar(),

                  const SizedBox(height: 24),
                  _buildPodiumSection(),
                  const SizedBox(height: 32),
                  _buildTop10Section(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
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
          // Botón Running
          _modalityIconButton(Icons.directions_run, TeamModality.running),
          const SizedBox(width: 16),
          // SELECTOR DE ZONA (Centro)
          _buildZoneSelector(),
          const SizedBox(width: 16),
          // Botón Ciclisme
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

  // --- EL RESTO DE WIDGETS SE MANTIENEN CON LA LÓGICA DE PODIUMTEAMS Y FILTEREDTOP10 ---

  Widget _buildToggleSwitch(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Para que los botones ocupen el alto total
        children: [
          // BOTÓN EQUIPS (Activo en esta vista)
          Expanded(
            child: TextButton(
              onPressed: () {
                // Al estar ya en Equips, podemos dejarlo vacío
                // o hacer un pequeño print para comprobar que funciona
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1058E5), // Color del efecto al tocar
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                  'Equips',
                  style: TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold)
              ),
            ),
          ),

          // BOTÓN INDIVIDUAL (Inactivo en esta vista, navega a la otra)
          Expanded(
            child: TextButton(
              onPressed: () {
                // Pon aquí el nombre de la ruta que tengas configurada
                Navigator.pushReplacementNamed(context, AppRouter.individualRankingRoute);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey, // Color del efecto al tocar
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                  'Individual',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSection() {
    final first = podiumTeams.isNotEmpty ? podiumTeams[0] : null;
    final second = podiumTeams.length > 1 ? podiumTeams[1] : null;
    final third = podiumTeams.length > 2 ? podiumTeams[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildPodiumPilar(team: second, rank: 2, height: 100, baseColor: const Color(0xFFF0F0F0), badgeColor: const Color(0xFFB4B4B4))),
          Expanded(flex: 1, child: Padding(padding: const EdgeInsets.only(bottom: 20.0), child: _buildPodiumPilar(team: first, rank: 1, height: 130, baseColor: const Color(0xFFFFF7D0), badgeColor: const Color(0xFFFFC107), isFirst: true))),
          Expanded(child: _buildPodiumPilar(team: third, rank: 3, height: 70, baseColor: const Color(0xFFFBE4D4), badgeColor: const Color(0xFFD97D43))),
        ],
      ),
    );
  }

  Widget _buildPodiumPilar({required TeamRankingModel? team, required int rank, required double height, required Color baseColor, required Color badgeColor, bool isFirst = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (team != null) ...[
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(radius: isFirst ? 36 : 28, backgroundColor: const Color(0xFF2864FF), child: Icon(_selectedModality == TeamModality.running ? Icons.directions_run : Icons.directions_bike, color: Colors.white, size: isFirst ? 32 : 24)),
              Positioned(bottom: -8, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: Text(rank.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ],
          ),
          const SizedBox(height: 16),
          Text(team.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text('${team.modalityPoints.firstWhere((pair) => pair.first == _selectedModality).second} pts', style: const TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
        ],
        Container(height: height, width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: baseColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))), child: Icon(Icons.emoji_events, color: badgeColor.withValues(alpha: 0.5), size: 32)),
      ],
    );
  }

  Widget _buildTop10Section() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOP 10 EQUIPS - $_selectedZone'.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0)),
              TextButton(onPressed: () => Navigator.pushNamed(context, AppRouter.totalRankingRoute),
                  child: const Text('Veure tot', style: TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 16),
          if (filteredTop10.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No hi ha equips per aquesta zona i modalitat", style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTop10.length,
              itemBuilder: (context, index) => _buildTeamCard(filteredTop10[index].name, filteredTop10[index].zones,
                  filteredTop10[index].isUserTeam, index + 1, filteredTop10[index].modalityPoints.firstWhere((pair) => pair.first == _selectedModality).second),
            ),
        ],
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