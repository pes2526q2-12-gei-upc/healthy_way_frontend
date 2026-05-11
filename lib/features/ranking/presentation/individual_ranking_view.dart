import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_comunity_bar.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/models/ranking_models.dart' as models;
import '../../../core/services/ranking_service.dart';
import '../../../shared/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class IndividualRanking extends StatefulWidget {
  const IndividualRanking({super.key});

  @override
  State<IndividualRanking> createState() => _IndividualRankingState();
}

class _IndividualRankingState extends State<IndividualRanking> {
  // Ahora el estado se controla por el criterio de ordenación
  String _orderBy = 'points'; // 'points' o 'distance'
  List<models.IndividualRanking> _rankingData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRanking();
  }

  // Llamada al servicio real
  Future<void> _fetchRanking() async {
    setState(() => _isLoading = true);

    try {
      final data = await RankingService().getIndividualRanking(_orderBy);
      setState(() {
        // El backend ya lo da ordenado, solo pillamos los datos
        _rankingData = List<models.IndividualRanking>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error al carregar rànquing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Top 3 para el podio y Top 10 para la lista
    final podiumUsers = _rankingData.take(3).toList();
    final top10Users = _rankingData.take(10).toList();
    final currentUserId = context.watch<AuthProvider>().currentUser?.userId;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: Column(
        children: [
          const CommunityHeader(selectedIndex: 0),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1058E5)))
                : RefreshIndicator(
              onRefresh: _fetchRanking,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildToggleSwitch(context),
                    const SizedBox(height: 20),

                    _buildFilterBar(), // Nueva barra de Punts/Distància

                    const SizedBox(height: 24),
                    _buildPodiumSection(podiumUsers),
                    const SizedBox(height: 32),
                    _buildTop10Section(top10Users, currentUserId ?? -1),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- NUEVA BARRA DE FILTRADO (Sustituye a Zonas e Iconos) ---
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
          ],
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

  // --- PODIO ACTUALIZADO ---
  Widget _buildPodiumSection(List<models.IndividualRanking> podium) {
    final first = podium.isNotEmpty ? podium[0] : null;
    final second = podium.length > 1 ? podium[1] : null;
    final third = podium.length > 2 ? podium[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildPodiumPilar(user: second, rank: 2, height: 100, badgeColor: const Color(0xFFB4B4B4), baseColor: const Color(0xFFF0F0F0))),
          Expanded(flex: 1, child: Padding(padding: const EdgeInsets.only(bottom: 20.0), child: _buildPodiumPilar(user: first, rank: 1, height: 130, badgeColor: const Color(0xFFFFC107), baseColor: const Color(0xFFFFF7D0), isFirst: true))),
          Expanded(child: _buildPodiumPilar(user: third, rank: 3, height: 70, badgeColor: const Color(0xFFD97D43), baseColor: const Color(0xFFFBE4D4))),
        ],
      ),
    );
  }

  Widget _buildPodiumPilar({required models.IndividualRanking? user, required int rank, required double height, required Color baseColor, required Color badgeColor, bool isFirst = false}) {
    String valueText = '';
    if (user != null) {
      valueText = _orderBy == 'points' ? '${user.totalPoints} pts' : '${user.totalDistance.toStringAsFixed(1)} km';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (user != null) ...[
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                  radius: isFirst ? 36 : 28,
                  backgroundColor: const Color(0xFF2864FF),
                  child: Icon(Icons.person, color: Colors.white, size: isFirst ? 32 : 24)
              ),
              Positioned(bottom: -8, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: Text(rank.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ],
          ),
          const SizedBox(height: 16),
          Text(user.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(valueText, style: const TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
        ],
        Container(height: height, width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: baseColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))), child: Icon(Icons.emoji_events, color: badgeColor.withValues(alpha: 0.5), size: 32)),
      ],
    );
  }

  // --- TOP 10 ACTUALIZADO ---
  Widget _buildTop10Section(List<models.IndividualRanking> top10, int currentUserId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOP 10 USUARIS'.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0)),
              TextButton(onPressed: () => Navigator.pushNamed(context, AppRouter.individualTotalRankingRoute),
                  child: const Text('Veure tot', style: TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 16),
          if (top10.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Encara no hi ha dades disponibles", style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: top10.length,
              itemBuilder: (context, index) {
                final user = top10[index];
                // Mostramos puntos o distancia según la selección
                final dynamic value = _orderBy == 'points' ? user.totalPoints : user.totalDistance;
                final String unit = _orderBy == 'points' ? 'punts' : 'km';

                return _buildUserCard(user.name, value, user.userId == currentUserId, index + 1, unit, user.teamName);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUserCard(String name, dynamic value, bool isCurrentUser, int rank, String unit, String teamName) {
    // Lógica de formato que vimos antes
    String displayValue = (unit == 'punts')
        ? value.toInt().toString()
        : value.toStringAsFixed(2);

    // Colores dinámicos
    final Color cardColor = isCurrentUser ? const Color(0xFFEBF2FF) : Colors.white;
    final Color primaryBlue = const Color(0xFF1058E5);
    final Color textColor = isCurrentUser ? primaryBlue : const Color(0xFF2D3142);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        // Añadimos un borde si es el usuario actual
        border: isCurrentUser
            ? Border.all(color: primaryBlue.withValues(alpha: 0.5), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: isCurrentUser
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
                rank.toString(),
                style: TextStyle(
                  color: isCurrentUser ? primaryBlue : Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: primaryBlue,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min, // Hace que el Row solo ocupe lo necesario
          children: [
            Flexible(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.bold,
                  fontSize: 15,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis, // Si el nombre es muy largo, pone "..."
              ),
            ),

            // Tu lógica de la etiqueta del equipo
            if (teamName != 'none') ...[
              const SizedBox(width: 8), // Espacio entre el nombre y la etiqueta
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  teamName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10, // Un pelín más pequeña para que no sature la vista
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
                color: isCurrentUser ? primaryBlue.withValues(alpha: 0.7) : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.rankingRoute),
              child: const Text('Equips', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: const Center(child: Text('Individual', style: TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }
}