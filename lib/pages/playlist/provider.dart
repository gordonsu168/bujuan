import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music/pages/main/provider.dart';
import 'package:bujuan_music/utils/cache_utils.dart';
import 'package:bujuan_music_api/api/playlist/entity/playlist_detail_entity.dart';
import 'package:bujuan_music_api/api/song/entity/song_detail_entity.dart';
import 'package:bujuan_music_api/common/music_api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
class PlaylistDetail extends _$PlaylistDetail {
  @override
  Future<PlaylistData> build(int id) async {
    final cacheKey = 'playlist_$id';

    // 1. 尝试加载缓存
    final cachedJson = await CacheUtils.getCache(cacheKey);
    PlaylistData? cachedData;
    if (cachedJson != null) {
      try {
        cachedData = PlaylistData.fromJson(cachedJson);
      } catch (e) {
        print('Failed to parse cached playlist: $e');
      }
    }

    // 2. 定义获取网络数据的逻辑
    Future<PlaylistData> fetchNetwork() async {
      var playlistDetailEntity = await BujuanMusicManager().playlistDetail(id: id);
      if (playlistDetailEntity == null) {
        return cachedData ?? PlaylistData(PlaylistDetailEntity(), [], Colors.transparent);
      }

      var colorScheme = await ColorScheme.fromImageProvider(
        provider: CachedNetworkImageProvider(
          '${playlistDetailEntity.playlist?.coverImgUrl}?param=100y100',
        ),
      );

      var songDetail = await BujuanMusicManager().songDetail(
        ids: playlistDetailEntity.playlist!.trackIds!.map((e) => e.id ?? 0).toList(),
      );

      var medias = await compute(_buildPlaylistData, songDetail);
      var primary = colorScheme.primary;

      final newData = PlaylistData(playlistDetailEntity, medias, primary);

      // 保存到缓存
      await CacheUtils.setCache(cacheKey, newData.toJson());

      return newData;
    }

    if (cachedData != null) {
      // 如果有缓存，异步触发网络同步
      fetchNetwork().then((newData) {
        state = AsyncData(newData);
      }).catchError((e) {
        print('Silent network sync failed: $e');
      });
      // 立即返回缓存数据
      return cachedData;
    }

    // 3. 如果没缓存，等待网络请求
    return await fetchNetwork();
  }
}

List<MediaItem> _buildPlaylistData(SongDetailEntity? detail) {
  var medias = (detail?.songs ?? [])
      .map(
        (e) => MediaItem(
          id: '${e.id}',
          title: e.name ?? "",
          duration: Duration(milliseconds: e.dt ?? 0),
          artist: (e.ar ?? []).map((e) => e.name).toList().join(' '),
          artUri: Uri.parse(e.al?.picUrl ?? ''),
          extras: {'mv': e.mv ?? 0},
        ),
      )
      .toList();
  return medias;
}

class PlaylistData {
  PlaylistDetailEntity detail;
  List<MediaItem> medias;
  Color color;

  PlaylistData(this.detail, this.medias, this.color);

  Map<String, dynamic> toJson() {
    return {
      'detail': detail.toJson(),
      'medias': medias.map((m) => {
        'id': m.id,
        'title': m.title,
        'duration': m.duration?.inMilliseconds ?? 0,
        'artist': m.artist,
        'artUri': m.artUri?.toString(),
        'extras': m.extras,
      }).toList(),
      'color': color.value,
    };
  }

  factory PlaylistData.fromJson(Map<String, dynamic> json) {
    final detailMap = json['detail'] as Map<String, dynamic>;
    final mediasList = json['medias'] as List;
    final colorValue = json['color'] as int;

    return PlaylistData(
      PlaylistDetailEntity.fromJson(detailMap),
      mediasList.map((m) {
        final map = m as Map<String, dynamic>;
        return MediaItem(
          id: map['id'],
          title: map['title'],
          duration: Duration(milliseconds: map['duration'] ?? 0),
          artist: map['artist'],
          artUri: map['artUri'] != null ? Uri.parse(map['artUri']) : null,
          extras: map['extras'] != null ? Map<String, dynamic>.from(map['extras']) : null,
        );
      }).toList(),
      Color(colorValue),
    );
  }
}
