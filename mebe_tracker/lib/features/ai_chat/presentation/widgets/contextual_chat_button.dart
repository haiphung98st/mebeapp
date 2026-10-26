import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/icons/mebe_icons.dart';
import '../../../../shared/providers/subscription_provider.dart';

class ContextualChatButton extends ConsumerWidget {
  const ContextualChatButton({
    super.key,
    this.prefilledMessage,
  });

  final String? prefilledMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton.extended(
          onPressed: () => context.push(
            '/ai-chat',
            extra: prefilledMessage != null ? {'message': prefilledMessage} : null,
          ),
          backgroundColor: AppColors.blossom,
          foregroundColor: AppColors.white,
          icon: const MeBeIcon(type: MeBeIconType.mascotBunny, size: 18),
          label: const Text('Hỏi AI'),
        ),
        if (!isPremium)
          Positioned(
            top: -4,
            right: -4,
            child: const ClipOval(child: MeBeIcon(type: MeBeIconType.premium, size: 18)),
          ),
      ],
    );
  }
}
