import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'drawer.dart';
import 'creator.dart';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translation App',
      home: const TranslationPage(),
      initialRoute: '/',
      routes: {
        '/drawer': (context) => const Details(),
        '/Creator': (context) => const Creator(),
      },
    );
  }
}

class TranslationPage extends StatefulWidget {
  const TranslationPage({Key? key}) : super(key: key);

  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  int currentDialogIndex = 0;
  final Logger _logger = Logger('TranslationPage');
  TextEditingController textEditingController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  String enteredText = '';
  Timer? _timer;
  String? transcribedText = '';
  String TextChoose = 'Conyo';
  String resultText = '';
  String Url = 'http://192.168.92.146:5000';
  bool isTranscribed = true;
  String finalText = '';
  int currentIndex = 0;
  bool isVisible = true;
  double _fontSize = 40.0;
  bool isRecording = false;
  late FlutterSoundRecorder _audioRecorder;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
     requestPermissions();
    _audioRecorder = FlutterSoundRecorder();
    _audioRecorder.openRecorder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkKeyboardVisibility();
    });
  }

  void _navigateToDetails() {
    Navigator.pushNamed(context, '/drawer');
  }

  void _navigateToDevelopers() {
    Navigator.pushNamed(context, '/Creator');
  }

  void _navigateToHome() {
    Navigator.pushNamed(context, '/');
  }

Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the app is run for the first time
    bool? isFirstTime = prefs.getBool('isFirstTime');

    if (isFirstTime == null || isFirstTime) {
      _showDialogFirst(0);
      prefs.setBool('isFirstTime', false);
    }
  }


  void checkKeyboardVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQueryData = MediaQuery.of(context);
      final keyboardHeight = mediaQueryData.viewInsets.bottom;
      if (mounted) {
        setState(() {
          isVisible = keyboardHeight <= 0;
        });
      }
    });
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.storage,
    ].request();

    if (statuses[Permission.microphone]!.isGranted &&
        statuses[Permission.storage]!.isGranted) {
      // Permissions granted
    } else if (statuses[Permission.microphone]!.isDenied) {
      _showPermissionDeniedDialog();
    } else if (statuses[Permission.microphone]!.isPermanentlyDenied ||
        statuses[Permission.storage]!.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
              'Please grant the required permissions to use this feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> toggleRecording() async {
    try {
      if (!isRecording) {
        final tempDir = await getTemporaryDirectory();
        final recordingPath = '${tempDir.path}/my_audio.wav';
        await _audioRecorder.startRecorder(
          toFile: recordingPath,
          codec: Codec.pcm16WAV,
        );
        Fluttertoast.showToast(
          msg: 'Recording!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        setState(() {
          isRecording = true;
        });
      } else {
        await _audioRecorder.stopRecorder();
        Fluttertoast.showToast(
          msg: 'Recording stopped',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        await sendAudioToServer();
        setState(() {
          isRecording = false;
        });
      }
    } catch (e) {
      _logger.severe('Error toggling recording: $e');
    }
  }

  Future<void> sendAudioToServer() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final recordingPath = '${tempDir.path}/my_audio.wav';
      var uri = Uri.parse('$Url/upload_audio/$TextChoose');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('audio', recordingPath));

      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseBody);
        String recognizedText = jsonResponse['recognized_text'];
        String translatedText = jsonResponse['translated_text'];
        setState(() {
          transcribedText = recognizedText.replaceAll('"', '');
          print(transcribedText);
          resultText = translatedText.replaceAll('"', '');
          print(resultText);
        });
      } else {
        _logger.warning('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      _logger.severe('Error sending audio to server: $e');
    }
  }

  Future<void> sendTextToServer(String text) async {
    try {
      // Replace the URL with your server endpoint
      // ignore: prefer_interpolation_to_compose_strings
      var uri = Uri.parse('$Url/upload_text/$TextChoose');

      var request = http.MultipartRequest('POST', uri)
        ..fields['text'] =
            enteredText; // Sending text as a field in the request

      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseBody);
        String recognizedText = jsonResponse['input_text'];
        String translatedText = jsonResponse['translated_text'];

        setState(() {
          transcribedText = recognizedText.replaceAll('"', '');
          print(transcribedText);
          resultText = translatedText.replaceAll('"', '');
          print(resultText);
        });
      } else {
        _logger.warning('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      _logger.severe('Error sending text to server: $e');
    }
  }

  void _showNextDialog(int currentIndex) {
    if (currentIndex < 9) {
      setState(() {
        currentDialogIndex = currentIndex + 1;
      });
      _showDialog(currentDialogIndex);
    } else {
      // Handle the last dialog
      Navigator.of(context).maybePop(); // Close the dialog
      _navigateToHome(); // Navigate to home page
    }
  }

  void _showPreviousDialog(int currentIndex) {
    if (currentIndex > 0) {
      setState(() {
        currentDialogIndex = currentIndex - 1;
      });
      _showDialog(currentDialogIndex);
    }
  }

  void _showDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.asset(_getImagePath(index)),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (index > 0)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showPreviousDialog(index);
                    },
                    child: Text('Back'),
                  ),
                SizedBox(width: 8), // Add some space in the middle
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showNextDialog(index);
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showDialogFirst(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.asset(_getImagePathFirst(index)),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (index > 0)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showPreviousDialog(index);
                    },
                    child: Text('Back'),
                  ),
                SizedBox(width: 8), // Add some space in the middle
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showNextDialog(index);
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _textController
        .dispose(); // Dispose the TextEditingController to avoid memory leaks
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel(); // Cancel the timer on dispose
    }

    _audioRecorder.closeRecorder(); // Dispose the audio recorder
    super.dispose();
  }

  Map<String, dynamic> _calculatePaddingre() {
    const double initialFontSize = 40.0;
    const double fontSizePerLine = 5.0;
    const double minFontSize = 16.0;

    String text = isTranscribed ? transcribedText ?? "" : enteredText ?? "";

    // Check if the text is not empty

    // Create a TextPainter to measure the text layout
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize:
              initialFontSize, // Use the initial font size for measurement
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 3, // Set max lines to your desired value
    );

    textPainter.layout(
        maxWidth:
            400); // Specify the maximum width of your TextField (1 is just a placeholder)

    // Calculate the number of lines based on the visual layout
    int numberOfVisualLines = textPainter.computeLineMetrics().length;
    print(numberOfVisualLines);
    // Calculate the font size based on the number of visual lines
    double calculatedFontSize =
        initialFontSize - fontSizePerLine * (numberOfVisualLines - 1);
    print(calculatedFontSize);
    calculatedFontSize = calculatedFontSize.clamp(minFontSize, initialFontSize);
    return {'fontSize': calculatedFontSize};

    // If the text is empty, return the initial font size
  }

  void _updateFontSize() {
    setState(() {
      _fontSize = _calculatePaddingre()['fontSize'];
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showfab = MediaQuery.of(context).viewInsets.bottom != 0;

    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      foregroundColor: Colors.white70,
      backgroundColor: Colors.lightBlue.shade500,
      fixedSize: const Size(150, 50),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation'),
        backgroundColor: Colors.lightBlue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.error_outline),
            onPressed: () {
              _showDialog(0);
            },
          )
        ],
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
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.white10),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade800,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 25, left: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: _fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              controller: TextEditingController(
                                  text: isTranscribed
                                      ? transcribedText
                                      : enteredText),
                              onChanged: (text) {
                                if (_timer != null && _timer!.isActive) {
                                  _timer!.cancel(); // Cancel the previous timer
                                }
                                _timer = Timer(
                                    const Duration(milliseconds: 800), () {
                                  setState(() {
                                    setState(() {
                                      enteredText = text;
                                      isTranscribed = !text.isEmpty;
                                      _updateFontSize();
                                      // Switch to enteredText when the user starts typing
                                    });
                                    sendTextToServer(enteredText);
                                    print(
                                        enteredText); // Capture the text after a delay
                                  });
                                });

                                // You can use enteredText to send to the server
                              },
                              decoration: const InputDecoration(
                                hintText: 'Enter Text',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          )
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Opacity(
                            opacity: 0.5,
                            child: Text(
                                enteredText.isNotEmpty
                                    ? (MediaQuery.of(context)
                                                .viewInsets
                                                .bottom >
                                            0
                                        ? 'Translating...'
                                        : (resultText ?? ''))
                                    : '',
                                style: TextStyle(
                                    fontSize: _calculatePaddingre()['fontSize'],
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ))),
                ],
              ),
            ),
          ),
          Container(
            height: 100,
            decoration: const BoxDecoration(color: Colors.white10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: style,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext builder) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: const Text('Conyo'),
                              onTap: () {
                                Navigator.pop(context, 'Conyo');
                              },
                            ),
                            ListTile(
                              title: const Text('English'),
                              onTap: () {
                                Navigator.pop(context, 'English');
                              },
                            ),
                          ],
                        );
                      },
                    ).then((value) {
                      if (value != null ) {
                        setState(() {
                          TextChoose = value;
                          print('Press : ' + TextChoose);
                        });
                      }
                    });
                  },
                  child: Text(TextChoose),
                ),
                const Icon(
                  Ionicons.arrow_forward_outline,
                  size: 35,
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: style,
                  child: const Text("Bisaya"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Visibility(
              visible: !showfab,
              child: SizedBox(
                height: 80,
                width: 80,
                child: GestureDetector(
                  onTap: toggleRecording,
                  child: FloatingActionButton(
                    backgroundColor: isRecording ? Colors.red : null,
                    child: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      size: 42,
                    ),
                    onPressed: () {
                      toggleRecording();
                    },
                  ),
                ),
              ),
            ),
          )
        ],
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

String _getImagePath(int index) {
  switch (index) {
    case 0:
      return 'assets/loc/1.png';
    case 1:
      return 'assets/loc/2.png';
    case 2:
      return 'assets/loc/3.png';
    case 3:
      return 'assets/loc/4.png';
    case 4:
      return 'assets/loc/5.png';
    case 5:
      return 'assets/loc/6.png';
    case 6:
      return 'assets/loc/7.png';
    case 7:
      return 'assets/loc/8.png';
    case 8:
      return 'assets/loc/9.png';
    case 9:
      return 'assets/loc/10.png';
    default:
      return 'assets/vars/welcome.png';
  }
}

String _getImagePathFirst(int index) {
  switch (index) {
    case 0:
      return 'assets/vars/welcome.png';
    case 1:
      return 'assets/loc/2.png';
    case 2:
      return 'assets/loc/1.png';
    case 3:
      return 'assets/loc/4.png';
    case 4:
      return 'assets/loc/5.png';
    case 5:
      return 'assets/loc/6.png';
    case 6:
      return 'assets/loc/7.png';
    case 7:
      return 'assets/loc/8.png';
    case 8:
      return 'assets/loc/9.png';
    case 9:
      return 'assets/loc/10.png';
    default:
      return 'assets/vars/welcome.png';
  }
}
