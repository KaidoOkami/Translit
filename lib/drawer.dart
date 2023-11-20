import 'package:flutter/material.dart';
import 'package:food/Creator.dart';
import 'package:food/main.dart';


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
              child: const Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 20, left: 10, right: 10, bottom: 20),
                      child: Text(
                        'App info',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                20,
                                fontWeight: FontWeight.bold, // Set text color to be visible on the background
                            ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 35, left: 10, right: 10, bottom: 20),
                      child: Text(
                        'This app was made in compliance with the requirements for the degree of Bachelor of Science in Information Technology.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Adjust the font size
                          fontWeight:
                              FontWeight.bold, // You can add bold if needed
                        ),
                      ),

                    ),
                  ),
                   Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 45, left: 10, right: 10, bottom: 20),
                      child: Text(
                        'Notes to the App\n'
                        'I. The app response may vary depending on the internet speed.\n\n'
                        'II. The app is running on a Python Flask server, only intended for testing use and is not the final release.\n\n'
                        'III. For the speech recognition to work clearly, speak the words clearly and not rushing. The user can speak in Bisaya as well.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}

_headerapp() {
  return DrawerHeader(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 28, 133, 178),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
      child: SizedBox(
        width: 150,
        height: 200,
        child: Image.asset('assets/vars/icon.png'),
      ));
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
