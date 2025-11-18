import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo/bloc/authbloc/auth_bloc.dart';
import 'package:ludo/bloc/authbloc/auth_event.dart';
import 'package:ludo/bloc/authbloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _email = TextEditingController(text: 'demo@sociair.com');
  final _pass = TextEditingController(text: '1234');
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _anim.forward();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 900 ? 480.0 : width * 0.92;

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _anim,
          child: Container(
            width: cardWidth,
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.air,
                            color: Colors.indigo,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Sociair',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sign in to continue to your dashboard',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    SizedBox(height: 18),
                    TextField(
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _pass,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                context.read<AuthBloc>().add(
                                  LoginRequested(
                                    email: _email.text,
                                    password: _pass.text,
                                  ),
                                );
                              },
                        child: state is AuthLoading
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Sign in',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        _email.text = 'demo@sociair.com';
                        _pass.text = '1234';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Demo credentials filled')),
                        );
                      },
                      child: Text(
                        'Use demo credentials',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
