import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/models/ranking_models.dart' as models;
import '../../../core/services/ranking_service.dart';
import '../../../shared/providers/auth_provider.dart';

class IndividualTotalRanking extends StatefulWidget {
  const IndividualTotalRanking({super.key});

  @override
  State<IndividualTotalRanking> createState() => _IndividualTotalRankingState();
}

class _IndividualTotalRankingState extends State<IndividualTotalRanking> {
  // Estado para el control de datos
  String _orderBy = 'points'; // 'points' o 'distance'
  List<models.IndividualRanking> _rankingData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRanking();
  }

  // Llamada al servicio para obtener todos los usuarios ordenados
  Future<void> _fetchRanking() async {
    setState(() => _isLoading = true);
    try {
      final data = await RankingService().getIndividualRanking(_orderBy);
      setState(() {
        _rankingData = List<models.IndividualRanking>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error al carregar rànquing total: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthProvider>().currentUser?.userId;

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

            // --- 2. BARRA DE FILTRADO (Punts/Distància) ---
            _buildFilterBar(),
            const SizedBox(height: 24),

            // --- 3. TÍTULO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'TOTS ELS USUARIS'.toUpperCase(),
                style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.0
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- 4. LISTA COMPLETA ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF1058E5)))
                  : RefreshIndicator(
                onRefresh: _fetchRanking,
                child: _rankingData.isEmpty
                    ? const Center(child: Text("No hi ha dades disponibles", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  itemCount: _rankingData.length,
                  itemBuilder: (context, index) {
                    final user = _rankingData[index];
                    final dynamic value = _orderBy == 'points' ? user.totalPoints : user.totalDistance;
                    final String unit = _orderBy == 'points' ? 'punts' : 'km';

                    return _buildUserCard(
                        user.name,
                        value,
                        user.userId == currentUserId,
                        index + 1,
                        unit,
                        user.teamName // Asegúrate que tu modelo tiene teamName
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

  // Barra de filtrado idéntica a la del Top 10 para mantener coherencia
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Expanded(child: _filterButton('Punts', 'points')),
            Expanded(child: _filterButton('Distància', 'distance')),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String label, String value) {
    bool isSelected = _orderBy == value;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() => _orderBy = value);
          _fetchRanking();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // La función de la carta de usuario que ya tienes perfeccionada
  Widget _buildUserCard(String name, dynamic value, bool isCurrentUser, int rank, String unit, String teamName) {
    String displayValue = (unit == 'punts') ? value.toInt().toString() : value.toStringAsFixed(2);
    final Color primaryBlue = const Color(0xFF1058E5);
    final Color textColor = isCurrentUser ? primaryBlue : const Color(0xFF2D3142);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFEBF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser ? Border.all(color: primaryBlue.withValues(alpha: 0.5), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 25,
              child: Text(rank.toString(), style: TextStyle(color: isCurrentUser ? primaryBlue : Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            CircleAvatar(radius: 18, backgroundColor: primaryBlue, child: const Icon(Icons.person, color: Colors.white, size: 20)),
          ],
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(name, style: TextStyle(fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.bold, fontSize: 15, color: textColor), overflow: TextOverflow.ellipsis),
            ),
            if (teamName != 'none') ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(12)),
                child: Text(teamName, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(displayValue, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
            Text(unit, style: TextStyle(color: isCurrentUser ? primaryBlue.withValues(alpha: 0.7) : Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}