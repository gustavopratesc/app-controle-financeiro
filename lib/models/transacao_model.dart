class Transacao {
  final String id;
  final String usuarioId; // Relacionamento com o dono da transação
  final String titulo;
  final double valor;
  final DateTime data;
  final String tipo; // 'receita' ou 'despesa'
  final int isSynced; // 0 para falso (não sincronizado), 1 para verdadeiro

  Transacao({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.valor,
    required this.data,
    required this.tipo,
    this.isSynced = 0, // Por padrão, toda nova transação nasce não sincronizada
  });

  factory Transacao.fromMap(Map<String, dynamic> map) {
    return Transacao(
      id: map['id'] as String,
      usuarioId: map['usuarioId'] as String,
      titulo: map['titulo'] as String,
      valor: (map['valor'] as num).toDouble(),
      data: DateTime.parse(map['data'] as String), // O SQLite guarda datas como String (ISO 8601)
      tipo: map['tipo'] as String,
      isSynced: map['isSynced'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'titulo': titulo,
      'valor': valor,
      'data': data.toIso8601String(), // Convertendo DateTime para formato de banco
      'tipo': tipo,
      'isSynced': isSynced,
    };
  }

  Transacao copyWith({
    String? id,
    String? usuarioId,
    String? titulo,
    double? valor,
    DateTime? data,
    String? tipo,
    int? isSynced,
  }) {
    return Transacao(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      tipo: tipo ?? this.tipo,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}