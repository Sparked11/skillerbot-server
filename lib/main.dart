import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/drill.dart';
import 'drill_detail_page.dart';
import 'package:csv/csv.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'widgets/app_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userDataString = prefs.getString('userData');

  String? email;

  if (isLoggedIn && userDataString != null) {
    final userData = jsonDecode(userDataString);
    email = userData['email'];
  }

  runApp(SoccerSkillerApp(
    isLoggedIn: isLoggedIn,
    userEmail: email,
  ));
}

class SoccerSkillerApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userEmail;

  const SoccerSkillerApp({
    super.key,
    required this.isLoggedIn,
    this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoccerSkiller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF040000),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Poppins', color: Colors.white),
        ),
      ),
      home: AppEntry(isLoggedIn: isLoggedIn, userEmail: userEmail),
    );
  }
}

// ----------- SIGN UP SCREEN -------------

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isSignUpHover = false;
  bool isLoginHover = false;

  bool isFormValid() {
    return emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040000),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', width: 229, height: 183),
                const SizedBox(height: 12),
                const Text('TRAIN. TRACK. TRANSFORM',
                    style: TextStyle(
                      color: Color(0xFFC0C0C0),
                      fontFamily: 'Poppins',
                      fontSize: 20,
                    )),
                const SizedBox(height: 24),
                const Text('Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                    )),
                const SizedBox(height: 24),
                _buildInputField(emailController, 'Email Address'),
                const SizedBox(height: 16),
                _buildInputField(passwordController, 'Password', obscure: true),
                const SizedBox(height: 16),
                _buildInputField(confirmPasswordController, 'Confirm Password',
                    obscure: true),
                const SizedBox(height: 32),
                _hoverButton(
                  "Sign Up",
                  isSignUpHover,
                  isFormValid()
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoadingScreen(
                                next: MultiStepFormScreen(
                                  userEmail: emailController.text.trim(),
                                  userPassword: passwordController.text.trim(),
                                ),
                              ),
                            ),
                          );
                        }
                      : null,
                ),
                const SizedBox(height: 24),
                _hoverLink("Already have an account? Log In", isLoginHover, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                }),
                const SizedBox(
                    height: 60), // extra bottom padding for breathing room
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
          color: Colors.white, fontFamily: 'Poppins', fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: Colors.white70, fontFamily: 'Poppins', fontSize: 16),
        filled: true,
        fillColor: const Color(0xFF373737),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _hoverButton(String text, bool hover, VoidCallback? onTap) {
    return MouseRegion(
      onEnter: (_) => setState(() => isSignUpHover = true),
      onExit: (_) => setState(() => isSignUpHover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 106,
        height: 35,
        decoration: BoxDecoration(
          color: onTap == null
              ? Colors.grey.shade700
              : (hover ? const Color(0xFF2A93D9) : const Color(0xFF37B5FF)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: (onTap != null && hover)
              ? [
                  BoxShadow(
                      color: const Color(0xFF37B5FF).withOpacity(0.6),
                      blurRadius: 10)
                ]
              : [],
          // subtle glow on hover
        ),
        transform: (onTap != null && hover)
            ? (Matrix4.identity()..scale(1.05))
            : Matrix4.identity(),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(text,
              style: TextStyle(
                color: onTap == null ? Colors.grey[400] : Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 16,
              )),
        ),
      ),
    );
  }

  Widget _hoverLink(String text, bool hover, VoidCallback onTap) {
    return MouseRegion(
      onEnter: (_) => setState(() => isLoginHover = true),
      onExit: (_) => setState(() => isLoginHover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: hover ? const Color(0xFF37B5FF) : Colors.white,
            fontFamily: 'Poppins',
            fontSize: 16,
            decoration: hover ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }
}

// ----------- LOG IN SCREEN -------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isLoginHover = false;
  bool isSignUpHover = false;

  bool isFormValid() {
    return usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040000),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', width: 229, height: 183),
                const SizedBox(height: 12),
                const Text('TRAIN. TRACK. TRANSFORM',
                    style: TextStyle(
                        color: Color(0xFFC0C0C0),
                        fontFamily: 'Poppins',
                        fontSize: 20)),
                const SizedBox(height: 24),
                const Text('Log In',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 30)),
                const SizedBox(height: 24),
                _buildInputField(usernameController, 'Username'),
                const SizedBox(height: 16),
                _buildInputField(passwordController, 'Password', obscure: true),
                const SizedBox(height: 32),
                _hoverButton(
                  "Log In",
                  isLoginHover,
                  isFormValid()
                      ? () async {
                          setState(() {
                            isLoginHover = false;
                          });

                          final username = usernameController.text.trim();
                          final password = passwordController.text.trim();

                          final sheetBestUrl =
                              'https://sheet.best/api/sheets/40dc0262-f967-41a8-81bb-ea8bb4eb5641'; // replace with your URL

                          try {
                            final response =
                                await http.get(Uri.parse(sheetBestUrl));

                            if (response.statusCode == 200) {
                              final List<dynamic> rows =
                                  json.decode(response.body);

                              bool found = false;
                              Map<String, dynamic> userRow = {};

                              for (final row in rows) {
                                final rowUsername =
                                    (row['username'] ?? '').toString().trim();
                                final rowPassword =
                                    (row['password'] ?? '').toString().trim();

                                if (rowUsername == username &&
                                    rowPassword == password) {
                                  found = true;
                                  userRow = {
                                    'name': row['name'],
                                    'email': row['email'],
                                    'username': rowUsername,
                                    'location': row['location'],
                                    'club': row['club'],
                                    'achievement': row['achievement'],
                                  };
                                  break;
                                }
                              }

                              if (found) {
                                // ✅ Navigate ONLY if found
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SoccerHomePage(
                                      user: userRow,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No account found. Sign Up.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error fetching user data.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : null,
                ),
                const SizedBox(height: 24),
                _hoverLink("Don’t have an account? Sign Up", isSignUpHover, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()));
                }),
                const SizedBox(height: 60), // extra breathing room
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
          color: Colors.white, fontFamily: 'Poppins', fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: Colors.white70, fontFamily: 'Poppins', fontSize: 16),
        filled: true,
        fillColor: const Color(0xFF373737),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _hoverButton(String text, bool hover, VoidCallback? onTap) {
    return MouseRegion(
      onEnter: (_) => setState(() => isLoginHover = true),
      onExit: (_) => setState(() => isLoginHover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 106,
        height: 35,
        decoration: BoxDecoration(
          color: onTap == null
              ? Colors.grey.shade700
              : (hover ? const Color(0xFF2A93D9) : const Color(0xFF37B5FF)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: (onTap != null && hover)
              ? [
                  BoxShadow(
                      color: const Color(0xFF37B5FF).withOpacity(0.6),
                      blurRadius: 10)
                ]
              : [],
        ),
        transform: (onTap != null && hover)
            ? (Matrix4.identity()..scale(1.05))
            : Matrix4.identity(),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(text,
              style: TextStyle(
                color: onTap == null ? Colors.grey[400] : Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 16,
              )),
        ),
      ),
    );
  }

  Widget _hoverLink(String text, bool hover, VoidCallback onTap) {
    return MouseRegion(
      onEnter: (_) => setState(() => isSignUpHover = true),
      onExit: (_) => setState(() => isSignUpHover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: hover ? const Color(0xFF37B5FF) : Colors.white,
            fontFamily: 'Poppins',
            fontSize: 16,
            decoration: hover ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }
}

// ----------- LOADING SCREEN -------------

class LoadingScreen extends StatefulWidget {
  final Widget next;
  const LoadingScreen({super.key, required this.next});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  double topOffset = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Bouncing animation loop
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() => topOffset = topOffset == 0 ? 12 : 0);
    });

    // Simulate loading
    Future.delayed(const Duration(seconds: 2), () {
      _timer.cancel();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => widget.next));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37B5FF),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedPadding(
              padding: EdgeInsets.only(bottom: topOffset),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: const Text("⚽", style: TextStyle(fontSize: 60)),
            ),
            const SizedBox(height: 20),
            const Text(
              "Loading...",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ----------- MULTI-STEP FORM -------------

class MultiStepFormScreen extends StatefulWidget {
  final String userEmail;
  final String userPassword;

  const MultiStepFormScreen({
    super.key,
    required this.userEmail,
    required this.userPassword,
  });

  @override
  _MultiStepFormScreenState createState() => _MultiStepFormScreenState();
}

class _MultiStepFormScreenState extends State<MultiStepFormScreen> {
  // Shared form data:
  final Map<String, dynamic> formData = {};

// Current step:
  int currentStep = 1;

// Step 1 controllers:
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

// Step 2 state:
  String? selectedPosition; // Forward, Midfielder, Defender, Goalkeeper
  String? selectedExperience; // Novice, Beginner, Intermediate, Elite

// Step 3 (training goals):
  final List<String> allGoals = [
    'Dribbling',
    'Ball Control/Touch',
    'Shooting',
    'Passing',
    'Speed',
    'Endurance',
    'Decision-Making',
    'Strength',
    'Goalkeeping'
  ];
  final Set<String> selectedGoals = {};

// Step 4 controllers:
  final TextEditingController cityStateController = TextEditingController();
  final TextEditingController clubNameController = TextEditingController();

// Step 5 controllers:
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  bool get isStep1Valid =>
      nameController.text.trim().isNotEmpty &&
      ageController.text.trim().isNotEmpty &&
      int.tryParse(ageController.text) != null &&
      int.parse(ageController.text) >= 1 &&
      int.parse(ageController.text) <= 30;

  bool get isStep2Valid =>
      selectedPosition != null && selectedExperience != null;

  bool get isStep3Valid => selectedGoals.isNotEmpty;

  bool get isStep4Valid =>
      cityStateController.text.trim().isNotEmpty &&
      clubNameController.text.trim().isNotEmpty;

  bool get isStep5Valid =>
      phoneController.text.trim().isNotEmpty &&
      usernameController.text.trim().isNotEmpty &&
      usernameController.text.length <= 15;

  @override
  void initState() {
    super.initState();

    formData['email'] = widget.userEmail;
    formData['password'] = widget.userPassword;
  }

// This helper handles step switching
  Widget _buildStepContent() {
    switch (currentStep) {
      case 1:
        return stepOne();
      case 2:
        return stepTwo();
      case 3:
        return stepThree();
      case 4:
        return stepFour();
      case 5:
        return stepFive();
      case 6:
        return stepSix(); // ✅ Add this!
      default:
        return const Center(child: Text("Invalid step"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040000),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Builder(
            builder: (_) {
              switch (currentStep) {
                case 1:
                  return stepOne();
                case 2:
                  return stepTwo();
                case 3:
                  return stepThree();
                case 4:
                  return stepFour();
                case 5:
                  return stepFive();
                case 6:
                  return stepSix();
                default:
                  return const Center(
                      child: Text("Unknown step",
                          style: TextStyle(color: Colors.white)));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget stepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo left aligned
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Image.asset('assets/logo2.jpeg', width: 201, height: 54),
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: const [
              Text(
                "Let's Get to Know You!",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 27,
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: 300,
                child: Text(
                  "Before we get to training, let’s learn a bit about you to customize your experience!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Progress Bar (1/5)
        Center(
          child: Container(
            width: 264,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(32),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 1 / 5,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF37B5FF),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF37B5FF).withOpacity(0.7),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Name input
        _buildInputField(nameController, 'Name'),
        const SizedBox(height: 16),

        // Age input (number only)
        TextField(
          controller: ageController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
              color: Colors.white, fontFamily: 'Poppins', fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Age',
            hintStyle: const TextStyle(
                color: Colors.white70, fontFamily: 'Poppins', fontSize: 16),
            filled: true,
            fillColor: const Color(0xFF373737),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 40),

        // Next button (right aligned, disabled if not valid)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _glowHoverButton("Next", isStep1Valid ? _goToStep2 : null),
          ],
        ),
      ],
    );
  }

  Widget stepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo left aligned
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Image.asset('assets/logo2.jpeg', width: 201, height: 54),
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: const [
              Text(
                "Let's Get to Know You!",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 27,
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: 300,
                child: Text(
                  "Before we get to training, let’s learn a bit about you to customize your experience!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Progress Bar (2/5)
        Center(
          child: Container(
            width: 264,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(32),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 2 / 5,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF37B5FF),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF37B5FF).withOpacity(0.7),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Dropdown: Position on the Field
        DropdownButtonFormField<String>(
          value: selectedPosition,
          dropdownColor: const Color(0xFF373737),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF373737),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: const Text('Position on the Field',
              style: TextStyle(
                  color: Colors.white70, fontFamily: 'Poppins', fontSize: 16)),
          style: const TextStyle(
              color: Colors.white, fontFamily: 'Poppins', fontSize: 16),
          items: ['Forward', 'Midfielder', 'Defender', 'Goalkeeper']
              .map((pos) => DropdownMenuItem(value: pos, child: Text(pos)))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedPosition = val;
            });
          },
        ),
        const SizedBox(height: 16),

        // Dropdown: Experience Level
        DropdownButtonFormField<String>(
          value: selectedExperience,
          dropdownColor: const Color(0xFF373737),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF373737),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: const Text('Experience Level',
              style: TextStyle(
                  color: Colors.white70, fontFamily: 'Poppins', fontSize: 16)),
          style: const TextStyle(
              color: Colors.white, fontFamily: 'Poppins', fontSize: 16),
          items: ['Novice', 'Beginner', 'Intermediate', 'Elite']
              .map(
                  (level) => DropdownMenuItem(value: level, child: Text(level)))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedExperience = val;
            });
          },
        ),
        const SizedBox(height: 40),

        // Back and Next buttons in row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _glowHoverButton("Back", _goToStep1),
            _glowHoverButton("Next", isStep2Valid ? _goToStep3 : null),
          ],
        ),
      ],
    );
  }

  Widget stepThree() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
          bottom: 24), // some bottom padding so buttons are reachable
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo left aligned
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Image.asset('assets/logo2.jpeg', width: 201, height: 54),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: const [
                Text(
                  "Let's Get to Know You!",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 27,
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: 300,
                  child: Text(
                    "Before we get to training, let’s learn a bit about you to customize your experience!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Progress Bar (3/5)
          Center(
            child: Container(
              width: 264,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 3 / 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF37B5FF),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF37B5FF).withOpacity(0.7),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title text centered with fixed size (173 x 48)
          Center(
            child: SizedBox(
              width: 173,
              height: 48,
              child: const Center(
                child: Text(
                  "Training Goal (Select all that apply)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Grid of goals without Expanded, wrapped inside the scroll view
          GridView.count(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // disable inner scrolling
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: allGoals.map((goal) {
              final bool selected = selectedGoals.contains(goal);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      selectedGoals.remove(goal);
                    } else {
                      selectedGoals.add(goal);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF37B5FF)
                        : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF37B5FF).withOpacity(0.7),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                  width: 106,
                  height: 75,
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          goal,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (selected)
                        const Positioned(
                          top: 4,
                          left: 4,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Back and Next buttons in row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _glowHoverButton("Back", _goToStep2),
              _glowHoverButton("Next", isStep3Valid ? _goToStep4 : null),
            ],
          ),
        ],
      ),
    );
  }

// Step 4 - City/Club Info
  Widget stepFour() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Image.asset('assets/logo2.jpeg', width: 201, height: 54),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: const [
                Text(
                  "Let's Get to Know You!",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 27,
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: 300,
                  child: Text(
                    "Before we get to training, let’s learn a bit about you to customize your experience!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Progress bar (4/5)
          Center(
            child: Container(
              width: 264,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 4 / 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF37B5FF),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF37B5FF).withOpacity(0.7),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildInputField(cityStateController, 'City, State'),
          const SizedBox(height: 16),
          _buildInputField(clubNameController, 'Club/Team Name*'),
          const SizedBox(height: 16),

          // Note below inputs
          Center(
            child: SizedBox(
              width: 400,
              height: 24,
              child: Text(
                "*= 'N/A' if not part of a club/team",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Back and Next buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _glowHoverButton("Back", _goToStep3),
              _glowHoverButton("Next", isStep4Valid ? _goToStep5 : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget stepFive() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Image.asset('assets/logo2.jpeg', width: 201, height: 54),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: const [
                Text(
                  "Let's Get to Know You!",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 27,
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: 300,
                  child: Text(
                    "Before we get to training, let’s learn a bit about you to customize your experience!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Progress Bar (5/5)
          Center(
            child: Container(
              width: 264,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF37B5FF),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF37B5FF).withOpacity(0.7),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Phone Number
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Poppins', fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Phone Number',
              hintStyle: const TextStyle(
                  color: Colors.white70, fontFamily: 'Poppins', fontSize: 16),
              filled: true,
              fillColor: const Color(0xFF373737),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Username
          TextField(
            controller: usernameController,
            maxLength: 15,
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Poppins', fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Username',
              counterText: "",
              hintStyle: const TextStyle(
                  color: Colors.white70, fontFamily: 'Poppins', fontSize: 16),
              filled: true,
              fillColor: const Color(0xFF373737),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _glowHoverButton("Back", _goToStep4),
              _glowHoverButton("Finish", isStep5Valid ? _goToStep6 : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget stepSix() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Image.asset('assets/logo.png', width: 229, height: 183),
          const SizedBox(height: 16),
          const Text(
            "TRAIN. TRACK. TRANSFORM.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              color: Color(0xFFC0C0C0),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Text(
            "You’re All Set!",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              fontSize: 27,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const SizedBox(
            width: 223,
            height: 38,
            child: Text(
              "Now, we know what you need most! Time to get training!",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          _CoolAnimatedButton(
            text: "Get Started!",
            onTap: () async {
              if (isStep1Valid &&
                  isStep2Valid &&
                  isStep3Valid &&
                  isStep4Valid &&
                  isStep5Valid) {
                try {
                  await registerUser(
                    name: nameController.text.trim(),
                    age: ageController.text.trim(),
                    goals: selectedGoals
                        .join(','), // convert List to comma-separated string
                    position: formData['position'] ?? '',
                    experience: formData['experience'] ?? '',
                    username: usernameController.text.trim(),
                    phone: phoneController.text.trim(),
                    email: formData['email'] ?? '',
                    password: formData['password'] ?? '',
                    userID: formData['userID'] ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    location: formData['location'] ?? '',
                    club: formData['club'] ?? '',
                  );

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', true);
                  await prefs.setString('userData', json.encode(formData));

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MainNavigation(userEmail: widget.userEmail),
                    ),
                  );
                } catch (e) {
                  print("❌ Error saving to Google Sheets: $e");

                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text("Error"),
                      content: Text("Something went wrong. Please try again."),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Button builder with glow hover animation
  Widget _glowHoverButton(String text, VoidCallback? onTap) {
    return _GlowHoverButton(text: text, onTap: onTap);
  }

  void _goToStep1() {
    setState(() {
      currentStep = 1;
    });
  }

  void _goToStep2() {
    setState(() {
      currentStep = 2;
    });
  }

  void _goToStep3() {
    setState(() {
      currentStep = 3;
    });
  }

  void _goToStep4() {
    setState(() {
      currentStep = 4;
    });
  }

  void _goToStep5() {
    setState(() {
      currentStep = 5;
    });
  }

  void _goToStep6() {
    formData['phone'] = phoneController.text.trim();
    formData['username'] = usernameController.text.trim();
    formData['club'] = clubNameController.text.trim();
    formData['location'] = cityStateController.text.trim();
    formData['position'] = selectedPosition ?? '';
    formData['experience'] = selectedExperience ?? '';

    setState(() {
      currentStep = 6;
    });
  }

  void _finishForm() {
    formData['position'] = selectedPosition; // when they select their position
    formData['email'] = emailController.text; // from sign up
    formData['password'] = passwordController.text;
    formData['userID'] = DateTime.now().millisecondsSinceEpoch.toString();
    formData['phone'] = phoneController.text.trim();
    formData['username'] = usernameController.text.trim();
    formData['club'] = clubNameController.text.trim();
    formData['location'] = cityStateController.text.trim();
    formData['position'] = selectedPosition ?? '';
    formData['experience'] = selectedExperience ?? '';
    formData['userID'] = DateTime.now().millisecondsSinceEpoch.toString();

    // Save all data to formData
    formData['name'] = nameController.text.trim();
    formData['age'] = int.parse(ageController.text.trim());
    formData['position'] = selectedPosition!;
    formData['experience'] = selectedExperience!;
    formData['trainingGoals'] = selectedGoals.toList();

    // For now, just show a simple dialog with collected info
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Form Completed'),
        content: SingleChildScrollView(
          child: Text(
              formData.entries.map((e) => '${e.key}: ${e.value}').join('\n')),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to previous screen (or home)
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(
          color: Colors.white, fontFamily: 'Poppins', fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: Colors.white70, fontFamily: 'Poppins', fontSize: 16),
        filled: true,
        fillColor: const Color(0xFF373737),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}

// Glow hover button widget for consistency and animation
class _GlowHoverButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  const _GlowHoverButton({required this.text, required this.onTap});

  @override
  State<_GlowHoverButton> createState() => _GlowHoverButtonState();
}

class _GlowHoverButtonState extends State<_GlowHoverButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return MouseRegion(
      onEnter: (_) {
        if (enabled) setState(() => isHovered = true);
      },
      onExit: (_) {
        if (enabled) setState(() => isHovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 106,
        height: 35,
        decoration: BoxDecoration(
          color: enabled
              ? (isHovered ? const Color(0xFF2A93D9) : const Color(0xFF37B5FF))
              : Colors.grey.shade700,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isHovered && enabled
              ? [
                  BoxShadow(
                      color: const Color(0xFF37B5FF).withOpacity(0.6),
                      blurRadius: 10)
                ]
              : [],
        ),
        transform: isHovered && enabled
            ? (Matrix4.identity()..scale(1.05))
            : Matrix4.identity(),
        child: TextButton(
          onPressed: widget.onTap,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(widget.text,
              style: TextStyle(
                color: enabled ? Colors.black : Colors.grey[400],
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 16,
              )),
        ),
      ),
    );
  }
}

class _CoolAnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _CoolAnimatedButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_CoolAnimatedButton> createState() => _CoolAnimatedButtonState();
}

class _CoolAnimatedButtonState extends State<_CoolAnimatedButton> {
  bool isHovered = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    double scale = isPressed ? 0.97 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) {
          setState(() => isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => isPressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 100),
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 219,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF37B5FF),
              borderRadius: BorderRadius.circular(26),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: const Color(0xFF37B5FF).withOpacity(0.6),
                        blurRadius: 14,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> registerUser({
  required String name,
  required String age,
  required String goals,
  required String position,
  required String experience,
  required String username,
  required String phone,
  required String email,
  required String password,
  required String userID,
  required String location,
  required String club,
}) async {
  final data = {
    'name': name,
    'age': age,
    'goals': goals,
    'position': position,
    'experience': experience,
    'username': username,
    'phone': phone,
    'email': email,
    'password': password,
    'userID': userID,
    'location': location,
    'club': club,
    'streak': '0',
    'skillerpoints': '0',
    'latest': '',
    'achievement': '',
  };

  final response = await http.post(
    Uri.parse(
        'https://api.sheetbest.com/sheets/40dc0262-f967-41a8-81bb-ea8bb4eb5641'),
    headers: {
      'Content-Type': 'application/json',
      'X-Api-Key':
          r'fLNa8X9rZQiyZGOZU#F0Q9YPIp2$adDeZ1SWFp1cq!$cOhaPUXTMvD#ykW-OuaEy',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    print('✅ User registered successfully');
  } else {
    print('❌ Failed to register user: ${response.statusCode}');
  }
}

Future<void> updateAchievements({
  required String userEmail,
  required String newAchievement,
}) async {
  final responseGet = await http.get(
    Uri.parse(
        'https://sheet.best/api/sheets/40dc0262-f967-41a8-81bb-ea8bb4eb5641/email/$userEmail'),
  );

  if (responseGet.statusCode == 200) {
    final List data = jsonDecode(responseGet.body);
    if (data.isNotEmpty) {
      final current = data[0]['achievement'] ?? '';
      final updated =
          (current.isEmpty ? newAchievement : '$current, $newAchievement');

      final responsePut = await http.put(
        Uri.parse(
            'https://sheet.best/api/sheets/40dc0262-f967-41a8-81bb-ea8bb4eb5641/email/$userEmail'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'achievement': updated}),
      );

      if (responsePut.statusCode == 200) {
        print('✅ Achievements updated');
      } else {
        print('❌ Failed to update achievements');
      }
    }
  }
}

Future<void> updateProgress({
  required String userEmail,
  required int newSkillerPoints,
  required int newStreak,
}) async {
  final responsePut = await http.put(
    Uri.parse(
        'https://sheet.best/api/sheets/40dc0262-f967-41a8-81bb-ea8bb4eb5641/email/$userEmail'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'skillerpoints': newSkillerPoints.toString(),
      'streak': newStreak.toString(),
    }),
  );

  if (responsePut.statusCode == 200) {
    print('✅ Progress updated');
  } else {
    print('❌ Failed to update progress');
  }
}

// Homepage

class SoccerHomePage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const SoccerHomePage({super.key, this.user});

  @override
  State<SoccerHomePage> createState() => _SoccerHomePageState();
}

class _SoccerHomePageState extends State<SoccerHomePage>
    with SingleTickerProviderStateMixin {
  List<Drill> drills = [];
  int drillsCompleted = 0;
  int skillerPoints = 0;
  bool isLoading = true;

  int streakCount = 0;

  late AnimationController _rainbowController;

  @override
  void initState() {
    super.initState();
    loadDrillsFromCsv();
    loadStreak();

    _rainbowController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rainbowController.dispose();
    super.dispose();
  }

  Future<void> loadDrillsFromCsv() async {
    try {
      final rawData = await rootBundle.loadString('assets/drillslist.csv');
      final List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(rawData, eol: '\n');

      if (csvTable.isNotEmpty) csvTable.removeAt(0);

      final allDrills = csvTable
          .map((row) => row.length >= 8 ? Drill.fromCsvRow(row) : null)
          .whereType<Drill>()
          .toList();

      allDrills.shuffle();
      drills = allDrills.take(3).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getImageForDrill(String name) {
    if (name.contains("Juggling")) return 'assets/juggling.jpg';
    if (name.contains("Aerial")) return 'assets/aerialnew.jpg';
    if (name.contains("Fitness")) return 'assets/fitness.jpg';
    return 'assets/juggling.jpg';
  }

  Future<void> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      streakCount = prefs.getInt('streakCount') ?? 0;
    });
  }

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat('yyyy-MM-dd').format(
      DateTime.now().subtract(Duration(days: 1)),
    );

    final lastActiveDate = prefs.getString('lastActiveDate');
    int currentStreak = prefs.getInt('streakCount') ?? 0;

    if (lastActiveDate == today) return;

    if (lastActiveDate == yesterday) {
      currentStreak++;
    } else {
      currentStreak = 1;
    }

    await prefs.setString('lastActiveDate', today);
    await prefs.setInt('streakCount', currentStreak);

    setState(() {
      streakCount = currentStreak;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.sports_soccer, color: Colors.blueAccent),
              title: const Text('Drills'),
              onTap: () {
                // already on home page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.local_fire_department, color: Colors.orange),
              title: const Text('Streak'),
              onTap: () {
                // TODO: implement navigation
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.volunteer_activism, color: Colors.green),
              title: const Text('Donate'),
              onTap: () {
                // TODO: implement navigation
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.rate_review, color: Colors.purple),
              title: const Text('Testimonials'),
              onTap: () {
                // TODO: implement navigation
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: const Text('Profile'),
              onTap: () {
                // TODO: implement navigation
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('About Us'),
              onTap: () {
                // TODO: implement navigation
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellowAccent),
                  const SizedBox(width: 5),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/Logo2.jpeg', width: 200),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Colors.lightBlueAccent),
                        const SizedBox(width: 5),
                        Text(
                          "$skillerPoints",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.star, color: Colors.yellowAccent),
                        const SizedBox(width: 5),
                        const Text(
                          "SkillerPoints",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Divider(color: Colors.white, thickness: 0.3, height: 1),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, top: 12),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 28.0, top: 12),
                child: Text(
                  "Today's Drills",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: drills.length,
                  itemBuilder: (context, index) {
                    final drill = drills[index];
                    return DrillCard(
                      image: getImageForDrill(drill.name),
                      title: drill.name,
                      difficulty: drill.level,
                      needed: drill.materials,
                      time: drill.duration,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DrillDetailPage(
                              drill: drill,
                              onDrillSubmitted: (points) async {
                                setState(() {
                                  skillerPoints += points;
                                  drillsCompleted += 1;
                                });
                                if (drillsCompleted >= 3) {
                                  await updateStreak();
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Completed $drillsCompleted/3",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: AnimatedBuilder(
                  animation: _rainbowController,
                  builder: (context, child) {
                    final color = HSVColor.fromAHSV(
                      1,
                      (_rainbowController.value * 360) % 360,
                      1,
                      1,
                    ).toColor();
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WeeklyChallengePage()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "🏆 Weekly Challenge",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.0),
                child: Text(
                  "Tomorrow's Drills",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
              ),
              const DrillCard(
                image: 'assets/fitness.jpg',
                title: "Surprise Drill",
                difficulty: "?",
                needed: "?",
                time: "?",
                isCardBlurred: true,
              ),
              const SizedBox(height: 24)
            ],
          ),
        ),
      ),
    );
  }
}

// --- Your DrillCard remains unchanged ---

class DrillCard extends StatefulWidget {
  final String image;
  final String title;
  final String difficulty;
  final String needed;
  final String time;
  final bool isBlurred;
  final bool isCardBlurred;
  final VoidCallback? onTap;

  const DrillCard({
    super.key,
    required this.image,
    required this.title,
    required this.difficulty,
    required this.needed,
    required this.time,
    this.isBlurred = false,
    this.isCardBlurred = false,
    this.onTap,
  });

  @override
  State<DrillCard> createState() => _DrillCardState();
}

class _DrillCardState extends State<DrillCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isHovered
            ? [
                BoxShadow(
                  color: Colors.lightBlueAccent.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.grey.withOpacity(0.5),
                    BlendMode.saturation,
                  ),
                  child: Image.asset(
                    widget.image,
                    width: 110,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (!widget.isBlurred)
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/nobackgroundicon.png',
                    width: 35,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 6),
                  Text("Difficulty: ${widget.difficulty}",
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.white70)),
                  Text("Needed: ${widget.needed}",
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.white70)),
                  Text("Time: ${widget.time}",
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  const Text("*Click on image to see more info*",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ),
          )
        ],
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: widget.isCardBlurred
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Opacity(opacity: 0.3, child: cardContent),
                  )
                : cardContent,
          ),
        ),
      ),
    );
  }
}

class TodaysDrillsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  TodaysDrillsPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Welcome, ${user['name']}!"),
          Text("Your goals: ${user['goals']}"),
          // Load drills based on user['goals'], etc.
        ],
      ),
    );
  }
}

// Streak Page

class StreakPage extends StatelessWidget {
  const StreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Streak',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      drawer: AppDrawer(), // 👈 Add this for the menu
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
              child: Image.asset('assets/Logo2.jpeg', width: 120),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Divider(color: Colors.white, thickness: 0.3, height: 1),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth < 400 ? 12 : 28,
                ),
                children: const [
                  ProgressCard(
                    image: 'assets/progress1.jpg',
                    title: "Drills Done:",
                    detail1: "Total: 56",
                    detail2: "Current section: 6/10",
                  ),
                  ProgressCard(
                    image: 'assets/progress2.jpg',
                    title: "Juggling Record:",
                    detail1: "Total: 150",
                    detail2: "*Click image to upload video",
                  ),
                  ProgressCard(
                    image: 'assets/progress3.jpg',
                    title: "Skill level:",
                    detail1: "Total: Intermediate",
                    detail2: "Live response: Intermediate",
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        Text(
                          "Streak",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFFFF760D),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.local_fire_department,
                            color: Colors.blueAccent),
                      ],
                    ),
                  ),
                  SizedBox(height: 14),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            size: 32, color: Colors.white),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Drills Done This Month:",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "23",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Streak:",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_fire_department,
                                    color: Colors.lightBlueAccent),
                                SizedBox(width: 5),
                                Text(
                                  "Streak: 512",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressCard extends StatefulWidget {
  final String image;
  final String title;
  final String detail1;
  final String detail2;

  const ProgressCard({
    super.key,
    required this.image,
    required this.title,
    required this.detail1,
    required this.detail2,
  });

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive margins and image size
    final horizontalMargin = screenWidth < 400 ? 8.0 : 20.0;
    final imageWidth = screenWidth < 400 ? 80.0 : 110.0;
    final imageHeight = screenWidth < 400 ? 65.0 : 90.0;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
        margin:
            EdgeInsets.symmetric(vertical: 10.0, horizontal: horizontalMargin),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: Colors.lightBlueAccent.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                widget.image,
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            color: Color(0xFF37B5FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(widget.detail1,
                        style: const TextStyle(color: Colors.white70)),
                    Text(widget.detail2,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Page

class ProfilePage extends StatefulWidget {
  final String userEmail;

  const ProfilePage({super.key, required this.userEmail});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void showCharacterPopup(BuildContext context, int userSkillerPoints) {
    showDialog(
      context: context,
      builder: (context) =>
          CharacterSelectionDialog(userSkillerPoints: userSkillerPoints),
    );
  }

  Map<String, dynamic>? profile;
  bool isLoading = true;
  String selectedAvatar = 'assets/default_user.png';

  final characters = [
    Character(
      name: 'Dribblebot',
      type: 'dribbling',
      imagePath: 'assets/avatars/char1.png',
      stageCosts: [50, 100, 200],
    ),
    Character(
      name: 'ShooterX',
      type: 'shooting',
      imagePath: 'assets/avatars/char2.png',
      stageCosts: [50, 100, 200],
    ),
    Character(
      name: 'PassMaster',
      type: 'passing',
      imagePath: 'assets/avatars/char3.png',
      stageCosts: [50, 100, 200],
    ),
    Character(
      name: 'TouchWizard',
      type: 'ball control',
      imagePath: 'assets/avatars/char4.png',
      stageCosts: [50, 100, 200],
    ),
    Character(
      name: 'Wall',
      type: 'goalkeeping',
      imagePath: 'assets/avatars/char5.png',
      stageCosts: [50, 100, 200],
    ),
    Character(
      name: 'Jet',
      type: 'speed',
      imagePath: 'assets/avatars/char6.png',
      stageCosts: [50, 100, 200],
    ),
    Character(
      name: 'Tank',
      type: 'strength',
      imagePath: 'assets/avatars/char7.png',
      stageCosts: [50, 100, 200],
    ),
    Character(
      name: 'Brainiac',
      type: 'decision making',
      imagePath: 'assets/avatars/char8.png',
      stageCosts: [50, 100, 200],
    ),
    Character(
      name: 'IronLungs',
      type: 'endurance',
      imagePath: 'assets/avatars/char9.png',
      stageCosts: [50, 100, 200],
    ),
    Character(
      name: 'Maestro',
      type: 'dribbling',
      imagePath: 'assets/avatars/char10.png',
      stageCosts: [50, 100, 200],
    ),
  ];

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://sheet.best/api/sheets/40dc0262-f967-41a8-81bb-ea8bb4eb5641',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-Api-Key':
              r'fLNa8X9rZQiyZGOZU#F0Q9YPIp2$adDeZ1SWFp1cq!$cOhaPUXTMvD#ykW-OuaEy',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final userProfile = data.firstWhere(
          (row) => row['email'] == widget.userEmail,
          orElse: () => null,
        );

        if (userProfile != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userData', json.encode(userProfile));
          setState(() {
            profile = userProfile;
            selectedAvatar = userProfile['avatar'] ?? 'assets/default_user.png';
          });
        }
      }
    } catch (e) {
      print("Error fetching from Sheet: $e");
    }

    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      final data = json.decode(userDataString);
      setState(() {
        profile = data;
        selectedAvatar = data['avatar'] ?? 'assets/default_user.png';
      });
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void showAvatarPicker() {
    final int skillerPoints =
        int.tryParse(profile?['skillerPoints'] ?? '0') ?? 0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: characters.map((character) {
              final index = characters.indexOf(character);
              final unlockCost = (index + 1) * 10;
              final isUnlocked = skillerPoints >= unlockCost;

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => CharacterDetailPopup(
                      character: character,
                      skillerPoints: skillerPoints,
                      isUnlocked: isUnlocked,
                      onSelected: () async {
                        final prefs = await SharedPreferences.getInstance();
                        setState(() => selectedAvatar = character.imagePath);
                        Navigator.pop(context); // close detail
                        Navigator.pop(context); // close avatar grid
                        profile?['avatar'] = character.imagePath;
                        await prefs.setString('userData', json.encode(profile));
                      },
                    ),
                  );
                },
                child: Stack(
                  children: [
                    ColorFiltered(
                      colorFilter: isUnlocked
                          ? const ColorFilter.mode(
                              Colors.transparent, BlendMode.multiply)
                          : const ColorFilter.mode(
                              Colors.grey, BlendMode.saturation),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: AssetImage(character.imagePath),
                      ),
                    ),
                    if (!isUnlocked)
                      const Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(Icons.lock, size: 16, color: Colors.red),
                      )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final username = profile?['username'] ?? 'username';
    final name = profile?['name'] ?? 'Your Name';
    final city = profile?['location'] ?? 'City, State';
    final streak = profile?['streak'] ?? '0';
    final skillerPoints = profile?['skillerPoints'] ?? '0';
    final latestAchiev = profile?['latestAchievement'] ?? 'None';

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            backgroundColor: Colors.black,
            title: const Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/soccer_header.jpeg', fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Transform.translate(
                  offset: const Offset(0, -60),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(selectedAvatar),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            showCharacterPopup(
                              context,
                              skillerPoints,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text('@$username',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
                Text(name,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(city, style: const TextStyle(color: Colors.white54)),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Overview',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(''),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      _overviewCard(
                          Icons.local_fire_department, '$streak', 'Day Streak'),
                      _overviewCard(
                          Icons.star, '$skillerPoints', 'Total SkillerPoints'),
                      _overviewCard(Icons.attach_money, '\$50', 'Donated'),
                      _overviewCard(
                          Icons.emoji_events, latestAchiev, 'Latest Achiev'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Achievements',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AchievementsPage()),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('View All',
                              style: TextStyle(color: Colors.lightBlueAccent)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      6,
                      (index) => Container(
                        width: MediaQuery.of(context).size.width / 3 - 30,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.emoji_events,
                            color: Colors.white70),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          )
        ],
      ),
    );
  }

  static Widget _overviewCard(IconData icon, String value, String label) {
    return SizedBox(
      width: 160,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(icon, color: Colors.lightBlueAccent, size: 28),
            const SizedBox(width: 10),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Character {
  final String imagePath;
  final String name;
  final String type;
  final List<int> stageCosts;

  Character({
    required this.imagePath,
    required this.name,
    required this.type,
    required this.stageCosts,
  });
}

class CharacterDetailPopup extends StatelessWidget {
  final Character character;
  final int skillerPoints;
  final bool isUnlocked;
  final VoidCallback onSelected;

  const CharacterDetailPopup({
    super.key,
    required this.character,
    required this.skillerPoints,
    required this.isUnlocked,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage(character.imagePath),
            ),
            const SizedBox(height: 12),
            Text(character.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            Text(character.type,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            ...List.generate(character.stageCosts.length, (index) {
              final cost = character.stageCosts[index];
              final isAvailable = skillerPoints >= cost;

              return ListTile(
                title: Text('Stage ${index + 1}',
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text('$cost SkillerPoints',
                    style: TextStyle(
                        color: isAvailable ? Colors.green : Colors.redAccent)),
                trailing: isAvailable
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.lock, color: Colors.redAccent),
              );
            }),
            const SizedBox(height: 20),
            if (isUnlocked)
              ElevatedButton(
                onPressed: onSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Select Character'),
              )
            else
              const Text('Not enough SkillerPoints',
                  style: TextStyle(color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}

class CharacterSelectionDialog extends StatefulWidget {
  final int userSkillerPoints;

  const CharacterSelectionDialog({super.key, required this.userSkillerPoints});

  @override
  State<CharacterSelectionDialog> createState() =>
      _CharacterSelectionDialogState();
}

class _CharacterSelectionDialogState extends State<CharacterSelectionDialog> {
  int currentIndex = 0;

  final List<Map<String, dynamic>> characters = [
    {
      "name": "IronClad",
      "images": [
        "assets/ironcladS1.png",
        "assets/ironcladS2.png",
        "assets/ironcladS3.png"
      ],
      "prices": ["FREE", "50 SP", "95 SP"],
      "type": "strength",
    },
    {
      "name": "Speedster",
      "images": [
        "assets/speedsterS1.png",
        "assets/speedsterS2.png",
        "assets/speedsterS3.png"
      ],
      "prices": ["FREE", "60 SP", "100 SP"],
      "type": "speed",
    },
    // Add more characters here...
  ];

  void nextChar() {
    setState(() {
      currentIndex = (currentIndex + 1) % characters.length;
    });
  }

  void prevChar() {
    setState(() {
      currentIndex = (currentIndex - 1 + characters.length) % characters.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentChar = characters[currentIndex];

    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 311,
        height: 512,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Row: Back button + SkillerPoints
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    Text(
                      widget.userSkillerPoints.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Colors.yellow, size: 18),
                  ],
                ),
              ],
            ),

            // Character Name
            Text(
              currentChar["name"],
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Character Image with arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left,
                      color: Color(0xFF37B5FF), size: 30),
                  onPressed: prevChar,
                ),
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          currentChar["images"][1]), // Show stage 2 image
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right,
                      color: Color(0xFF37B5FF), size: 30),
                  onPressed: nextChar,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Purchase Button
            SizedBox(
              width: 106,
              height: 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37B5FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // handle purchase logic here
                },
                child: const Text(
                  "Purchase",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Price Text
            Text(
              currentChar["prices"][1] == "FREE"
                  ? "Free to unlock"
                  : "Earn ${currentChar["prices"][1]} to purchase",
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: Colors.white, thickness: 0.4),

            const SizedBox(height: 8),

            // Evolution Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Evolution:",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Evolution Images
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildStageBox(
                    currentChar["images"][0], currentChar["prices"][0]),
                const Icon(Icons.arrow_right, color: Color(0xFF37B5FF)),
                buildStageBox(
                    currentChar["images"][1], currentChar["prices"][1]),
                const Icon(Icons.arrow_right, color: Color(0xFF37B5FF)),
                buildStageBox(
                    currentChar["images"][2], currentChar["prices"][2]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStageBox(String image, String price) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// =================== ACHIEVEMENTS PAGE ======================

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> achievements = [
      {
        'title': 'Juggling Genius',
        'desc': 'Reach 100 juggles',
        'earned': true,
        'date': '2025-07-10'
      },
      {
        'title': 'First Touch',
        'desc': 'Submit your first drill',
        'earned': true,
        'date': '2025-07-09'
      },
      {
        'title': 'Speed Demon',
        'desc': 'Finish 10 sprint drills',
        'earned': false
      },
      {'title': 'Streak King', 'desc': 'Keep a 30-day streak', 'earned': false},
      {
        'title': 'Dribble Pro',
        'desc': 'Master 20 dribble drills',
        'earned': false
      },
      {
        'title': 'Team Player',
        'desc': 'Join a team session',
        'earned': true,
        'date': '2025-07-11'
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('All Achievements',
            style: TextStyle(color: Colors.white)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.8,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final a = achievements[index];
          return _FlipCard(
            title: a['title'],
            desc: a['desc'],
            earned: a['earned'] == true,
            date: a['earned'] == true ? a['date'] : null,
          );
        },
      ),
    );
  }
}

class _FlipCard extends StatefulWidget {
  final String title;
  final String desc;
  final bool earned;
  final String? date;

  const _FlipCard({
    required this.title,
    required this.desc,
    required this.earned,
    this.date,
  });

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _toggleCard() {
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    isFront = !isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isBack = angle > pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: isBack ? _buildBack() : _buildFront(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.emoji_events,
            size: 32, color: widget.earned ? Colors.amber : Colors.grey),
        const SizedBox(height: 8),
        Text(widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.earned ? Colors.white : Colors.white38,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            )),
      ],
    );
  }

  Widget _buildBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white70)),
          if (widget.date != null) ...[
            const SizedBox(height: 6),
            Text("Earned: ${widget.date}",
                style: const TextStyle(
                    fontSize: 11, color: Colors.lightBlueAccent)),
          ]
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AppEntry extends StatelessWidget {
  final bool isLoggedIn;
  final String? userEmail;

  const AppEntry({super.key, required this.isLoggedIn, this.userEmail});

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn && userEmail != null) {
      return MainNavigation(userEmail: userEmail!);
    } else {
      return const SignUpScreen(); // Shows sign-up flow
    }
  }
}

class MainNavigation extends StatefulWidget {
  final String userEmail;

  const MainNavigation({super.key, required this.userEmail});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SoccerHomePage(),
      StreakPage(),
      DonationPage(),
      TestimonialPage(),
      ProfilePage(userEmail: widget.userEmail), // ✅ pass email here
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: ''),
        ],
      ),
    );
  }
}

// Testimonials Page

class TestimonialPage extends StatefulWidget {
  const TestimonialPage({super.key});

  @override
  State<TestimonialPage> createState() => _TestimonialPageState();
}

class _TestimonialPageState extends State<TestimonialPage> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 0;
  final TextEditingController _testimonialController = TextEditingController();

  bool isSubmitting = false;

  Future<void> sendTestimonial(int rating, String testimonial) async {
    setState(() => isSubmitting = true);

    const serviceId = 'service_79tuh3y';
    const templateId = 'template_9ui7oua';
    const publicKey = 'X3wodZxa85q2sJO6w';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': publicKey,
        'template_params': {
          'rating': rating.toString(),
          'testimonial': testimonial,
        }
      }),
    );

    setState(() => isSubmitting = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Thank you for your feedback!")),
      );
      _testimonialController.clear();
      setState(() => _rating = 0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send. Please try again.")),
      );
      print("EmailJS error: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: AppDrawer(), // 👈 Add drawer
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Testimonials',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "We value your feedback",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please rate your experience and leave a testimonial below.",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.yellowAccent,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() => _rating = index + 1);
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _testimonialController,
                        maxLines: 5,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Write your testimonial...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a testimonial.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                if (_formKey.currentState!.validate() &&
                                    _rating > 0) {
                                  sendTestimonial(
                                    _rating,
                                    _testimonialController.text.trim(),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Please rate and write a testimonial."),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        "What others are saying:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _testimonialCard(
                              "Alex, 16", "Helped me improve my juggling!"),
                          _testimonialCard("Mia, 14", "Love the daily drills!"),
                          _testimonialCard(
                              "Jordan, 18", "Great way to track my progress."),
                          _testimonialCard(
                              "Sophia, 15", "The streaks keep me motivated."),
                          _testimonialCard(
                              "Liam, 17", "Clean and easy to use app."),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _testimonialCard(String name, String feedback) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feedback,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// Donation Page

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  double? selectedAmount;
  final TextEditingController _customAmountController = TextEditingController();
  bool isDonating = false;
  bool showThanks = false;

  Future<void> _donate(double amount) async {
    setState(() {
      isDonating = true;
      showThanks = false;
    });

    final url =
        'https://paypal.me/SoccerSkiller?country.x=US&locale.x=en_US&amount=$amount';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isDonating = false;
      showThanks = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      showThanks = false;
    });
  }

  void _onDonatePressed() {
    double? amount = selectedAmount;
    if (amount == null && _customAmountController.text.isNotEmpty) {
      amount = double.tryParse(_customAmountController.text);
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select or enter a valid donation amount")),
      );
      return;
    }

    _donate(amount);
  }

  Widget _amountButton(double amount) {
    final isSelected = selectedAmount == amount;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAmount = amount;
          _customAmountController.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white10,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          "\$$amount",
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: AppDrawer(), // 👈 Add the drawer
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Donate',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Support Needy Kids ❤️",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Your donation helps provide soccer equipment to children who can’t afford it. Together, we can make dreams come true and bring smiles to their faces. Every dollar counts — thank you for making a difference!",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Choose an amount:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _amountButton(5),
                        _amountButton(10),
                        _amountButton(25),
                        _amountButton(50),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Or enter a custom amount:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customAmountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter amount in USD",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          selectedAmount = null;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isDonating ? 0.5 : 1,
                      child: ElevatedButton(
                        onPressed: isDonating ? null : _onDonatePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                        child: isDonating
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Donate Now",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (showThanks)
              Center(
                child: Container(
                  color: Colors.black87.withOpacity(0.7),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, color: Colors.redAccent, size: 80),
                        SizedBox(height: 20),
                        Text(
                          "❤️ Thank you for your generous donation! ❤️",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Weekly Challenge Page

class WeeklyChallengePage extends StatefulWidget {
  const WeeklyChallengePage({super.key});

  @override
  State<WeeklyChallengePage> createState() => _WeeklyChallengePageState();
}

class _WeeklyChallengePageState extends State<WeeklyChallengePage> {
  WeeklyChallenge? currentChallenge;
  bool isCompleted = false;
  String? selectedFileName;

  final WeeklyChallengeService challengeService = WeeklyChallengeService();

  @override
  void initState() {
    super.initState();
    loadChallenge();
  }

  Future<void> loadChallenge() async {
    await challengeService.loadChallenges();

    setState(() {
      // Replace 'beginner' with user’s actual level
      currentChallenge = challengeService.getCurrentChallenge('beginner');
    });
  }

  Future<void> pickVideoFile() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Video upload is not supported on Web yet."),
        ),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
      });
    }
  }

  void submitChallenge() {
    if (selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a video before submitting."),
        ),
      );
      return;
    }

    setState(() {
      isCompleted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Challenge submitted successfully! 🎉"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Weekly Challenge",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: currentChallenge == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "🔥 ${currentChallenge!.title}",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentChallenge!.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "⭐ Earn ${currentChallenge!.points} SkillerPoints",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "✅ You’ve already completed this week’s challenge!\nSee you next week.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 18,
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: pickVideoFile,
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Select Video"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (selectedFileName != null)
                          Text(
                            "📄 Selected: $selectedFileName",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed:
                              selectedFileName == null ? null : submitChallenge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedFileName == null
                                ? Colors.grey
                                : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Submit Challenge",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}

/// Model
class WeeklyChallenge {
  final String title;
  final String description;
  final int points;
  final String level;

  WeeklyChallenge({
    required this.title,
    required this.description,
    required this.points,
    required this.level,
  });

  factory WeeklyChallenge.fromCsvRow(List<dynamic> row) {
    return WeeklyChallenge(
      title: row[0] as String,
      description: row[1] as String,
      points: int.parse(row[2].toString()),
      level: row[3] as String,
    );
  }
}

/// Service
class WeeklyChallengeService {
  List<WeeklyChallenge> allChallenges = [];

  Future<void> loadChallenges() async {
    final rawData = await rootBundle.loadString('assets/weekly_challenges.csv');
    final csvTable = const CsvToListConverter().convert(rawData, eol: '\n');

    allChallenges = csvTable.skip(1).map(WeeklyChallenge.fromCsvRow).toList();
  }

  WeeklyChallenge getCurrentChallenge(String userLevel) {
    final weekOfYear =
        int.parse(DateFormat("w").format(DateTime.now())); // 1..52

    final filtered = allChallenges
        .where((c) => c.level.toLowerCase() == userLevel.toLowerCase())
        .toList();

    if (filtered.isEmpty) {
      throw Exception("No challenges found for level: $userLevel");
    }

    final index = weekOfYear % filtered.length;

    return filtered[index];
  }
}
