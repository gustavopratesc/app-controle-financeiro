import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../viewmodels/transacao_viewmodel.dart';
import 'adicionar_transacao_view.dart';
import '../core/cotacao_provider.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escutando a inteligência financeira que construímos
    final saldo = ref.watch(saldoProvider);
    final transacoesState = ref.watch(transacaoViewModelProvider);
    // Lê o estado da nossa API
    final cotacaoAsync = ref.watch(cotacaoDolarProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Controle Financeiro'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // --- NOVO BOTÃO DE SINCRONIZAÇÃO MANUAL ---
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Sincronizar com a Nuvem',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sincronizando dados...')),
              );

              final syncService = ref.read(sincronizacaoServiceProvider);
              await syncService.sincronizarTransacoesPendentes();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sincronização concluída!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          // --- BOTÃO DE SAIR ORIGINAL ---
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sair',
            onPressed: () {
              ref.read(usuarioLogadoProvider.notifier).logout();
              Navigator.pushReplacementNamed(context, '/'); 
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- HEADER COM O SALDO DINÂMICO E A COTAÇÃO DA API ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                const Text('Saldo Atual', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  // Formatação de moeda simplificada para o visual
                  'R\$ ${saldo.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // --- WIDGET DA API DE COTAÇÃO REPOSICIONADO ---
                cotacaoAsync.when(
                  // 1. ESTADO DE SUCESSO: Mostra a cotação real da API
                  data: (cotacao) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cotacao,
                      style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  // 2. ESTADO DE ERRO: Caso falte internet
                  error: (err, stack) => const Text(
                    'Cotação indisponível (Offline)',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  
                  // 3. ESTADO DE CARREGAMENTO (SKELETON SCREEN)
                  loading: () => Container(
                    width: 150,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3), // Efeito de esqueleto translúcido
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- LISTA DE TRANSAÇÕES REATIVA ---
          Expanded(
            child: transacoesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (erro, stack) => Center(child: Text('Erro ao carregar dados: $erro')),
              data: (transacoes) {
                if (transacoes.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma movimentação ainda.\nClique no botão + para começar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transacoes.length,
                  itemBuilder: (context, index) {
                    final t = transacoes[index];
                    final isReceita = t.tipo == 'receita';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isReceita ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            isReceita ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isReceita ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(t.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(t.data.toIso8601String().split('T')[0]),
                        trailing: Text(
                          'R\$ ${t.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: TextStyle(
                            color: isReceita ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onLongPress: () {
                          ref.read(transacaoViewModelProvider.notifier).remover(t.id);
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
      
      // --- BOTÃO FLUTUANTE PARA NOVA TRANSAÇÃO ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AdicionarTransacaoView(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}