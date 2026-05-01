import 'package:flutter/material.dart';
import '../../core/router/app_router.dart';

class CommunityHeader extends StatelessWidget {
  final int selectedIndex;

  const CommunityHeader({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1058E5);

    return Container(
      // 1. AJUSTE VERTICAL: Menos top (48 en vez de 60) y menos bottom (16 en vez de 24)
      padding: const EdgeInsets.only(top: 38, left: 20, right: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comunitat',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26, // Un pelín más pequeño para equilibrar
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          // 2. AJUSTE VERTICAL: Menos separación entre el título y los botones
          const SizedBox(height: 16),

          Row(
            children: [
              _CustomTab(
                title: 'Rànquing',
                icon: Icons.insert_chart_outlined,
                isSelected: selectedIndex == 0,
                onTap: () => Navigator.pushNamed(context, AppRouter.rankingRoute),
                primaryBlue: primaryBlue,
              ),
              const SizedBox(width: 8),
              _CustomTab(
                title: 'El Meu Equip',
                icon: Icons.people_alt_outlined,
                isSelected: selectedIndex == 1,
                onTap: () => Navigator.pushNamed(context, AppRouter.myTeamRoute),
                primaryBlue: primaryBlue,
              ),
              const SizedBox(width: 8),
              _CustomTab(
                title: 'Xat',
                icon: Icons.chat_bubble_outline,
                isSelected: selectedIndex == 2,
                onTap: () => Navigator.pushNamed(context, AppRouter.chatRoute),
                primaryBlue: primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- SUB-WIDGET PRIVADO DE LOS BOTONES ---
class _CustomTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryBlue;

  const _CustomTab({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // 3. AJUSTE VERTICAL: Reducido a 10 para que los botones no sean tan altos
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
            // 4. BOTONES REDONDEADOS: 50 crea la forma de píldora perfecta
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? primaryBlue : Colors.white,
              ),
              const SizedBox(width: 4), // Ligeramente más juntos para que quepa bien
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? primaryBlue : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}