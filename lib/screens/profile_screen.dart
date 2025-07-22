import 'package:flutter/material.dart';
import 'package:attendance_app/models/user_model.dart';
import 'package:attendance_app/database/user_db.dart';
import 'package:attendance_app/screens/login_screen.dart'; // for navigation
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final fetchedUser = await UserDb().getUser();
    setState(() {
      user = fetchedUser;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = SharedPreferencesAsync();
    await prefs.remove('auth_token');
    await UserDb().deleteUser(); // Optional: clear stored user info
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _logout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow('Name', user!.name),
                  _buildRow('User ID', user!.userId),
                  _buildRow('Designation', user!.designation),
                  _buildRow('Officer Type', user!.officerType),
                  _buildRow('Mobile', user!.mobile),
                  _buildRow('Booth Number', user!.boothNumber),
                  _buildRow('Booth Name', user!.boothName),
                ],
              ),
            ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:attendance_app/models/user_model.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   // Dummy user for now
//   UserModel get dummyUser => UserModel(
//         name: 'Shyam',
//         userId: 'U123456',
//         designation: 'Booth Level Officer',
//         officerType: 'Regular',
//         mobile: '9876543210',
//         boothNumber: '42',
//         boothName: 'Sunrise Public School',
//       );

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Logout Confirmation'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               // TODO: Add logout logic (clear token, redirect to login)
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Logged out successfully")),
//               );
//             },
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = dummyUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => _showLogoutDialog(context),
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildRow('Name', user.name),
//             _buildRow('User ID', user.userId),
//             _buildRow('Designation', user.designation),
//             _buildRow('Officer Type', user.officerType),
//             _buildRow('Mobile', user.mobile),
//             _buildRow('Booth Number', user.boothNumber),
//             _buildRow('Booth Name', user.boothName),
//           ],
//         ),
//       ),
//     );
//   }
// }
