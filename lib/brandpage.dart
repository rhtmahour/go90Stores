import 'package:flutter/material.dart';

class Brandpage extends StatelessWidget {
  const Brandpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: 500,
      color: Colors.purple[50],
      child: Column(
        // Wrapped the Rows in a Column widget
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5, left: 10),
            child: Text(
              'Shop By Brands',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 150,
                  //color: Colors.white,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: Row(
                    children: [
                      const Text(
                        'TATA Tea',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 70,
                        //color: Colors.green[50],
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            image: const DecorationImage(
                                image: AssetImage('assets/images/tata.png'),
                                fit: BoxFit.cover)),
                        alignment: Alignment.topCenter,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 150,
                  //color: Colors.white,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: Row(
                    children: [
                      const Text(
                        'Dettol',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        height: 50,
                        width: 80,
                        //color: Colors.green[50],
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            image: const DecorationImage(
                                image: AssetImage('assets/images/dettol.png'),
                                fit: BoxFit.cover)),
                        alignment: Alignment.topCenter,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 150,
                  //color: Colors.white,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: Row(
                    children: [
                      const Text(
                        'Coca-Cola',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        height: 50,
                        width: 70,
                        //color: Colors.green[50],
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            image: const DecorationImage(
                                image:
                                    AssetImage('assets/images/coca_cola.png'),
                                fit: BoxFit.cover)),
                        alignment: Alignment.topCenter,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 150,
                  //color: Colors.white,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: Row(
                    children: [
                      const Text(
                        'LOreal',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          height: 50,
                          width: 90,
                          //color: Colors.green[50],
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              image: const DecorationImage(
                                  image: AssetImage('assets/images/loreal.png'),
                                  fit: BoxFit.cover)),
                          alignment: Alignment.topCenter,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 150,
                  //color: Colors.white,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: Row(
                    children: [
                      const Text(
                        'India Gate',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        height: 50,
                        width: 70,
                        //color: Colors.green[50],
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            image: const DecorationImage(
                                image:
                                    AssetImage('assets/images/india_gate.png'),
                                fit: BoxFit.cover)),
                        alignment: Alignment.topCenter,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 150,
                  //color: Colors.white,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: Row(
                    children: [
                      const Text(
                        'Catch',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 50,
                          width: 80,
                          //color: Colors.green[50],
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              image: const DecorationImage(
                                  image: AssetImage('assets/images/catch.png'),
                                  fit: BoxFit.cover)),
                          alignment: Alignment.topCenter,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
