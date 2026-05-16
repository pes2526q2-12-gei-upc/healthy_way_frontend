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
  String _selectedModality = 'running';
  String _selectedScope = 'current';
  String _orderBy = 'points';
  List<models.IndividualRanking> _rankingData = [];
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
            // --- CABECERA CON BOTÓN VOLVER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1058E5)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Rànquing Individual',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1058E5)),
                  ),
                ],
              ),
            ),

            // --- FILTROS (REAPROVECHADOS) ---
            const SizedBox(height: 10),
            _buildFilterBar(),
            const SizedBox(height: 15),
            _buildOrderFilterBar(),
            const SizedBox(height: 20),

            // --- LISTA COMPLETA ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF1058E5)))
                  : RefreshIndicator(
                onRefresh: _fetchRanking,
                child: _rankingData.isEmpty
                    ? const Center(child: Text("No hi ha dades disponibles", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _rankingData.length,
                  itemBuilder: (context, index) {
                    final user = _rankingData[index];
                    final value = _orderBy == 'points' ? user.points : user.distance;
                    bool isMe = user.user_id == currentUserId;
                    return _buildUserCard(user, isMe, index, value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE UI (SINCRONIZADOS CON LA VISTA PRINCIPAL) ---

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
            if (user.teamName != '' && user.teamName != 'none') ...[
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
}