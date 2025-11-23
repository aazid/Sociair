import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  int _messages = 128;
  int _calls = 24;
  int _posts = 18;
  double _engagement = 4.8;
  
  
  double _previousEngagement = 4.8; 

  Timer? _ticker;

  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoad);
    on<SimulateUpdate>(_onSimulate);
    on<ManualRefresh>(_onManualRefresh);
  }

  void _onLoad(LoadDashboardData event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    await Future.delayed(const Duration(milliseconds: 700));
    emit(_currentLoaded());
    _ticker ??= Timer.periodic(const Duration(seconds: 4), (_) {
      add(SimulateUpdate());
    });
  }

  void _onSimulate(SimulateUpdate event, Emitter<DashboardState> emit) {
    _previousEngagement = _engagement;

    _messages = (_messages + _randBetween(-5, 5)).clamp(0, 119);

    _calls = (_calls + _randBetween(-3, 3)).clamp(0, 69);

    _posts = (_posts + _randBetween(-2, 2)).clamp(0, 53);

    _engagement = (_engagement + (_randBetween(-5, 5) / 10)).clamp(1.0, 12.0);
    emit(_currentLoaded());
  }

  void _onManualRefresh(
    ManualRefresh event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(_currentLoaded());
  }

  DashboardLoaded _currentLoaded() {
    return DashboardLoaded(
      totalMessages: _messages,
      totalCalls: _calls,
      totalPosts: _posts,
      engagementRate: double.parse(_engagement.toStringAsFixed(1)),
    );
  }

  int _randBetween(int a, int b) =>
      a + (b == 0 ? 0 : DateTime.now().millisecondsSinceEpoch % (b - a + 1));

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
