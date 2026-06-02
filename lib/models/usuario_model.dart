class Usuario {
  final String id;
  final String nome;
  final String email;
  final String senha; // Armazenaremos o hash/senha para a validação local

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
  });

  // Converte os dados do Banco (Map) para um Objeto Dart
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String,
    );
  }

  // Converte o Objeto Dart para um formato que o Banco/API entenda (Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }

  // Permite clonar o objeto alterando apenas alguns campos (Essencial para o Riverpod)
  Usuario copyWith({
    String? id,
    String? nome,
    String? email,
    String? senha,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
    );
  }
}