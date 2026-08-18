import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart' show Share;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

/// Shared reader screen for legal documents (terms, privacy, disclaimer).
/// Renders [markdownContent] with a consistent style, a "last updated" bar,
/// and a share action.
class LegalTextScreen extends StatelessWidget {
  const LegalTextScreen({
    super.key,
    required this.title,
    required this.markdownContent,
    required this.lastUpdated,
    this.accentColor = AppColors.blossom,
  });

  final String title;
  final String markdownContent;
  final String lastUpdated;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.powder,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Chia sẻ',
            onPressed: () => Share.share('$title\n\n$markdownContent'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            color: accentColor.withValues(alpha: 0.08),
            child: Row(
              children: [
                Icon(Icons.update, size: 14, color: accentColor),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Cập nhật lần cuối: $lastUpdated',
                  style: AppTextStyles.bodySm.copyWith(color: accentColor),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.cream,
              child: Markdown(
                data: markdownContent,
                padding: const EdgeInsets.all(AppSpacing.lg),
                styleSheet: MarkdownStyleSheet(
                  h1: AppTextStyles.headingLg,
                  h2: AppTextStyles.headingMd.copyWith(color: accentColor),
                  h3: AppTextStyles.headingSm,
                  p: AppTextStyles.bodyMd.copyWith(height: 1.6),
                  strong: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                  listBullet: AppTextStyles.bodyMd,
                  blockquotePadding: const EdgeInsets.all(AppSpacing.md),
                  blockquoteDecoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border(left: BorderSide(color: accentColor, width: 3)),
                  ),
                  h2Padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
                  h3Padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
