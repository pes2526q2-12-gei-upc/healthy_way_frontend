import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/team_service.dart';
import '../../../shared/models/team_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_comunity_bar.dart';

class CreateTeamView extends StatefulWidget {
  const CreateTeamView({super.key});

  @override
  State<CreateTeamView> createState() => _CreateTeamViewState();
}

class _CreateTeamViewState extends State<CreateTeamView> {
  final _formKey = GlobalKey<FormState>();

  // Controladors del formulari
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isOpen = true;
  String _selectedZone = 'Barcelona';
  String _selectedModality = 'running';
  bool _isLoading = false;

  static const Color _primaryBlue = Color(0xFF1058E5);
  static const Color _bgColor = Color(0xFFF4F6F9);

  final List<String> _zones = ['Barcelona', 'Girona', 'Lleida', 'Tarragona'];
  final List<Map<String, dynamic>> _modalities = [
    {'value': 'running', 'label': 'Running', 'icon': Icons.directions_run},
    {'value': 'cycling', 'label': 'Cycling', 'icon': Icons.directions_bike},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newTeam = TeamModel(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      open: _isOpen,
      zone: _selectedZone,
      modality: _selectedModality,
      numMembers: 1,
    );

    try {
      final createdTeam = await TeamService().createTeam(newTeam);

      if (!mounted) return;

      if (createdTeam != null) {
        // Actualitzem l'usuari amb el nou equip
        final authProvider = context.read<AuthProvider>();
        final currentUser = authProvider.currentUser!;
        final updatedUser = User(
          userId: currentUser.userId,
          nom: currentUser.nom,
          username: currentUser.username,
          email: currentUser.email,
          team: createdTeam.name,
        );
        await authProvider.login(updatedUser);

        if (!mounted) return;
        // Tornem a my_team, substituint aquesta pantalla
        Navigator.of(context).pop();
      } else {
        _showErrorSnackbar('No s\'ha pogut crear l\'equip. Torna-ho a intentar.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error en la connexió. Comprova que el servidor està actiu.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: Column(
        children: [
          // Header de comunitat (igual que la resta de vistes socials)
          CommunityHeader(selectedIndex: 1),

          // Contingut desplaçable amb el formulari
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Títol de la secció
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _primaryBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Crea el teu equip',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1D26),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.only(left: 14),
                      child: Text(
                        'Omple la informació per crear el teu equip',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── CAMP: Nom de l'equip ──
                    _buildSectionLabel('Nom de l\'equip *'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Ex: Els Llampecs',
                      maxLength: 50,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'El nom és obligatori';
                        }
                        if (v.trim().length < 3) {
                          return 'Mínim 3 caràcters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── CAMP: Descripció ──
                    _buildSectionLabel('Descripció'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descriptionController,
                      hintText: 'Explica de quin va el vostre equip...',
                      maxLength: 255,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // ── CAMP: Zona ──
                    _buildSectionLabel('Zona *'),
                    const SizedBox(height: 8),
                    _buildDropdownZone(),
                    const SizedBox(height: 20),

                    // ── CAMP: Modalitat ──
                    _buildSectionLabel('Modalitat *'),
                    const SizedBox(height: 12),
                    _buildModalitySelector(),
                    const SizedBox(height: 20),

                    // ── CAMP: Equip obert ──
                    _buildOpenSwitch(),
                    const SizedBox(height: 36),

                    // ── BOTÓ CREAR ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Crear Equip',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botó cancel·lar
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel·lar',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers de UI ───────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D3142),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDropdownZone() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedZone,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          items: _zones.map((zone) {
            return DropdownMenuItem(
              value: zone,
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: _primaryBlue),
                  const SizedBox(width: 8),
                  Text(zone, style: const TextStyle(fontSize: 14)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedZone = value);
          },
        ),
      ),
    );
  }

  Widget _buildModalitySelector() {
    return Row(
      children: _modalities.map((m) {
        final isSelected = _selectedModality == m['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedModality = m['value']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: m['value'] == 'running' ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? _primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? _primaryBlue : Colors.grey.shade200,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _primaryBlue.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Icon(
                    m['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    m['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOpenSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isOpen
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: _isOpen ? Colors.green[600] : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Equip obert',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF2D3142),
                  ),
                ),
                Text(
                  _isOpen
                      ? 'Qualsevol pot unir-se'
                      : 'Només per invitació',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOpen,
            onChanged: (v) => setState(() => _isOpen = v),
            activeThumbColor: _primaryBlue,
          ),
        ],
      ),
    );
  }
}
