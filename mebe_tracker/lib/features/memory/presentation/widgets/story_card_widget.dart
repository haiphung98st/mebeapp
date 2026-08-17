import 'package:flutter/material.dart';

import '../../../../shared/models/story_card.dart';

class StoryCardWidget extends StatelessWidget {
  const StoryCardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.onShare,
    this.compact = false,
  });

  final StoryCard card;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final bool compact;

  static const _themes = {
    'blossom': _ThemeColors(
      bg: Color(0xFFFFE4EF),
      accent: Color(0xFFF472A0),
      soft: Color(0xFFFFB7CE),
      text: Color(0xFF8B2252),
    ),
    'lavender': _ThemeColors(
      bg: Color(0xFFF0E8FF),
      accent: Color(0xFFA67CD8),
      soft: Color(0xFFC9A8F5),
      text: Color(0xFF5E3A8C),
    ),
    'mint': _ThemeColors(
      bg: Color(0xFFDFFAF2),
      accent: Color(0xFF34A880),
      soft: Color(0xFF7DE8C8),
      text: Color(0xFF1A6B52),
    ),
    'gold': _ThemeColors(
      bg: Color(0xFFFFF8E1),
      accent: Color(0xFFD4A017),
      soft: Color(0xFFFFD700),
      text: Color(0xFF7A5B00),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final t = _themes[card.theme] ?? _themes['blossom']!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: t.accent.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardTop(t: t, card: card, compact: compact),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                compact ? 8 : 12,
                16,
                compact ? 4 : 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.titleVi,
                    style: TextStyle(
                      fontSize: compact ? 13 : 16,
                      fontWeight: FontWeight.w900,
                      color: t.text,
                      height: 1.2,
                    ),
                  ),
                  if (!compact && card.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      card.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: t.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  Divider(color: t.soft, thickness: 1, height: compact ? 12 : 16),
                  Text(
                    card.contentVi,
                    style: TextStyle(
                      fontSize: compact ? 11 : 13,
                      color: t.text.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                    maxLines: compact ? 2 : null,
                    overflow: compact ? TextOverflow.ellipsis : TextOverflow.visible,
                  ),
                ],
              ),
            ),
            _CardFooter(t: t, card: card, onShare: onShare, compact: compact),
          ],
        ),
      ),
    );
  }
}

class _ThemeColors {
  const _ThemeColors({
    required this.bg,
    required this.accent,
    required this.soft,
    required this.text,
  });

  final Color bg;
  final Color accent;
  final Color soft;
  final Color text;
}

class _CardTop extends StatelessWidget {
  const _CardTop({required this.t, required this.card, required this.compact});

  final _ThemeColors t;
  final StoryCard card;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 56 : 80,
      decoration: BoxDecoration(
        color: t.soft.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -12,
            top: -12,
            child: Container(
              width: compact ? 56 : 80,
              height: compact ? 56 : 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.soft.withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -20,
            child: Container(
              width: compact ? 36 : 48,
              height: compact ? 36 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.accent.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Bunny mascot
          Positioned(
            right: compact ? 10 : 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                '🐰',
                style: TextStyle(fontSize: compact ? 24 : 36),
              ),
            ),
          ),
          // Date chip
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: t.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${card.cardDate.day}/${card.cardDate.month}/${card.cardDate.year}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({
    required this.t,
    required this.card,
    required this.onShare,
    required this.compact,
  });

  final _ThemeColors t;
  final StoryCard card;
  final VoidCallback? onShare;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 8, compact ? 4 : 8),
      child: Row(
        children: [
          Text(
            'MeBé ✨',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: t.accent.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          if (onShare != null && !compact)
            IconButton(
              icon: Icon(Icons.share_rounded, size: 18, color: t.accent),
              onPressed: onShare,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
        ],
      ),
    );
  }
}
