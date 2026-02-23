import 'package:flutter/material.dart';
import '../../shared/widgets/app_sidebar.dart';
import '../../shared/services/pastas_db.dart';
import 'modal_criar_pasta.dart';

class _PastaItem {
  final String nome;
  final bool visible;
  const _PastaItem({required this.nome, required this.visible});
}

class CriarTreinamento extends StatefulWidget {
  const CriarTreinamento({super.key});

  @override
  State<CriarTreinamento> createState() => _CriarTreinamentoState();
}

class _CriarTreinamentoState extends State<CriarTreinamento> {
  late Future<List<_PastaItem>> _pastasFuture;

  @override
  void initState() {
    super.initState();
    _pastasFuture = _carregarPastas();
  }

  Future<List<_PastaItem>> _carregarPastas() async {
    final bd = PastasBb();
    final Map<String, dynamic> data = await bd.readAll();

    final itens = <_PastaItem>[];

    for (final nome in data.keys) {
      final pasta = data[nome];

      bool visible = true; // default

      // Se já for um Map com metadados
      if (pasta is Map<String, dynamic>) {
        final v = pasta['_visible'];
        if (v is bool) visible = v;
      }

      itens.add(_PastaItem(nome: nome, visible: visible));
    }

    itens.sort((a, b) => a.nome.compareTo(b.nome));
    return itens;
  }

  Future<void> _reload() async {
    setState(() {
      _pastasFuture = _carregarPastas();
    });
  }

  /// Garante que a pasta esteja no formato:
  /// { "_visible": bool, "videos": {...} }
  Map<String, dynamic> _normalizePasta(dynamic pastaAtual) {
    // Caso já esteja no formato novo
    if (pastaAtual is Map<String, dynamic> && pastaAtual.containsKey('videos')) {
      return {
        '_visible': (pastaAtual['_visible'] is bool) ? pastaAtual['_visible'] : true,
        'videos': (pastaAtual['videos'] is Map<String, dynamic>) ? pastaAtual['videos'] : <String, dynamic>{},
      };
    }

    // Caso antigo: { "Titulo": "url" }
    if (pastaAtual is Map<String, dynamic>) {
      return {
        '_visible': true,
        'videos': Map<String, dynamic>.from(pastaAtual),
      };
    }

    // Caso venha estranho
    return {
      '_visible': true,
      'videos': <String, dynamic>{},
    };
  }

  Future<void> _toggleVisibilidade(String nome) async {
    final bd = PastasBb();
    final Map<String, dynamic> data = await bd.readAll();

    final atual = _normalizePasta(data[nome]);
    final bool vis = (atual['_visible'] as bool?) ?? true;

    atual['_visible'] = !vis;
    data[nome] = atual;

    await bd.writeAll(data);

    await _reload();
  }

  Future<void> _deletarPasta(String nome) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar pasta?'),
        content: Text('Tem certeza que deseja apagar "$nome"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Apagar')),
        ],
      ),
    );

    if (ok != true) return;

    final bd = PastasBb();
    final Map<String, dynamic> data = await bd.readAll();

    data.remove(nome);

    await bd.writeAll(data);

    await _reload();
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
                      'Criar Treinamento',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: FutureBuilder<List<_PastaItem>>(
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

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: pastas.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _GridCard(
                            icon: Icons.create_new_folder_rounded,
                            title: 'Criar pasta',
                            onTap: () => {
                                showCreateFolderModal(context),
                            }

                          );
                        }

                        final pasta = pastas[index - 1];

                        return _GridCard(
                          icon: Icons.folder_rounded,
                          title: pasta.nome,
                          onTap: () {
                            // aqui você abre a pasta, lista vídeos etc
                          },
                          showActions: true,
                          isVisible: pasta.visible,
                          onToggleVisible: () => _toggleVisibilidade(pasta.nome),
                          onDelete: () => _deletarPasta(pasta.nome),
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

  // ações (opcionais)
  final bool showActions;
  final bool isVisible;
  final VoidCallback? onToggleVisible;
  final VoidCallback? onDelete;

  const _GridCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showActions = false,
    this.isVisible = true,
    this.onToggleVisible,
    this.onDelete,
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
        child: Stack(
          children: [
            // conteúdo central
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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

            // ações no topo direito
            if (showActions)
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      tooltip: isVisible ? 'Deixar invisível' : 'Deixar visível',
                      icon: Icon(
                        isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: onToggleVisible,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      tooltip: 'Apagar pasta',
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}