import 'package:bujuan_music/pages/user/provider.dart';
import 'package:bujuan_music/widgets/backdrop.dart';
import 'package:bujuan_music/widgets/loading.dart';
import 'package:bujuan_music/widgets/main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '../../router/app_router.dart';
import '../../utils/adaptive_screen_utils.dart';
import '../../widgets/cache_image.dart';
import '../main/phone/widgets.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(newAlbumProvider);
    bool desktop = medium(context) || expanded(context);
    return album.when(
      data: (playlist) =>
          desktop ? DesktopUser(playlist: playlist) : MobileUser(playlist: playlist),
      loading: () => const Center(child: LoadingIndicator()),
      error: (_, __) => const Center(child: Text('Oops, something unexpected happened')),
    );
  }
}

class MobileUser extends StatelessWidget {
  final UserData playlist;

  const MobileUser({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(
          leading: CachedImage(
            imageUrl: playlist.userInfo.avatarUrl ?? "",
            width: 35.w,
            height: 35.w,
            pHeight: 100,
            pWidth: 100,
            borderRadius: 20.w,
          ),
          title: 'Music library (${playlist.likeList.playlist?.length})',
          actions: [
            IconButton(
              icon: Icon(HugeIconsSolid.cloud, size: 22.sp),
              tooltip: 'My Cloud',
              onPressed: () => context.push(AppRouter.cloud),
            ),
          ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.w),
        child: CustomScrollView(
          slivers: [
            SliverGrid.builder(
              itemCount: (playlist.likeList.playlist ?? []).length,
              itemBuilder: (context, index) {
                final song = (playlist.likeList.playlist ?? [])[index];
                return GestureDetector(
                  child: BackdropView(
                    blur: true,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          CachedImage(
                            imageUrl: song.coverImgUrl?.toString() ?? '',
                            width: 40.w,
                            height: 40.w,
                            borderRadius: 20.w,
                            pHeight: 80,
                            pWidth: 80,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                              child: Text(
                            song.name ?? '',
                            style: TextStyle(fontSize: 12.sp, overflow: TextOverflow.ellipsis),
                            maxLines: 2,
                          ))
                        ],
                      )),
                  onTap: () => context.push(AppRouter.playlist, extra: song.id),
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 10.w),
            ),
            SliverToBoxAdapter(
              child: DynamicPadding(),
            )
          ],
        ),
      ),
    );
  }
}

class DesktopUser extends StatelessWidget {
  final UserData playlist;

  const DesktopUser({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.w),
          child: SizedBox(
            width: 260.w,
            child: Column(
              children: [
                CachedImage(
                  imageUrl: playlist.userInfo.avatarUrl ?? '',
                  width: 200.w,
                  height: 200.w,
                  borderRadius: 100.w,
                ),
                SizedBox(height: 15.w),
                Text(
                  playlist.userInfo.nickname ?? '',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10.w),
                Text(
                  playlist.userInfo.signature ?? '',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
        Expanded(
            child: ListView.builder(
          padding: EdgeInsets.only(bottom: 45.w),
          itemCount: (playlist.likeList.playlist ?? []).length,
          itemBuilder: (context, index) {
            final song = (playlist.likeList.playlist ?? [])[index];
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.w),
              leading: CachedImage(
                imageUrl: song.coverImgUrl?.toString() ?? '',
                width: 48.w,
                height: 48.w,
                borderRadius: 24.w,
              ),
              title: Text(song.name ?? ''),
              subtitle: Text('${song.trackCount ?? 0} songs'),
              onTap: () => context.push(AppRouter.playlist, extra: song.id),
            );
          },
        ))
      ],
    );
  }
}
