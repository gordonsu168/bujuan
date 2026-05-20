import 'package:audio_service/audio_service.dart';
import 'package:bujuan_music_api/api/recommend/entity/recommend_resource_entity.dart';
import 'package:bujuan_music_api/api/recommend/entity/recommend_song_entity.dart';
import 'package:bujuan_music_api/api/top/entity/top_artist_entity.dart';
import 'package:bujuan_music_api/bujuan_music_api.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
Future<HomeData> newAlbum(Ref ref) async {
  var recommendResourceFuture = BujuanMusicManager().recommendResource();
  var topArtistFuture = BujuanMusicManager().topArtist(limit: 10);
  var recommendSongFuture = BujuanMusicManager().recommendSongs();

  var list = await Future.wait([
    recommendResourceFuture,
    topArtistFuture,
    recommendSongFuture,
  ]);
  return compute(_buildHomeData, list);
}

HomeData _buildHomeData(List list) {
  var playlist = list[0] as RecommendResourceEntity;
  var listArtist = list[1] as TopArtistEntity;
  var recommendSongEntity = list[2] as RecommendSongEntity;
  var recommend = recommendSongEntity.data?.dailySongs ?? [];

  var medias = recommend
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
  return HomeData(
    playlist,
    listArtist,
    medias,
    recommend.isEmpty ? '' : recommend.first.al?.picUrl ?? '',
  );
}

@riverpod
Future<List<MediaItem>> recommendSongs(Ref ref) async {
  var recommendSongEntity = await BujuanMusicManager().recommendSongs();
  var list = recommendSongEntity?.data?.dailySongs ?? [];
  return list
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
}

class HomeData {
  // TopArtistEntity topArtistEntity;
  RecommendResourceEntity recommendResourceEntity;
  TopArtistEntity topArtistEntity;
  List<MediaItem> medias;
  String image;

  HomeData(this.recommendResourceEntity, this.topArtistEntity, this.medias, this.image);
}
