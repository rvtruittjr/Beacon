import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../providers/brand_kit_provider.dart';

class LogoTab extends ConsumerWidget {
  const LogoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logosAsync = ref.watch(brandLogosProvider);

    return logosAsync.when(
      loading: () => const LoadingIndicator(),
      error: (_, __) => const Center(child: Text('Failed to load logos')),
      data: (logos) {
        if (logos.isEmpty) {
          return EmptyState(
            blockColor: AppColors.blockViolet,
            icon: Icons.image_outlined,
            headline: 'No logos yet',
            supportingText: 'Upload your logo variations here.',
            ctaLabel: 'Upload logo',
            onCtaPressed: () => _uploadLogo(context, ref),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: 'Upload logo',
                      icon: Icons.upload_outlined,
                      onPressed: () => _uploadLogo(context, ref),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.maxWidth > 600 ? 4 : 2;
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: logos.length,
                          itemBuilder: (context, index) {
                            final logo = logos[index];
                            return _LogoCard(
                              name: logo['name'] as String? ?? 'Logo',
                              url: logo['file_url'] as String? ?? '',
                              onDelete: () =>
                                  _deleteLogo(ref, logo['id'] as String),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _uploadLogo(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['svg', 'png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    final client = SupabaseService.client;
    final user = client.auth.currentUser;
    final brandId = ref.read(currentBrandProvider);
    if (user == null || brandId == null) return;

    final path = '${user.id}/$brandId/assets/logo/${file.name}';
    await client.storage.from('brand-assets').uploadBinary(
          path,
          file.bytes!,
          fileOptions: FileOptions(upsert: true),
        );

    final url = client.storage.from('brand-assets').getPublicUrl(path);

    await client.from('assets').insert({
      'brand_id': brandId,
      'user_id': user.id,
      'name': file.name,
      'file_url': url,
      'file_type': 'logo',
      'mime_type': 'image/${file.extension ?? 'png'}',
    });

    ref.invalidate(brandLogosProvider);
  }

  Future<void> _deleteLogo(WidgetRef ref, String id) async {
    await SupabaseService.client.from('assets').delete().eq('id', id);
    ref.invalidate(brandLogosProvider);
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard({
    required this.name,
    required this.url,
    required this.onDelete,
  });

  final String name;
  final String url;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor = theme.colorScheme.surface;

    return GestureDetector(
      onTap: () => _showLightbox(context),
      onSecondaryTapUp: (details) => _showContextMenu(context, details),
      onLongPress: () => _showContextMenuMobile(context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? surfaceColor : Colors.white,
          borderRadius: BorderRadius.all(AppRadius.lg),
          boxShadow: isDark ? null : AppShadows.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: url.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.image_outlined,
                          size: 32,
                          color: mutedColor,
                        ),
                      )
                    : Icon(
                        Icons.image_outlined,
                        size: 32,
                        color: mutedColor,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                name,
                style: TextStyle(color: mutedColor, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLightbox(BuildContext context) {
    if (url.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, TapUpDetails details) {
    _showMenu(context, details.globalPosition);
  }

  void _showContextMenuMobile(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero) +
        Offset(box.size.width / 2, box.size.height);
    _showMenu(context, pos);
  }

  void _showMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value == 'delete') onDelete();
    });
  }
}
