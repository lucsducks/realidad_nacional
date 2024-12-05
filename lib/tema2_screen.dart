import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:realidadnacional/comentarios_section.dart';
import 'package:realidadnacional/home_screen.dart';
import 'package:realidadnacional/topics.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:html' as html; // Importamos dart:html para manejo web

class TemaDescentralizacionScreen extends StatefulWidget {
  const TemaDescentralizacionScreen({super.key});

  @override
  State<TemaDescentralizacionScreen> createState() =>
      _TemaDescentralizacionScreenState();
}

class _TemaDescentralizacionScreenState
    extends State<TemaDescentralizacionScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.dispose();
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

  @override
  Widget build(BuildContext context) {
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
              color: const Color.fromARGB(255, 1, 10, 25).withOpacity(0.8),
            ),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              slivers: [
                CustomSliverAppBar(isScrolled: _isScrolled),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      FadeIn(child: const Inicio()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 60),
                            _buildCentralizacionStats(),
                            const SizedBox(height: 60),
                            _buildHistoricalContext(),
                            const SizedBox(height: 60),
                            _buildObjectives(),
                            const SizedBox(height: 60),
                            _buildChallengesSection(),
                            const SizedBox(height: 60),
                            ComentariosSectionGeneral(
                              topic: Topics.decentralizationProcess,
                              title:
                                  'Comentarios sobre el Proceso de Descentralización',
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                      const Footer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sección de estadísticas de centralización
  Widget _buildCentralizacionStats() {
    return VisibilityDetector(
      key: const Key('centralization-stats'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3) {
          _controller.forward();
        }
      },
      child: Column(
        children: [
          const Text(
            'Impacto de la Centralización',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildStatCard(
                title: 'Concentración Poblacional',
                percentage: '40%',
                description: 'de la población en solo 9 ciudades',
                icon: Icons.people,
                color: Colors.blue,
              ),
              _buildStatCard(
                title: 'Concentración Económica',
                percentage: '66%',
                description: 'del PBI en 5 departamentos',
                icon: Icons.monetization_on,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Concentración Electoral',
                percentage: '52%',
                description: 'de electores en 10 provincias',
                icon: Icons.how_to_vote,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildComparativeCharts(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String percentage,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 300,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            percentage,
            style: TextStyle(
              color: color,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparativeCharts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Distribución de Recursos por Regiones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.blue,
                    value: 40,
                    title: 'Lima',
                    radius: 100,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: 35,
                    title: 'Otras regiones costeras',
                    radius: 100,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.orange,
                    value: 25,
                    title: 'Sierra y Selva',
                    radius: 100,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sección de contexto histórico
  Widget _buildHistoricalContext() {
    return VisibilityDetector(
      key: const Key('historical-context'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3) {
          _controller.forward();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Contexto Histórico',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildHistoryCard(
                title: 'Sistema Incaico',
                description:
                    'El centralismo tiene raíces históricas desde el imperio incaico, donde el poder se concentraba en el Cusco.',
                icon: Icons.architecture,
              ),
              _buildHistoryCard(
                title: 'Periodo Colonial',
                description:
                    'Durante el virreinato, Lima se convirtió en el centro administrativo y económico, fortaleciendo el centralismo.',
                icon: Icons.castle,
              ),
              _buildHistoryCard(
                title: 'República',
                description:
                    'Las políticas republicanas mantuvieron y profundizaron el centralismo, concentrando recursos en la capital.',
                icon: Icons.account_balance,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      width: 300,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 30),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Sección de objetivos
  Widget _buildObjectives() {
    return VisibilityDetector(
      key: const Key('objectives'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3) {
          _controller.forward();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Objetivos de la Descentralización',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildObjectiveCard(
                title: 'Transferencia de Competencias',
                description:
                    'Distribuir responsabilidades y competencias a gobiernos regionales y locales.',
                icon: Icons.transform,
                color: Colors.blue.withOpacity(0.2),
              ),
              _buildObjectiveCard(
                title: 'Distribución de Recursos',
                description:
                    'Asignar recursos de manera equitativa para un desarrollo regional equilibrado.',
                icon: Icons.account_balance_wallet,
                color: Colors.green.withOpacity(0.2),
              ),
              _buildObjectiveCard(
                title: 'Participación Ciudadana',
                description:
                    'Promover la participación activa de la ciudadanía en la gestión pública.',
                icon: Icons.people,
                color: Colors.orange.withOpacity(0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 300,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
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
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Sección de desafíos
  Widget _buildChallengesSection() {
    return VisibilityDetector(
      key: const Key('challenges'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3) {
          _controller.forward();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Desafíos y Limitaciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildChallengeCard(
                title: 'Gestión y Servicios',
                items: [
                  'Planificación de nuevos puntos de servicio',
                  'Equilibrio entre costos y disponibilidad',
                  'Capacidad administrativa limitada',
                ],
                color: Colors.red.withOpacity(0.2),
                icon: Icons.warning_rounded,
              ),
              _buildChallengeCard(
                title: 'Infraestructura',
                items: [
                  'Limitaciones en recursos físicos',
                  'Falta de conectividad',
                  'Mantenimiento deficiente',
                ],
                color: Colors.orange.withOpacity(0.2),
                icon: Icons.build,
              ),
              _buildChallengeCard(
                title: 'Política',
                items: [
                  'Inestabilidad política actual',
                  'Falta de continuidad en proyectos',
                  'Resistencia al cambio',
                ],
                color: Colors.orange.withOpacity(0.2),
                icon: Icons.policy,
              ),
              _buildChallengeCard(
                title: 'Reformas Necesarias',
                items: [
                  'Clarificación de responsabilidades',
                  'Nuevo sistema de ingresos',
                  'Fortalecimiento de capacidades',
                ],
                color: Colors.blue.withOpacity(0.2),
                icon: Icons.lightbulb,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard({
    required String title,
    required List<String> items,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 300,
      height: 230,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
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
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.arrow_right,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
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
    Future<void> downloadFile() async {
      final Uri url = Uri.parse('https://peruvian-web.vercel.app/tema2.pptx');

      if (kIsWeb) {
        // Para web
        if (!await launchUrl(url, webOnlyWindowName: '_blank')) {
          throw Exception('No se pudo abrir $url');
        }
      } else {
        if (!await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        )) {
          throw Exception('No se pudo abrir $url');
        }
      }
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: isMobile
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SelectableText(
                        'Proceso de Descentralización en el Perú',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SelectableText(
                        'La descentralización en el Perú representa un proceso fundamental de reorganización política y administrativa que busca distribuir el poder, los recursos y las responsabilidades desde el gobierno central hacia las regiones y localidades. Este proceso, iniciado formalmente en 2002, ha transformado significativamente la gestión pública, enfrentando tanto logros como desafíos en su implementación.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(10),
                        height: 60,
                        width: 300,
                        child: FilledButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                            ),
                            onPressed: () => downloadFile,
                            child: Text('Descargar Presentación')),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Image.asset(
                      'des.png',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SelectableText(
                          'Proceso de Descentralización en el Perú',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SelectableText(
                          'La descentralización en el Perú representa un proceso fundamental de reorganización política y administrativa que busca distribuir el poder, los recursos y las responsabilidades desde el gobierno central hacia las regiones y localidades. Este proceso, iniciado formalmente en 2002, ha transformado significativamente la gestión pública, enfrentando tanto logros como desafíos en su implementación.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(10),
                          height: 60,
                          width: 300,
                          child: FilledButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                              ),
                              onPressed: () {
                                downloadFile();
                              },
                              child: Text('Descargar Presentación')),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Image.asset(
                      'des.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
