import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realidadnacional/commentary_service.dart';
import 'package:realidadnacional/auth_services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:realidadnacional/topics.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  final ScrollController _scrollController = ScrollController();
  late AnimationController _controller;
  late CommentaryService _commentaryService;
  late AuthService _authService;

  List<dynamic> _comments = [];
  bool _isLoading = true;
  bool _isSendingComment = false;
  bool _showScrollToTop = false;
  int _offset = 0;
  bool _hasMoreComments = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scrollController.addListener(() {
      setState(() {
        _showScrollToTop = _scrollController.offset > 200;
      });

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreComments();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context, listen: false);
    _commentaryService = CommentaryService(_authService);
    _fetchComments();
  }

  Future<void> _loadMoreComments() async {
    if (!_isLoadingMore && _hasMoreComments) {
      setState(() {
        _isLoadingMore = true;
      });

      final result = await _commentaryService.getCommentariesByTopic(
          widget.topic, _offset + 10);

      if (result['success']) {
        final newComments = result['data']['data'] as List;
        if (newComments.isNotEmpty) {
          setState(() {
            _comments.addAll(newComments);
            _offset += 10;
            _hasMoreComments = newComments.length == 10;
          });
        } else {
          setState(() {
            _hasMoreComments = false;
          });
        }
      }

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
      _offset = 0;
    });

    final result =
        await _commentaryService.getCommentariesByTopic(widget.topic, _offset);

    if (result['success']) {
      setState(() {
        _comments = result['data']['data'];
        _hasMoreComments = _comments.length == 10;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Error al obtener comentarios: ${result['error']}');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _comentarioController.dispose();
    _scrollController.dispose();
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
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                FadeIn(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                SlideInLeft(
                  child: _buildCommentInput(),
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : _buildExistingComments(),
              ],
            ),
          ),
          if (_showScrollToTop)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.blue,
                child: Icon(Icons.arrow_upward),
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ),
        ],
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
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '¿Qué opinas?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _comentarioController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: _getPlaceholderText(),
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
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: Colors.black.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 15),
          FilledButton(
            onPressed: !_isSendingComment ? _submitComment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isSendingComment
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send),
                      SizedBox(width: 8),
                      Text('Enviar Comentario'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _getPlaceholderText() {
    switch (widget.topic) {
      case Topics.decentralizationProcess:
        return '¿Cuál es tu opinión sobre la descentralización en el Perú? Comparte tus ideas y experiencias...';
      default:
        return '¿Qué piensas sobre la estructura económica y el desarrollo del país? Comparte tu perspectiva...';
    }
  }

  void _submitComment() async {
    final content = _comentarioController.text.trim();
    if (content.isEmpty) {
      _showErrorSnackbar('El comentario no puede estar vacío');
      return;
    }

    if (!_authService.isAuthenticated) {
      _showErrorSnackbar('Debes iniciar sesión para comentar');
      return;
    }

    setState(() {
      _isSendingComment = true;
    });

    try {
      final result =
          await _commentaryService.postCommentary(content, widget.topic);
      if (result['success']) {
        _comentarioController.clear();
        await _fetchComments();
        _showSuccessSnackbar('¡Comentario publicado!');
      } else {
        _showErrorSnackbar(
            result['error'] ?? 'Error al publicar el comentario');
      }
    } finally {
      setState(() {
        _isSendingComment = false;
      });
    }
  }

  Widget _buildExistingComments() {
    if (_comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'Sé el primero en comentar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _comments.length + (_hasMoreComments ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _comments.length) {
          return _isLoadingMore
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : SizedBox();
        }

        final comment = _comments[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: SlideInLeft(
            child: _buildCommentCard(
              username: comment['user']['fullName'] ?? 'Anónimo',
              comment: comment['content'] ?? '',
              date: DateTime.parse(comment['creationDate']),
              commentId: comment['id'],
              userId: comment['user']['id'],
              votes: comment['votes'] ?? 0,
              userVote: comment['userVote'],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentCard({
    required String username,
    required String comment,
    required DateTime date,
    required int commentId,
    required String userId,
    required int votes,
    required String? userVote,
  }) {
    final isOwner =
        (_authService.isAuthenticated && userId == _authService.userId);
    final hasVotedUp = userVote == 'up';
    final hasVotedDown = userVote == 'down';

    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      username.substring(0, 1).toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        timeago.format(date, locale: 'es'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isOwner)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editComment(commentId, comment);
                    } else if (value == 'delete') {
                      _deleteComment(commentId);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white70, size: 20),
                          SizedBox(width: 8),
                          Text('Editar', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.white70, size: 20),
                          SizedBox(width: 8),
                          Text('Eliminar',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                  color: Colors.grey[850],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            comment,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildVoteButton(
                icon: Icons.thumb_up,
                isSelected: hasVotedUp,
                onPressed: () => _voteComment(commentId, VoteType.up),
              ),
              SizedBox(width: 4),
              Text(
                votes.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              _buildVoteButton(
                icon: Icons.thumb_down,
                isSelected: hasVotedDown,
                onPressed: () => _voteComment(commentId, VoteType.down),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.white54,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _deleteComment(int commentaryId) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(
          '¿Eliminar comentario?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final result = await _commentaryService.deleteCommentary(commentaryId);
      if (result['success']) {
        await _fetchComments();
        _showSuccessSnackbar('Comentario eliminado');
      } else {
        _showErrorSnackbar(
            result['error'] ?? 'Error al eliminar el comentario');
      }
    }
  }

  void _editComment(int commentaryId, String currentContent) {
    showDialog(
      context: context,
      builder: (context) => CommentEditDialog(
        initialContent: currentContent,
        onCancel: () => Navigator.of(context).pop(),
        onSave: (newContent) async {
          if (newContent.trim().isEmpty) {
            _showErrorSnackbar('El comentario no puede estar vacío');
            return;
          }
          Navigator.of(context).pop();

          final result = await _commentaryService.editCommentary(
            commentaryId,
            newContent.trim(),
          );

          if (result['success']) {
            await _fetchComments();
            _showSuccessSnackbar('Comentario actualizado');
          } else {
            _showErrorSnackbar(
                result['error'] ?? 'Error al editar el comentario');
          }
        },
      ),
    );
  }

  void _voteComment(int commentaryId, VoteType vote) async {
    if (!_authService.isAuthenticated) {
      _showErrorSnackbar('Debes iniciar sesión para votar');
      return;
    }

    final result = await _commentaryService.voteCommentary(commentaryId, vote);
    if (result['success']) {
      await _fetchComments();
      _showSuccessSnackbar('Voto registrado');
    } else {
      _showErrorSnackbar(result['error'] ?? 'Error al registrar el voto');
    }
  }
}

class CommentEditDialog extends StatefulWidget {
  final String initialContent;
  final VoidCallback onCancel;
  final Function(String) onSave;

  const CommentEditDialog({
    Key? key,
    required this.initialContent,
    required this.onCancel,
    required this.onSave,
  }) : super(key: key);

  @override
  _CommentEditDialogState createState() => _CommentEditDialogState();
}

class _CommentEditDialogState extends State<CommentEditDialog> {
  late TextEditingController _controller;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _controller.addListener(() {
      setState(() {
        _hasChanges = _controller.text != widget.initialContent;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 425,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Editar Comentario',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 4,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Edita tu comentario',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _hasChanges
                      ? () => widget.onSave(_controller.text)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
