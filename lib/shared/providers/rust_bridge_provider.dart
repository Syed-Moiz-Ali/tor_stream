import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bridge/bridge.dart';

final rustBridgeInitProvider = FutureProvider<bool>((ref) async {
  try {
    await RustLib.init();
    return true;
  } catch (e) {
    return false;
  }
});

final engineInfoProvider = FutureProvider<EngineInfo>((ref) async {
  await ref.watch(rustBridgeInitProvider.future);
  return getEngineInfo();
});

final engineHealthProvider = FutureProvider<bool>((ref) async {
  await ref.watch(rustBridgeInitProvider.future);
  return ping();
});
