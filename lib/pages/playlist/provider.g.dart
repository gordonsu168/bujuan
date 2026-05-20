// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlaylistDetail)
const playlistDetailProvider = PlaylistDetailFamily._();

final class PlaylistDetailProvider
    extends $AsyncNotifierProvider<PlaylistDetail, PlaylistData> {
  const PlaylistDetailProvider._({
    required PlaylistDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'playlistDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playlistDetailHash();

  @override
  String toString() {
    return r'playlistDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PlaylistDetail create() => PlaylistDetail();

  @override
  bool operator ==(Object other) {
    return other is PlaylistDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playlistDetailHash() => r'b7479abc51684834deb508fe79da462b27419752';

final class PlaylistDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          PlaylistDetail,
          AsyncValue<PlaylistData>,
          PlaylistData,
          FutureOr<PlaylistData>,
          int
        > {
  const PlaylistDetailFamily._()
    : super(
        retry: null,
        name: r'playlistDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlaylistDetailProvider call(int id) =>
      PlaylistDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'playlistDetailProvider';
}

abstract class _$PlaylistDetail extends $AsyncNotifier<PlaylistData> {
  late final _$args = ref.$arg as int;
  int get id => _$args;

  FutureOr<PlaylistData> build(int id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<PlaylistData>, PlaylistData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PlaylistData>, PlaylistData>,
              AsyncValue<PlaylistData>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
