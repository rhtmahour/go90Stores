import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go90stores/productpage.dart';

class Slider1 extends StatefulWidget {
  const Slider1({super.key});

  @override
  State<Slider1> createState() => _Slider1State();
}

class _Slider1State extends State<Slider1> {
  int currentPageIndex = 0; // State to track the current page index

  final List<String> imagePaths = [
    "assets/images/slider11.webp",
    "assets/images/slider12.webp",
    "assets/images/slider13.webp",
    "assets/images/slider14.webp",
    "assets/images/slider15.webp",
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: imagePaths.length,
          itemBuilder: (context, index, realIndex) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductPage(storeId: ''),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: AssetImage(imagePaths[index]),
                    fit: BoxFit.cover,
                  ),
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
