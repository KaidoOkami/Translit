import 'package:flutter/material.dart';
import 'package:food/Creator.dart';
import 'package:food/main.dart';
import 'package:ionicons/ionicons.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translation App',
      home: const Details(),
      initialRoute: '/',
     routes: {
        '/main': (context) => const TranslationPage(),
        '/Creator': (context) => const Creator(),
      },
    );
  }
}


class Details extends StatefulWidget {
  const Details({Key? key}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}



class _DetailsState extends State<Details> {

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
        title: Text('Details Screen'),
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
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10.0)), // Set the elevation (shadow) value
          child: Container(
            width:
                double.infinity, // Set width to take the full available width
            height: 600,
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0), // Adjust the horizontal padding as needed
            decoration: BoxDecoration(
              color: Colors.blue, // Set your desired background color
              borderRadius: BorderRadius.circular(
                  10.0), // Optionally, set border radius for rounded corners
            ),
            child: const Center(
              child: Text(
                'Elevated Card',
                style: TextStyle(
                  color: Colors
                      .white, // Set text color to be visible on the background
                ),
              ),
            ),
          ),
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



