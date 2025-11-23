import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ludo/bloc/authbloc/auth_bloc.dart';
import 'package:ludo/bloc/authbloc/auth_state.dart';
import 'package:ludo/screens/splash_screen.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: Color(0xFFF7F9FB),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: false,
      ),
    );

    return ScreenUtilInit(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sociair Demo',
        theme: theme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoaded) return LoginScreen();
            return SplashScreen();
          },
        ),
      ),
    );
  }
}
