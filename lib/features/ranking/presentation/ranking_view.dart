import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_comunity_bar.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/models/ranking_models.dart' as models;
import '../../../core/services/ranking_service.dart';
import '../../../shared/providers/auth_provider.dart';

class Ranking extends StatefulWidget {
  const Ranking({super.key});

  @override
  State<Ranking> createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  String _selectedModality = 'running';
  String _selectedZone = 'Totes';
  String _orderBy = 'points';

  List<models.TeamRanking> _podiumTeams = [];
  List<models.TeamRanking> _top10Teams = [];
  bool _isLoading = true;

  final List<String> _zones = ['Totes', 'Barcelona', 'Lleida', 'Girona', 'Tarragona'];

  @override
  void initState() {
    super.initState();
    _fetchRanking();
  }

  Future<void> _fetchRanking() async {
    setState(() => _isLoading = true);

    if (_orderBy == 'distance') {
      setState(() {
        _podiumTeams = [];
        _top10Teams = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final String zoneParam = _selectedZone == 'Totes' ? 'All' : _selectedZone;
      final data = await RankingService().getTeamRanking(_selectedModality, zoneParam);

      setState(() {
        // Separamos los 3 primeros para el podio
        _podiumTeams = data.take(3).toList();
        _top10Teams = data.take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error al carregar rànquing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userTeam = context.watch<AuthProvider>().currentUser?.team;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            const CommunityHeader(selectedIndex: 0),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF1058E5)))
                  : RefreshIndicator(
                onRefresh: _fetchRanking,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      _buildToggleSwitch(context),
                      const SizedBox(height: 20),

                      // --- FILTROS DE DEPORTE Y ZONA ---
                      _buildFilterBar(),
                      const SizedBox(height: 15),

                      // --- FILTRO DE PUNTS / DISTANCIA ---
                      _buildOrderFilterBar(),
                      const SizedBox(height: 24),

                      // --- SECCIÓN DEL PODIO ---
                      _buildPodiumSection(userTeam),
                      const SizedBox(height: 32),

                      // --- SECCIÓN TOP 10 ---
                      _buildTop10Section(userTeam),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FILTROS (DISEÑO ORIGINAL MANTENIDO) ---

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _modalityIconButton(Icons.directions_run, 'running'),
          const SizedBox(width: 16),
          _buildZoneSelector(),
          const SizedBox(width: 16),
          _modalityIconButton(Icons.directions_bike, 'cycling'),
        ],
      ),
    );
  }

  Widget _modalityIconButton(IconData icon, String modality) {
    bool isSelected = _selectedModality == modality;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedModality = modality);
        _fetchRanking();
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
        child: Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 22),
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
              setState(() => _selectedZone = newValue);
              _fetchRanking();
            }
          },
          items: _zones.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Expanded(child: _orderButton('Punts', 'points')),
            Expanded(child: _orderButton('Distància', 'distance')),
          ],
        ),
      ),
    );
  }

  Widget _orderButton(String label, String value) {
    bool isSelected = _orderBy == value;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() => _orderBy = value);
          _fetchRanking();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF1058E5) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  // --- PODIO ---

  Widget _buildPodiumSection(String? userTeam) {
    final first = _podiumTeams.isNotEmpty ? _podiumTeams[0] : null;
    final second = _podiumTeams.length > 1 ? _podiumTeams[1] : null;
    final third = _podiumTeams.length > 2 ? _podiumTeams[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildPodiumPilar(team: second, rank: 2, height: 100, baseColor: const Color(0xFFF0F0F0), badgeColor: const Color(0xFFB4B4B4), userTeam: userTeam)),
          Expanded(flex: 1, child: Padding(padding: const EdgeInsets.only(bottom: 20.0), child: _buildPodiumPilar(team: first, rank: 1, height: 130, baseColor: const Color(0xFFFFF7D0), badgeColor: const Color(0xFFFFC107), isFirst: true, userTeam: userTeam))),
          Expanded(child: _buildPodiumPilar(team: third, rank: 3, height: 70, baseColor: const Color(0xFFFBE4D4), badgeColor: const Color(0xFFD97D43), userTeam: userTeam)),
        ],
      ),
    );
  }

  Widget _buildPodiumPilar({required models.TeamRanking? team, required int rank, required double height, required Color baseColor, required Color badgeColor, bool isFirst = false, String? userTeam}) {
    bool isUser = team?.name == userTeam;
    String displayValue = '';
    String unit = _orderBy == 'points' ? 'pts' : 'km';

    if (team != null) {
      displayValue = _orderBy == 'points' ? team.points.toString() : team.distance.toStringAsFixed(1);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (team != null) ...[
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Añadido: Borde exterior si es el equipo del usuario
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isUser ? const Color(0xFF1058E5) : Colors.transparent, width: 2),
                ),
                child: CircleAvatar(
                    radius: isFirst ? 36 : 28,
                    backgroundColor: const Color(0xFF2864FF),
                    child: Icon(_selectedModality == 'running' ? Icons.directions_run : Icons.directions_bike, color: Colors.white, size: isFirst ? 32 : 24)
                ),
              ),
              Positioned(
                  bottom: -8,
                  child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: Text(rank.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                  )
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
              team.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isUser ? const Color(0xFF1058E5) : Colors.black87) // Resalta nombre en azul
          ),
          Text(
              '$displayValue $unit',
              style: TextStyle(color: isUser ? const Color(0xFF1058E5) : const Color(0xFF1058E5), fontWeight: FontWeight.bold, fontSize: 12)
          ),
          const SizedBox(height: 8),
        ],
        Container(
            height: height,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: baseColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
            child: Icon(Icons.emoji_events, color: badgeColor.withValues(alpha: 0.5), size: 32)
        ),
      ],
    );
  }

  // --- LISTA TOP 10 ---

  Widget _buildTop10Section(String? userTeam) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOP 10 EQUIPS - ${_selectedZone.toUpperCase()}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0)),
              TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.totalRankingRoute),
                  child: const Text('Veure tot', style: TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold, fontSize: 12))
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_top10Teams.isEmpty && _podiumTeams.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No hi ha equips per aquesta zona i modalitat", style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _top10Teams.length,
              itemBuilder: (context, index) {
                final team = _top10Teams[index];
                final value = _orderBy == 'points' ? team.points : team.distance;

                return _buildTeamCard(team.name, team.zone, team.name == userTeam, index, value);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(String name, String zone, bool isUserTeam, int rank, dynamic value) {
    // Lógica de formato
    String unit = _orderBy == 'points' ? 'punts' : 'km';
    String displayValue = _orderBy == 'points' ? value.toInt().toString() : value.toStringAsFixed(1);

    // Colores dinámicos idénticos a los del ranking individual
    final Color cardColor = isUserTeam ? const Color(0xFFEBF2FF) : Colors.white;
    final Color primaryBlue = const Color(0xFF1058E5);
    final Color textColor = isUserTeam ? primaryBlue : const Color(0xFF2D3142);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        // Mismo borde que en individual
        border: isUserTeam
            ? Border.all(color: primaryBlue.withValues(alpha: 0.5), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            // Sombra azulada si es tu equipo, sombra gris normal si no
            color: isUserTeam
                ? primaryBlue.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 25,
              child: Text(
                (rank+1).toString(),
                style: TextStyle(
                  color: isUserTeam ? primaryBlue : Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: primaryBlue,
              // Aquí mantenemos el icono dinámico del deporte
              child: Icon(
                  _selectedModality == 'running' ? Icons.directions_run : Icons.directions_bike,
                  color: Colors.white,
                  size: 20
              ),
            ),
          ],
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name,
                style: TextStyle(
                  // Extra bold si es tu equipo
                  fontWeight: isUserTeam ? FontWeight.w800 : FontWeight.bold,
                  fontSize: 15,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // La etiqueta de la zona (equivalente al teamName en el individual)
            if (_selectedZone == 'Totes') ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  zone,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              displayValue,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                color: isUserTeam ? primaryBlue.withValues(alpha: 0.7) : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TOGGLE SUPERIOR ---

  Widget _buildToggleSwitch(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1058E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Equips', style: TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.individualRankingRoute),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Individual', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}