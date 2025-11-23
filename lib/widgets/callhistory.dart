import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ludo/model/call_model.dart';

class CallHistory extends StatelessWidget {
  final CallModel call;
  final VoidCallback? onTap;

  CallHistory({Key? key, required this.call, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildCallTypeIcon(),
      title: Text(call.name, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(call.phoneNumber),
          SizedBox(height: 2.h),
          Text(
            _formatTimestamp(call.timestamp),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (call.duration != null)
            Text(
              _formatDuration(call.duration!),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          SizedBox(width: 8.h),
          IconButton(
            onPressed: onTap,
            icon: Icon(Icons.call, color: Colors.green),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildCallTypeIcon() {
    IconData icon;
    Color color;

    switch (call.type) {
      case CallType.incoming:
        icon = Icons.call_received;
        color = call.status == CallStatus.missed ? Colors.red : Colors.green;
        break;
      case CallType.outgoing:
        icon = Icons.call_made;
        color = Colors.blue;
        break;
      case CallType.missed:
        icon = Icons.call_received;
        color = Colors.red;
        break;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }
}
