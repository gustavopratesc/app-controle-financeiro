import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/usuario_model.dart';
import '../core/providers.dart';

class AuthViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Estado inicial neutro da ViewModel
  }

  // --- LÓGICA DE LOGIN ---
  Future<bool> login(String email, String senha) async {
    // 1. Avisa a interface que estamos carregando os dados
    state = const AsyncValue.loading(); 
    
    try {
      // 2. Acessa o repositório através da injeção de dependência
      final repo = ref.read(usuarioRepositoryProvider);
      final usuario = await repo.login(email, senha);

      if (usuario != null) {
        // 3. Sucesso! Atualiza o estado global da sessão com o ID do usuário
        ref.read(usuarioLogadoProvider.notifier).login(usuario.id);
        state = const AsyncValue.data(null);
        return true;
      } else {
        // 4. Falha de credenciais
        state = AsyncValue.error('E-mail ou senha inválidos', StackTrace.current);
        return false;
      }
    } catch (e) {
      state = AsyncValue.error('Erro interno ao tentar logar.', StackTrace.current);
      return false;
    }
  }

  // --- LÓGICA DE CADASTRO ---
  Future<bool> cadastrar(String nome, String email, String senha) async {
    state = const AsyncValue.loading();
    
    try {
      final repo = ref.read(usuarioRepositoryProvider);
      
      // Criamos a entidade com um ID universal único (UUID)
      final novoUsuario = Usuario(
        id: const Uuid().v4(),
        nome: nome,
        email: email,
        senha: senha,
      );

      await repo.cadastrar(novoUsuario);
      
      // Já fazemos o login automático logo após o cadastro para uma UX mais fluida
      ref.read(usuarioLogadoProvider.notifier).login(novoUsuario.id);
      state = const AsyncValue.data(null);
      return true;
      
    } catch (e) {
      // O ConflictAlgorithm.fail do SQLite vai cair aqui se o e-mail já existir
      state = AsyncValue.error('Este e-mail já está cadastrado.', StackTrace.current);
      return false;
    }
  }
}

// Provedor que exporta a ViewModel para a camada de Interface (View)
final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, void>(() {
  return AuthViewModel();
});