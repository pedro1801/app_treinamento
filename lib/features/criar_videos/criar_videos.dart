import 'package:flutter/material.dart';
import '../../shared/widgets/app_sidebar.dart';
import '../../shared/services/videos_db.dart';
import '../criar_videos/modal_criar_pasta.dart';

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
    final bd = VideosDb();
    final jsonStr = await bd.readAll();
    final Map<String, dynamic> data = jsonStr;

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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

              // grid de pastas + botão criar
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _pastasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
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

                    // agora mesmo se não tiver pastas, a grid ainda mostra o botão "Criar pasta"
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 quadrados por linha
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0, // quadrado
                          ),
                      itemCount:
                          pastas.length + 1, // +1 por causa do "Criar pasta"
                      itemBuilder: (context, index) {
                        // primeiro item: criar pasta
                        if (index == 0) {
                          return _GridCard(
                            icon: Icons.create_new_folder_rounded,
                            title: 'Criar pasta',
                            onTap: () {
                              showCreateFolderModal(context);
                            },
                          );
                        }

                        // demais itens: pastas do JSON
                        final nome = pastas[index - 1];

                        return _GridCard(
                          icon: Icons.folder_rounded,
                          title: nome,
                          onTap: () {
                          },
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

class _GridCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _GridCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
