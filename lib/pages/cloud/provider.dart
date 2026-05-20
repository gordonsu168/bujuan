import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music/common/bujuan_music_handler.dart';
import 'package:bujuan_music_api/api/cloud/entity/cloud_entity.dart';
import 'package:bujuan_music_api/common/music_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
Future<List<MediaItem>> cloudMediaList(Ref ref) async {
  final cloudEntity = await BujuanMusicManager().userCloud(limit: 2000, offset: 0);
  if (cloudEntity == null || cloudEntity.data == null) {
    return [];
  }
  return compute(_buildCloudMediaList, cloudEntity.data!);
}

List<MediaItem> _buildCloudMediaList(List<CloudData> cloudData) {
  return cloudData
      .map(
        (e) {
      final song = e.simpleSong;
      return MediaItem(
        id: '${e.songId ?? 0}',
        title: (song?.name ?? e.fileName) ?? '',
        duration: Duration(milliseconds: (song?.dt ?? 0)),
        artist: (song?.ar ?? []).map((a) => a.name).join(' '),
        artUri: Uri.tryParse(song?.al?.picUrl ?? e.coverUrl ?? ''),
      );
    },
      )
      .toList();
}
