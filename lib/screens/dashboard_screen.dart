import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo/bloc/authbloc/auth_bloc.dart';
import 'package:ludo/bloc/authbloc/auth_event.dart';
import 'package:ludo/blocs/dashboardbloc/dashboard_bloc.dart';
import 'package:ludo/blocs/dashboardbloc/dashboard_event.dart';
import 'package:ludo/blocs/dashboardbloc/dashboard_state.dart';
import 'package:ludo/widgets/Stat_Card.dart';
import 'package:ludo/widgets/small_chart.dart';
import 'package:ludo/screens/post_screens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () => context.read<DashboardBloc>().add(ManualRefresh()),
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
          TextButton.icon(
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
            icon: Icon(Icons.logout, size: 16, color: Colors.white),
            label: Text('Logout', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading || state is DashboardInitial) {
                  return Container(
                    height: 120,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.blue[700]),
                    ),
                  );
                }
                if (state is DashboardLoaded) {
                  return Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Messages',
                          value: state.totalMessages.toString(),
                          subtitle: 'Total',
                          icon: Icons.message,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          color: Colors.green,
                          icon: Icons.call,
                          subtitle: 'Total',
                          title: 'Calls',
                          value: state.totalCalls.toString(),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostScreens(),
                              ),
                            );
                          },
                          child: StatCard(
                            color: Colors.orange,
                            icon: Icons.post_add,
                            subtitle: 'Tap to view',
                            title: 'Posts',
                            value: state.totalPosts.toString(),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return SizedBox();
              },
            ),

            SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Engagement Rate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      BlocBuilder<DashboardBloc, DashboardState>(
                        builder: (context, state) {
                          final value = state is DashboardLoaded
                              ? '${state.engagementRate}%'
                              : '--';
                          return Text(
                            value,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Container(height: 200, child: SmallChart()),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.read<DashboardBloc>().add(
                            SimulateUpdate(),
                          ),
                          child: Text('Simulate Update'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.read<DashboardBloc>().add(
                            ManualRefresh(),
                          ),
                          child: Text(
                            'Refresh',
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.blue[700]!),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
