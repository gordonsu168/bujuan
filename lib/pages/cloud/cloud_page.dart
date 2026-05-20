import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '../../common/bujuan_music_handler.dart';
import '../../router/app_router.dart';
import '../../utils/adaptive_screen_utils.dart';
import '../../widgets/backdrop.dart';
import '../../widgets/cache_image.dart';
import '../../widgets/loading.dart';
import '../../widgets/main_appbar.dart';
import '../main/phone/widgets.dart';
import 'provider.dart';

class CloudPage extends ConsumerWidget {
  const CloudPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudList = ref.watch(cloudMediaListProvider);
    bool desktop = medium(context) || expanded(context);
    return cloudList.when(
      data: (medias) =>
          desktop ? DesktopCloud(medias: medias) : MobileCloud(medias: medias),
      loading: () => const Center(child: LoadingIndicator()),
      error: (_, __) => const Center(child: Text('Oops, something unexpected happened')),
    );
  }
}

class MobileCloud extends StatelessWidget {
  final List<MediaItem> medias;

  const MobileCloud({super.key, required this.medias});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(
        title: 'My Cloud (${medias.length})',
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(HugeIconsSolid.arrowLeft01, size: 24.sp),
        ),
      ),
      body: medias.isEmpty
          ? const Center(child: Text('No cloud songs found'))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
                    leading: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(24.w),
                      ),
                      child: Icon(HugeIconsSolid.play, color: Theme.of(context).primaryColor, size: 24.sp),
                    ),
                    title: Text(
                      'Play All',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${medias.length} songs'),
                    onTap: () => BujuanMusicHandler().updateQueue(
                      medias,
                      index: 0,
                      queueName: 'Cloud Music',
                    ),
                  ),
                ),
                SliverFixedExtentList(
                  itemExtent: 75,
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = medias[index];
                      return RepaintBoundary(
                        child: _CloudSongItem(
                          mediaItem: song,
                          onTap: () => BujuanMusicHandler().updateQueue(
                            medias,
                            index: index,
                            queueName: 'Cloud Music',
                          ),
                        ),
                      );
                    },
                    childCount: medias.length,
                    addAutomaticKeepAlives: false,
                  ),
                ),
                SliverToBoxAdapter(child: DynamicPadding()),
              ],
            ),
    );
  }
}

class DesktopCloud extends StatelessWidget {
  final List<MediaItem> medias;

  const DesktopCloud({super.key, required this.medias});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(HugeIconsSolid.arrowLeft01, size: 24.sp),
        ),
        title: Text('My Cloud (${medias.length})'),
        actions: [
          if (medias.isNotEmpty)
            TextButton.icon(
              onPressed: () => BujuanMusicHandler().updateQueue(
                medias,
                index: 0,
                queueName: 'Cloud Music',
              ),
              icon: Icon(HugeIconsSolid.play, size: 20.sp),
              label: const Text('Play All'),
            ),
          SizedBox(width: 20.w),
        ],
      ),
      body: medias.isEmpty
          ? const Center(child: Text('No cloud songs found'))
          : ListView.builder(
              padding: EdgeInsets.only(bottom: 45.w),
              itemExtent: 75,
              itemCount: medias.length,
              itemBuilder: (context, index) {
                final song = medias[index];
                return _CloudSongItem(
                  mediaItem: song,
                  onTap: () => BujuanMusicHandler().updateQueue(
                    medias,
                    index: index,
                    queueName: 'Cloud Music',
                  ),
                );
              },
            ),
    );
  }
}

class _CloudSongItem extends StatelessWidget {
  final MediaItem mediaItem;
  final VoidCallback? onTap;

  const _CloudSongItem({required this.mediaItem, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
      leading: CachedImage(
        imageUrl: mediaItem.artUri?.toString() ?? '',
        width: 48.w,
        height: 48.w,
        borderRadius: 24.w,
      ),
      title: Text(
        mediaItem.title,
        style: TextStyle(fontSize: 14.sp),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        mediaItem.artist ?? '',
        style: TextStyle(fontSize: 12.sp),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(HugeIconsSolid.play, size: 20.sp),
        onPressed: onTap,
      ),
      onTap: onTap,
    );
  }
}
