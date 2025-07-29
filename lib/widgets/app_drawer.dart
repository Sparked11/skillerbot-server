import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Center(
              child: Text(
                'Skillers Soccer',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text(
              'Home',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            title: const Text(
              'Profile',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          ListTile(
            title: const Text(
              'Achievements',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/achievements');
            },
          ),
          ListTile(
            title: const Text(
              'Testimonials',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/testimonials');
            },
          ),
          ListTile(
            title: const Text(
              'Donate',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/donate');
            },
          ),
        ],
      ),
    );
  }
}
