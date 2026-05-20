// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cloudMediaList)
const cloudMediaListProvider = CloudMediaListProvider._();

final class CloudMediaListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MediaItem>>,
          List<MediaItem>,
          FutureOr<List<MediaItem>>
        >
    with $FutureModifier<List<MediaItem>>, $FutureProvider<List<MediaItem>> {
  const CloudMediaListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudMediaListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudMediaListHash();

  @$internal
  @override
  $FutureProviderElement<List<MediaItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MediaItem>> create(Ref ref) {
    return cloudMediaList(ref);
  }
}

String _$cloudMediaListHash() => r'1a475edda16d688dd5f8f1a2d194964e55d4432a';
