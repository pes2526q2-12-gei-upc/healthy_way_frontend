import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/team_service.dart';
import '../../../shared/models/team_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_comunity_bar.dart';
import 'team_management_view.dart';
import 'create_team_view.dart';

class MyTeam extends StatefulWidget {
  const MyTeam({super.key});

  @override
  State<MyTeam> createState() => _MyTeamState();
}

class _MyTeamState extends State<MyTeam> {
  static const Color _primaryBlue = Color(0xFF1058E5);
  static const Color _bgColor = Color(0xFFF4F6F9);

  // Future per carregar les dades de l'equip desde el backend
  Future<TeamModel?>? _teamFuture;
  Future<List<TeamModel>>? _publicTeamsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  void _loadTeamData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null && user.hasTeam && user.team!.isNotEmpty) {
      setState(() {
        _teamFuture = TeamService().getTeamByName(user.team!);
      });
    } else {
      setState(() {
        _publicTeamsFuture = TeamService().getAllTeams();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: _bgColor,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: Column(
        children: [
          CommunityHeader(selectedIndex: 1),
          Expanded(
            child: user == null
                ? const Center(child: CircularProgressIndicator())
                : user.hasTeam
                    ? _buildTeamView(context, user.team!)
                    : _buildNoTeamView(context),
          ),
        ],
      ),
    );
  }

  // ─── VISTA: USUARI AMB EQUIP ─────────────────────────────────────────────────

  Widget _buildTeamView(BuildContext context, String teamName) {
    return FutureBuilder<TeamModel?>(
      future: _teamFuture,
      builder: (context, snapshot) {
        // Mentre carrega, mostrem un skeleton/loader però ja tenim el nom
        final team = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _teamFuture = TeamService().getTeamByName(teamName);
            });
          },
          color: _primaryBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Targeta principal de l'equip ──
                _buildTeamCard(context, teamName, team, isLoading),
                const SizedBox(height: 24),

                // ── Progrés Setmanal ──
                _buildWeeklyProgress(),
                const SizedBox(height: 24),

                // ── Membres ──
                _buildMembersList(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamCard(
    BuildContext context,
    String teamName,
    TeamModel? team,
    bool isLoading,
  ) {
    final zone = team?.zone ?? '—';
    final modality = team?.modality ?? '—';
    final modalityIcon = modality == 'cycling'
        ? Icons.directions_bike
        : Icons.directions_run;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar de l'equip (cercle pintat, sense imatge de moment)
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1058E5), Color(0xFF4A85F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              // Indicador de modalitat
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF34C759),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    modalityIcon,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Nom de l'equip
          Text(
            teamName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D26),
            ),
          ),
          const SizedBox(height: 4),

          // Zona i descripció
          isLoading
              ? const SizedBox(
                  height: 16,
                  width: 140,
                  child: LinearProgressIndicator(borderRadius: BorderRadius.all(Radius.circular(4))),
                )
              : Text(
                  '${team?.description ?? 'Sense descripció'} · $zone',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),

          const SizedBox(height: 20),

          // Estadístiques (hardcoded — no hi ha endpoint d'estadístiques d'equip)
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  // ⚠️ Hardcoded: estadístiques pendents d'endpoint
                  value: '0',
                  label: 'Punts Totals',
                  color: _primaryBlue,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  // ⚠️ Hardcoded: estadístiques pendents d'endpoint
                  value: '0',
                  label: 'Zones Conquerides',
                  color: const Color(0xFF34C759),
                ),
              ),
            ],
          ),

          // Botons d'accions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamManagementView(teamName: teamName),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people_outline, size: 16),
                  label: const Text('Gestionar', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryBlue,
                    side: BorderSide(color: _primaryBlue.withValues(alpha: 0.3)),
                    backgroundColor: _primaryBlue.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (team != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateTeamView(team: team),
                        ),
                      ).then((_) {
                         // Recarregar les dades de l'equip a l'anar enrere
                         _loadTeamData();
                      });
                    }
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Editar Equip', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryBlue,
                    side: BorderSide(color: _primaryBlue.withValues(alpha: 0.3)),
                    backgroundColor: _primaryBlue.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    // ⚠️ Tot hardcoded — no hi ha endpoint de progrés setmanal
    const double progressValue = 0.0;
    const String progressLabel = '0%';
    const String goalLabel = 'Objectiu: 15k';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progrés Setmanal',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            Text(
              goalLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aconseguit',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    progressLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D26),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE8EEF7),
                  valueColor: const AlwaysStoppedAnimation<Color>(_primaryBlue),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Les dades de progrés s\'actualitzaran aviat',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;

    // ⚠️ Hardcoded: només es mostra l'usuari actual, no hi ha endpoint per llistar membres
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Membres',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Afegir',
                style: TextStyle(
                  color: _primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Membre: l'usuari actual
        _buildMemberCard(
          name: '${user.nom} (Tu)',
          status: 'Membre actiu',
          isOnline: true,
          // ⚠️ Hardcoded: punts pendents d'endpoint
          points: '0 pts',
          avatarColor: _primaryBlue,
        ),
      ],
    );
  }

  Widget _buildMemberCard({
    required String name,
    required String status,
    required bool isOnline,
    required String points,
    required Color avatarColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: avatarColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, color: avatarColor, size: 24),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isOnline ? const Color(0xFF34C759) : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Punts
          Text(
            points,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: _primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // ─── VISTA: USUARI SENSE EQUIP ───────────────────────────────────────────────

  Widget _buildNoTeamView(BuildContext context) {
    return FutureBuilder<List<TeamModel>>(
      future: _publicTeamsFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final publicTeams = snapshot.data ?? [];
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Missatge d'inici ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1058E5), Color(0xFF4A85F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Encara no tens equip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Uneix-te a un equip existent o crea el teu propi per competir amb altres equips de la teva zona.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botó crear equip
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/create_team'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          'Crear nou equip',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Cerca per unir-se a un equip privat ──
              const Text(
                'Unir-se a un equip privat',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D26),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Introdueix el nom de l\'equip',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _primaryBlue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final teamName = _searchController.text.trim();
                      if (teamName.isNotEmpty) {
                        final success = await TeamService().requestJoinPrivateTeam(teamName);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? 'Sol·licitud enviada correctament' : 'Error al enviar la sol·licitud'),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                          if (success) _searchController.clear();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.search),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Capçalera llista d'equips ──
              Row(
                children: [
                  const Text(
                    'Equips disponibles',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D26),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${publicTeams.length}',
                        style: const TextStyle(
                          color: _primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Llista de targetes d'equips ──
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (publicTeams.isEmpty)
                const Text('No hi ha equips públics disponibles.', style: TextStyle(color: Colors.grey))
              else
                ...publicTeams.map((team) => _buildTeamListCard(context, team)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamListCard(BuildContext context, TeamModel team) {
    final modality = team.modality;
    final modalityIcon =
    modality == 'cycling' ? Icons.directions_bike : Icons.directions_run;
    final modalityColor =
    modality == 'cycling' ? const Color(0xFFFF9500) : const Color(0xFF34C759);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            // Confirm dialog
            final shouldJoin = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Unir-se a l\'equip'),
                content: Text('Vols unir-te a l\'equip "${team.name}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel·lar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white),
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
            );

            if (shouldJoin == true && context.mounted) {
              final success = await TeamService().joinTeam(team.name);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('T\'has unit a "${team.name}" correctament!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Update current user
                  await context.read<AuthProvider>().updateTeam(team.name);
                  _loadTeamData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error en unir-se a l\'equip'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar de l'equip
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _primaryBlue.withValues(alpha: 0.7),
                        _primaryBlue,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.people_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),

                // Info de l'equip
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1A1D26),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          // Zona
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 3),
                          Text(
                            team.zone,
                            style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(width: 10),
                          // Membres
                          const Icon(Icons.people_outline,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 3),
                          Text(
                            '${team.numMembers} membres',
                            style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Modalitat
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: modalityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(modalityIcon,
                                    size: 11, color: modalityColor),
                                const SizedBox(width: 3),
                                Text(
                                  modality,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: modalityColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Fletxa
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.grey, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}