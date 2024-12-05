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

class TemaScreen extends StatefulWidget {
  const TemaScreen({super.key});

  @override
  State<TemaScreen> createState() => _TemaScreenState();
}

class _TemaScreenState extends State<TemaScreen>
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
                      FadeIn(child: Inicio()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 60),
                            _buildPBISection(),
                            const SizedBox(height: 60),
                            _buildHistoricalContext(),
                            const SizedBox(height: 60),
                            _buildChallengesSection(),
                            const SizedBox(height: 60),
                            ComentariosSectionGeneral(
                              topic: Topics.economicStructure,
                              title:
                                  'Comentarios sobre la Estructura Económica',
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                      Footer(),
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

  Widget _buildPBISection() {
    return VisibilityDetector(
      key: const Key('pbi-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3) {
          _controller.forward();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Distribución del PBI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'PBI peruano: S/ 563,784,379,000',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
            ),
          ),
          const Text(
            'Fuente: INEI 2023',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildPBICard(
                title: 'Sector Primario',
                percentage: '30%',
                description:
                    'Agricultura, ganadería, pesca, minería y explotación forestal',
                icon: Icons.agriculture,
                color: Colors.green,
              ),
              _buildPBICard(
                title: 'Sector Secundario',
                percentage: '35%',
                description:
                    'Manufactura, construcción y producción de energía',
                icon: Icons.factory,
                color: Colors.blue,
              ),
              _buildPBICard(
                title: 'Sector Terciario',
                percentage: '35%',
                description:
                    'Comercio, transporte, turismo y servicios financieros',
                icon: Icons.business,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 60),
          _buildComparativeCharts(),
        ],
      ),
    );
  }

  Widget _buildComparativeCharts() {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Comparativa Regional vs Nacional',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          isMobile
              ? Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: Colors.green,
                              value: 30,
                              title: '30%',
                              radius: 100,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.blue,
                              value: 35,
                              title: '35%',
                              radius: 100,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.orange,
                              value: 35,
                              title: '35%',
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
                    SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: Colors.green,
                              value: 45,
                              title: '45%',
                              radius: 100,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.blue,
                              value: 25,
                              title: '25%',
                              radius: 100,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.orange,
                              value: 30,
                              title: '30%',
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
                )
              : Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: Colors.green,
                                value: 30,
                                title: '30%',
                                radius: 100,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.blue,
                                value: 35,
                                title: '35%',
                                radius: 100,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.orange,
                                value: 35,
                                title: '35%',
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
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: Colors.green,
                                value: 45,
                                title: '45%',
                                radius: 100,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.blue,
                                value: 25,
                                title: '25%',
                                radius: 100,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.orange,
                                value: 30,
                                title: '30%',
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
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildPBICard({
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
            'Contexto Histórico y Político',
            textAlign: TextAlign.center,
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
                title: 'Independencia',
                year: '1821',
                description:
                    'La independencia de Perú permitió el establecimiento de una economía nacional independiente, facilitando la creación de políticas económicas propias.',
                icon: Icons.flag,
              ),
              _buildHistoryCard(
                title: 'Reforma Agraria',
                year: '1970',
                description:
                    'Las reformas agrarias redistribuyeron las tierras, impactando profundamente la economía rural y la estructura agraria del país.',
                icon: Icons.agriculture,
              ),
              _buildHistoryCard(
                title: 'Políticas Neoliberales',
                year: '1990',
                description:
                    'Las políticas neoliberales promovieron la apertura económica, modernizando la economía peruana e integrándola al mercado global.',
                icon: Icons.trending_up,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String year,
    required String description,
    required IconData icon,
  }) {
    return Container(
      width: 300,
      height: 220,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    year,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ],
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
            'Retos y Oportunidades',
            textAlign: TextAlign.center,
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
                title: 'Retos Nacionales',
                items: [
                  'Dependencia de Recursos Naturales',
                  'Desigualdad y Pobreza',
                  'Crisis Educativa y Salud',
                ],
                color: Colors.red.withOpacity(0.2),
                icon: Icons.warning_rounded,
              ),
              _buildChallengeCard(
                title: 'Oportunidades Nacionales',
                items: [
                  'Reformas Estructurales',
                  'Expansión de la Economía Digital',
                  'Crecimiento en Sectores Clave',
                ],
                color: Colors.green.withOpacity(0.2),
                icon: Icons.trending_up,
              ),
              _buildChallengeCard(
                title: 'Retos Regionales',
                items: [
                  'Cambio Climático y agricultura',
                  'Brechas de Infraestructura',
                  'Acceso a Servicios Básicos',
                ],
                color: Colors.orange.withOpacity(0.2),
                icon: Icons.warning_amber,
              ),
              _buildChallengeCard(
                title: 'Oportunidades Regionales',
                items: [
                  'Impulso a Negocios Sostenibles',
                  'Exportación e Innovación',
                  'Planeamiento Estratégico',
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
      final Uri url = Uri.parse('https://peruvian-web.vercel.app/tema1.pptx');

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
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SelectableText(
                        'Estructura Económica y Desarrollo del País y la Región',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SelectableText(
                        'El estudio de la estructura económica y el desarrollo del país y la región aborda la organización, evolución y distribución de los recursos económicos en el Perú y Huánuco. Este análisis comprende la interacción entre los sectores productivos, las políticas económicas implementadas a lo largo de la historia y su impacto en el desarrollo tanto nacional como regional. Examina además los desafíos actuales y las oportunidades futuras para el crecimiento sostenible',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
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
                            onPressed: downloadFile,
                            child: Text('Descargar Presentación')),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Image.asset(
                      'economia.png',
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
                        SelectableText(
                          'Estructura Económica y Desarrollo del País y la Región',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SelectableText(
                          'El estudio de la estructura económica y el desarrollo del país y la región aborda la organización, evolución y distribución de los recursos económicos en el Perú y Huánuco. Este análisis comprende la interacción entre los sectores productivos, las políticas económicas implementadas a lo largo de la historia y su impacto en el desarrollo tanto nacional como regional. Examina además los desafíos actuales y las oportunidades futuras para el crecimiento sostenible',
                          style: TextStyle(
                            color: Colors.white70,
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
                      'economia.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
