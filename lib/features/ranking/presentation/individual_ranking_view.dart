import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_comunity_bar.dart';
import '../../../core/router/app_router.dart';

// --- NUEVO MODELO PARA USUARIOS ---
enum UserModality { running, ciclisme }

class Pair<A, B> {
  final A first;
  final B second;

  Pair(this.first, this.second);
}

class UserRankingModel {
  final String id;
  final String name;
  final bool isCurrentUser;
  final List<Pair <UserModality, int>> modalityPoints;
  final String zone;

  UserRankingModel({
    required this.id,
    required this.name,
    required this.modalityPoints,
    required this.zone,
    this.isCurrentUser = false,
  });
}

class IndividualRanking extends StatefulWidget {
  const IndividualRanking({super.key});

  @override
  State<IndividualRanking> createState() => _IndividualRankingState();
}

class _IndividualRankingState extends State<IndividualRanking> {
  UserModality _selectedModality = UserModality.running;
  String _selectedZone = 'Barcelona';

  final List<String> _zones = ['Barcelona', 'Lleida', 'Girona', 'Tarragona'];

  // --- DATOS HARDCODEADOS PARA PRUEBAS (USUARIOS) ---
  final List<UserRankingModel> allUsers = [
    // BARCELONA + RUNNING (> 10 usuarios para probar límite)
    ...List.generate(12, (i) => UserRankingModel(
        id: 'bcn_r_u_$i',
        name: i == 4 ? 'El Teu Usuari' : 'Runner BCN $i',
        modalityPoints: {Pair(UserModality.running, 3500 - (i * 100)), Pair(UserModality.ciclisme, 1500 - (i * 80))}.toList(),
        zone: 'Barcelona',
        isCurrentUser: i == 4
    )),

    // GIRONA + CICLISME (< 3 usuarios para probar podio incompleto)
    UserRankingModel(id: 'gi_c_u_1', name: 'Laura Pedals', modalityPoints: {Pair(UserModality.ciclisme, 4200)}.toList(), zone: 'Girona'),
    UserRankingModel(id: 'gi_c_u_2', name: 'Marc Rodes', modalityPoints: {Pair(UserModality.ciclisme, 3800)}.toList(), zone: 'Girona'),

    // LLEIDA + RUNNING
    UserRankingModel(id: 'll_r_u_1', name: 'Anna Boira', modalityPoints: {Pair(UserModality.running, 2900)}.toList(), zone: 'Lleida'),

    // TARRAGONA + CICLISME
    UserRankingModel(id: 'ta_c_u_1', name: 'Joan Tàrraco', modalityPoints: {Pair(UserModality.ciclisme, 3100)}.toList(), zone: 'Tarragona'),
  ];

  List<UserRankingModel> filteredTop10 = [];
  List<UserRankingModel> podiumUsers = [];

  @override
  void initState() {
    super.initState();
    _processUsers();
  }

  bool isModalityPoints(UserRankingModel user, UserModality modality) {
    return user.modalityPoints.any((pair) => pair.first == modality);
  }

  void _processUsers() {
    List<UserRankingModel> filtered = allUsers
        .where((user) => isModalityPoints(user, _selectedModality) && user.zone == _selectedZone)
        .toList();

    // Ordenamos por puntos de la modalidad seleccionada
    filtered.sort((a, b) {
      int pointsA = a.modalityPoints.firstWhere((pair) => pair.first == _selectedModality).second;
      int pointsB = b.modalityPoints.firstWhere((pair) => pair.first == _selectedModality).second;
      return pointsB.compareTo(pointsA); // Orden descendente
    });

    setState(() {
      filteredTop10 = filtered.take(10).toList();
      podiumUsers = filtered.take(3).toList();
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
                  _buildToggleSwitch(context), // Equips / Individual (Actualizado)
                  const SizedBox(height: 20),

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

  // WIDGETS DE FILTRADO
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

  // --- TOGGLE SWITCH ACTUALIZADO ---
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
          Expanded(
            child: TextButton(
              onPressed: () {
                // Pon aquí el nombre de la ruta que tengas configurada
                Navigator.pushReplacementNamed(context, AppRouter.rankingRoute);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey, // Color del efecto al tocar
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                  'Equips',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)
              ),
            ),
          ),

          Expanded(
            child: TextButton(
              onPressed: () {
                // Al estar ya en Individual, podemos dejarlo vacío
                // o hacer un pequeño print para comprobar que funciona
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1058E5), // Color del efecto al tocar
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                  'Individual',
                  style: TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SECCIÓN PODIO ---
  Widget _buildPodiumSection() {
    final first = podiumUsers.isNotEmpty ? podiumUsers[0] : null;
    final second = podiumUsers.length > 1 ? podiumUsers[1] : null;
    final third = podiumUsers.length > 2 ? podiumUsers[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildPodiumPilar(user: second, rank: 2, height: 100, baseColor: const Color(0xFFF0F0F0), badgeColor: const Color(0xFFB4B4B4))),
          Expanded(flex: 1, child: Padding(padding: const EdgeInsets.only(bottom: 20.0), child: _buildPodiumPilar(user: first, rank: 1, height: 130, baseColor: const Color(0xFFFFF7D0), badgeColor: const Color(0xFFFFC107), isFirst: true))),
          Expanded(child: _buildPodiumPilar(user: third, rank: 3, height: 70, baseColor: const Color(0xFFFBE4D4), badgeColor: const Color(0xFFD97D43))),
        ],
      ),
    );
  }

  Widget _buildPodiumPilar({required UserRankingModel? user, required int rank, required double height, required Color baseColor, required Color badgeColor, bool isFirst = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (user != null) ...[
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Icono de persona en lugar del icono de deporte/equipo
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
          Text('${user.modalityPoints.firstWhere((pair) => pair.first == _selectedModality).second} pts', style: const TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
        ],
        Container(height: height, width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: baseColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))), child: Icon(Icons.emoji_events, color: badgeColor.withValues(alpha: 0.5), size: 32)),
      ],
    );
  }

  // --- SECCIÓN TOP 10 ---
  Widget _buildTop10Section() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOP 10 USUARIS - $_selectedZone'.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0)),
              TextButton(onPressed: () => Navigator.pushNamed(context, AppRouter.individualTotalRankingRoute),
                  child: const Text('Veure tot', style: TextStyle(color: Color(0xFF1058E5), fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 16),
          if (filteredTop10.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Encara no hi ha usuaris en aquesta zona", style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTop10.length,
              itemBuilder: (context, index) => _buildUserCard(filteredTop10[index].name, filteredTop10[index].modalityPoints.firstWhere((pair) => pair.first == _selectedModality).second,
                  filteredTop10[index].isCurrentUser, index + 1),
            ),
        ],
      ),
    );
  }

  // TARJETA DE USUARIO REDUCIDA Y LIMPIA
  Widget _buildUserCard(String name, int points, bool isCurrentUser, int rank) {

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
          // Si es el usuario actual, le ponemos el borde azul izquierdo
          decoration: BoxDecoration(
              border: isCurrentUser ? const Border(left: BorderSide(color: Color(0xFF1058E5), width: 5)) : null
          ),
          // Reducimos un poco el padding vertical para que sea más compacta
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Número de rango
              SizedBox(
                  width: 24,
                  child: Text(
                      rank.toString(),
                      style: TextStyle(
                          color: isCurrentUser ? const Color(0xFF1058E5) : Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      )
                  )
              ),

              // Avatar de persona
              CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF2864FF).withValues(alpha: 0.8),
                  child: const Icon(Icons.person, color: Colors.white, size: 20)
              ),
              const SizedBox(width: 12),

              // Nombre del usuario (ya sin el subtítulo de zonas debajo)
              Expanded(
                child: Text(
                    name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isCurrentUser ? const Color(0xFF1058E5) : Colors.black87
                    )
                ),
              ),

              // Puntos
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      points.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isCurrentUser ? const Color(0xFF1058E5) : Colors.black87
                      )
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