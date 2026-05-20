import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:bujuan_music/common/local_proxy_service.dart';
import 'package:just_audio/just_audio.dart';

class BujuanMusicHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  // 私有构造函数
  BujuanMusicHandler._internal() {
    // 播放器状态同步到 audio_service
    _audioPlayer.playerStateStream.listen((PlayerState state) {
      var playing = state.playing;
      playbackState.add(
        playbackState.value.copyWith(
          playing: playing,
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[state.processingState]!,
          systemActions: const {MediaAction.seek},
          androidCompactActionIndices: const [1, 2, 3],
          controls: [
            MediaControl.skipToPrevious,
            playing ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          repeatMode: AudioServiceRepeatMode.all,
          shuffleMode: AudioServiceShuffleMode.none,
        ),
      );
    });
    _audioPlayer.currentIndexStream.listen((index) {
      if (playbackState.value.queueIndex != index) {
        playbackState.add(playbackState.value.copyWith(queueIndex: index));
        if (queue.value.isNotEmpty && index != null && index > 0) {
          mediaItem.add(queue.value[index]);
        }
      }
    });
    _audioPlayer.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });

    _audioPlayer.bufferedPositionStream.listen((buffered) {
      playbackState.add(playbackState.value.copyWith(bufferedPosition: buffered));
    });

    _audioPlayer.loopModeStream.listen((loopMode) {
      playbackState.add(
        playbackState.value.copyWith(
          repeatMode: const {
            LoopMode.all: AudioServiceRepeatMode.all,
            LoopMode.off: AudioServiceRepeatMode.none,
            LoopMode.one: AudioServiceRepeatMode.one,
          }[loopMode]!,
        ),
      );
    });

    _audioPlayer.shuffleModeEnabledStream.listen((enable) {
      playbackState.add(
        playbackState.value.copyWith(
          shuffleMode: enable ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        ),
      );
    });
    _audioPlayer.setShuffleModeEnabled(false);
    _audioPlayer.setLoopMode(LoopMode.all);
  }

  static final BujuanMusicHandler _instance = BujuanMusicHandler._internal();

  factory BujuanMusicHandler() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();

  init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  /// 更新播放列表
  @override
  Future<void> updateQueue(
    List<MediaItem> songs, {
    int index = 0,
    String queueName = '',
    bool save = true,
    Duration? position,
  }) async {
    if (songs.isEmpty) return;
    var playlist = <ProgressiveAudioSource>[];
    if (queueTitle.value == queueName) {
      _audioPlayer.seek(Duration.zero, index: index);
    } else {
      queueTitle.value = queueName;
      queue.add(songs);
      for (var song in songs) {
        playlist.add(
          ProgressiveAudioSource(Uri.parse(LocalProxyService().proxyUrl(song.id)), tag: song.id),
        );
      }
      try {
        await _audioPlayer.setAudioSources(
          playlist,
          initialIndex: index,
          initialPosition: position,
          preload: false,
        );
      } catch (e) {
        print('Error setting audio sources: $e');
      }
    }
    if (index == 0) {
      mediaItem.add(songs[index]);
    }
    play();
  }

  /// 播放
  @override
  Future<void> play() async {
    await _audioPlayer.play();
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// 暂停
  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// 停止
  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// 播放 / 暂停切换
  Future<void> toggle() async {
    _audioPlayer.playing ? pause() : play();
  }

  /// 下一首
  @override
  Future<void> skipToNext() async {
    await _audioPlayer.seekToNext();
  }

  /// 上一首
  @override
  Future<void> skipToPrevious() async {
    await _audioPlayer.seekToPrevious();
  }

  /// 切换循环/随机模式（按你原来的逻辑改造，保证 shuffle 生效）
  Future<void> changeLoopMode() async {
    if (_audioPlayer.shuffleModeEnabled) {
      // 如果当前是 shuffle -> 关闭 shuffle，设为 all 循环
      await setShuffleEnabled(false);
      await _audioPlayer.setLoopMode(LoopMode.all);
    } else {
      // 非 shuffle 情况下，按顺序切换 loopMode -> one -> shuffle
      if (_audioPlayer.loopMode == LoopMode.all) {
        await _audioPlayer.setLoopMode(LoopMode.one);
      } else if (_audioPlayer.loopMode == LoopMode.one) {
        // 开启 shuffle
        await setShuffleEnabled(true);
        await _audioPlayer.setLoopMode(LoopMode.all);
      } else {
        // default -> set loop all
        await _audioPlayer.setLoopMode(LoopMode.all);
      }
    }
  }

  /// 显式设置 shuffle 开关（如果你有独立按钮）
  Future<void> setShuffleEnabled(bool enabled) async {
    await _audioPlayer.setShuffleModeEnabled(enabled);
    if (enabled) {
      // 必须调用 shuffle() 生成随机播放列表
      await _audioPlayer.shuffle();
    }
  }

  /// 清理资源（如果需要）
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }

  @override
  Future<void> onTaskRemoved() {
    dispose();
    print('任务被移除');
    return super.onTaskRemoved();
  }
}
