import 'package:client_web/signup.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Welcome to Skill Connect",
      "content":
          "Skill Connect is a freelance marketplace connecting professionals with clients. Secure payments, verified skills, and seamless collaboration ensure success.",
      "image": "assets/welcome_bg.jpeg",
    },
    {
      "title": "For Freelancers",
      "content":
          "Freelancers can showcase their expertise, submit proposals, and secure projects with ease. Verified profiles boost credibility.",
      "image": "assets/freelancer_bg.jpeg",
    },
    {
      "title": "For Clients",
      "content":
          "Clients can post jobs, hire the best talent, and track project progress in real time. Transparent reviews help find the right match.",
      "image": "assets/client_bg.jpeg",
    },
    {
      "title": "Freelancer Features",
      "content":
          "Profiles, portfolios, skill verification, and real-time chat ensure freelancers can grow their careers efficiently.",
      "image": "assets/freelancer_features.jpeg",
    },
    {
      "title": "Proposal Submission",
      "content":
          "Freelancers submit proposals for jobs. Clients review and hire the best candidate based on experience and ratings.",
      "image": "assets/proposal_submission.jpeg",
    },
    {
      "title": "Job Posting for Clients",
      "content":
          "Clients create job posts with details, budget, and deadlines. Freelancers can filter and apply for suitable projects.",
      "image": "assets/job_posting.png",
    },
    {
      "title": "Project Tracking",
      "content":
          "Skill Connect offers a built-in tracking system for monitoring progress, exchanging files, and meeting deadlines.",
      "image": "assets/project_tracking.png",
    },
    {
      "title": "Secure Payments",
      "content":
          "An escrow system ensures payments are secure. Clients release payments only after work is delivered satisfactorily.",
      "image": "assets/secure_payments.jpeg",
    },
    {
      "title": "Ratings & Reviews",
      "content":
          "Trust is built through reviews. Both clients and freelancers can leave feedback after successful project completion.",
      "image": "assets/ratings_reviews.jpeg",
    }
  ];

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_pages[index]['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(color: Colors.black.withOpacity(0.6)),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset("assets/newlogo.png", height: 80),
                        const SizedBox(height: 20),
                        Text(
                          _pages[index]['title']!,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            _pages[index]['content']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Pagination dots
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  List.generate(_pages.length, (index) => buildDot(index)),
            ),
          ),

          // Navigation buttons
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                if (_currentIndex > 0)
                  ElevatedButton(
                    onPressed: _prevPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Previous",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),

                // Next Button (Hidden on Last Page)
                if (_currentIndex < _pages.length - 1)
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Next",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),

                // Get Started Button (Only on Last Page)
                if (_currentIndex == _pages.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientSignup(),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32), // Forest Green
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Get Started",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: _currentIndex == index ? 12 : 8,
      height: _currentIndex == index ? 12 : 8,
      decoration: BoxDecoration(
        color: _currentIndex == index ? Colors.white : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
