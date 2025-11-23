import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/callbloc/call_bloc.dart';
import '../bloc/callbloc/call_event.dart';
import '../bloc/callbloc/call_state.dart';
import '../model/call_model.dart';
import '../widgets/callhistory.dart' as CallHistoryWidget;

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _dialController = TextEditingController();
  String _dialedNumber = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load call history when screen opens
    context.read<CallBloc>().add(LoadCallHistory());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallBloc, CallState>(
      listener: (context, state) {
        if (state is CallInProgress) {
          _showActiveCallScreen(context, state.activeCall);
        } else if (state is IncomingCallState) {
          _showIncomingCallScreen(context, state.call);
        } else if (state is CallError) {
          _showErrorSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'Call Center',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),

        body: TabBarView(
          controller: _tabController,
          children: [
            _buildRecentsTab(),
            _buildContactsTab(),
            _buildKeypadTab(),
          ],
        ),

        bottomNavigationBar: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Recents', icon: Icon(Icons.history)),
              Tab(text: 'Contacts', icon: Icon(Icons.contacts)),
              Tab(text: 'Keypad', icon: Icon(Icons.dialpad)),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showMakeCallDialog(context);
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add_call, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRecentsTab() {
    return BlocBuilder<CallBloc, CallState>(
      builder: (context, state) {
        if (state is CallLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CallHistoryLoaded) {
          if (state.calls.isEmpty) {
            return _buildEmptyState('No recent calls', Icons.call);
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CallBloc>().add(LoadCallHistory());
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.calls.length,
              itemBuilder: (context, index) {
                final call = state.calls[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: CallHistoryWidget.CallHistory(
                    call: call,
                    onTap: () => _makeCall(call.name, call.phoneNumber),
                  ),
                );
              },
            ),
          );
        } else if (state is CallError) {
          return _buildErrorState(state.message);
        }
        return _buildEmptyState('Tap refresh to load calls', Icons.refresh);
      },
    );
  }

  Widget _buildContactsTab() {
    final contacts = _getDefaultContacts();

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                contact['name']![0],
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              contact['name']!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(contact['phone']!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () =>
                      _makeCall(contact['name']!, contact['phone']!),
                  icon: const Icon(Icons.call, color: Colors.green),
                ),
                IconButton(
                  onPressed: () => _sendMessage(contact['phone']!),
                  icon: const Icon(Icons.message, color: Colors.blue),
                ),
              ],
            ),
            onTap: () => _makeCall(contact['name']!, contact['phone']!),
          ),
        );
      },
    );
  }

  Widget _buildKeypadTab() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          // Display area
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.h),
            margin: EdgeInsets.only(bottom: 32.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _dialedNumber.isEmpty ? '' : _dialedNumber,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w500,
                color: _dialedNumber.isEmpty ? Colors.grey : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 0.3.h),
          // Keypad
          SizedBox(
            height: 280.h,
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(12, (index) => _buildKeypadButton(index)),
            ),
          ),
          // Action buttons
          SizedBox(height: 28.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.backspace,
                onPressed: _deleteLast,
                color: Colors.red.shade400,
              ),
              _buildActionButton(
                icon: Icons.call,
                onPressed: _dialedNumber.isNotEmpty ? _callFromKeypad : null,
                color: Colors.green,
                size: 60.w,
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(int index) {
    final keypadValues = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '*',
      '0',
      '#',
    ];

    final keypadLetters = [
      '',
      'ABC',
      'DEF',
      'GHI',
      'JKL',
      'MNO',
      'PQRS',
      'TUV',
      'WXYZ',
      '',
      '+',
      '',
    ];

    return GestureDetector(
      onTap: () => _addDigit(keypadValues[index]),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              keypadValues[index],
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (keypadLetters[index].isNotEmpty)
              Text(
                keypadLetters[index],
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                  letterSpacing: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    double size = 50,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size.w,
        height: size.h,
        decoration: BoxDecoration(
          color: onPressed != null ? color : Colors.grey.shade300,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: (size * 0.5).sp),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red.shade400),
          SizedBox(height: 16.h),
          Text(
            error,
            style: TextStyle(fontSize: 16.sp, color: Colors.red.shade600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<CallBloc>().add(LoadCallHistory()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _addDigit(String digit) {
    setState(() {
      _dialedNumber += digit;
    });
  }

  void _deleteLast() {
    if (_dialedNumber.isNotEmpty) {
      setState(() {
        _dialedNumber = _dialedNumber.substring(0, _dialedNumber.length - 1);
      });
    }
  }

  void _clearAll() {
    setState(() {
      _dialedNumber = '';
    });
  }

  void _callFromKeypad() {
    if (_dialedNumber.isNotEmpty) {
      _makeCall('Unknown', _dialedNumber);
    }
  }

  void _makeCall(String name, String phoneNumber) {
    context.read<CallBloc>().add(
      MakeCall(name: name, phoneNumber: phoneNumber, avatar: null),
    );
  }

  void _sendMessage(String phoneNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message to $phoneNumber - Feature coming soon')),
    );
  }

  void _showMakeCallDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make a Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.isNotEmpty) {
                Navigator.pop(context);
                _makeCall(
                  nameController.text.isEmpty ? 'Unknown' : nameController.text,
                  phoneController.text,
                );
              }
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _showActiveCallScreen(BuildContext context, CallModel call) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _ActiveCallScreen(call: call)),
    );
  }

  void _showIncomingCallScreen(BuildContext context, CallModel call) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _IncomingCallDialog(call: call),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  List<Map<String, String>> _getDefaultContacts() {
    return [
      {'name': 'John Doe', 'phone': '+1 234 567 8901'},
      {'name': 'Jane Smith', 'phone': '+1 234 567 8902'},
      {'name': 'Alex Johnson', 'phone': '+1 234 567 8903'},
      {'name': 'Sarah Wilson', 'phone': '+1 234 567 8904'},
      {'name': 'Mike Brown', 'phone': '+1 234 567 8905'},
      {'name': 'Emily Davis', 'phone': '+1 234 567 8906'},
      {'name': 'Chris Lee', 'phone': '+1 234 567 8907'},
      {'name': 'Lisa Garcia', 'phone': '+1 234 567 8908'},
      {'name': 'David Miller', 'phone': '+1 234 567 8909'},
      {'name': 'Emma White', 'phone': '+1 234 567 8910'},
    ];
  }
}

class _ActiveCallScreen extends StatefulWidget {
  final CallModel call;

  const _ActiveCallScreen({Key? key, required this.call}) : super(key: key);

  @override
  State<_ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<_ActiveCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  Duration _callDuration = Duration.zero;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _startTimer();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = Duration(seconds: timer.tick);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade900,
              Colors.black87,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 40.h),
              _buildCallStatus(),
              SizedBox(height: 40.h),
              _buildCallerInfo(),
              const Spacer(),
              _buildCallControls(),
              SizedBox(height: 40.h),
              _buildEndCallButton(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallStatus() {
    return Column(
      children: [
        Text(
          'Call in Progress',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          _formatDuration(_callDuration),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCallerInfo() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 150.w,
                height: 150.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 70.r,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: widget.call.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            widget.call.avatar!,
                            width: 140.w,
                            height: 140.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 24.h),
        Text(
          widget.call.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.call.phoneNumber,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 140.w,
      height: 140.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade600],
        ),
      ),
      child: Center(
        child: Text(
          widget.call.name.isNotEmpty ? widget.call.name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 48.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: _isMuted ? Icons.mic_off : Icons.mic,
          isActive: _isMuted,
          onTap: () {
            setState(() {
              _isMuted = !_isMuted;
            });
            context.read<CallBloc>().add(ToggleMute());
          },
        ),
        _buildControlButton(
          icon: Icons.dialpad,
          onTap: () {
            // Show keypad
          },
        ),
        _buildControlButton(
          icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
          isActive: _isSpeakerOn,
          onTap: () {
            setState(() {
              _isSpeakerOn = !_isSpeakerOn;
            });
            context.read<CallBloc>().add(ToggleSpeaker());
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.blue.shade800 : Colors.white,
          size: 28.sp,
        ),
      ),
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: () {
        context.read<CallBloc>().add(EndCall(callId: widget.call.id));
        Navigator.pop(context);
      },
      child: Container(
        width: 70.w,
        height: 70.h,
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(Icons.call_end, color: Colors.white, size: 32.sp),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _IncomingCallDialog extends StatelessWidget {
  final CallModel call;

  const _IncomingCallDialog({Key? key, required this.call}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade700,
              Colors.indigo.shade900,
              Colors.black87,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 60.h),
              Text(
                'Incoming Call',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 60.h),
              _buildCallerInfo(),
              const Spacer(),
              _buildActionButtons(context),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallerInfo() {
    return Column(
      children: [
        CircleAvatar(
          radius: 80.r,
          backgroundColor: Colors.white.withOpacity(0.1),
          child: call.avatar != null
              ? ClipOval(
                  child: Image.network(
                    call.avatar!,
                    width: 160.w,
                    height: 160.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  ),
                )
              : _buildDefaultAvatar(),
        ),
        SizedBox(height: 24.h),
        Text(
          call.name,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          call.phoneNumber,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 160.w,
      height: 160.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade600],
        ),
      ),
      child: Center(
        child: Text(
          call.name.isNotEmpty ? call.name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 48.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 60.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _declineCall(context),
            child: Container(
              width: 70.w,
              height: 70.h,
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.call_end, color: Colors.white, size: 32.sp),
            ),
          ),
          GestureDetector(
            onTap: () => _acceptCall(context),
            child: Container(
              width: 70.w,
              height: 70.h,
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.call, color: Colors.white, size: 32.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _acceptCall(BuildContext context) {
    context.read<CallBloc>().add(AnswerCall(callId: ""));
    Navigator.pop(context);
  }

  void _declineCall(BuildContext context) {
    context.read<CallBloc>().add(EndCall(callId: call.id));
    Navigator.pop(context);
  }
}
