import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import 'package:realidadnacional/auth_services.dart';
import 'package:realidadnacional/modal.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isLoading = true;
  Timer? _messageTimer;
  String _currentMessage = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadResources();
    _currentMessage = _getRandomMessage();
    _messageTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _isLoading) {
        setState(() {
          _currentMessage = _getRandomMessage();
        });
      }
    });
  }

  Future<void> _loadResources() async {
    try {
      await Future.wait([
        precacheImage(const AssetImage('background.png'), context),
        precacheImage(const AssetImage('economia.png'), context),
        precacheImage(const AssetImage('des.png'), context),
      ]);

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  String _getRandomMessage() {
    final messages = [
      "🚀 Preparando el despegue...",
      "🎨 Pintando la realidad nacional...",
      "📚 Cargando conocimiento...",
      "🌟 Casi listo para brillar...",
      "🎯 Afinando los detalles...",
      "🔍 Explorando la realidad nacional...",
      "🌎 Conectando con Perú...",
      "💡 Encendiendo ideas...",
      "🏗️ Construyendo experiencias...",
      "✨ Puliendo los últimos detalles...",
    ];

    return messages[DateTime.now().second % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 3, 22, 50),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 3, 16, 34),
                Color.fromARGB(255, 5, 37, 87),
              ],
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: const Icon(
                          Icons.rocket_launch,
                          size: 80,
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: 200,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        _currentMessage,
                        key: ValueKey<String>(_currentMessage),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Realidad Nacional',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Image.asset(
            'background.png',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 1, 10, 25).withOpacity(0.8)),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              slivers: [
                CustomSliverAppBar(isScrolled: _isScrolled),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, index) => const InfoWeb(),
                      childCount: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSliverAppBar extends StatelessWidget {
  final bool isScrolled;

  const CustomSliverAppBar({required this.isScrolled});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final authService = Provider.of<AuthService>(context);
    final isAuthenticated = authService.isAuthenticated;
    final username = authService.username ?? '';

    return SliverAppBar(
      backgroundColor: isScrolled ? Colors.black : Colors.transparent,
      automaticallyImplyLeading: false,
      expandedHeight: 50,
      pinned: true,
      title: const Text(
        'GRUPO 2',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (isMobile)
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            color: Colors.black87,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'inicio',
                child: Text('Inicio', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'tema1',
                child: Text('Estructura económica y desarrollo',
                    style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'tema2',
                child: Text('Proceso de descentralización y su impacto',
                    style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'acceder',
                child: Text('Acceder', style: TextStyle(color: Colors.white)),
              ),
            ],
            onSelected: (String value) {
              switch (value) {
                case 'inicio':
                  context.push('/');
                  break;
                case 'tema1':
                  context.push('/estructura-economica-desarrollo');
                  break;
                case 'tema2':
                  context.push('/descentralizacion-y-impacto');
                  break;
                case 'acceder':
                  showAuthModal(context);
                  break;
              }
            },
          )
        else
          isAuthenticated
              ? Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        username,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        await authService.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Sesión cerrada exitosamente')),
                        );
                      },
                      tooltip: 'Cerrar Sesión',
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showAuthModal(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Acceder',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
      ],
      flexibleSpace: !isMobile
          ? FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              background: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.push('/');
                      },
                      child: const Text('Inicio',
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/estructura-economica-desarrollo');
                      },
                      child: const Text('Estructura económica y desarrollo',
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/descentralizacion-y-impacto');
                      },
                      child: const Text(
                          'Proceso de descentralización y su impacto',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class InfoWeb extends StatelessWidget {
  const InfoWeb();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Inicio(),
              Temas(),
              Nosotros(),
            ],
          ),
        ),
        Footer(),
      ],
    );
  }
}

class Nosotros extends StatelessWidget {
  const Nosotros({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        children: [
          FadeInDown(
            child: const Text(
              'Nuestro Equipo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeIn(
            child: const Text(
              'Conoce al equipo detrás de este proyecto',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Primera fila
          const Wrap(
            spacing: 60,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _MemberCard(
                name: 'Carbajal Herrera Luis Manuel',
                image: 'luis.jpg',
                role: 'Desarrollador',
                github: 'github.com/username',
                linkedin: 'linkedin.com/in/username',
              ),
              _MemberCard(
                name: 'Rosas Lucas Fredhy Eduardo',
                image: 'lcuas.png',
                role: 'Desarrollador',
                github: 'github.com/username',
                linkedin: 'linkedin.com/in/username',
              ),
              _MemberCard(
                name: 'Romero Bardales Leonardo Josue',
                image: 'leo.jpeg',
                role: 'Desarrollador',
                github: 'https://github.com/LeonN534',
                linkedin: 'linkedin.com/in/username',
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Wrap(
            spacing: 60,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _MemberCard(
                name: 'Julca Garcia Jhonatan Anibal',
                image: 'julca.webp',
                role: 'Desarrollador',
                github: 'github.com/username',
                linkedin: 'linkedin.com/in/username',
              ),
              _MemberCard(
                name: 'Clauido Montes Kevin',
                image: 'kevin.png',
                role: 'Desarrollador',
                github: 'github.com/username',
                linkedin: 'linkedin.com/in/username',
              ),

            ],
          ),
        ],
      ),
    );
  }
}

class ComentariosSection extends StatefulWidget {
  const ComentariosSection({super.key});

  @override
  State<ComentariosSection> createState() => _ComentariosSectionState();
}

class _ComentariosSectionState extends State<ComentariosSection>
    with SingleTickerProviderStateMixin {
  final TextEditingController _comentarioController = TextEditingController();
  late AnimationController _controller;
  final List<Animation<Offset>> _commentAnimations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Animaciones para los comentarios existentes
    for (int i = 0; i < 3; i++) {
      _commentAnimations.add(
        Tween<Offset>(
          begin: const Offset(1.5, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(
            i * 0.2,
            0.8 + (i * 0.2),
            curve: Curves.easeOutBack,
          ),
        )),
      );
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return VisibilityDetector(
      key: const Key('comentarios-section'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 30) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Column(
          children: [
            // Título
            FadeInDown(
              child: const Text(
                'Comentarios',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Campo de comentario
            FadeInUp(
              child: Container(
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
                        hintText: '¿Qué opinas sobre este tema?',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.6)),
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
                    ElevatedButton(
                      onPressed: () {
                        // Aquí irá la lógica para enviar el comentario
                      },
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
              ),
            ),

            const SizedBox(height: 40),

            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _CommentCard(
                  username: 'Usuario ${index + 1}',
                  comment: _getRandomComment(),
                  date: DateTime.now().subtract(Duration(days: index)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRandomComment() {
    final comments = [
      'Me parece un tema muy interesante y relevante para nuestra sociedad actual.',
      'Excelente análisis, pero creo que hay aspectos que podrían profundizarse más.',
      'Esta información me ha ayudado mucho a entender mejor la situación del país.',
    ];
    return comments[DateTime.now().second % comments.length];
  }
}

// Widget para cada comentario individual
class _CommentCard extends StatelessWidget {
  final String username;
  final String comment;
  final DateTime date;

  const _CommentCard({
    required this.username,
    required this.comment,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
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
                _formatDate(date),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.black.withOpacity(0.8),
      child: const Center(
        child: Text(
          '© 2024 UNHEVAL - Todos los derechos reservados',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _MemberCard extends StatefulWidget {
  final String name;
  final String image;
  final String role;
  final String github;
  final String linkedin;

  const _MemberCard({
    required this.name,
    required this.image,
    required this.role,
    required this.github,
    required this.linkedin,
  });

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 250,
        height: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isHovered ? 0.3 : 0.2),
              blurRadius: isHovered ? 15 : 10,
              offset: Offset(0, isHovered ? 8 : 5),
            ),
          ],
        ),
        transform: Matrix4.identity()..translate(0.0, isHovered ? -5.0 : 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(widget.image),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.role,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.link, color: Colors.blue),
                  onPressed: () {
                    // Añadir enlace a LinkedIn
                  },
                  tooltip: 'LinkedIn',
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.code, color: Colors.blue),
                  onPressed: () {
                    // Añadir enlace a GitHub
                  },
                  tooltip: 'GitHub',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Temas extends StatefulWidget {
  const Temas({super.key});

  @override
  State<Temas> createState() => _TemasState();
}

class _TemasState extends State<Temas> with SingleTickerProviderStateMixin {
  bool isVisible = false;
  late AnimationController _controller;
  late Animation<Offset> _slideInLeftAnimation;
  late Animation<Offset> _slideInRightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideInLeftAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _slideInRightAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return VisibilityDetector(
      key: const Key('temas-section'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 30) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Temas de Interés',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            isMobile
                ? Column(
                    children: [
                      SlideTransition(
                        position: _slideInLeftAnimation,
                        child: _TemaCard(
                          onPressed: () {
                            context.push('/descentralizacion-y-impacto');
                          },
                          title: 'Estructura económica y desarrollo',
                          description:
                              'Análisis profundo de la estructura económica del Perú, examinando los sectores clave, políticas de desarrollo y su impacto en el crecimiento económico nacional.',
                          imagePath: 'economia.png',
                        ),
                      ),
                      const SizedBox(height: 20),
                      SlideTransition(
                        position: _slideInRightAnimation,
                        child: _TemaCard(
                          onPressed: () {
                            context.push('/descentralizacion-y-impacto');
                          },
                          title: 'Proceso de descentralización y su impacto',
                          description:
                              'Estudio del proceso de descentralización en el Perú, evaluando sus logros, desafíos y efectos en el desarrollo regional y la gobernanza local.',
                          imagePath: 'des.png',
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SlideTransition(
                          position: _slideInLeftAnimation,
                          child: _TemaCard(
                            onPressed: () {
                              context.push('/estructura-economica-desarrollo');
                            },
                            title: 'Estructura económica y desarrollo',
                            description:
                                'Análisis profundo de la estructura económica del Perú, examinando los sectores clave, políticas de desarrollo y su impacto en el crecimiento económico nacional.',
                            imagePath: 'economia.png',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: SlideTransition(
                          position: _slideInRightAnimation,
                          child: _TemaCard(
                            onPressed: () {
                              context.push('/estructura-economica-desarrollo');
                            },
                            title: 'Proceso de descentralización y su impacto',
                            description:
                                'Estudio del proceso de descentralización en el Perú, evaluando sus logros, desafíos y efectos en el desarrollo regional y la gobernanza local.',
                            imagePath: 'des.png',
                          ),
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

class _TemaCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback onPressed;

  const _TemaCard({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: double.infinity,
            height: 200,
            fit: BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Leer más',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: isMobile
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Realidad Nacional',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Es esta web tocaremos temas de interés nacional, abordaremos sus antecedentes, proyecciones a futuro, impacto en el ámbito nacional y regional y no solamente podrás encontrar información sobre tema, sino que podrás interactuar con otros usuarios y compartir tus opiniones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: ModelViewer(
                    src: 'https://peruvian-web.vercel.app/archivo.glb',
                    alt: 'A 3D model peru',
                    ar: true,
                    autoRotateDelay: 10,
                    autoRotate: true,
                    cameraControls: true,
                    cameraOrbit: '35deg 45deg 4.5m',
                    minCameraOrbit: 'auto auto auto',
                    maxCameraOrbit: 'auto auto auto',
                    interpolationDecay: 200,
                  ),
                ),
              ],
            )
          : const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Realidad Nacional',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Es esta web tocaremos temas de interés nacional, abordaremos sus antecedentes, proyecciones a futuro, impacto en el ámbito nacional y regional y no solamente podrás encontrar información sobre tema, sino que podrás interactuar con otros usuarios y compartir tus opiniones.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ModelViewer(
                      src: 'https://peruvian-web.vercel.app/archivo.glb',
                      alt: 'A 3D model peru',
                      ar: true,
                      autoRotateDelay: 43,
                      autoRotate: true,
                      cameraControls: true,
                      cameraOrbit: '5deg 10deg 3.8m',
                      minCameraOrbit: 'auto auto auto',
                      maxCameraOrbit: 'auto auto auto',
                      interpolationDecay: 250,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
