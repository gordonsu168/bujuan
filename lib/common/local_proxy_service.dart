import 'dart:io';

import 'package:bujuan_music_api/api/song/entity/song_url_entity.dart';
import 'package:bujuan_music_api/common/music_api.dart';

class LocalProxyService {
  LocalProxyService._internal();

  static final LocalProxyService _instance = LocalProxyService._internal();

  factory LocalProxyService() => _instance;

  final int port = 8848;
  final Map<String, _CachedUrl> _cache = {}; // songId -> URL + expire
  final Map<String, DateTime> _lastRequestTime = {}; // songId -> 最近请求时间
  HttpServer? _server;
  bool _started = false;

  final Duration minInterval = Duration(seconds: 1); // 最小请求间隔

  Future<void> start() async {
    if (_started) return;
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
      _started = true;
      print('LocalProxyService running on http://127.0.0.1:$port');
      _server!.listen((HttpRequest request) async {
        final path = request.uri.path;

        if (path.startsWith('/song/')) {
          final songId = path.split('/').last;

          try {
            print('Proxying request for songId: $songId');
            // ① 获取真实播放地址
            final realUrl = await _getUrl(songId);
            if (realUrl.isEmpty) {
              print('Error: Real URL is empty for songId: $songId');
              throw 'Real URL is empty';
            }

            print('$songId  --->  $realUrl');

            // ② 转发真实音频请求（流式）
            final client = HttpClient();
            final realRequest = await client.getUrl(Uri.parse(realUrl));
            final realResponse = await realRequest.close();

            // ③ 把真实响应头复制给本地响应
            realResponse.headers.forEach((name, values) {
              request.response.headers.set(name, values.join(','));
            });

            request.response.statusCode = realResponse.statusCode;

            // ④ 流式转发（关键）
            await realResponse.pipe(request.response);
          } catch (e) {
            print('Proxy error for songId $songId: $e');
            request.response
              ..statusCode = 500
              ..write('Proxy error: $e')
              ..close();
          }
        } else {
          request.response
            ..statusCode = 404
            ..write('Not found')
            ..close();
        }
      });
    } catch (e) {
      print('Failed to start LocalProxyService: $e');
    }
  }

  Future<String> _getUrl(String songId) async {
    final now = DateTime.now();

    // 拦截短时间内重复请求
    final lastTime = _lastRequestTime[songId];
    if (lastTime != null && now.difference(lastTime) < minInterval) {
      print('Returning cached URL (throttle) for $songId');
      return _cache[songId]?.url ?? '';
    }
    _lastRequestTime[songId] = now;

    // 缓存有效直接返回
    final cached = _cache[songId];
    if (cached != null && cached.expire.isAfter(now.add(Duration(seconds: 15)))) {
      print('Returning cached URL for $songId');
      return cached.url;
    }

    // 缓存不存在或过期 → 请求后端
    print('Fetching new URL from server for $songId');
    final newUrl = await fetchUrlFromServer(songId);
    if (newUrl.isNotEmpty) {
      final expire = now.add(Duration(minutes: 15));
      _cache[songId] = _CachedUrl(newUrl, expire);
    }

    return newUrl;
  }

  Future<String> fetchUrlFromServer(String songId) async {
    // 逐级降级获取 URL：云盘歌曲通常没有 jyeffect/sky 级别
    final levels = ['standard', 'exhigh', 'lossless', 'hires'];
    for (final level in levels) {
      try {
        print('Requesting songUrl for $songId with level $level');
        SongUrlEntity? songUrlEntity = await BujuanMusicManager().songUrl(ids: [songId], level: level);
        if (songUrlEntity != null && (songUrlEntity.data ?? []).isNotEmpty) {
          final url = songUrlEntity.data!.first.url ?? '';
          if (url.isNotEmpty) {
            print('Successfully got URL for $songId: $url');
            return url;
          }
        }
        print('No URL found for $songId with level $level');
      } catch (e) {
        print('Error calling songUrl for $songId with level $level: $e');
        continue;
      }
    }
    return '';
  }

  String proxyUrl(String songId) => 'http://127.0.0.1:$port/song/$songId';
}

class _CachedUrl {
  final String url;
  final DateTime expire;

  _CachedUrl(this.url, this.expire);
}
