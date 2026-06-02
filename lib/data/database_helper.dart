import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Esta fábrica permite que o sqflite rode no browser
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  // Padrão Singleton: garante uma única instância da classe em todo o ciclo de vida do app
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter que inicializa ou retorna o banco de dados ativo
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('controle_financeiro.db');
    return _database!;
  }

  // --- MÉTODO ATUALIZADO DENTRO DA CLASSE ---
  Future<Database> _initDB(String filePath) async {
    // 1. Verifica se estamos rodando na Web
    if (kIsWeb) {
      // Usa a versão em memória persistente pelo navegador
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ),
      );
    }

    // 2. Comportamento normal para Android/iOS
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Criação das tabelas relacionais espelhando fielmente os Modelos de Dados
  Future _createDB(Database db, int version) async {
    // Tabela de Usuários
    await db.execute('''
      CREATE TABLE usuarios (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL
      )
    ''');

    // Tabela de Transações com Chave Estrangeira lógica relacionada ao Usuário
    await db.execute('''
      CREATE TABLE transacoes (
        id TEXT PRIMARY KEY,
        usuarioId TEXT NOT NULL,
        titulo TEXT NOT NULL,
        valor REAL NOT NULL,
        data TEXT NOT NULL,
        tipo TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Fecha a conexão de forma segura quando necessário
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}