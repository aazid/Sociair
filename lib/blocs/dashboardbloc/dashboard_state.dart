// import 'package:ludo/blocs/dashboardbloc/dashboard_bloc.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalMessages;
  final int totalCalls;
  final int totalPosts;
  final double engagementRate;

  DashboardLoaded({
    required this.totalCalls,
    required this.totalMessages,
    required this.totalPosts,
    required this.engagementRate,
  });
}
