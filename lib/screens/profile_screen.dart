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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2E3F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1B23),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEF4444).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.logout,
                color: Color(0xFFEF4444),
                size: 20,
              ),
              onPressed: () => _showLogoutDialog(context),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      body: user == null
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1B23),
                    Color(0xFF2D2E3F),
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                ),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1B23),
                    Color(0xFF2D2E3F),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user!.designation,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Profile Details
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRow('User ID', user!.userId),
                    _buildRow('Officer Type', user!.officerType),
                    _buildRow('Mobile', user!.mobile),
                    
                    const SizedBox(height: 24),
                    Text(
                      'Booth Information',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRow('Booth Number', user!.boothNumber),
                    _buildRow('Booth Name', user!.boothName),
                  ],
                ),
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
