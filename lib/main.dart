// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fluttergotchi',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Fluttergotchi'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int myCount = 0;
  late Timer timer;
  // I will want the timer to keep counting since this will be real time
  bool keepCounting = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (keepCounting) myCount += 1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: StatusControls(),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            DisplayArea(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(
                color: Colors.black12,
                thickness: 6,
              ),
            ),
            // SizedBox(
            //   width: double.infinity,
            //   height: MediaQuery.of(context).size.height / 2.6,

            // ),
            StatusArea(),
          ],
        ),
      ),
    );
  }
}

class StatusArea extends StatelessWidget {
  const StatusArea({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          minHeight: 25,
          value: .7,
        ),
        SizedBox(height: 25),
        LinearProgressIndicator(
          minHeight: 25,
          value: .98,
        ),
        SizedBox(height: 25),
        LinearProgressIndicator(
          minHeight: 25,
          value: .27,
        ),
        SizedBox(height: 25),
        LinearProgressIndicator(
          minHeight: 25,
          value: .67,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(
            color: Colors.black12,
            thickness: 6,
          ),
        ),
        Row(
          children: [
            Text("Age"),
            VerticalDivider(
              width: 20,
              thickness: 100,
              indent: 20,
              endIndent: 0,
              color: Colors.red,
            ),
            Text("Weight"),
            VerticalDivider(
              width: 20,
              thickness: 100,
              indent: 20,
              endIndent: 0,
              color: Colors.red,
            ),
            Text("Sickness"),
          ],
        )
      ],
    );
  }
}

// Where the Fluttergotchi will be displayed
class DisplayArea extends StatelessWidget {
  const DisplayArea({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2.2,
    );
  }
}

// Since i'm building a tamagotchi inspired game, the nav bar isn't really a nav bar in the traditional sense
// and instead they end up doing stuff instead of navigating
class StatusControls extends StatelessWidget {
  const StatusControls({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.black12,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        selectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (value) {},
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dining_outlined,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bathtub_outlined,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bedtime_outlined,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_hospital_outlined,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              // Documentation page
              Icons.info_outline,
            ),
            label: "",
          ),
        ],
      ),
    );
  }
}
