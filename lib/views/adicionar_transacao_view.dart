import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/transacao_viewmodel.dart';

class AdicionarTransacaoView extends ConsumerStatefulWidget {
  const AdicionarTransacaoView({super.key});

  @override
  ConsumerState<AdicionarTransacaoView> createState() => _AdicionarTransacaoViewState();
}

class _AdicionarTransacaoViewState extends ConsumerState<AdicionarTransacaoView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _valorController = TextEditingController();
  
  // O tipo padrão começa como 'despesa' (comportamento mais comum do usuário)
  String _tipoSelecionado = 'despesa'; 

  @override
  void dispose() {
    _tituloController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      // 1. Substitui vírgulas por pontos e converte para double com segurança
      final valorTexto = _valorController.text.replaceAll(',', '.');
      final valor = double.tryParse(valorTexto) ?? 0.0;

      // 2. Chama a ViewModel para injetar no banco de dados
      ref.read(transacaoViewModelProvider.notifier).adicionar(
        _tituloController.text.trim(),
        valor,
        _tipoSelecionado,
        DateTime.now(), // Usa a data e hora exatas da transação
      );

      // 3. Recolhe a janela deslizante de volta para baixo
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos MediaQuery para o formulário subir junto com o teclado do celular
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ocupa apenas o espaço necessário
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nova Transação',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // --- CAMPO: TÍTULO ---
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título (Ex: Conta de Luz, Salário)'),
              validator: (value) => value == null || value.isEmpty ? 'Informe o título' : null,
            ),
            const SizedBox(height: 16),

            // --- CAMPO: VALOR ---
            TextFormField(
              controller: _valorController,
              decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: 'R\$ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe o valor';
                if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- SELETOR: RECEITA / DESPESA ---
            DropdownButtonFormField<String>(
              value: _tipoSelecionado,
              decoration: const InputDecoration(labelText: 'Tipo de Movimentação'),
              items: const [
                DropdownMenuItem(value: 'receita', child: Text('Receita (+)')),
                DropdownMenuItem(value: 'despesa', child: Text('Despesa (-)')),
              ],
              onChanged: (String? novoValor) {
                if (novoValor != null) {
                  setState(() => _tipoSelecionado = novoValor);
                }
              },
            ),
            const SizedBox(height: 32),

            // --- BOTÃO: SALVAR ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: _salvar,
              child: const Text('ADICIONAR', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24), // Espaçamento extra para a base do celular
          ],
        ),
      ),
    );
  }
}