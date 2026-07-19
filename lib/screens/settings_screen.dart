import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.controller,
    super.key,
  });

  final AppController controller;

  Future<void> _editApiKey(BuildContext context) async {
    final textController = TextEditingController(
      text: controller.geminiApiKey,
    );
    bool obscureText = true;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Gemini API key'),
              content: TextField(
                controller: textController,
                obscureText: obscureText,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: 'API key',
                  hintText: 'Paste your Gemini API key',
                  suffixIcon: IconButton(
                    tooltip: obscureText ? 'Show key' : 'Hide key',
                    onPressed: () {
                      setDialogState(() => obscureText = !obscureText);
                    },
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, textController.text);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    textController.dispose();

    if (result == null || !context.mounted) {
      return;
    }

    await controller.setGeminiApiKey(result);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.hasGeminiApiKey
              ? 'Gemini API key saved.'
              : 'Gemini API key removed.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.key_outlined),
                    title: const Text('Gemini API key'),
                    subtitle: Text(
                      controller.hasGeminiApiKey
                          ? 'Configured on this device'
                          : 'Not configured',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _editApiKey(context),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark mode'),
                    value: controller.darkMode,
                    onChanged: controller.setDarkMode,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.flag_outlined),
                    title: const Text('UK vehicles only'),
                    subtitle: const Text(
                      'Use UK registration years and RHD research defaults.',
                    ),
                    value: controller.ukOnly,
                    onChanged: controller.setUkOnly,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Vehicle Key Verifier'),
                subtitle: Text('Version 0.1.0'),
              ),
            ),
          ],
        );
      },
    );
  }
}