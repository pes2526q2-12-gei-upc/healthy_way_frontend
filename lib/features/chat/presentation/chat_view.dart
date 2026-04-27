import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/chat_service.dart';
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
  bool _useHardcoded = false; // Si la API falla, usem missatges de prova
  Timer? _pollTimer;

  // ⚠️ Hardcoded: chatId. Idealment vindria del backend vinculat a l'equip
  static const int _chatId = 1;

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
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    try {
      final messages = await ChatService().getMessages(_chatId);
      if (mounted) {
        setState(() {
          if (messages.isEmpty) {
            // Si la API retorna buit, usem hardcoded per demostrar la vista
            _useHardcoded = true;
            _messages = _getHardcodedMessages();
          } else {
            _useHardcoded = false;
            _messages = messages;
          }
          _isLoading = false;
        });
        _scrollToBottom();
        _startPolling();
      }
    } catch (e) {
      // Si la API no respon, mostrem dades de prova
      if (mounted) {
        setState(() {
          _useHardcoded = true;
          _messages = _getHardcodedMessages();
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _startPolling() {
    if (_useHardcoded) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_messages.isNotEmpty) {
        final newMessages = await ChatService().getMessagesSince(
          _chatId,
          _messages.last.timestamp,
        );
        if (mounted && newMessages.isNotEmpty) {
          setState(() => _messages.addAll(newMessages));
          _scrollToBottom();
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    _messageController.clear();

    if (_useHardcoded) {
      // Mode de prova: afegim el missatge localment
      setState(() {
        _messages.add(ChatMessage(
          senderUsername: user.username,
          content: text,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
      return;
    }

    setState(() => _isSending = true);

    try {
      final success = await ChatService().sendMessage(
        chatId: _chatId,
        senderId: user.userId,
        content: text,
      );

      if (mounted) {
        if (success) {
          // Afegim l'entrada localment per feedback immediat
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
            SnackBar(
              content: const Text('No s\'ha pogut enviar el missatge'),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          // Restaurem el text
          _messageController.text = text;
        }
      }
    } catch (e) {
      if (mounted) {
        _messageController.text = text;
      }
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

  // ⚠️ Missatges hardcoded de demostració (basats en el mockup)
  List<ChatMessage> _getHardcodedMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        senderUsername: 'Marc Soler',
        content: 'Ei equip! Algú s\'anima a fer la ruta de Collserola aquesta tarda? 🏔️',
        timestamp: DateTime(now.year, now.month, now.day, 10, 30),
      ),
      ChatMessage(
        senderUsername: 'Laura Vila',
        content: 'Jo puc a partir de les 18h! M\'han dit que l\'aire està excel·lent avui.',
        timestamp: DateTime(now.year, now.month, now.day, 10, 32),
      ),
      ChatMessage(
        senderUsername: '_self_', // Marcador per al missatge propi
        content: 'Perfecte, a les 18h ens veiem a l\'entrada del parc! 👍',
        timestamp: DateTime(now.year, now.month, now.day, 10, 35),
      ),
      ChatMessage(
        senderUsername: 'Pau Riera',
        content: 'Compteu amb mi també. Portaré aigua extra.',
        timestamp: DateTime(now.year, now.month, now.day, 10, 40),
      ),
      ChatMessage(
        senderUsername: 'Marc Soler',
        content: 'Genial! Doncs ja som 4. Ens veiem allà 💪',
        timestamp: DateTime(now.year, now.month, now.day, 10, 42),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentUsername =
        context.watch<AuthProvider>().currentUser?.username ?? '';

    return Scaffold(
      backgroundColor: _bgColor,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: Column(
        children: [
          CommunityHeader(selectedIndex: 2),

          // Banner informatiu si estem en mode hardcoded
          if (_useHardcoded && !_isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.amber[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode de prova — els missatges no es guarden al servidor',
                      style: TextStyle(fontSize: 11, color: Colors.amber[900]),
                    ),
                  ),
                ],
              ),
            ),

          // Cos del xat
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _primaryBlue),
                  )
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessagesList(currentUsername),
          ),

          // Barra d'escriptura
          _buildInputBar(),
        ],
      ),
    );
  }

  // ─── Llista de missatges ─────────────────────────────────────────────────────

  Widget _buildMessagesList(String currentUsername) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length + 1, // +1 pel separador "Avui"
      itemBuilder: (context, index) {
        // Primer element = separador de dia
        if (index == 0) {
          return _buildDaySeparator('Avui');
        }

        final msg = _messages[index - 1];
        final isMe = msg.senderUsername == currentUsername ||
            msg.senderUsername == '_self_';

        // Decidim si mostrem el nom de l'emissor (agrupació)
        final showSenderName = index == 1 ||
            _messages[index - 2].senderUsername != msg.senderUsername;

        return _buildMessageBubble(
          message: msg,
          isMe: isMe,
          showSenderName: showSenderName,
        );
      },
    );
  }

  Widget _buildDaySeparator(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 0.5)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 0.5)),
        ],
      ),
    );
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
            ],
          ),
        ],
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