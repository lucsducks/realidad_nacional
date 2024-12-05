// lib/widgets/comentarios_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realidadnacional/commentary_service.dart';
import 'package:realidadnacional/auth_services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:realidadnacional/topics.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ComentariosSectionGeneral extends StatefulWidget {
  final Topics topic;
  final String title;

  const ComentariosSectionGeneral({
    Key? key,
    required this.topic,
    required this.title,
  }) : super(key: key);

  @override
  State<ComentariosSectionGeneral> createState() =>
      _ComentariosSectionGeneralState();
}

class _ComentariosSectionGeneralState extends State<ComentariosSectionGeneral>
    with SingleTickerProviderStateMixin {
  final TextEditingController _comentarioController = TextEditingController();
  late AnimationController _controller;
  late CommentaryService _commentaryService;
  late AuthService _authService;

  List<dynamic> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context, listen: false);
    _commentaryService = CommentaryService(_authService);

    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
    });
    final result =
        await _commentaryService.getCommentariesByTopic(widget.topic, 0);
    if (result['success']) {
      setState(() {
        _comments =
            result['data']['data']; // Ajusta según la respuesta de tu API
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al obtener comentarios: ${result['error']}')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('comentarios-section-${widget.topic.value}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3) {
          _controller.forward();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            // Campo de comentario
            _buildCommentInput(),
            const SizedBox(height: 40),
            // Comentarios existentes
            _isLoading
                ? const CircularProgressIndicator()
                : _buildExistingComments(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _comentarioController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText:
                  '¿Qué opinas sobre ${widget.topic == Topics.decentralizationProcess ? 'la descentralización en el Perú' : 'la estructura económica y desarrollo'}?',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 15),
          FilledButton(
            onPressed: _submitComment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Enviar Comentario'),
          ),
        ],
      ),
    );
  }

  /// Envía el comentario al backend.
  void _submitComment() async {
    final content = _comentarioController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El comentario no puede estar vacío')),
      );
      return;
    }

    if (!_authService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe iniciar sesión para comentar')),
      );
      return;
    }

    final result =
        await _commentaryService.postCommentary(content, widget.topic);
    if (result['success']) {
      _comentarioController.clear();
      await _fetchComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario enviado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al enviar comentario: ${result['error']}')),
      );
    }
  }

  /// Construye la lista de comentarios existentes.
  Widget _buildExistingComments() {
    if (_comments.isEmpty) {
      return const Text(
        'No hay comentarios',
        style: TextStyle(color: Colors.white),
      );
    }
    return Column(
      children: _comments.map((comment) {
        return Column(
          children: [
            SlideInLeft(
              child: _buildCommentCard(
                username: comment['user']['fullName'] ?? 'Anónimo',
                comment: comment['content'] ?? '',
                date: DateTime.parse(comment['creationDate']),
                commentId: comment['id'],
                userId: comment['user']['id'],
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  /// Construye una tarjeta de comentario individual.
  Widget _buildCommentCard({
    required String username,
    required String comment,
    required DateTime date,
    required int commentId,
    required String userId,
  }) {
    final isOwner =
        (_authService.isAuthenticated && userId == _authService.userId);

    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Información del usuario y la fecha.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          /// Contenido del comentario.
          Text(
            comment,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),

          /// Botones de acción: Votar, Editar, Eliminar.
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up, color: Colors.white),
                onPressed: () {
                  _voteComment(commentId, VoteType.up);
                },
              ),
              IconButton(
                icon: const Icon(Icons.thumb_down, color: Colors.white),
                onPressed: () {
                  _voteComment(commentId, VoteType.down);
                },
              ),
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    _editComment(commentId, comment);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    _deleteComment(commentId);
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Elimina un comentario.
  void _deleteComment(int commentaryId) async {
    final result = await _commentaryService.deleteCommentary(commentaryId);
    if (result['success']) {
      await _fetchComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario eliminado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al eliminar comentario: ${result['error']}')),
      );
    }
  }

  /// Edita un comentario existente.
  void _editComment(int commentaryId, String currentContent) {
    final TextEditingController _editController =
        TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) {
        return CommentEditDialog(
          controller: _editController,
          onCancel: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          onSave: (newContent) async {
            if (newContent.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('El comentario no puede estar vacío')),
              );
              return;
            }
            final result = await _commentaryService.editCommentary(
                commentaryId, newContent);
            if (result['success']) {
              Navigator.of(context).pop(); // Close the dialog
              await _fetchComments();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Comentario editado')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Error al editar comentario: ${result['error']}')),
              );
            }
          },
        );
      },
    );
  }

  /// Vota un comentario.
  void _voteComment(int commentaryId, VoteType vote) async {
    if (!_authService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe iniciar sesión para votar')),
      );
      return;
    }
    final result = await _commentaryService.voteCommentary(commentaryId, vote);
    if (result['success']) {
      await _fetchComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voto registrado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al votar: ${result['error']}')),
      );
    }
  }
}

class CommentEditDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onCancel;
  final Function(String) onSave;

  const CommentEditDialog({
    Key? key,
    required this.controller,
    required this.onCancel,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[850],
      child: Container(
        width: 425,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Editar Comentario',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Edita tu comentario',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => onSave(controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Guardar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
