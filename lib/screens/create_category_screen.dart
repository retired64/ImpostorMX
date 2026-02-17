/*
 * Impostor MX - Juego de fiesta libre y gratuito
 * Copyright (C) 2026 Retired64 
 *
 * Este programa es software libre: puedes redistribuirlo y/o modificarlo
 * bajo los términos de la Licencia Pública General GNU publicada por
 * la Free Software Foundation, ya sea la versión 3 de la Licencia, o
 * (a tu elección) cualquier versión posterior.
 *
 * Este programa se distribuye con la esperanza de que sea útil,
 * pero SIN NINGUNA GARANTÍA; sin siquiera la garantía implícita de
 * COMERCIABILIDAD o APTITUD PARA UN PROPÓSITO PARTICULAR. Consulta la
 * Licencia Pública General GNU para más detalles.
 *
 * Deberías haber recibido una copia de la Licencia Pública General GNU
 * junto con este programa. Si no es así, consulta <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/language_provider.dart'; // Importamos el LanguageProvider
import '../widgets/common.dart';
import '../widgets/inputs.dart';
import '../config/theme.dart';
import '../words.dart';

class CreateCategoryScreen extends StatefulWidget {
  final Category? categoryToEdit;
  const CreateCategoryScreen({super.key, this.categoryToEdit});
  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _nameCtrl = TextEditingController();
  final _emojiCtrl = TextEditingController();
  List<TextEditingController> _wordControllers = [];
  Color _selectedColor = Colors.purple;

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameCtrl.text = widget.categoryToEdit!.name;
      _emojiCtrl.text = widget.categoryToEdit!.icon;
      _selectedColor = widget.categoryToEdit!.color;
      for (var w in widget.categoryToEdit!.words)
        _wordControllers.add(TextEditingController(text: w));
    } else {
      for (int i = 0; i < 5; i++) _wordControllers.add(TextEditingController());
    }
  }

  void _save() {
    if (_nameCtrl.text.isEmpty) return;

    final validWords = _wordControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (validWords.length < 5) {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('create_min_words')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final newCat = Category(
      id: widget.categoryToEdit?.id ?? DateTime.now().toString(),
      name: _nameCtrl.text,
      icon: _emojiCtrl.text.isEmpty ? '✨' : _emojiCtrl.text,
      words: validWords,
      color: _selectedColor,
    );

    final p = Provider.of<GameProvider>(context, listen: false);
    widget.categoryToEdit != null
        ? p.saveCustomCategory(newCat, isEdit: true)
        : p.saveCustomCategory(newCat);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: GameBackground(
        child: Column(
          children: [
            GameNavBar(
              title: widget.categoryToEdit != null
                  ? lang.translate('create_title_edit')
                  : lang.translate('create_title_new'),
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GameCard(
                      child: Column(
                        children: [
                          MinimalInput(
                            controller: _nameCtrl,
                            hint: lang.translate('create_input_name'),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: MinimalInput(
                                  controller: _emojiCtrl,
                                  hint: lang.translate('create_input_emoji'),
                                  maxLength: 2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children:
                                        [
                                              Colors.purple,
                                              Colors.pink,
                                              Colors.blue,
                                              Colors.orange,
                                              Colors.green,
                                            ]
                                            .map(
                                              (c) => GestureDetector(
                                                onTap: () => setState(
                                                  () => _selectedColor = c,
                                                ),
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                    right: 8,
                                                  ),
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                    color: c,
                                                    shape: BoxShape.circle,
                                                    border: _selectedColor == c
                                                        ? Border.all(
                                                            color: Colors.white,
                                                            width: 2,
                                                          )
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang.translate('create_words_title'),
                          style: AppTheme.heading(18),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppColors.accent,
                          ),
                          onPressed: () => setState(
                            () => _wordControllers.add(TextEditingController()),
                          ),
                        ),
                      ],
                    ),
                    ..._wordControllers.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              "${e.key + 1}.",
                              style: const TextStyle(color: Colors.white30),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MinimalInput(
                                controller: e.value,
                                hint: lang.translate('create_input_word'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white24,
                                size: 16,
                              ),
                              onPressed: () => setState(() {
                                e.value.dispose();
                                _wordControllers.removeAt(e.key);
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: BouncyButton(
                text: lang.translate('create_btn_save'),
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
