import 'dashboard_view.dart';
import 'cadastro_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_viewmodel.dart';

// O ConsumerStatefulWidget é a ponte que permite à View "escutar" os Providers
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  // A chave global é obrigatória para acessar o estado do formulário e validá-lo
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para capturar o texto digitado
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Limpeza de memória, prática fundamental de arquitetura
  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Acionado ao clicar no botão Entrar
  void _fazerLogin() async {
    // 1. O FormState roda os métodos "validator" de cada campo da tela
    if (_formKey.currentState!.validate()) {
      
      // 2. Chama a ViewModel enviando os dados limpos (trim remove espaços em branco)
      final viewModel = ref.read(authViewModelProvider.notifier);
      final sucesso = await viewModel.login(
        _emailController.text.trim(),
        _senhaController.text.trim(),
      );

      // 3. Se deu certo, futuramente direcionamos para o Dashboard.
      if (sucesso && mounted) {
        // Removemos o SnackBar e colocamos a navegação real
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardView()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escutando o estado atual da autenticação (loading, data ou error)
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    // ref.listen fica ouvindo mudanças invisíveis. Ideal para mostrar SnackBars de erro!
    ref.listen<AsyncValue<void>>(authViewModelProvider, (anterior, proximo) {
      proximo.whenOrNull(
        error: (erro, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(erro.toString()), backgroundColor: Colors.red),
          );
        },
      );
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Conecta a chave ao formulário
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.account_balance_wallet, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 24),
                const Text(
                  'Bem-vindo(a)',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // --- CAMPO DE E-MAIL ---
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe o e-mail';
                    if (!value.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // --- CAMPO DE SENHA ---
                TextFormField(
                  controller: _senhaController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true, // Esconde a senha
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe a senha';
                    if (value.length < 4) return 'A senha deve ter no mínimo 4 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // --- BOTÃO DE LOGIN ---
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  // Trava o botão enviando 'null' para o onPressed se estiver carregando
                  onPressed: isLoading ? null : _fazerLogin,
                  child: isLoading
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text('ENTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                
                // --- NAVEGAÇÃO PARA CADASTRO ---
                TextButton(
                  onPressed: isLoading ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CadastroView()),
                    );
                  },
                  child: const Text('Não tem uma conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}