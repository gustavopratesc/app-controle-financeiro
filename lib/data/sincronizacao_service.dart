import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transacao_model.dart';
import 'database_helper.dart';

class SincronizacaoService {
  final _supabase = Supabase.instance.client;
  final _dbHelper = DatabaseHelper.instance;

  Future<void> sincronizarTransacoesPendentes() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'transacoes',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    if (maps.isEmpty) {
      print('Nenhuma transação pendente de sincronização.');
      return; 
    }

    final transacoesPendentes = maps.map((map) => Transacao.fromMap(map)).toList();

    for (var transacao in transacoesPendentes) {
      try {
        final dadosParaNuvem = {
          'id': transacao.id,
          'usuarioId': transacao.usuarioId, 
          'titulo': transacao.titulo,
          'valor': transacao.valor,
          'data': transacao.data.toIso8601String(),
          'tipo': transacao.tipo,
        };

        await _supabase.from('transacoes').insert(dadosParaNuvem);

        await db.update(
          'transacoes',
          {'isSynced': 1}, 
          where: 'id = ?',
          whereArgs: [transacao.id],
        );

        print('Transação ${transacao.titulo} sincronizada com sucesso!');
        
      } catch (e) {
        print('Falha ao sincronizar a transação ${transacao.id}: $e');
      }
    }
  }

  // --- REMOVER DA NUVEM ---
  Future<void> deletarNaNuvem(String id) async {
    try {
      await _supabase.from('transacoes').delete().eq('id', id);
      print('Transação de ID $id removida da nuvem com sucesso.');
    } catch (e) {
      print('Falha ao deletar transação na nuvem: $e');
    }
  }
}