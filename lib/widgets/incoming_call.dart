import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ludo/bloc/callbloc/call_bloc.dart';
import 'package:ludo/bloc/callbloc/call_event.dart';
import 'package:ludo/model/call_model.dart';
import 'dart:async';

class IncomingCallWidget extends StatefulWidget {
  final CallModel call;

  const IncomingCallWidget({Key? key, required this.call}) : super(key: key);

  @override
  State<IncomingCallWidget> createState() => _IncomingCallWidgetState();
}

class _IncomingCallWidgetState extends State<IncomingCallWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _buttonLocked = false;
  bool _instantReady = false;
  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeIn));

    _pulseController.repeat(reverse: true);
    _slideController.forward();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _instantReady = true;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.indigo.shade800,
                Colors.indigo.shade900,
                Colors.black87,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 50.h),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Incoming Call',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 40.w,
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60.h),
                Expanded(flex: 3, child: _buildCallerInfo()),
                Expanded(
                  flex: 1,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildActionButtons(),
                    ),
                  ),
                ),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallerInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 170.w,
                height: 170.h,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 85.r,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  child: widget.call.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            widget.call.avatar!,
                            width: 170.w,
                            height: 170.h,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 32.h),
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            widget.call.name,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
        SizedBox(height: 8.h),
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            widget.call.phoneNumber,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Center(
        child: Text(
          widget.call.name.isNotEmpty ? widget.call.name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 60.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 80.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: Icons.call_end,
            color: Colors.red.shade600,
            onTap: _declineCall,
          ),
          _buildActionButton(
            icon: Icons.call,
            color: Colors.green.shade600,
            onTap: _acceptCall,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        if (_buttonLocked || !_instantReady) return;
        onTap();
      },
      borderRadius: BorderRadius.circular(40.r),
      child: Container(
        width: 75.w,
        height: 75.h,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 36.sp),
      ),
    );
  }

  void _acceptCall() {
    context.read<CallBloc>().add(AnswerCall(callId: widget.call.id));
    Navigator.pop(context);
  }

  void _declineCall() {
    context.read<CallBloc>().add(EndCall(callId: widget.call.id));
    Navigator.pop(context);
  }
}
