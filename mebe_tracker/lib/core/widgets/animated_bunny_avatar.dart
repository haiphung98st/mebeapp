import 'package:flutter/material.dart';

import 'bunny_avatar.dart';
import '../../features/profile/data/avatar_config.dart';

class AnimatedBunnyAvatar extends StatefulWidget {
  const AnimatedBunnyAvatar({
    super.key,
    required this.config,
    this.size = 100,
    this.isAsleep = false,
  });

  final AvatarConfig config;
  final double size;
  final bool isAsleep;

  @override
  State<AnimatedBunnyAvatar> createState() => _AnimatedBunnyAvatarState();
}

class _AnimatedBunnyAvatarState extends State<AnimatedBunnyAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _breathe = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathe,
      builder: (_, child) => Transform.scale(
        scale: _breathe.value,
        child: child,
      ),
      child: BunnyAvatar(
        size: widget.size,
        isAsleep: widget.isAsleep,
        primaryColor: widget.config.headColor,
        earColor: widget.config.earColor,
        eyeColor: widget.config.eyeColor,
        noseColor: widget.config.noseColor,
        cheekColor: widget.config.cheekColor,
      ),
    );
  }
}
