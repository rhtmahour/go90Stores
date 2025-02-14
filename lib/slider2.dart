import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class Slider2 extends StatefulWidget {
  const Slider2({super.key});

  @override
  State<Slider2> createState() => _Slider2State();
}

class _Slider2State extends State<Slider2> {
  int currentPageIndex = 0; // State to track the current page index

  final List<String> imagePaths = [
    "assets/images/slider1.webp",
    "assets/images/slider2.webp",
    "assets/images/slider3.webp",
    "assets/images/slider4.webp",
    "assets/images/slider5.webp",
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: imagePaths.length,
          itemBuilder: (context, index, realIndex) {
            return Container(
              margin: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: AssetImage(imagePaths[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 200.0,
            enlargeCenterPage: true,
            autoPlay: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.8,
            onPageChanged: (index, reason) {
              setState(() {
                currentPageIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 20.0),
        DotsIndicator(
          dotsCount: imagePaths.length,
          position: currentPageIndex.toDouble(), // This should work as a double
          decorator: DotsDecorator(
            color: Colors.blue,
            activeColor: Colors.purple,
            size: const Size.square(9.0),
            spacing: const EdgeInsets.all(3.0),
            activeSize: const Size(18.0, 9.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ],
    );
  }
}
