import '../data/sincronizacao_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transacao_repository.dart';
import '../data/usuario_repository.dart';

// --- CAMADA DE REPOSITÓRIOS ---

final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  return UsuarioRepository();
});

final transacaoRepositoryProvider = Provider<TransacaoRepository>((ref) {
  return TransacaoRepository();
});


// --- ESTADO GERAL DA APLICAÇÃO (PADRÃO MODERNO) ---

// Criamos uma classe controladora para o estado do usuário logado.
// Isso protege o dado e cria métodos claros de login e logout.
class UsuarioLogadoNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null; // Estado inicial: ninguém logado
  }

  void login(String id) {
    state = id;
  }

  void logout() {
    state = null;
  }
}

// Injetamos a classe no Riverpod usando o novo NotifierProvider
final usuarioLogadoProvider = NotifierProvider<UsuarioLogadoNotifier, String?>(() {
  return UsuarioLogadoNotifier();
});

final sincronizacaoServiceProvider = Provider<SincronizacaoService>((ref) {
  return SincronizacaoService();
});