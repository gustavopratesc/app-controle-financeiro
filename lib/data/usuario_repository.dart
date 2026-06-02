import 'package:sqflite/sqflite.dart';
import '../models/usuario_model.dart';
import 'database_helper.dart';

class UsuarioRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // C: CREATE (Cadastro de novo usuário)
  Future<int> cadastrar(Usuario usuario) async {
    final db = await _dbHelper.database;
    
    // O banco lançará uma exceção se tentarmos inserir um e-mail já existente
    // devido à restrição UNIQUE que configuramos na tabela.
    return await db.insert(
      'usuarios',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail, 
    );
  }

  // Lógica de Autenticação (Login)
  Future<Usuario?> login(String email, String senha) async {
    final db = await _dbHelper.database;
    
    // Simula uma requisição de autenticação buscando correspondência exata
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );

    // Se a query retornar algum resultado, as credenciais estão corretas
    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    
    // Retorna nulo caso o e-mail ou a senha estejam incorretos
    return null; 
  }

  // R: READ (Busca os dados do usuário para manter o perfil ativo no Dashboard)
  Future<Usuario?> buscarPorId(String id) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }
}