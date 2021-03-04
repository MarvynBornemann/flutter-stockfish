import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

class Stockfish {
  final state = ValueNotifier(StockfishState.starting);

  Stockfish._() {
    compute(_initCallback, null).then(
      (_) => state.value = StockfishState.ready,
      onError: (_) => state.value = StockfishState.error,
    );
  }

  Future<String> getOutputBuffer() => compute(_getOutputBufferCallback, null);

  Future<String> uci(String command) => compute(_uciCallback, command);

  Future<void> dispose() => compute(_disposeCallback, null);

  static Stockfish _instance;
  static Stockfish get instance => _instance ??= Stockfish._();
}

enum StockfishState {
  error,
  ready,
  starting,
}

final _lib = Platform.isAndroid
    ? DynamicLibrary.open('libstockfish.so')
    : DynamicLibrary.process();

Future<void> _initCallback(Null _) async => _initNative();

final void Function() _initNative =
    _lib.lookup<NativeFunction<Void Function()>>('stockfish_init').asFunction();

Future<String> _getOutputBufferCallback(Null _) async {
  final pointer = _getOutputBufferNative();
  final string = Utf8.fromUtf8(pointer);
  free(pointer);

  return string;
}

final Pointer<Utf8> Function() _getOutputBufferNative = _lib
    .lookup<NativeFunction<Pointer<Utf8> Function()>>('stockfish_get_output_buffer')
    .asFunction();

Future<String> _uciCallback(String command) async {
  final commandPointer = Utf8.toUtf8(command);

  final resultPointer = _uciNative(commandPointer);
  final result = Utf8.fromUtf8(resultPointer);
  free(resultPointer);
  free(commandPointer);

  return result;
}

final Pointer<Utf8> Function(Pointer<Utf8>) _uciNative = _lib
    .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>(
        'stockfish_uci')
    .asFunction();

Future<void> _disposeCallback(Null _) async => _disposeNative();

final void Function() _disposeNative =
    _lib.lookup<NativeFunction<Void Function()>>('stockfish_dispose').asFunction();
