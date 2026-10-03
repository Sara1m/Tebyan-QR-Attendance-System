import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pull_down_button/pull_down_button.dart';

import 'colors.dart';
import 'images.dart';

/// Keeps content readable on wide screens (laptops) by limiting its width.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child, this.maxWidth = 680});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// The curved, gradient header used at the top of every page.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryColor.withOpacity(.25),
              blurRadius: 24,
              offset: const Offset(0, 10))
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        child: Stack(
          children: [
            // decorative circles
            PositionedDirectional(
              top: -40,
              end: -30,
              child: _circle(150, Colors.white.withOpacity(.06)),
            ),
            PositionedDirectional(
              bottom: -60,
              start: -40,
              child: _circle(170, AppColors.accent.withOpacity(.10)),
            ),
            PositionedDirectional(
              top: 34,
              end: 96,
              child: _diamond(14, AppColors.accent.withOpacity(.55)),
            ),
            PositionedDirectional(
              top: 34,
              end: 120,
              child: _diamond(14, AppColors.accent.withOpacity(.35)),
            ),
            SafeArea(
              bottom: false,
              child: ResponsiveBody(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            if (leading != null) leading!,
                            const Spacer(),
                            ...actions,
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1.3)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(subtitle!,
                            style: TextStyle(
                                color: Colors.white.withOpacity(.75),
                                fontSize: 14,
                                height: 1.4)),
                      ],
                      if (bottom != null) ...[
                        const SizedBox(height: 18),
                        bottom!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _diamond(double size, Color color) => Transform.rotate(
        angle: 0.785398, // 45°
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
      );
}

/// Small brand badge (app mark + name) shown at the top of main pages.
class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(AppImages.mark, width: 34, height: 34),
        ),
        const SizedBox(width: 8),
        const Text('Tebyan',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: .5)),
      ],
    );
  }
}

/// A round, translucent icon button for use on the dark header.
class HeaderButton extends StatelessWidget {
  const HeaderButton(
      {super.key, required this.icon, required this.onTap, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: _withTooltip(Material(
          color: Colors.white.withOpacity(.12),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        )),
    );
  }

  Widget _withTooltip(Widget child) =>
      tooltip == null ? child : Tooltip(message: tooltip!, child: child);
}

/// Standard page: gradient header on top, scrollable content under it.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
    this.headerBottom,
    this.floatingActionButton,
    this.showBack = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? headerBottom;
  final Widget body;
  final Widget? floatingActionButton;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          GradientHeader(
            title: title,
            subtitle: subtitle,
            actions: actions,
            bottom: headerBottom,
            leading: showBack
                ? HeaderButton(icon: Icons.arrow_back, onTap: () => Get.back())
                : const BrandBadge(),
          ),
          Expanded(child: ResponsiveBody(child: body)),
        ],
      ),
    );
  }
}

/// White rounded card with a soft shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryColor.withOpacity(.07),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Coloured square showing a course code (e.g. CS210).
class CourseBadge extends StatelessWidget {
  const CourseBadge({super.key, required this.code, this.size = 56});
  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.courseColor(code);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, .25)!],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: FittedBox(
          child: Text(code.isEmpty ? '—' : code,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ),
      ),
    );
  }
}

/// Round icon with a soft background.
class IconBubble extends StatelessWidget {
  const IconBubble(
      {super.key, required this.icon, this.color, this.size = 46});
  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.color1;
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(color: c.withOpacity(.12), shape: BoxShape.circle),
      child: Icon(icon, color: c, size: size * .5),
    );
  }
}

/// Small pill showing a status, e.g. "Present".
class StatusChip extends StatelessWidget {
  const StatusChip(
      {super.key, required this.text, required this.color, this.icon});
  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Number + label tile shown inside headers.
class StatTile extends StatelessWidget {
  const StatTile(
      {super.key, required this.value, required this.label, this.icon});
  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(.12)),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.accent, size: 22),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withOpacity(.7), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => Center(
      child: SpinKitThreeBounce(color: AppColors.color1, size: 22));
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.color4,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: AppColors.color1),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], height: 1.5)),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

/// Fades and slides list items in, one after another.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final int ms = 300 + index.clamp(0, 8).toInt() * 70;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: child),
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
      child: Row(
        children: [
          Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// One entry in the "⋮" menu.
class MenuAction {
  const MenuAction({
    required this.title,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;
}

/// The "⋮" button that opens a small menu.
Widget appMenu(List<MenuAction> actions) {
  return PullDownButton(
    itemBuilder: (context) => actions
        .map((a) => PullDownMenuItem(
              title: a.title.tr,
              icon: a.icon,
              iconColor: a.destructive ? null : AppColors.primaryColor,
              isDestructive: a.destructive,
              itemTheme:
                  PullDownMenuItemTheme(textStyle: Get.textTheme.titleMedium),
              onTap: a.onTap,
            ))
        .toList(),
    routeTheme: const PullDownMenuRouteTheme(width: 220),
    position: PullDownMenuPosition.over,
    buttonBuilder: (context, showMenu) => CupertinoButton(
      onPressed: showMenu,
      padding: EdgeInsets.zero,
      child: Icon(Icons.more_vert, color: AppColors.primaryColor),
    ),
  );
}

/// Text field label shown above inputs in forms.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 8, bottom: 6, top: 14),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.color1)),
      );
}
