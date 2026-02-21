import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../shared/widgets/app_sidebar.dart';

class CriarVideos extends StatefulWidget {
  const CriarVideos({super.key});

  @override
  State<CriarVideos> createState() => _CriarVideosState();
}

class _CriarVideosState extends State<CriarVideos> {
  late Future<List<String>> _pastasFuture;

  @override
  void initState() {
    super.initState();
    _pastasFuture = _carregarPastas();
  }

  Future<List<String>> _carregarPastas() async {
    final jsonStr = await rootBundle.loadString('assets/data/videos.json');
    final Map<String, dynamic> data = jsonDecode(jsonStr);

    // As “pastas” são as chaves do primeiro nível
    return data.keys.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // topo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Criar Vídeos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              // lista de pastas
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _pastasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro ao ler JSON: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final pastas = snapshot.data ?? [];
                    if (pastas.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma pasta encontrada.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pastas.length,
                      itemBuilder: (context, i) {
                        final nome = pastas[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.18)),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.folder_rounded, color: Colors.white),
                            title: Text(
                              nome,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                            onTap: () {
                              // depois a gente abre a pasta e lista os vídeos dentro dela
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}