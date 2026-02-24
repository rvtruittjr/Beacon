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
  _NavItem('Archive', LucideIcons.archive, '/app/archive'),
  _NavItem('Sharing', LucideIcons.share2, '/app/sharing'),
  _NavItem('Settings', LucideIcons.settings, '/app/settings'),
];

const _mobileNavItems = [
  _NavItem('Snapshot', LucideIcons.home, '/app/snapshot'),
  _NavItem('Kit', LucideIcons.palette, '/app/brand-kit'),
  _NavItem('Library', LucideIcons.folderOpen, '/app/library'),
  _NavItem('Archive', LucideIcons.archive, '/app/archive'),
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
    return Scaffold(
      backgroundColor: AppColors.sidebarBg,
      body: Row(
        children: [
          // ── Sidebar (always dark, flat right edge like reference)
          Container(
            width: 250,
            color: AppColors.sidebarBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.x2l),

                // Logo — yellow like "Moo" in reference
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    'Beacøn',
                    style: AppFonts.clashDisplay(
                      fontSize: 24,
                      color: AppColors.blockYellow,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Brand switcher
                const BrandSwitcher(),

                const SizedBox(height: AppSpacing.x2l),

                // Nav items
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
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

          // ── Content area — floating panel with rounded corners
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                top: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.all(AppRadius.x2l),
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          ),
        ],
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

    // Reference style: active = white icon + white text, no bg fill
    // Hover = slightly lighter text
    // Default = muted gray
    final Color iconColor;
    final Color textColor;

    if (isActive) {
      iconColor = AppColors.sidebarText;
      textColor = AppColors.sidebarText;
    } else if (_isHovered) {
      iconColor = AppColors.sidebarText.withValues(alpha: 0.8);
      textColor = AppColors.sidebarText.withValues(alpha: 0.8);
    } else {
      iconColor = AppColors.sidebarMuted;
      textColor = AppColors.sidebarMuted;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.item.path),
        child: Container(
          height: 46,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          color: Colors.transparent,
          child: Row(
            children: [
              Icon(widget.item.icon, size: 20, color: iconColor),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: AppFonts.inter(
                    fontSize: 15,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                    color: textColor,
                  ),
                ),
              ),
              if (isActive)
                Icon(
                  LucideIcons.chevronUp,
                  size: 16,
                  color: AppColors.sidebarText,
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
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.sidebarSurface,
        borderRadius: BorderRadius.all(AppRadius.xl),
      ),
      child: Column(
        children: [
          // Avatar — large circle like reference
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.blockYellow,
            child: Text(
              displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.textOnYellow,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Name
          Text(
            displayName.isNotEmpty ? displayName : 'Welcome',
            style: AppFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.sidebarText,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          // Subtitle / email
          if (email.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              email,
              style: AppFonts.inter(
                fontSize: 12,
                color: AppColors.sidebarMuted,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Upgrade button — yellow pill like reference
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                // TODO: upgrade flow
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.blockYellow,
                foregroundColor: AppColors.textOnYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(AppRadius.full),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Upgrade',
                style: AppFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnYellow,
                ),
              ),
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
        .indexWhere((item) => currentPath == item.path);
    if (currentIndex < 0) currentIndex = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.sidebarBg,
          boxShadow: AppShadows.lg,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _mobileNavItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isActive = index == currentIndex;

                return GestureDetector(
                  onTap: () => context.go(item.path),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.sidebarSurface
                          : Colors.transparent,
                      borderRadius: BorderRadius.all(AppRadius.md),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: isActive
                              ? AppColors.sidebarText
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
                                ? AppColors.sidebarText
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
