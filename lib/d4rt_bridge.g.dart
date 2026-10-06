// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'd4rt_bridge.dart';

// **************************************************************************
// D4rtBridgeGenerator
// **************************************************************************

/// Generated bridge for D4rtBridgeImpl.
///
/// Do not modify by hand.

/// Bridge definition for [D4rtBridgeImpl].
final d4rtBridgeImplBridge = BridgedClass(
  name: 'D4rtBridgeImpl',
  nativeType: D4rtBridgeImpl,
  staticMethods: {
    'fn': (visitor, positionalArgs, namedArgs) {
      positionalArgs.requireExactCount(2, 'D4rtBridgeImpl.fn');
      return D4rtBridgeImpl.fn(
        positionalArgs.required<String>(0, 'formulaName'),
        positionalArgs.extractMap<String, dynamic>(1, 'inputValues'),
      );
    },
  },
);

/// Register all d4rt_bridge bridges from this file with the interpreter.
void registerD4rtBridgeBridges(D4rt interpreter) {
  // ignore: unused_local_variable
  const defaultUri = 'd4rt_bridge.dart';

  interpreter.registerBridgedClass(
    d4rtBridgeImplBridge,
    'package:formulas/runtime_bridge.dart',
  );
}
