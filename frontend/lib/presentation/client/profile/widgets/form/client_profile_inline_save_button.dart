import 'package:flutter/material.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class ClientProfileInlineSaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback? onSave;

  const ClientProfileInlineSaveButton({
    super.key,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ClientActionButton(
      label: 'Guardar perfil',
      loadingLabel: 'Guardando...',
      icon: Icons.save_rounded,
      isLoading: isSaving,
      onPressed: onSave,
    );
  }
}