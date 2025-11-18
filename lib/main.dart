import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo/bloc/authbloc/auth_bloc.dart';
import 'package:ludo/blocs/dashboardbloc/dashboard_bloc.dart';
import 'package:ludo/blocs/dashboardbloc/dashboard_event.dart';
import 'package:ludo/myApp.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => DashboardBloc()..add(LoadDashboardData())),
      ],
      child: MyApp(),
    ),
  );
}
