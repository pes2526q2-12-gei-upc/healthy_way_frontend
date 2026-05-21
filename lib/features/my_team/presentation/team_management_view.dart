import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/team_service.dart';
import '../../../shared/providers/auth_provider.dart';

class TeamManagementView extends StatefulWidget {
  final String teamName;

  const TeamManagementView({super.key, required this.teamName});

  @override
  State<TeamManagementView> createState() => _TeamManagementViewState();
}

class _TeamManagementViewState extends State<TeamManagementView> {
  static const Color _primaryBlue = Color(0xFF1058E5);
  static const Color _bgColor = Color(0xFFF4F6F9);

  List<Map<String, dynamic>> _requests = [];
  List<String> _members = [];
  bool _isLoading = true;
  int _currentTab = 0; // 0 = Solicitudes, 1 = Miembros
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _currentUsername = context.read<AuthProvider>().currentUser?.username;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _loadRequests();
    await _loadMembers();
  }

  Future<void> _loadRequests() async {
    try {
      final requests = await TeamService().getJoinRequests(widget.teamName);
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error carregant sol·licituds: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMembers() async {
    try {
      final members = await TeamService().getTeamMembers(widget.teamName);
      if (mounted) {
        setState(() {
          _members = members;
        });
      }
    } catch (e) {
      debugPrint('Error carregant membres: $e');
    }
  }

  Future<void> _handleAccept(String username) async {
    final acceptorUsername = context.read<AuthProvider>().currentUser?.username ?? '';
    final success = await TeamService().acceptJoinRequest(
      teamName: widget.teamName,
      username: username,
      acceptorUsername: acceptorUsername,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sol·licitud acceptada correctament')),
      );
      _loadRequests();
    }
  }

  Future<void> _handleDeny(String username) async {
    final success = await TeamService().denyJoinRequest(widget.teamName, username);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sol·licitud denegada')),
      );
      setState(() {
        _requests.removeWhere((req) => req['username'] == username);
      });
    }
  }

  Future<void> _handleRemoveMember(String username) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar membre'),
        content: Text('Estàs segur que vols eliminar $username de l\'equip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success = await TeamService().removeMember(widget.teamName, username);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$username eliminat de l\'equip')),
        );
        _loadMembers();
      }
    }
  }

  Future<void> _handleLeaveTeam() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abandonar equip'),
        content: const Text('Estàs segur que vols abandonar aquest equip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Abandonar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success = await TeamService().leaveTeam(widget.teamName, _currentUsername ?? '');
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Has abandonat l\'equip')),
        );
        Navigator.pop(context, true); // Torna a la pantalla anterior
      }
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Gestió d\'Equip', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tabs/Buttons to switch between sections
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _currentTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _currentTab == 0 ? _primaryBlue : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              'Sol·licituds',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _currentTab == 0 ? _primaryBlue : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _currentTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _currentTab == 1 ? _primaryBlue : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              'Membres',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _currentTab == 1 ? _primaryBlue : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content based on current tab
                Expanded(
                  child: _currentTab == 0 ? _buildRequestsSection() : _buildMembersSection(),
                ),
              ],
            ),
    );
  }

  Widget _buildRequestsSection() {
    return _requests.isEmpty
        ? const Center(
            child: Text(
              'No hi ha sol·licituds pendents.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _requests.length,
            itemBuilder: (context, index) {
              final request = _requests[index];
              return _buildRequestCard(request);
            },
          );
  }

  Widget _buildMembersSection() {
    // Separa el usuario actual del resto
    final currentUserMember = _members.contains(_currentUsername) ? _currentUsername : null;
    final otherMembers = _members.where((m) => m != _currentUsername).toList();

    // Ordena para que el actual sea el primero
    final orderedMembers = <String>[];
    if (currentUserMember != null) {
      orderedMembers.add(currentUserMember);
    }
    orderedMembers.addAll(otherMembers);

    return _members.isEmpty
        ? const Center(
            child: Text(
              'No hi ha membres en aquest equip.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orderedMembers.length,
            itemBuilder: (context, index) {
              final member = orderedMembers[index];
              final isCurrentUser = member == _currentUsername;
              return _buildMemberCard(member, isCurrentUser);
            },
          );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _primaryBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: _primaryBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['username'] ?? 'Usuari Desconegut',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request['requestDate'] ?? '',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _handleDeny(request['username'] ?? ''),
                tooltip: 'Denegar',
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _handleAccept(request['username'] ?? ''),
                tooltip: 'Acceptar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(String member, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser
            ? Border.all(color: _primaryBlue, width: 2)
            : Border.all(color: Colors.grey.shade100, width: 1),
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? _primaryBlue.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: isCurrentUser ? _primaryBlue : Colors.grey,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser ? '$member (Tu)' : member,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCurrentUser ? _primaryBlue : Colors.black,
                  ),
                ),
                if (isCurrentUser)
                  const Text(
                    'Membre actual',
                    style: TextStyle(
                      color: _primaryBlue,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (isCurrentUser)
            TextButton(
              onPressed: _handleLeaveTeam,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text(
                'Abandonar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () => _handleRemoveMember(member),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
