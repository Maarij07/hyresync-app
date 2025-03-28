import 'package:flutter/material.dart';
import 'package:hyresync/features/auth/sign_in.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  int _currentPage = 0;
  
  final List<OnboardingContent> _contents = [
    OnboardingContent(
      image: 'assets/images/onboard-1.png',
      title: 'Apply Your\nFavorite Job!',
      description: 'Find your dream Job between more than 1 million job offers from client all around the world.',
    ),
    OnboardingContent(
      image: 'assets/images/onboard-2.png',
      title: 'Get Your Dream\nJob!',
      description: 'With this application you can get a job according to your skills',
    ),
    OnboardingContent(
      image: 'assets/images/onboard-3.png',
      title: 'Make Your Career Choice!',
      description: 'You can choose a job according to your criteria, starting from the type of work, location, salary, schedule',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _contents.length - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignIn()),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final isLastPage = _currentPage == _contents.length - 1;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content takes most of the space
            Expanded(
              child: Center(
                child: Image.asset(
                  _contents[_currentPage].image,
                  width: screenSize.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            // Bottom section with text and pagination
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading text
                  Text(
                    _contents[_currentPage].title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Description text
                  Text(
                    _contents[_currentPage].description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Pagination row
                  Row(
                    children: [
                      // Pagination dots
                      Row(
                        children: List.generate(
                          _contents.length,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? const Color(0xFF0057FF)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(
                                _currentPage == index ? 4 : 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Spacer
                      const Spacer(),
                      
                      // Navigation arrows or button
                      if (_currentPage > 0)
                        GestureDetector(
                          onTap: _previousPage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      const SizedBox(width: 10),
                      
                      // Next button or Start Now button
                      GestureDetector(
                        onTap: _nextPage,
                        child: isLastPage
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0057FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Start Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0057FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String image;
  final String title;
  final String description;
  
  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}