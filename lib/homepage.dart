import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int completed = 0;

  final List<Map<String, String>> drills = [
    {
      'title': 'Intro to Juggling',
      'difficulty': 'Easy',
      'needed': 'Soccer Ball',
      'time': '15 minutes',
      'image': 'assets/juggling.jpg',
    },
    {
      'title': 'Aerial Ball Control',
      'difficulty': 'Intermediate',
      'needed': 'Soccer Ball',
      'time': '10 minutes',
      'image': 'assets/aerial.jpg',
    },
    {
      'title': 'Fitness Training',
      'difficulty': 'Intense',
      'needed': 'Running Shoes',
      'time': '10 minutes',
      'image': 'assets/fitness.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040000),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/Logo2.jpeg', width: 30),
                      const SizedBox(width: 8),
                      const Text(
                        "SOCCERSKILLER",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset('assets/flame.png', width: 20),
                      const SizedBox(width: 5),
                      const Text(
                        "512",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // "Today's Drills" Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: Text(
                  "Today's Drills:",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            // Drill Cards
            Expanded(
              child: ListView.builder(
                itemCount: drills.length,
                itemBuilder: (context, index) {
                  final drill = drills[index];
                  return GestureDetector(
                    onTap: () {
                      // handle drill click
                      setState(() {
                        if (completed < 3) completed++;
                      });
                    },
                    child: MouseRegion(
                      onEnter: (_) => setState(() {}),
                      onExit: (_) => setState(() {}),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              child: Image.asset(
                                drill['image']!,
                                width: 120,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      drill['title']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Difficulty: ${drill['difficulty']}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      "Needed: ${drill['needed']}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      "Time: ${drill['time']}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Text(
                                      "*Click on image to see more info*",
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: 'Poppins',
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Completed counter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Completed $completed/3",
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tomorrow's Drills Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Tomorrow's Drills:",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: ''),
        ],
      ),
    );
  }
}
