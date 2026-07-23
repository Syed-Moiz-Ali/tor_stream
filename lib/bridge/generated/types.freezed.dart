// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FrbEngineEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FrbEngineEventCopyWith<$Res> {
  factory $FrbEngineEventCopyWith(
    FrbEngineEvent value,
    $Res Function(FrbEngineEvent) then,
  ) = _$FrbEngineEventCopyWithImpl<$Res, FrbEngineEvent>;
}

/// @nodoc
class _$FrbEngineEventCopyWithImpl<$Res, $Val extends FrbEngineEvent>
    implements $FrbEngineEventCopyWith<$Res> {
  _$FrbEngineEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FrbEngineEvent_SessionStartedImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_SessionStartedImplCopyWith(
    _$FrbEngineEvent_SessionStartedImpl value,
    $Res Function(_$FrbEngineEvent_SessionStartedImpl) then,
  ) = __$$FrbEngineEvent_SessionStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FrbEngineEvent_SessionStartedImplCopyWithImpl<$Res>
    extends
        _$FrbEngineEventCopyWithImpl<$Res, _$FrbEngineEvent_SessionStartedImpl>
    implements _$$FrbEngineEvent_SessionStartedImplCopyWith<$Res> {
  __$$FrbEngineEvent_SessionStartedImplCopyWithImpl(
    _$FrbEngineEvent_SessionStartedImpl _value,
    $Res Function(_$FrbEngineEvent_SessionStartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FrbEngineEvent_SessionStartedImpl
    extends FrbEngineEvent_SessionStarted {
  const _$FrbEngineEvent_SessionStartedImpl() : super._();

  @override
  String toString() {
    return 'FrbEngineEvent.sessionStarted()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_SessionStartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return sessionStarted();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return sessionStarted?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (sessionStarted != null) {
      return sessionStarted();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return sessionStarted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return sessionStarted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (sessionStarted != null) {
      return sessionStarted(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_SessionStarted extends FrbEngineEvent {
  const factory FrbEngineEvent_SessionStarted() =
      _$FrbEngineEvent_SessionStartedImpl;
  const FrbEngineEvent_SessionStarted._() : super._();
}

/// @nodoc
abstract class _$$FrbEngineEvent_SessionStoppedImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_SessionStoppedImplCopyWith(
    _$FrbEngineEvent_SessionStoppedImpl value,
    $Res Function(_$FrbEngineEvent_SessionStoppedImpl) then,
  ) = __$$FrbEngineEvent_SessionStoppedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FrbEngineEvent_SessionStoppedImplCopyWithImpl<$Res>
    extends
        _$FrbEngineEventCopyWithImpl<$Res, _$FrbEngineEvent_SessionStoppedImpl>
    implements _$$FrbEngineEvent_SessionStoppedImplCopyWith<$Res> {
  __$$FrbEngineEvent_SessionStoppedImplCopyWithImpl(
    _$FrbEngineEvent_SessionStoppedImpl _value,
    $Res Function(_$FrbEngineEvent_SessionStoppedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FrbEngineEvent_SessionStoppedImpl
    extends FrbEngineEvent_SessionStopped {
  const _$FrbEngineEvent_SessionStoppedImpl() : super._();

  @override
  String toString() {
    return 'FrbEngineEvent.sessionStopped()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_SessionStoppedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return sessionStopped();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return sessionStopped?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (sessionStopped != null) {
      return sessionStopped();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return sessionStopped(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return sessionStopped?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (sessionStopped != null) {
      return sessionStopped(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_SessionStopped extends FrbEngineEvent {
  const factory FrbEngineEvent_SessionStopped() =
      _$FrbEngineEvent_SessionStoppedImpl;
  const FrbEngineEvent_SessionStopped._() : super._();
}

/// @nodoc
abstract class _$$FrbEngineEvent_TorrentAddedImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_TorrentAddedImplCopyWith(
    _$FrbEngineEvent_TorrentAddedImpl value,
    $Res Function(_$FrbEngineEvent_TorrentAddedImpl) then,
  ) = __$$FrbEngineEvent_TorrentAddedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt id, String? name, BigInt totalBytes});
}

/// @nodoc
class __$$FrbEngineEvent_TorrentAddedImplCopyWithImpl<$Res>
    extends
        _$FrbEngineEventCopyWithImpl<$Res, _$FrbEngineEvent_TorrentAddedImpl>
    implements _$$FrbEngineEvent_TorrentAddedImplCopyWith<$Res> {
  __$$FrbEngineEvent_TorrentAddedImplCopyWithImpl(
    _$FrbEngineEvent_TorrentAddedImpl _value,
    $Res Function(_$FrbEngineEvent_TorrentAddedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? totalBytes = null,
  }) {
    return _then(
      _$FrbEngineEvent_TorrentAddedImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as BigInt,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalBytes: null == totalBytes
            ? _value.totalBytes
            : totalBytes // ignore: cast_nullable_to_non_nullable
                  as BigInt,
      ),
    );
  }
}

/// @nodoc

class _$FrbEngineEvent_TorrentAddedImpl extends FrbEngineEvent_TorrentAdded {
  const _$FrbEngineEvent_TorrentAddedImpl({
    required this.id,
    this.name,
    required this.totalBytes,
  }) : super._();

  @override
  final BigInt id;
  @override
  final String? name;
  @override
  final BigInt totalBytes;

  @override
  String toString() {
    return 'FrbEngineEvent.torrentAdded(id: $id, name: $name, totalBytes: $totalBytes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_TorrentAddedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, totalBytes);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbEngineEvent_TorrentAddedImplCopyWith<_$FrbEngineEvent_TorrentAddedImpl>
  get copyWith =>
      __$$FrbEngineEvent_TorrentAddedImplCopyWithImpl<
        _$FrbEngineEvent_TorrentAddedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return torrentAdded(id, name, totalBytes);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return torrentAdded?.call(id, name, totalBytes);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (torrentAdded != null) {
      return torrentAdded(id, name, totalBytes);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return torrentAdded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return torrentAdded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (torrentAdded != null) {
      return torrentAdded(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_TorrentAdded extends FrbEngineEvent {
  const factory FrbEngineEvent_TorrentAdded({
    required final BigInt id,
    final String? name,
    required final BigInt totalBytes,
  }) = _$FrbEngineEvent_TorrentAddedImpl;
  const FrbEngineEvent_TorrentAdded._() : super._();

  BigInt get id;
  String? get name;
  BigInt get totalBytes;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbEngineEvent_TorrentAddedImplCopyWith<_$FrbEngineEvent_TorrentAddedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbEngineEvent_MetadataReceivedImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_MetadataReceivedImplCopyWith(
    _$FrbEngineEvent_MetadataReceivedImpl value,
    $Res Function(_$FrbEngineEvent_MetadataReceivedImpl) then,
  ) = __$$FrbEngineEvent_MetadataReceivedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt id, String name, BigInt totalBytes});
}

/// @nodoc
class __$$FrbEngineEvent_MetadataReceivedImplCopyWithImpl<$Res>
    extends
        _$FrbEngineEventCopyWithImpl<
          $Res,
          _$FrbEngineEvent_MetadataReceivedImpl
        >
    implements _$$FrbEngineEvent_MetadataReceivedImplCopyWith<$Res> {
  __$$FrbEngineEvent_MetadataReceivedImplCopyWithImpl(
    _$FrbEngineEvent_MetadataReceivedImpl _value,
    $Res Function(_$FrbEngineEvent_MetadataReceivedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? totalBytes = null,
  }) {
    return _then(
      _$FrbEngineEvent_MetadataReceivedImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as BigInt,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        totalBytes: null == totalBytes
            ? _value.totalBytes
            : totalBytes // ignore: cast_nullable_to_non_nullable
                  as BigInt,
      ),
    );
  }
}

/// @nodoc

class _$FrbEngineEvent_MetadataReceivedImpl
    extends FrbEngineEvent_MetadataReceived {
  const _$FrbEngineEvent_MetadataReceivedImpl({
    required this.id,
    required this.name,
    required this.totalBytes,
  }) : super._();

  @override
  final BigInt id;
  @override
  final String name;
  @override
  final BigInt totalBytes;

  @override
  String toString() {
    return 'FrbEngineEvent.metadataReceived(id: $id, name: $name, totalBytes: $totalBytes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_MetadataReceivedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, totalBytes);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbEngineEvent_MetadataReceivedImplCopyWith<
    _$FrbEngineEvent_MetadataReceivedImpl
  >
  get copyWith =>
      __$$FrbEngineEvent_MetadataReceivedImplCopyWithImpl<
        _$FrbEngineEvent_MetadataReceivedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return metadataReceived(id, name, totalBytes);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return metadataReceived?.call(id, name, totalBytes);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (metadataReceived != null) {
      return metadataReceived(id, name, totalBytes);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return metadataReceived(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return metadataReceived?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (metadataReceived != null) {
      return metadataReceived(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_MetadataReceived extends FrbEngineEvent {
  const factory FrbEngineEvent_MetadataReceived({
    required final BigInt id,
    required final String name,
    required final BigInt totalBytes,
  }) = _$FrbEngineEvent_MetadataReceivedImpl;
  const FrbEngineEvent_MetadataReceived._() : super._();

  BigInt get id;
  String get name;
  BigInt get totalBytes;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbEngineEvent_MetadataReceivedImplCopyWith<
    _$FrbEngineEvent_MetadataReceivedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbEngineEvent_TorrentRemovedImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_TorrentRemovedImplCopyWith(
    _$FrbEngineEvent_TorrentRemovedImpl value,
    $Res Function(_$FrbEngineEvent_TorrentRemovedImpl) then,
  ) = __$$FrbEngineEvent_TorrentRemovedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt id});
}

/// @nodoc
class __$$FrbEngineEvent_TorrentRemovedImplCopyWithImpl<$Res>
    extends
        _$FrbEngineEventCopyWithImpl<$Res, _$FrbEngineEvent_TorrentRemovedImpl>
    implements _$$FrbEngineEvent_TorrentRemovedImplCopyWith<$Res> {
  __$$FrbEngineEvent_TorrentRemovedImplCopyWithImpl(
    _$FrbEngineEvent_TorrentRemovedImpl _value,
    $Res Function(_$FrbEngineEvent_TorrentRemovedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null}) {
    return _then(
      _$FrbEngineEvent_TorrentRemovedImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as BigInt,
      ),
    );
  }
}

/// @nodoc

class _$FrbEngineEvent_TorrentRemovedImpl
    extends FrbEngineEvent_TorrentRemoved {
  const _$FrbEngineEvent_TorrentRemovedImpl({required this.id}) : super._();

  @override
  final BigInt id;

  @override
  String toString() {
    return 'FrbEngineEvent.torrentRemoved(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_TorrentRemovedImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbEngineEvent_TorrentRemovedImplCopyWith<
    _$FrbEngineEvent_TorrentRemovedImpl
  >
  get copyWith =>
      __$$FrbEngineEvent_TorrentRemovedImplCopyWithImpl<
        _$FrbEngineEvent_TorrentRemovedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return torrentRemoved(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return torrentRemoved?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (torrentRemoved != null) {
      return torrentRemoved(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return torrentRemoved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return torrentRemoved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (torrentRemoved != null) {
      return torrentRemoved(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_TorrentRemoved extends FrbEngineEvent {
  const factory FrbEngineEvent_TorrentRemoved({required final BigInt id}) =
      _$FrbEngineEvent_TorrentRemovedImpl;
  const FrbEngineEvent_TorrentRemoved._() : super._();

  BigInt get id;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbEngineEvent_TorrentRemovedImplCopyWith<
    _$FrbEngineEvent_TorrentRemovedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbEngineEvent_DownloadStartedImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_DownloadStartedImplCopyWith(
    _$FrbEngineEvent_DownloadStartedImpl value,
    $Res Function(_$FrbEngineEvent_DownloadStartedImpl) then,
  ) = __$$FrbEngineEvent_DownloadStartedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt id});
}

/// @nodoc
class __$$FrbEngineEvent_DownloadStartedImplCopyWithImpl<$Res>
    extends
        _$FrbEngineEventCopyWithImpl<$Res, _$FrbEngineEvent_DownloadStartedImpl>
    implements _$$FrbEngineEvent_DownloadStartedImplCopyWith<$Res> {
  __$$FrbEngineEvent_DownloadStartedImplCopyWithImpl(
    _$FrbEngineEvent_DownloadStartedImpl _value,
    $Res Function(_$FrbEngineEvent_DownloadStartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null}) {
    return _then(
      _$FrbEngineEvent_DownloadStartedImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as BigInt,
      ),
    );
  }
}

/// @nodoc

class _$FrbEngineEvent_DownloadStartedImpl
    extends FrbEngineEvent_DownloadStarted {
  const _$FrbEngineEvent_DownloadStartedImpl({required this.id}) : super._();

  @override
  final BigInt id;

  @override
  String toString() {
    return 'FrbEngineEvent.downloadStarted(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_DownloadStartedImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbEngineEvent_DownloadStartedImplCopyWith<
    _$FrbEngineEvent_DownloadStartedImpl
  >
  get copyWith =>
      __$$FrbEngineEvent_DownloadStartedImplCopyWithImpl<
        _$FrbEngineEvent_DownloadStartedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return downloadStarted(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return downloadStarted?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (downloadStarted != null) {
      return downloadStarted(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return downloadStarted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return downloadStarted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (downloadStarted != null) {
      return downloadStarted(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_DownloadStarted extends FrbEngineEvent {
  const factory FrbEngineEvent_DownloadStarted({required final BigInt id}) =
      _$FrbEngineEvent_DownloadStartedImpl;
  const FrbEngineEvent_DownloadStarted._() : super._();

  BigInt get id;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbEngineEvent_DownloadStartedImplCopyWith<
    _$FrbEngineEvent_DownloadStartedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbEngineEvent_DownloadPausedImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_DownloadPausedImplCopyWith(
    _$FrbEngineEvent_DownloadPausedImpl value,
    $Res Function(_$FrbEngineEvent_DownloadPausedImpl) then,
  ) = __$$FrbEngineEvent_DownloadPausedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt id});
}

/// @nodoc
class __$$FrbEngineEvent_DownloadPausedImplCopyWithImpl<$Res>
    extends
        _$FrbEngineEventCopyWithImpl<$Res, _$FrbEngineEvent_DownloadPausedImpl>
    implements _$$FrbEngineEvent_DownloadPausedImplCopyWith<$Res> {
  __$$FrbEngineEvent_DownloadPausedImplCopyWithImpl(
    _$FrbEngineEvent_DownloadPausedImpl _value,
    $Res Function(_$FrbEngineEvent_DownloadPausedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null}) {
    return _then(
      _$FrbEngineEvent_DownloadPausedImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as BigInt,
      ),
    );
  }
}

/// @nodoc

class _$FrbEngineEvent_DownloadPausedImpl
    extends FrbEngineEvent_DownloadPaused {
  const _$FrbEngineEvent_DownloadPausedImpl({required this.id}) : super._();

  @override
  final BigInt id;

  @override
  String toString() {
    return 'FrbEngineEvent.downloadPaused(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_DownloadPausedImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbEngineEvent_DownloadPausedImplCopyWith<
    _$FrbEngineEvent_DownloadPausedImpl
  >
  get copyWith =>
      __$$FrbEngineEvent_DownloadPausedImplCopyWithImpl<
        _$FrbEngineEvent_DownloadPausedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return downloadPaused(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return downloadPaused?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (downloadPaused != null) {
      return downloadPaused(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return downloadPaused(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return downloadPaused?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (downloadPaused != null) {
      return downloadPaused(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_DownloadPaused extends FrbEngineEvent {
  const factory FrbEngineEvent_DownloadPaused({required final BigInt id}) =
      _$FrbEngineEvent_DownloadPausedImpl;
  const FrbEngineEvent_DownloadPaused._() : super._();

  BigInt get id;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbEngineEvent_DownloadPausedImplCopyWith<
    _$FrbEngineEvent_DownloadPausedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbEngineEvent_DownloadFinishedImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_DownloadFinishedImplCopyWith(
    _$FrbEngineEvent_DownloadFinishedImpl value,
    $Res Function(_$FrbEngineEvent_DownloadFinishedImpl) then,
  ) = __$$FrbEngineEvent_DownloadFinishedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt id});
}

/// @nodoc
class __$$FrbEngineEvent_DownloadFinishedImplCopyWithImpl<$Res>
    extends
        _$FrbEngineEventCopyWithImpl<
          $Res,
          _$FrbEngineEvent_DownloadFinishedImpl
        >
    implements _$$FrbEngineEvent_DownloadFinishedImplCopyWith<$Res> {
  __$$FrbEngineEvent_DownloadFinishedImplCopyWithImpl(
    _$FrbEngineEvent_DownloadFinishedImpl _value,
    $Res Function(_$FrbEngineEvent_DownloadFinishedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null}) {
    return _then(
      _$FrbEngineEvent_DownloadFinishedImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as BigInt,
      ),
    );
  }
}

/// @nodoc

class _$FrbEngineEvent_DownloadFinishedImpl
    extends FrbEngineEvent_DownloadFinished {
  const _$FrbEngineEvent_DownloadFinishedImpl({required this.id}) : super._();

  @override
  final BigInt id;

  @override
  String toString() {
    return 'FrbEngineEvent.downloadFinished(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_DownloadFinishedImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbEngineEvent_DownloadFinishedImplCopyWith<
    _$FrbEngineEvent_DownloadFinishedImpl
  >
  get copyWith =>
      __$$FrbEngineEvent_DownloadFinishedImplCopyWithImpl<
        _$FrbEngineEvent_DownloadFinishedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return downloadFinished(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return downloadFinished?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (downloadFinished != null) {
      return downloadFinished(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return downloadFinished(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return downloadFinished?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (downloadFinished != null) {
      return downloadFinished(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_DownloadFinished extends FrbEngineEvent {
  const factory FrbEngineEvent_DownloadFinished({required final BigInt id}) =
      _$FrbEngineEvent_DownloadFinishedImpl;
  const FrbEngineEvent_DownloadFinished._() : super._();

  BigInt get id;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbEngineEvent_DownloadFinishedImplCopyWith<
    _$FrbEngineEvent_DownloadFinishedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbEngineEvent_ProgressUpdateImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_ProgressUpdateImplCopyWith(
    _$FrbEngineEvent_ProgressUpdateImpl value,
    $Res Function(_$FrbEngineEvent_ProgressUpdateImpl) then,
  ) = __$$FrbEngineEvent_ProgressUpdateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt id, FrbTorrentInfo info});
}

/// @nodoc
class __$$FrbEngineEvent_ProgressUpdateImplCopyWithImpl<$Res>
    extends
        _$FrbEngineEventCopyWithImpl<$Res, _$FrbEngineEvent_ProgressUpdateImpl>
    implements _$$FrbEngineEvent_ProgressUpdateImplCopyWith<$Res> {
  __$$FrbEngineEvent_ProgressUpdateImplCopyWithImpl(
    _$FrbEngineEvent_ProgressUpdateImpl _value,
    $Res Function(_$FrbEngineEvent_ProgressUpdateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? info = null}) {
    return _then(
      _$FrbEngineEvent_ProgressUpdateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as BigInt,
        info: null == info
            ? _value.info
            : info // ignore: cast_nullable_to_non_nullable
                  as FrbTorrentInfo,
      ),
    );
  }
}

/// @nodoc

class _$FrbEngineEvent_ProgressUpdateImpl
    extends FrbEngineEvent_ProgressUpdate {
  const _$FrbEngineEvent_ProgressUpdateImpl({
    required this.id,
    required this.info,
  }) : super._();

  @override
  final BigInt id;
  @override
  final FrbTorrentInfo info;

  @override
  String toString() {
    return 'FrbEngineEvent.progressUpdate(id: $id, info: $info)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_ProgressUpdateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.info, info) || other.info == info));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, info);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbEngineEvent_ProgressUpdateImplCopyWith<
    _$FrbEngineEvent_ProgressUpdateImpl
  >
  get copyWith =>
      __$$FrbEngineEvent_ProgressUpdateImplCopyWithImpl<
        _$FrbEngineEvent_ProgressUpdateImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return progressUpdate(id, info);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return progressUpdate?.call(id, info);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (progressUpdate != null) {
      return progressUpdate(id, info);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return progressUpdate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return progressUpdate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (progressUpdate != null) {
      return progressUpdate(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_ProgressUpdate extends FrbEngineEvent {
  const factory FrbEngineEvent_ProgressUpdate({
    required final BigInt id,
    required final FrbTorrentInfo info,
  }) = _$FrbEngineEvent_ProgressUpdateImpl;
  const FrbEngineEvent_ProgressUpdate._() : super._();

  BigInt get id;
  FrbTorrentInfo get info;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbEngineEvent_ProgressUpdateImplCopyWith<
    _$FrbEngineEvent_ProgressUpdateImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbEngineEvent_PeerUpdateImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_PeerUpdateImplCopyWith(
    _$FrbEngineEvent_PeerUpdateImpl value,
    $Res Function(_$FrbEngineEvent_PeerUpdateImpl) then,
  ) = __$$FrbEngineEvent_PeerUpdateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt id, FrbPeerStats stats});
}

/// @nodoc
class __$$FrbEngineEvent_PeerUpdateImplCopyWithImpl<$Res>
    extends _$FrbEngineEventCopyWithImpl<$Res, _$FrbEngineEvent_PeerUpdateImpl>
    implements _$$FrbEngineEvent_PeerUpdateImplCopyWith<$Res> {
  __$$FrbEngineEvent_PeerUpdateImplCopyWithImpl(
    _$FrbEngineEvent_PeerUpdateImpl _value,
    $Res Function(_$FrbEngineEvent_PeerUpdateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? stats = null}) {
    return _then(
      _$FrbEngineEvent_PeerUpdateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as BigInt,
        stats: null == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as FrbPeerStats,
      ),
    );
  }
}

/// @nodoc

class _$FrbEngineEvent_PeerUpdateImpl extends FrbEngineEvent_PeerUpdate {
  const _$FrbEngineEvent_PeerUpdateImpl({required this.id, required this.stats})
    : super._();

  @override
  final BigInt id;
  @override
  final FrbPeerStats stats;

  @override
  String toString() {
    return 'FrbEngineEvent.peerUpdate(id: $id, stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_PeerUpdateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, stats);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbEngineEvent_PeerUpdateImplCopyWith<_$FrbEngineEvent_PeerUpdateImpl>
  get copyWith =>
      __$$FrbEngineEvent_PeerUpdateImplCopyWithImpl<
        _$FrbEngineEvent_PeerUpdateImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return peerUpdate(id, stats);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return peerUpdate?.call(id, stats);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (peerUpdate != null) {
      return peerUpdate(id, stats);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return peerUpdate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return peerUpdate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (peerUpdate != null) {
      return peerUpdate(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_PeerUpdate extends FrbEngineEvent {
  const factory FrbEngineEvent_PeerUpdate({
    required final BigInt id,
    required final FrbPeerStats stats,
  }) = _$FrbEngineEvent_PeerUpdateImpl;
  const FrbEngineEvent_PeerUpdate._() : super._();

  BigInt get id;
  FrbPeerStats get stats;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbEngineEvent_PeerUpdateImplCopyWith<_$FrbEngineEvent_PeerUpdateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbEngineEvent_PeerConnectedImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_PeerConnectedImplCopyWith(
    _$FrbEngineEvent_PeerConnectedImpl value,
    $Res Function(_$FrbEngineEvent_PeerConnectedImpl) then,
  ) = __$$FrbEngineEvent_PeerConnectedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt id, String peerAddr});
}

/// @nodoc
class __$$FrbEngineEvent_PeerConnectedImplCopyWithImpl<$Res>
    extends
        _$FrbEngineEventCopyWithImpl<$Res, _$FrbEngineEvent_PeerConnectedImpl>
    implements _$$FrbEngineEvent_PeerConnectedImplCopyWith<$Res> {
  __$$FrbEngineEvent_PeerConnectedImplCopyWithImpl(
    _$FrbEngineEvent_PeerConnectedImpl _value,
    $Res Function(_$FrbEngineEvent_PeerConnectedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? peerAddr = null}) {
    return _then(
      _$FrbEngineEvent_PeerConnectedImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as BigInt,
        peerAddr: null == peerAddr
            ? _value.peerAddr
            : peerAddr // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FrbEngineEvent_PeerConnectedImpl extends FrbEngineEvent_PeerConnected {
  const _$FrbEngineEvent_PeerConnectedImpl({
    required this.id,
    required this.peerAddr,
  }) : super._();

  @override
  final BigInt id;
  @override
  final String peerAddr;

  @override
  String toString() {
    return 'FrbEngineEvent.peerConnected(id: $id, peerAddr: $peerAddr)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_PeerConnectedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.peerAddr, peerAddr) ||
                other.peerAddr == peerAddr));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, peerAddr);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbEngineEvent_PeerConnectedImplCopyWith<
    _$FrbEngineEvent_PeerConnectedImpl
  >
  get copyWith =>
      __$$FrbEngineEvent_PeerConnectedImplCopyWithImpl<
        _$FrbEngineEvent_PeerConnectedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return peerConnected(id, peerAddr);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return peerConnected?.call(id, peerAddr);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (peerConnected != null) {
      return peerConnected(id, peerAddr);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return peerConnected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return peerConnected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (peerConnected != null) {
      return peerConnected(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_PeerConnected extends FrbEngineEvent {
  const factory FrbEngineEvent_PeerConnected({
    required final BigInt id,
    required final String peerAddr,
  }) = _$FrbEngineEvent_PeerConnectedImpl;
  const FrbEngineEvent_PeerConnected._() : super._();

  BigInt get id;
  String get peerAddr;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbEngineEvent_PeerConnectedImplCopyWith<
    _$FrbEngineEvent_PeerConnectedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbEngineEvent_PeerDisconnectedImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_PeerDisconnectedImplCopyWith(
    _$FrbEngineEvent_PeerDisconnectedImpl value,
    $Res Function(_$FrbEngineEvent_PeerDisconnectedImpl) then,
  ) = __$$FrbEngineEvent_PeerDisconnectedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt id, String peerAddr, String reason});
}

/// @nodoc
class __$$FrbEngineEvent_PeerDisconnectedImplCopyWithImpl<$Res>
    extends
        _$FrbEngineEventCopyWithImpl<
          $Res,
          _$FrbEngineEvent_PeerDisconnectedImpl
        >
    implements _$$FrbEngineEvent_PeerDisconnectedImplCopyWith<$Res> {
  __$$FrbEngineEvent_PeerDisconnectedImplCopyWithImpl(
    _$FrbEngineEvent_PeerDisconnectedImpl _value,
    $Res Function(_$FrbEngineEvent_PeerDisconnectedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? peerAddr = null,
    Object? reason = null,
  }) {
    return _then(
      _$FrbEngineEvent_PeerDisconnectedImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as BigInt,
        peerAddr: null == peerAddr
            ? _value.peerAddr
            : peerAddr // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FrbEngineEvent_PeerDisconnectedImpl
    extends FrbEngineEvent_PeerDisconnected {
  const _$FrbEngineEvent_PeerDisconnectedImpl({
    required this.id,
    required this.peerAddr,
    required this.reason,
  }) : super._();

  @override
  final BigInt id;
  @override
  final String peerAddr;
  @override
  final String reason;

  @override
  String toString() {
    return 'FrbEngineEvent.peerDisconnected(id: $id, peerAddr: $peerAddr, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_PeerDisconnectedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.peerAddr, peerAddr) ||
                other.peerAddr == peerAddr) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, peerAddr, reason);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbEngineEvent_PeerDisconnectedImplCopyWith<
    _$FrbEngineEvent_PeerDisconnectedImpl
  >
  get copyWith =>
      __$$FrbEngineEvent_PeerDisconnectedImplCopyWithImpl<
        _$FrbEngineEvent_PeerDisconnectedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return peerDisconnected(id, peerAddr, reason);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return peerDisconnected?.call(id, peerAddr, reason);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (peerDisconnected != null) {
      return peerDisconnected(id, peerAddr, reason);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return peerDisconnected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return peerDisconnected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (peerDisconnected != null) {
      return peerDisconnected(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_PeerDisconnected extends FrbEngineEvent {
  const factory FrbEngineEvent_PeerDisconnected({
    required final BigInt id,
    required final String peerAddr,
    required final String reason,
  }) = _$FrbEngineEvent_PeerDisconnectedImpl;
  const FrbEngineEvent_PeerDisconnected._() : super._();

  BigInt get id;
  String get peerAddr;
  String get reason;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbEngineEvent_PeerDisconnectedImplCopyWith<
    _$FrbEngineEvent_PeerDisconnectedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbEngineEvent_ResumeSavedImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_ResumeSavedImplCopyWith(
    _$FrbEngineEvent_ResumeSavedImpl value,
    $Res Function(_$FrbEngineEvent_ResumeSavedImpl) then,
  ) = __$$FrbEngineEvent_ResumeSavedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt id});
}

/// @nodoc
class __$$FrbEngineEvent_ResumeSavedImplCopyWithImpl<$Res>
    extends _$FrbEngineEventCopyWithImpl<$Res, _$FrbEngineEvent_ResumeSavedImpl>
    implements _$$FrbEngineEvent_ResumeSavedImplCopyWith<$Res> {
  __$$FrbEngineEvent_ResumeSavedImplCopyWithImpl(
    _$FrbEngineEvent_ResumeSavedImpl _value,
    $Res Function(_$FrbEngineEvent_ResumeSavedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null}) {
    return _then(
      _$FrbEngineEvent_ResumeSavedImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as BigInt,
      ),
    );
  }
}

/// @nodoc

class _$FrbEngineEvent_ResumeSavedImpl extends FrbEngineEvent_ResumeSaved {
  const _$FrbEngineEvent_ResumeSavedImpl({required this.id}) : super._();

  @override
  final BigInt id;

  @override
  String toString() {
    return 'FrbEngineEvent.resumeSaved(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_ResumeSavedImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbEngineEvent_ResumeSavedImplCopyWith<_$FrbEngineEvent_ResumeSavedImpl>
  get copyWith =>
      __$$FrbEngineEvent_ResumeSavedImplCopyWithImpl<
        _$FrbEngineEvent_ResumeSavedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return resumeSaved(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return resumeSaved?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (resumeSaved != null) {
      return resumeSaved(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return resumeSaved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return resumeSaved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (resumeSaved != null) {
      return resumeSaved(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_ResumeSaved extends FrbEngineEvent {
  const factory FrbEngineEvent_ResumeSaved({required final BigInt id}) =
      _$FrbEngineEvent_ResumeSavedImpl;
  const FrbEngineEvent_ResumeSaved._() : super._();

  BigInt get id;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbEngineEvent_ResumeSavedImplCopyWith<_$FrbEngineEvent_ResumeSavedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FrbEngineEvent_ErrorImplCopyWith<$Res> {
  factory _$$FrbEngineEvent_ErrorImplCopyWith(
    _$FrbEngineEvent_ErrorImpl value,
    $Res Function(_$FrbEngineEvent_ErrorImpl) then,
  ) = __$$FrbEngineEvent_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt? id, String message, bool fatal});
}

/// @nodoc
class __$$FrbEngineEvent_ErrorImplCopyWithImpl<$Res>
    extends _$FrbEngineEventCopyWithImpl<$Res, _$FrbEngineEvent_ErrorImpl>
    implements _$$FrbEngineEvent_ErrorImplCopyWith<$Res> {
  __$$FrbEngineEvent_ErrorImplCopyWithImpl(
    _$FrbEngineEvent_ErrorImpl _value,
    $Res Function(_$FrbEngineEvent_ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? message = null,
    Object? fatal = null,
  }) {
    return _then(
      _$FrbEngineEvent_ErrorImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as BigInt?,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        fatal: null == fatal
            ? _value.fatal
            : fatal // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$FrbEngineEvent_ErrorImpl extends FrbEngineEvent_Error {
  const _$FrbEngineEvent_ErrorImpl({
    this.id,
    required this.message,
    required this.fatal,
  }) : super._();

  @override
  final BigInt? id;
  @override
  final String message;
  @override
  final bool fatal;

  @override
  String toString() {
    return 'FrbEngineEvent.error(id: $id, message: $message, fatal: $fatal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrbEngineEvent_ErrorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.fatal, fatal) || other.fatal == fatal));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, message, fatal);

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrbEngineEvent_ErrorImplCopyWith<_$FrbEngineEvent_ErrorImpl>
  get copyWith =>
      __$$FrbEngineEvent_ErrorImplCopyWithImpl<_$FrbEngineEvent_ErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() sessionStarted,
    required TResult Function() sessionStopped,
    required TResult Function(BigInt id, String? name, BigInt totalBytes)
    torrentAdded,
    required TResult Function(BigInt id, String name, BigInt totalBytes)
    metadataReceived,
    required TResult Function(BigInt id) torrentRemoved,
    required TResult Function(BigInt id) downloadStarted,
    required TResult Function(BigInt id) downloadPaused,
    required TResult Function(BigInt id) downloadFinished,
    required TResult Function(BigInt id, FrbTorrentInfo info) progressUpdate,
    required TResult Function(BigInt id, FrbPeerStats stats) peerUpdate,
    required TResult Function(BigInt id, String peerAddr) peerConnected,
    required TResult Function(BigInt id, String peerAddr, String reason)
    peerDisconnected,
    required TResult Function(BigInt id) resumeSaved,
    required TResult Function(BigInt? id, String message, bool fatal) error,
  }) {
    return error(id, message, fatal);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? sessionStarted,
    TResult? Function()? sessionStopped,
    TResult? Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult? Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult? Function(BigInt id)? torrentRemoved,
    TResult? Function(BigInt id)? downloadStarted,
    TResult? Function(BigInt id)? downloadPaused,
    TResult? Function(BigInt id)? downloadFinished,
    TResult? Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult? Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult? Function(BigInt id, String peerAddr)? peerConnected,
    TResult? Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult? Function(BigInt id)? resumeSaved,
    TResult? Function(BigInt? id, String message, bool fatal)? error,
  }) {
    return error?.call(id, message, fatal);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? sessionStarted,
    TResult Function()? sessionStopped,
    TResult Function(BigInt id, String? name, BigInt totalBytes)? torrentAdded,
    TResult Function(BigInt id, String name, BigInt totalBytes)?
    metadataReceived,
    TResult Function(BigInt id)? torrentRemoved,
    TResult Function(BigInt id)? downloadStarted,
    TResult Function(BigInt id)? downloadPaused,
    TResult Function(BigInt id)? downloadFinished,
    TResult Function(BigInt id, FrbTorrentInfo info)? progressUpdate,
    TResult Function(BigInt id, FrbPeerStats stats)? peerUpdate,
    TResult Function(BigInt id, String peerAddr)? peerConnected,
    TResult Function(BigInt id, String peerAddr, String reason)?
    peerDisconnected,
    TResult Function(BigInt id)? resumeSaved,
    TResult Function(BigInt? id, String message, bool fatal)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(id, message, fatal);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FrbEngineEvent_SessionStarted value)
    sessionStarted,
    required TResult Function(FrbEngineEvent_SessionStopped value)
    sessionStopped,
    required TResult Function(FrbEngineEvent_TorrentAdded value) torrentAdded,
    required TResult Function(FrbEngineEvent_MetadataReceived value)
    metadataReceived,
    required TResult Function(FrbEngineEvent_TorrentRemoved value)
    torrentRemoved,
    required TResult Function(FrbEngineEvent_DownloadStarted value)
    downloadStarted,
    required TResult Function(FrbEngineEvent_DownloadPaused value)
    downloadPaused,
    required TResult Function(FrbEngineEvent_DownloadFinished value)
    downloadFinished,
    required TResult Function(FrbEngineEvent_ProgressUpdate value)
    progressUpdate,
    required TResult Function(FrbEngineEvent_PeerUpdate value) peerUpdate,
    required TResult Function(FrbEngineEvent_PeerConnected value) peerConnected,
    required TResult Function(FrbEngineEvent_PeerDisconnected value)
    peerDisconnected,
    required TResult Function(FrbEngineEvent_ResumeSaved value) resumeSaved,
    required TResult Function(FrbEngineEvent_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult? Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult? Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult? Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult? Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult? Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult? Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult? Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult? Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult? Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult? Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult? Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult? Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult? Function(FrbEngineEvent_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FrbEngineEvent_SessionStarted value)? sessionStarted,
    TResult Function(FrbEngineEvent_SessionStopped value)? sessionStopped,
    TResult Function(FrbEngineEvent_TorrentAdded value)? torrentAdded,
    TResult Function(FrbEngineEvent_MetadataReceived value)? metadataReceived,
    TResult Function(FrbEngineEvent_TorrentRemoved value)? torrentRemoved,
    TResult Function(FrbEngineEvent_DownloadStarted value)? downloadStarted,
    TResult Function(FrbEngineEvent_DownloadPaused value)? downloadPaused,
    TResult Function(FrbEngineEvent_DownloadFinished value)? downloadFinished,
    TResult Function(FrbEngineEvent_ProgressUpdate value)? progressUpdate,
    TResult Function(FrbEngineEvent_PeerUpdate value)? peerUpdate,
    TResult Function(FrbEngineEvent_PeerConnected value)? peerConnected,
    TResult Function(FrbEngineEvent_PeerDisconnected value)? peerDisconnected,
    TResult Function(FrbEngineEvent_ResumeSaved value)? resumeSaved,
    TResult Function(FrbEngineEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class FrbEngineEvent_Error extends FrbEngineEvent {
  const factory FrbEngineEvent_Error({
    final BigInt? id,
    required final String message,
    required final bool fatal,
  }) = _$FrbEngineEvent_ErrorImpl;
  const FrbEngineEvent_Error._() : super._();

  BigInt? get id;
  String get message;
  bool get fatal;

  /// Create a copy of FrbEngineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrbEngineEvent_ErrorImplCopyWith<_$FrbEngineEvent_ErrorImpl>
  get copyWith => throw _privateConstructorUsedError;
}
