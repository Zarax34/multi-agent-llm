import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:multi_agent_llm/data/models/ollama_instance.dart';
import 'package:multi_agent_llm/core/network/ollama_discovery.dart';
import 'package:multi_agent_llm/services/hive_service.dart';

// Events
abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();
  @override
  List<Object?> get props => [];
}

class StartScan extends DiscoveryEvent {
  final String? subnet;
  const StartScan({this.subnet});
  @override
  List<Object?> get props => [subnet];
}

class StopScan extends DiscoveryEvent {}

class InstanceFound extends DiscoveryEvent {
  final OllamaInstance instance;
  const InstanceFound(this.instance);
  @override
  List<Object?> get props => [instance];
}

class ScanComplete extends DiscoveryEvent {}

class AddManualInstance extends DiscoveryEvent {
  final String ip;
  final int port;
  const AddManualInstance({required this.ip, this.port = 11434});
  @override
  List<Object?> get props => [ip, port];
}

class RemoveInstance extends DiscoveryEvent {
  final String ip;
  const RemoveInstance(this.ip);
  @override
  List<Object?> get props => [ip];
}

class LoadSavedInstances extends DiscoveryEvent {}

class TestConnection extends DiscoveryEvent {
  final String ip;
  final int port;
  const TestConnection({required this.ip, this.port = 11434});
  @override
  List<Object?> get props => [ip, port];
}

// State
class DiscoveryState extends Equatable {
  final List<OllamaInstance> instances;
  final bool isScanning;
  final int scannedCount;
  final int totalToScan;
  final String? error;
  final String? testResult;

  const DiscoveryState({
    this.instances = const [],
    this.isScanning = false,
    this.scannedCount = 0,
    this.totalToScan = 254,
    this.error,
    this.testResult,
  });

  DiscoveryState copyWith({
    List<OllamaInstance>? instances,
    bool? isScanning,
    int? scannedCount,
    int? totalToScan,
    String? error,
    String? testResult,
  }) {
    return DiscoveryState(
      instances: instances ?? this.instances,
      isScanning: isScanning ?? this.isScanning,
      scannedCount: scannedCount ?? this.scannedCount,
      totalToScan: totalToScan ?? this.totalToScan,
      error: error,
      testResult: testResult,
    );
  }

  @override
  List<Object?> get props => [instances, isScanning, scannedCount, totalToScan, error, testResult];
}

// BLoC
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final HiveService _hiveService = HiveService();
  StreamSubscription<OllamaInstance>? _scanSubscription;

  DiscoveryBloc() : super(const DiscoveryState()) {
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<InstanceFound>(_onInstanceFound);
    on<ScanComplete>(_onScanComplete);
    on<AddManualInstance>(_onAddManualInstance);
    on<RemoveInstance>(_onRemoveInstance);
    on<LoadSavedInstances>(_onLoadSavedInstances);
    on<TestConnection>(_onTestConnection);
  }

  void _onStartScan(StartScan event, Emitter<DiscoveryState> emit) {
    emit(state.copyWith(isScanning: true, scannedCount: 0, error: null));

    _scanSubscription?.cancel();
    int count = 0;

    _scanSubscription = OllamaDiscovery.scanNetwork(subnet: event.subnet).listen(
      (instance) {
        count++;
        add(InstanceFound(instance));
      },
      onDone: () => add(ScanComplete()),
      onError: (error) {
        emit(state.copyWith(isScanning: false, error: error.toString()));
      },
    );
  }

  void _onStopScan(StopScan event, Emitter<DiscoveryState> emit) {
    _scanSubscription?.cancel();
    emit(state.copyWith(isScanning: false));
  }

  void _onInstanceFound(InstanceFound event, Emitter<DiscoveryState> emit) async {
    final instances = List<OllamaInstance>.from(state.instances);

    // Avoid duplicates
    if (!instances.any((i) => i.ip == event.instance.ip)) {
      instances.add(event.instance);
      await _hiveService.saveOllamaInstance(event.instance);
    }

    emit(state.copyWith(
      instances: instances,
      scannedCount: state.scannedCount + 1,
    ));
  }

  void _onScanComplete(ScanComplete event, Emitter<DiscoveryState> emit) {
    emit(state.copyWith(isScanning: false));
  }

  void _onAddManualInstance(AddManualInstance event, Emitter<DiscoveryState> emit) async {
    final instance = OllamaInstance(
      ip: event.ip,
      port: event.port,
      isOnline: true,
      lastSeen: DateTime.now(),
    );

    final instances = List<OllamaInstance>.from(state.instances);
    if (!instances.any((i) => i.ip == event.ip)) {
      instances.add(instance);
      await _hiveService.saveOllamaInstance(instance);
    }

    emit(state.copyWith(instances: instances));
  }

  void _onRemoveInstance(RemoveInstance event, Emitter<DiscoveryState> emit) async {
    final instances = state.instances.where((i) => i.ip != event.ip).toList();
    await _hiveService.deleteOllamaInstance(event.ip);
    emit(state.copyWith(instances: instances));
  }

  void _onLoadSavedInstances(LoadSavedInstances event, Emitter<DiscoveryState> emit) {
    final instances = _hiveService.getOllamaInstances();
    emit(state.copyWith(instances: instances));
  }

  void _onTestConnection(TestConnection event, Emitter<DiscoveryState> emit) async {
    final result = await OllamaDiscovery.testConnection(event.ip, port: event.port);
    emit(state.copyWith(
      testResult: result ? 'Connected successfully' : 'Connection failed',
    ));
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
}
