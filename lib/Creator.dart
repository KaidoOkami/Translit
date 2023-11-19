import 'package:flutter/material.dart';
import 'package:food/drawer.dart';
import 'package:food/main.dart';
import 'package:ionicons/ionicons.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Creator(),
      initialRoute: '/',
      routes: {
        '/main': (context) => const TranslationPage(),
        '/drawer': (context) => const Details(),
      },
    );
  }
}

class Creator extends StatefulWidget {
  const Creator({Key? key}) : super(key: key);

  @override
  _CreatorState createState() => _CreatorState();
}

class _CreatorState extends State<Creator> {
  void _navigateToDetails() {
    Navigator.pushNamed(context, '/drawer');
  }

  void _navigateToDevelopers() {
    Navigator.pushNamed(context, '/Creator');
  }

  void _navigateToHome() {
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creator'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const Padding(padding: EdgeInsets.only(top: 50)),
            _headerapp(),
            _buildItem(
              icon: Icons.translate,
              title: 'Translate',
              onTap: _navigateToHome,
            ),
            _buildItem(
                icon: Icons.priority_high,
                title: 'Details',
                onTap: _navigateToDetails),
            _buildItem(
                icon: Icons.groups,
                title: 'Developers',
                onTap: _navigateToDevelopers)
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/welcome.png', // Replace with your image path
                  width: 100, // Adjust the width of the image
                  height: 100, // Adjust the height of the image
                ),
                const SizedBox(width: 16), // Add space between image and text
                Text(
                  'Your Text Here', // Replace with your text
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(
                height: 25), // Add vertical space between the two rows
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 16), // Add space between image and text
                Text(
                  'Your Text Here', // Replace with your text
                  style: TextStyle(fontSize: 18),
                ),
                Image.asset(
                  'assets/welcome.png', // Replace with your image path
                  width: 100, // Adjust the width of the image
                  height: 100, // Adjust the height of the image
                ),
              ],
            ),
            const SizedBox(
                height: 25), // Add vertical space between the two rows
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                Image.asset(
                  'assets/welcome.png', // Replace with your image path
                  width: 100, // Adjust the width of the image
                  height: 100, // Adjust the height of the image
                ), // Add space between image and text
                Text(
                  'Your Text Here', // Replace with your text
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            // Add more widgets below if needed
          ],
        ),
      ),
    );
  }
}

_headerapp() {
  return const DrawerHeader(
    decoration: BoxDecoration(
      color: Color(0xFF0000FF),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20.0),
        bottomRight: Radius.circular(20.0),
      ),
    ),
    child: Icon(Ionicons.language_outline),
  );
}

_buildItem(
    {required IconData icon,
    required title,
    required GestureTapCallback onTap}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: onTap,
    minLeadingWidth: 5,
  );
}
