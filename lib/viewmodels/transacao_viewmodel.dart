import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transacao_model.dart';
import '../core/providers.dart';

// O AsyncNotifier gerencia o estado de uma Lista de Transações
class TransacaoViewModel extends AsyncNotifier<List<Transacao>> {
  
  @override
  FutureOr<List<Transacao>> build() async {
    final usuarioId = ref.watch(usuarioLogadoProvider);
    if (usuarioId == null) return [];

    final repo = ref.read(transacaoRepositoryProvider);
    return await repo.listarPorUsuario(usuarioId);
  }

  // --- REGRA DE NEGÓCIO: ADICIONAR ---
  Future<void> adicionar(String titulo, double valor, String tipo, DateTime data) async {
    final usuarioId = ref.read(usuarioLogadoProvider);
    if (usuarioId == null) return;

    final novaTransacao = Transacao(
      id: const Uuid().v4(),
      usuarioId: usuarioId,
      titulo: titulo,
      valor: valor,
      data: data,
      tipo: tipo.toLowerCase(), 
    );

    final repo = ref.read(transacaoRepositoryProvider);
    await repo.inserir(novaTransacao);

    // Atualiza a tela instantaneamente
    ref.invalidateSelf();

    // Sincroniza com a nuvem automaticamente nos bastidores
    ref.read(sincronizacaoServiceProvider).sincronizarTransacoesPendentes();
  }

  // --- REGRA DE NEGÓCIO: REMOVER ---
  Future<void> remover(String id) async {
    // 1. Remove do SQLite local imediatamente
    final repo = ref.read(transacaoRepositoryProvider);
    await repo.deletar(id);
    
    // 2. Atualiza a interface em tempo real
    ref.invalidateSelf();

    // 3. Dispara a remoção na nuvem nos bastidores
    ref.read(sincronizacaoServiceProvider).deletarNaNuvem(id);
  }
}

// Provedor que exporta a ViewModel para a View
final transacaoViewModelProvider = AsyncNotifierProvider<TransacaoViewModel, List<Transacao>>(() {
  return TransacaoViewModel();
});

// --- CÁLCULO DE SALDO AUTOMÁTICO ---
final saldoProvider = Provider<double>((ref) {
  final transacoesState = ref.watch(transacaoViewModelProvider);

  return transacoesState.maybeWhen(
    data: (transacoes) {
      double saldo = 0.0;
      for (var t in transacoes) {
        if (t.tipo == 'receita') {
          saldo += t.valor;
        } else {
          saldo -= t.valor;
        }
      }
      return saldo;
    },
    orElse: () => 0.0, 
  );
});