import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/slide_model.dart';
import 'package:get/get.dart';

class IntroSliderPage extends StatefulWidget {
  @override
  _IntroSliderPageState createState() => _IntroSliderPageState();
}

class _IntroSliderPageState extends State<IntroSliderPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<SlideModel> slides = [
    SlideModel(
      image: 'assets/images/slide1.png',
      title: "Welcome to RNS HealthCare",
      description:
          "Your trusted partner for women’s health and gynaecological care.",
    ),
    SlideModel(
      image: 'assets/images/slide2.png',
      title: "Our Services",
      description: "Expert prenatal care, consultations, screenings, and more.",
    ),
    SlideModel(
      image: 'assets/images/slide3.png',
      title: "Book Now",
      description: "Schedule your appointment easily with our app.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (_, index) {
              final slide = slides[index];
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(slide.image, height: 300),
                    const SizedBox(height: 30),
                    Text(
                      slide.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      slide.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          
           Positioned(
            bottom: 150,
            left: 170,
            right: 00,
             child: Row(
                    children: List.generate(slides.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 12 : 8,
                        height: _currentPage == index ? 12 : 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index ? Colors.blue : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
           ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {

                    if (_currentPage == slides.length - 1) {
                      Get.offAllNamed('/home');
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == slides.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(color: Colors.white  ,)
                  ),
                  
                ),
            
              ],
            ),
          ),
        ],
      ),
    );
  }
}
