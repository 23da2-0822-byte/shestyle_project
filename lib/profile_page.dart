import 'package:flutter/material.dart';
import 'login_page.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STANDALONE PAGE — used if ever navigated to directly (e.g. deep-link)
// ─────────────────────────────────────────────────────────────────────────────

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5EBDD),
      body: SafeArea(child: ProfileBody()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE BODY — embedded directly in HomePage's IndexedStack (Tab 3)
// No Scaffold, no AppBar — the nav shell provides those.
// ─────────────────────────────────────────────────────────────────────────────

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _firestoreService.getUserProfile();
    if (mounted) setState(() => _userData = data);
  }

  @override
  Widget build(BuildContext context) {
    final userName = _userData?['name'] as String? ?? 'User';
    final userImage = _userData?['imageUrl'] as String? ?? '';

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE5D1C1), Color(0xFFF5EBDD)],
        ),
      ),
      child: Column(
        children: [
          // ── Profile Header ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 25, bottom: 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF5EBDD), width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 65,
                    backgroundImage: userImage.startsWith('http')
                        ? NetworkImage(userImage) as ImageProvider
                        : (userImage.isNotEmpty
                            ? AssetImage(userImage) as ImageProvider
                            : null),
                    child: userImage.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 15),
                // Name
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // ── Menu Items ─────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _buildMenuItem(Icons.shopping_cart_outlined, 'My Orders', () {}),
                _buildMenuItem(Icons.favorite_border, 'Wishlist', () {}),
                _buildMenuItem(Icons.location_on_outlined, 'Address Book', () {}),
                _buildMenuItem(Icons.account_balance_wallet_outlined, 'Payment', () {}),
                _buildMenuItem(Icons.settings_outlined, 'Settings', () {}),
                _buildMenuItem(Icons.logout, 'Log Out', () async {
                  await _authService.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Function() onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black, size: 26),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 18),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        ),
        const Divider(color: Colors.white70, thickness: 1, indent: 10, endIndent: 10),
      ],
    );
  }
}
