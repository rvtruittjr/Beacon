import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/providers/app_providers.dart';
import 'brand_switcher.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String path;
  const _NavItem(this.label, this.icon, this.path);
}

const _allNavItems = [
  _NavItem('Snapshot', LucideIcons.home, '/app/snapshot'),
  _NavItem('Brand Kit', LucideIcons.palette, '/app/brand-kit'),
  _NavItem('Library', LucideIcons.folderOpen, '/app/library'),
  _NavItem('Voice', LucideIcons.mic2, '/app/voice'),
  _NavItem('Audience', LucideIcons.users, '/app/audience'),
  _NavItem('Pillars', LucideIcons.layoutGrid, '/app/content-pillars'),
  _NavItem('Archive', LucideIcons.archive, '/app/archive'),
  _NavItem('Sharing', LucideIcons.share2, '/app/sharing'),
  _NavItem('Settings', LucideIcons.settings, '/app/settings'),
];

const _mobileNavItems = [
  _NavItem('Snapshot', LucideIcons.home, '/app/snapshot'),
  _NavItem('Kit', LucideIcons.palette, '/app/brand-kit'),
  _NavItem('Library', LucideIcons.folderOpen, '/app/library'),
  _NavItem('Archive', LucideIcons.archive, '/app/archive'),
  _NavItem('More', LucideIcons.menu, ''),
];

const _moreSheetItems = [
  _NavItem('Voice', LucideIcons.mic2, '/app/voice'),
  _NavItem('Audience', LucideIcons.users, '/app/audience'),
  _NavItem('Pillars', LucideIcons.layoutGrid, '/app/content-pillars'),
  _NavItem('Sharing', LucideIcons.share2, '/app/sharing'),
  _NavItem('Settings', LucideIcons.settings, '/app/settings'),
];

class AdaptiveScaffold extends ConsumerWidget {
  const AdaptiveScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;

    if (width > 768) {
      return _DesktopLayout(child: child);
    }

    return _MobileLayout(child: child);
  }
}

// ── Desktop Layout ──────────────────────────────────────────

class _DesktopLayout extends ConsumerWidget {
  const _DesktopLayout({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // ── Sidebar — dark rounded floating panel
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: AppColors.sidebarBg,
                borderRadius: BorderRadius.all(AppRadius.x2l),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Row(
                      children: [
                        Builder(builder: (context) {
                          final accent = Theme.of(context).colorScheme.primary;
                          final onAccent = Theme.of(context).colorScheme.onPrimary;
                          return Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.all(AppRadius.sm),
                            ),
                            child: Center(
                              child: Text(
                                'B',
                                style: AppFonts.clashDisplay(
                                  fontSize: 18,
                                  color: onAccent,
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Beacøn',
                          style: AppFonts.clashDisplay(
                            fontSize: 22,
                            color: AppColors.sidebarText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Brand switcher
                  const BrandSwitcher(),

                  const SizedBox(height: AppSpacing.lg),

                  // Nav items
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Column(
                        children: _allNavItems
                            .map((item) => _SidebarNavItem(item: item))
                            .toList(),
                      ),
                    ),
                  ),

                  // User profile card at bottom
                  const _SidebarUserCard(),

                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // ── Content area — white rounded panel
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.all(AppRadius.x2l),
                  boxShadow: isDark ? [] : AppShadows.card,
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sidebar nav item ────────────────────────────────────────

class _SidebarNavItem extends StatefulWidget {
  const _SidebarNavItem({required this.item});
  final _NavItem item;

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final isActive = currentPath == widget.item.path;

    final accent = Theme.of(context).colorScheme.primary;
    final onAccent = Theme.of(context).colorScheme.onPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.item.path),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          height: 44,
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isActive
                ? accent
                : _isHovered
                    ? AppColors.sidebarSurface
                    : Colors.transparent,
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 20,
                color: isActive
                    ? onAccent
                    : _isHovered
                        ? AppColors.sidebarText
                        : AppColors.sidebarMuted,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: AppFonts.inter(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? onAccent
                        : _isHovered
                            ? AppColors.sidebarText
                            : AppColors.sidebarMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sidebar user card ───────────────────────────────────────

class _SidebarUserCard extends ConsumerWidget {
  const _SidebarUserCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(currentUserProvider);

    final displayName = userData.whenOrNull(
          data: (data) => data?['full_name'] as String?,
        ) ??
        '';
    final email = userData.whenOrNull(
          data: (data) => data?['email'] as String?,
        ) ??
        '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.sidebarSurface,
        borderRadius: BorderRadius.all(AppRadius.lg),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName.isNotEmpty ? displayName : 'Welcome',
                  style: AppFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sidebarText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: AppFonts.inter(
                      fontSize: 11,
                      color: AppColors.sidebarMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile Layout ───────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    int currentIndex = _mobileNavItems
        .indexWhere((item) => item.path.isNotEmpty && currentPath == item.path);
    if (currentIndex < 0) {
      // Check if current path is a "More" screen
      final isMoreScreen =
          _moreSheetItems.any((item) => currentPath == item.path);
      currentIndex = isMoreScreen ? _mobileNavItems.length - 1 : 0;
    }

    return Scaffold(
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(
          bottom: 100 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: child,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.sidebarBg,
            borderRadius: BorderRadius.all(AppRadius.full),
            boxShadow: AppShadows.lg,
          ),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _mobileNavItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isActive = index == currentIndex;

                return GestureDetector(
                  onTap: () {
                    if (item.path.isEmpty) {
                      _showMoreSheet(context, currentPath);
                    } else {
                      context.go(item.path);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : AppColors.sidebarMuted,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : AppColors.sidebarMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

void _showMoreSheet(BuildContext context, String currentPath) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        borderRadius: BorderRadius.all(AppRadius.xl),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.sidebarMuted,
                  borderRadius: BorderRadius.all(AppRadius.full),
                ),
              ),
              ..._moreSheetItems.map((item) {
                final isActive = currentPath == item.path;
                return GestureDetector(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    context.go(item.path);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.all(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 20,
                          color: isActive
                              ? Theme.of(context).colorScheme.onPrimary
                              : AppColors.sidebarMuted,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          item.label,
                          style: AppFonts.inter(
                            fontSize: 15,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? Theme.of(context).colorScheme.onPrimary
                                : AppColors.sidebarText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ),
  );
}
