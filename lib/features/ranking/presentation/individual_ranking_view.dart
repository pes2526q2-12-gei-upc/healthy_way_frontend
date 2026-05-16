import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_comunity_bar.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/models/ranking_models.dart' as models;
import '../../../core/services/ranking_service.dart';
import '../../../shared/providers/auth_provider.dart';

class IndividualRanking extends StatefulWidget {
  const IndividualRanking({super.key});

  @override
  State<IndividualRanking> createState() => _IndividualRankingState();
}

class _IndividualRankingState extends State<IndividualRanking> {
  String _selectedModality = 'running';
  String _selectedScope = 'current'; // 'current' o 'total'
  String _orderBy = 'points';

  List<models.IndividualRanking> _podiumUsers = [];
  List<models.IndividualRanking> _top10Users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRanking();
  }

  Future<void> _fetchRanking() async {
    setState(() => _isLoading = true);
    try {
      final data = await RankingService().getIndividualRanking(
          _orderBy, _selectedModality, _selectedScope
      );
      final List<models.IndividualRanking> rankedList = List<models.IndividualRanking>.from(data);
      setState(() {
        _podiumUsers = rankedList.take(3).toList();
        _top10Users = rankedList.take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error al cargar ranking individual: $e');
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

                      // --- FILTROS (MODALIDAD Y SCOPE CORTO) ---
                      _buildFilterBar(),
                      const SizedBox(height: 15),

                      // --- FILTRO PUNTOS/DISTANCIA ---
                      _buildOrderFilterBar(),
                      const SizedBox(height: 24),

                      // --- PODIO (ADAPTADO DE EQUIPOS) ---
                      _buildPodiumSection(currentUserId),
                      const SizedBox(height: 32),

                      // --- LISTA TOP 10 ---
                      _buildTop10Section(currentUserId),
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

  // --- FILTROS (DISEÑO EQUIPOS ADAPTADO) ---

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _modalityIconButton(Icons.directions_run, 'running'),
          const SizedBox(width: 16),
          _buildScopeSelector(),
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
        padding: const EdgeInsets.all(12), // Mismo padding que en equipos
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

  Widget _buildScopeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1058E5).withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedScope,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1058E5), size: 20),
          style: const TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold, fontSize: 14),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedScope = newValue);
              _fetchRanking();
            }
          },
          items: const [
            DropdownMenuItem(value: 'current', child: Text('Actual')),
            DropdownMenuItem(value: 'total', child: Text('Total')),
          ],
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

  // --- PODIO (REUTILIZADO DE EQUIPOS) ---

  Widget _buildPodiumSection(dynamic currentUserId) {
    final first = _podiumUsers.isNotEmpty ? _podiumUsers[0] : null;
    final second = _podiumUsers.length > 1 ? _podiumUsers[1] : null;
    final third = _podiumUsers.length > 2 ? _podiumUsers[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildPodiumPilar(user: second, rank: 2, height: 100, baseColor: const Color(0xFFF0F0F0), badgeColor: const Color(0xFFB4B4B4), currentUserId: currentUserId)),
          Expanded(flex: 1, child: Padding(padding: const EdgeInsets.only(bottom: 20.0), child: _buildPodiumPilar(user: first, rank: 1, height: 130, baseColor: const Color(0xFFFFF7D0), badgeColor: const Color(0xFFFFC107), isFirst: true, currentUserId: currentUserId))),
          Expanded(child: _buildPodiumPilar(user: third, rank: 3, height: 70, baseColor: const Color(0xFFFBE4D4), badgeColor: const Color(0xFFD97D43), currentUserId: currentUserId)),
        ],
      ),
    );
  }

  Widget _buildPodiumPilar({required models.IndividualRanking? user, required int rank, required double height, required Color baseColor, required Color badgeColor, bool isFirst = false, dynamic currentUserId}) {
    bool isUser = user != null && user.user_id == currentUserId;
    String displayValue = '';
    String unit = _orderBy == 'points' ? 'pts' : 'km';

    if (user != null) {
      displayValue = _orderBy == 'points' ? user.points.toInt().toString() : user.distance.toStringAsFixed(1);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (user != null) ...[
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isUser ? const Color(0xFF1058E5) : Colors.transparent, width: 2),
                ),
                child: CircleAvatar(
                    radius: isFirst ? 36 : 28,
                    backgroundColor: const Color(0xFF2864FF),
                    child: const Icon(Icons.person, color: Colors.white, size: 24)
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
              user.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isUser ? const Color(0xFF1058E5) : Colors.black87)
          ),
          Text(
              '$displayValue $unit',
              style: const TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold, fontSize: 12)
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

  // --- LISTA TOP 10 (ADAPTADA DE EQUIPOS) ---

  Widget _buildTop10Section(dynamic currentUserId) {
    String scopeTitle = _selectedScope == 'current' ? 'ACTUAL' : 'TOTAL';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOP 10 INDIVIDUAL - $scopeTitle', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0)),
              TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.individualTotalRankingRoute),
                  child: const Text('Veure tot', style: TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold, fontSize: 12))
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _top10Users.length,
            itemBuilder: (context, index) {
              final user = _top10Users[index];
              final value = _orderBy == 'points' ? user.points : user.distance;
              bool isMe = user.user_id == currentUserId;

              return _buildUserCard(user, isMe, index, value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(models.IndividualRanking user, bool isMe, int rank, dynamic value) {
    String unit = _orderBy == 'points' ? 'punts' : 'km';
    String displayValue = _orderBy == 'points' ? value.toInt().toString() : value.toStringAsFixed(1);

    final Color cardColor = isMe ? const Color(0xFFEBF2FF) : Colors.white;
    final Color primaryBlue = const Color(0xFF1058E5);
    final Color textColor = isMe ? primaryBlue : const Color(0xFF2D3142);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: primaryBlue.withValues(alpha: 0.5), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: isMe ? primaryBlue.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
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
                (rank + 1).toString(),
                style: TextStyle(
                  color: isMe ? primaryBlue : Colors.grey.shade400,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                user.name,
                style: TextStyle(
                  fontWeight: isMe ? FontWeight.w800 : FontWeight.bold,
                  fontSize: 15,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Tag del equipo (similar al tag de zona de equipos)
            if (user.teamName != '') ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.teamName,
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
            ),
            Text(
              unit,
              style: TextStyle(
                color: isMe ? primaryBlue.withValues(alpha: 0.7) : Colors.grey,
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
              onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.rankingRoute),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Equips', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFF1058E5), borderRadius: BorderRadius.circular(24)),
              child: const Center(child: Text('Individual', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }
}