import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/services/chat_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../shared/models/chat_message.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_comunity_bar.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  static const Color _primaryBlue = Color(0xFF1058E5);
  static const Color _bgColor = Color(0xFFF4F6F9);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;



  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    SocketService().off('new-chat-message');
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.hasTeam) {
      setState(() {
        _messages = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final messages = await ChatService().getTeamMessages(user.team!);
      // Ordenar cronològicament (més antics a dalt)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
        _setupSocketListener();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages = [];
          _isLoading = false;
        });
      }
    }
  }

  void _setupSocketListener() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.hasTeam) return;

    // Netegem qualsevol listener anterior per evitar duplicats si es crida més d'un cop
    SocketService().off('new-chat-message');

    SocketService().on('new-chat-message', (data) {
      if (mounted) {
        final message = ChatMessage.fromJson(data as Map<String, dynamic>);
        
        setState(() {
          // Evitem duplicats si ja l'hem afegit localment a _sendMessage
          bool isDuplicate = _messages.any((m) => 
            m.senderUsername == message.senderUsername && 
            m.content == message.content &&
            (m.timestamp.difference(message.timestamp).inSeconds.abs() < 5)
          );

          if (!isDuplicate) {
            _messages.add(message);
            _scrollToBottom();
          }
        });
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.hasTeam) return;

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      final success = await ChatService().sendMessage(
        senderUsername: user.username,
        content: text,
      );

      if (mounted) {
        if (success) {
          // No cal afegir-lo localment si el polling és ràpid, però ho fem per UX
          setState(() {
            _messages.add(ChatMessage(
              senderUsername: user.username,
              content: text,
              timestamp: DateTime.now(),
            ));
          });
          _scrollToBottom();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No s\'ha pogut enviar el missatge')),
          );
          _messageController.text = text;
        }
      }
    } catch (e) {
      if (mounted) _messageController.text = text;
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Mostra accions per a un missatge (long-press). De moment només "Reportar".
  void _onMessageLongPress(ChatMessage message) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.report, color: Colors.red),
                title: const Text('Reportar missatge'),
                onTap: () {
                  Navigator.pop(ctx);
                  _reportMessage(message);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copiar contingut'),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: message.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Missatge copiat')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reportMessage(ChatMessage message) async {
    final user = context.read<AuthProvider>().currentUser;
    final reporter = user?.username ?? '';

    // Mostrem un loader ràpid
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await ChatService().reportMessage(
        reporterUsername: reporter,
        reportedUsername: message.senderUsername,
        content: message.content,
        timestamp: message.timestamp,
      );

      if (mounted) {
        Navigator.pop(context); // tancar loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Missatge reportat. Gràcies per la teva notificació.'
                : 'No s\'ha pogut enviar el report. S\'intentarà més tard.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error en reportar el missatge')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final hasTeam = user?.hasTeam ?? false;
    final currentUsername = user?.username ?? '';

    return Scaffold(
      backgroundColor: _bgColor,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: Column(
        children: [
          CommunityHeader(selectedIndex: 2),

          // Cos del xat
          Expanded(
            child: !hasTeam
                ? _buildNoTeamState()
                : _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _primaryBlue),
                      )
                    : _messages.isEmpty
                        ? _buildEmptyState()
                        : _buildMessagesList(currentUsername),
          ),

          // Barra d'escriptura (només si té equip)
          if (hasTeam) _buildInputBar(),
        ],
      ),
    );
  }

  // ─── Llista de missatges ─────────────────────────────────────────────────────

  Widget _buildMessagesList(String currentUsername) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg.senderUsername == currentUsername;

        // Decidim si mostrem el separador de data
        bool showDateSeparator = false;
        if (index == 0) {
          showDateSeparator = true;
        } else {
          final prevMsg = _messages[index - 1];
          if (!_isSameDay(msg.timestamp, prevMsg.timestamp)) {
            showDateSeparator = true;
          }
        }

        // Decidim si mostrem el nom de l'emissor (agrupació)
        // El mostrem si és el primer missatge, o si el remitent ha canviat, 
        // o si hi ha un separador de data entremig
        final showSenderName = index == 0 ||
            _messages[index - 1].senderUsername != msg.senderUsername ||
            showDateSeparator;

        final bubble = _buildMessageBubble(
          message: msg,
          isMe: isMe,
          showSenderName: showSenderName,
        );

        if (showDateSeparator) {
          return Column(
            children: [
              _buildDaySeparator(_getDateLabel(msg.timestamp)),
              bubble,
            ],
          );
        }
        return bubble;
      },
    );
  }

  Widget _buildDaySeparator(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 0.5)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 0.5)),
        ],
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      return 'HOY';
    } else if (msgDate == yesterday) {
      return 'AYER';
    } else {
      final months = [
        'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
      ];
      return '${date.day} de ${months[date.month - 1]}'.toUpperCase();
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Widget _buildMessageBubble({
    required ChatMessage message,
    required bool isMe,
    required bool showSenderName,
  }) {
    final timeStr =
        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    // Colors basats en el mockup
    final avatarColors = [
      const Color(0xFF1058E5),
      const Color(0xFF34C759),
      const Color(0xFFFF9500),
      const Color(0xFF8E44AD),
      const Color(0xFFE74C3C),
    ];
    final colorIndex =
        message.senderUsername.hashCode.abs() % avatarColors.length;
    final avatarColor = avatarColors[colorIndex];

    return Padding(
      padding: EdgeInsets.only(
        top: showSenderName ? 14 : 4,
        bottom: 2,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Nom de l'emissor (només si no sóc jo i és la primera del grup)
          if (!isMe && showSenderName)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 4),
              child: Text(
                message.senderUsername,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),

          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar (només per als altres i primer del grup)
              if (!isMe && showSenderName)
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: avatarColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: avatarColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 18,
                    color: avatarColor,
                  ),
                )
              else if (!isMe)
                const SizedBox(width: 44), // Espai per alinear

              // Bombolla del missatge
              Flexible(
                child: GestureDetector(
                  onLongPress: isMe
                      ? null
                      : () => _onMessageLongPress(message),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? _primaryBlue : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: isMe ? Colors.white : const Color(0xFF1A1D26),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe
                                    ? Colors.white.withValues(alpha: 0.65)
                                    : Colors.grey,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 3),
                              Icon(
                                Icons.done_all,
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Estat sense equip ──────────────────────────────────────────────────────────

  Widget _buildNoTeamState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_off_rounded,
                color: Colors.orange,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Encara no tens cap equip',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Per poder xatejar amb altres usuaris, primer has d\'unir-te a un equip o crear-ne un de nou a la secció d\'Equips.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Aquí podríem navegar a la pestanya d'equips si cal
                // Per ara només informem
              },
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text('Explorar Equips', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Estat buit ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: _primaryBlue,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Encara no hi ha missatges',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D26),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sigues el primer en escriure!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Barra d'entrada ─────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botó de contingut extra
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _bgColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.add, size: 20, color: Colors.grey[600]),
              onPressed: () {
                // Futura funcionalitat: enviar imatges/ubicació
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Adjuntar fitxers pròximament disponible'),
                    backgroundColor: _primaryBlue,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 10),

          // Camp de text
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Escriu un missatge...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Botó enviar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _primaryBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _isSending ? null : _sendMessage,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}