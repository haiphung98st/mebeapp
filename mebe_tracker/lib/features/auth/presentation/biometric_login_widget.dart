import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/services/biometric_service.dart';
import '../../../shared/services/credential_service.dart';

class BiometricLoginWidget extends ConsumerWidget {
  const BiometricLoginWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricService = ref.read(biometricServiceProvider);
    final credentialService = ref.read(credentialServiceProvider);

    return FutureBuilder<List<bool>>(
      future: Future.wait([
        biometricService.isAvailable(),
        biometricService.isBiometricEnabled(),
        credentialService.hasSavedCredentials(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final results = snapshot.data!;
        final isAvailable = results[0];
        final isEnabled = results[1];
        final hasCreds = results[2];
        if (!isAvailable || !isEnabled || !hasCreds) {
          return const SizedBox.shrink();
        }
        return _BiometricButton(
          biometricService: biometricService,
          credentialService: credentialService,
        );
      },
    );
  }
}

class _BiometricButton extends ConsumerWidget {
  const _BiometricButton({
    required this.biometricService,
    required this.credentialService,
  });

  final BiometricService biometricService;
  final CredentialService credentialService;

  Future<void> _doAuth(BuildContext context, WidgetRef ref, String name) async {
    final success = await biometricService.authenticate(
      reason: 'Xác thực để đăng nhập vào MeBé',
    );
    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name không thành công. Thử lại nhé.')),
        );
      }
      return;
    }
    final creds = await credentialService.loadCredentials();
    if (creds?.email == null || creds?.password == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần đăng nhập bằng email/mật khẩu lần đầu tiên nhé.'),
          ),
        );
      }
      return;
    }
    await ref.read(authRepositoryProvider).signInWithEmail(
          creds!.email!,
          creds.password!,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: biometricService.getBiometricName(),
      builder: (context, nameSnap) {
        final name = nameSnap.data ?? 'Sinh trắc học';
        final icon = name == 'Face ID'
            ? Icons.face_retouching_natural
            : Icons.fingerprint;

        return Column(
          children: [
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'hoặc',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(icon, size: 22),
                label: Text('Đăng nhập bằng $name'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.blossom),
                  foregroundColor: AppColors.blossom,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
                onPressed: () => _doAuth(context, ref, name),
              ),
            ),
          ],
        );
      },
    );
  }
}
