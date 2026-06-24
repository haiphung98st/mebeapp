import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Signature MeBé header: gradient panel with two bunny-ear blobs poking up
/// at the top and a rounded bulge along the bottom edge.
class BunnyHeader extends StatelessWidget {
  const BunnyHeader({
    super.key,
    required this.gradient,
    this.earLeftColor = AppColors.petal,
    this.earRightColor = AppColors.lilac,
    this.leading,
    this.title,
    this.subtitle,
    this.titleColor = AppColors.white,
    this.actions,
    this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 14, 20, 36),
  });

  final Gradient gradient;
  final Color earLeftColor;
  final Color earRightColor;
  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Color titleColor;
  final Widget? actions;
  final Widget? child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: _BottomBulgeClipper(),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(gradient: gradient),
            padding: padding,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (leading != null) leading!,
                      if (title != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: leading == null
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title!,
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: titleColor,
                                ),
                              ),
                              if (subtitle != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    subtitle!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: titleColor.withValues(alpha: 0.82),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      if (actions != null) actions!,
                    ],
                  ),
                  if (child != null) child!,
                ],
              ),
            ),
          ),
        ),
        Positioned(top: -22, left: 44, child: _EarBlob(color: earLeftColor)),
        Positioned(top: -22, left: 78, child: _EarBlob(color: earRightColor)),
      ],
    );
  }
}

class _EarBlob extends StatelessWidget {
  const _EarBlob({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
    );
  }
}

class _BottomBulgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const curve = 24.0;
    return Path()
      ..lineTo(0, size.height - curve)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + curve,
        size.width,
        size.height - curve,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
