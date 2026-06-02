import 'package:sqflite/sqflite.dart';
import '../models/transacao_model.dart';
import 'database_helper.dart';

class TransacaoRepository {
  // Puxa a instância única do nosso banco de dados
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // C: CREATE (Inserir)
  Future<int> inserir(Transacao transacao) async {
    final db = await _dbHelper.database;
    // O ConflictAlgorithm.replace garante que, se o ID já existir, ele atualiza
    return await db.insert(
      'transacoes', 
      transacao.toMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // R: READ (Listar por Usuário)
  Future<List<Transacao>> listarPorUsuario(String usuarioId) async {
    final db = await _dbHelper.database;
    
    // Faz a query SQL filtrando pelo ID do dono da transação
    final List<Map<String, dynamic>> maps = await db.query(
      'transacoes',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'data DESC', // Traz as mais recentes primeiro
    );

    // Converte a lista de Maps que o SQLite devolve em uma lista de objetos Transacao
    return maps.map((map) => Transacao.fromMap(map)).toList();
  }

  // U: UPDATE (Atualizar)
  Future<int> atualizar(Transacao transacao) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transacoes',
      transacao.toMap(),
      where: 'id = ?',
      whereArgs: [transacao.id],
    );
  }

  // D: DELETE (Remover)
  Future<int> deletar(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'transacoes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}