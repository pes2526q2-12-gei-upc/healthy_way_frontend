import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/models/ranking_models.dart' as models;
import '../../../core/services/ranking_service.dart';
import '../../../shared/providers/auth_provider.dart';

class TotalRanking extends StatefulWidget {
  const TotalRanking({super.key});

  @override
  State<TotalRanking> createState() => _TotalRankingState();
}

class _TotalRankingState extends State<TotalRanking> {
  // Estado de filtros
  String _selectedModality = 'running';
  String _selectedZone = 'Totes';
  String _orderBy = 'points';

  List<models.TeamRanking> _rankingData = [];
  bool _isLoading = true;

  final List<String> _zones = ['Totes', 'Barcelona', 'Lleida', 'Girona', 'Tarragona'];

  @override
  void initState() {
    super.initState();
    _fetchRanking();
  }

  Future<void> _fetchRanking() async {
    setState(() => _isLoading = true);

    // Si la ordenación es por distancia, devolvemos lista vacía por ahora
    if (_orderBy == 'distance') {
      setState(() {
        _rankingData = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final String zoneParam = _selectedZone == 'Totes' ? 'All' : _selectedZone;
      final data = await RankingService().getTeamRanking(_selectedModality, zoneParam);

      setState(() {
        _rankingData = data; // Aquí cogemos todos los equipos sin límite
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error al carregar rànquing d\'equips total: $e');
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // --- 1. BOTÓN ATRÁS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1058E5)),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // --- 2. FILA PRINCIPAL: [RUN] [SELECTOR ZONAS] [BIKE] ---
            _buildMainSelector(),
            const SizedBox(height: 15),

            // --- 3. BARRA DE PUNTS / DISTÀNCIA ---
            _buildOrderFilterBar(),
            const SizedBox(height: 24),

            // --- 4. TÍTULO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'TOTS ELS EQUIPS - ${_selectedZone.toUpperCase()}',
                style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.0
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- 5. LISTA COMPLETA ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF1058E5)))
                  : RefreshIndicator(
                onRefresh: _fetchRanking,
                child: _rankingData.isEmpty
                    ? const Center(child: Text("No hi ha equips en aquesta categoria", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  itemCount: _rankingData.length,
                  itemBuilder: (context, index) {
                    final team = _rankingData[index];
                    final dynamic value = _orderBy == 'points' ? team.points : team.distance;

                    return _buildTeamCard(
                      team.name,
                      team.zone,
                      team.name == userTeam,
                      index + 1, // Ranking real
                      value,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOS MISMOS WIDGETS DE FILTRADO QUE EN EL TOP 10 ---

  Widget _buildMainSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _modalityIcon(Icons.directions_run, 'running'),
        const SizedBox(width: 15),
        _buildZoneDropdown(),
        const SizedBox(width: 15),
        _modalityIcon(Icons.directions_bike, 'cycling'),
      ],
    );
  }

  Widget _buildZoneDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedZone,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1058E5)),
          style: const TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.bold, fontSize: 15),
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

  Widget _modalityIcon(IconData icon, String value) {
    bool isSelected = _selectedModality == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedModality = value);
        _fetchRanking();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1058E5) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: isSelected ? const Color(0xFF1058E5).withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                blurRadius: 8
            )
          ],
        ),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade400, size: 26),
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
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1058E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // --- LA MISMA TARJETA PREMIUM DEL TOP 10 ---

  Widget _buildTeamCard(String name, String zone, bool isUserTeam, int rank, dynamic value) {
    String unit = _orderBy == 'points' ? 'punts' : 'km';
    String displayValue = _orderBy == 'points' ? value.toInt().toString() : value.toStringAsFixed(1);

    final Color cardColor = isUserTeam ? const Color(0xFFEBF2FF) : Colors.white;
    final Color primaryBlue = const Color(0xFF1058E5);
    final Color textColor = isUserTeam ? primaryBlue : const Color(0xFF2D3142);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isUserTeam ? Border.all(color: primaryBlue.withValues(alpha: 0.5), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: isUserTeam ? primaryBlue.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
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
                rank.toString(),
                style: TextStyle(color: isUserTeam ? primaryBlue : Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: primaryBlue,
              child: Icon(_selectedModality == 'running' ? Icons.directions_run : Icons.directions_bike, color: Colors.white, size: 20),
            ),
          ],
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name,
                style: TextStyle(fontWeight: isUserTeam ? FontWeight.w800 : FontWeight.bold, fontSize: 15, color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_selectedZone == 'Totes') ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(12)),
                child: Text(zone, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(displayValue, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
            Text(unit, style: TextStyle(color: isUserTeam ? primaryBlue.withValues(alpha: 0.7) : Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}