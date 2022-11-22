// ignore_for_file: prefer_const_constructors, non_constant_identifier_names
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project3/my_flutter_app_icons.dart';

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
  // Gameplay loop handling
  int myCount = 0;
  late Timer timer;

  // Hidden Stats
  late Timer ageTimer;
  int age = 1;
  int timeUntilNextAge = 3600;
  int health = 100;
  int timeUntilNextFeeding = 0;
  bool canEat = true;
  int weight = 5;

  //Main stats
  int hunger = 50;
  int cleanliness = 50;
  int energy = 50;
  int happiness = 50;

  //Navigation
  int index = 4;

  // Misc Tools
  Random rng = Random();
  bool debug = false;
  bool isAlive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        decayStat();
      });
    });

    ageTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeUntilNextFeeding--;
        timeUntilNextAge--;
        if (timeUntilNextAge == 0) {
          ageUp();
        }
        if (timeUntilNextFeeding <= 0) {
          canEat = true;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    ageTimer.cancel();
  }

  void ageUp() {
    setState(() {
      age++;
      timeUntilNextAge = 3600;
    });
  }

  void decayStat() {
    if (rng.nextBool()) {
      int toDecay = rng.nextInt(100);
      if (toDecay <= 25) {
        hunger--;
        if (hunger <= 0) {
          hunger = 0;
        }
      } else if (toDecay <= 50) {
        cleanliness--;
        if (cleanliness <= 0) {
          cleanliness = 0;
        }
      } else if (toDecay <= 75) {
        energy--;
        if (energy <= 0) {
          energy = 0;
        }
      } else {
        happiness--;
        if (happiness <= 0) {
          happiness = 0;
        }
      }
      adjustHealth();
    }

    if (health <= 0) {
      isAlive = false;
    }
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
            Visibility(
              visible: index == 0,
              child: FeedingArea(),
            ),
            Visibility(
              visible: index == 4,
              child: StatusArea(
                hunger: hunger,
                cleanliness: cleanliness,
                energy: energy,
                happiness: happiness,
                age: age,
              ),
            ),
            Visibility(
              visible: debug,
              child: ElevatedButton(
                onPressed: () {
                  hunger = 50;
                  cleanliness = 50;
                  energy = 50;
                  happiness = 50;
                },
                child: Text('Debug Reset'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget FeedingArea() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            if (canEat) {
              adjustStat(toAdjust: 'hunger', amount: 35);
              adjustStat(toAdjust: 'happiness', amount: 15);
              setState(() {
                canEat = false;
                timeUntilNextFeeding = 1800;
              });
            }
          },
          label: Text('Cake'),
          icon: Icon(Icons.cake_rounded),
        ),
        ElevatedButton.icon(
          onPressed: () {
            if (canEat) {
              adjustStat(toAdjust: 'hunger', amount: 55);
              adjustStat(toAdjust: 'happiness', amount: 5);
              adjustStat(toAdjust: 'cleanliness', amount: -10);
              setState(() {
                canEat = false;
                timeUntilNextFeeding = 1800;
              });
            }
          },
          label: Text('Pizza'),
          icon: Icon(Icons.local_pizza_rounded),
        ),
        ElevatedButton.icon(
          onPressed: () {
            if (canEat) {
              adjustStat(toAdjust: 'hunger', amount: 50);
              setState(() {
                canEat = false;
                timeUntilNextFeeding = 1800;
              });
            }
          },
          label: Text('Bread'),
          icon: Icon(Icons.bakery_dining_rounded),
        ),
      ],
    );
  }

  void adjustStat({toAdjust, amount}) {
    switch (toAdjust) {
      case 'hunger':
        setState(() {
          hunger += amount as int;
        });
        break;
      case 'cleanliness':
        setState(() {
          cleanliness += amount as int;
        });
        break;
      case 'energy':
        setState(() {
          energy += amount as int;
        });
        break;
      case 'happiness':
        setState(() {
          happiness += amount as int;
        });
        break;
      default:
        break;
    }
  }

  void adjustHealth() {
    setState(() {
      // Become sick if hungry/dirty/tired/depressed
      if (hunger <= 0) {
        health -= 2;
      }

      if (cleanliness <= 33) {
        health -= 2;
      } else if (cleanliness <= 66) {
        health--;
      }

      if (energy <= 20) {
        health--;
      }

      if (happiness < 33) {
        health--;
      }

      // Alternatively become healthier if the opposite
      if (hunger >= 85) {
        health += 2;
      } else if (hunger > 66) {
        health++;
      }

      if (cleanliness >= 75) {
        health++;
      }

      if (energy > 50) {
        health++;
      }

      if (happiness > 75) {
        health++;
      }
    });
  }

  Widget StatusControls() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.black12,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.indigoAccent,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (value) {
          if (index != value) {
            index = value;
          }
        },
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
              Icons.games_outlined,
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

  Widget StatusArea({hunger, cleanliness, energy, happiness, age}) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.fastfood_rounded),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  minHeight: 25,
                  value: hunger / 100,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.clean_hands_rounded),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  minHeight: 25,
                  value: cleanliness / 100,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.hotel_rounded),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  minHeight: 25,
                  value: energy / 100,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(MyFlutterApp.gamepad)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  minHeight: 25,
                  value: happiness / 100,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.local_hospital_rounded)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  minHeight: 25,
                  value: health / 100,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(
            color: Colors.black12,
            thickness: 6,
            height: 15,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Age",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  age.toString(),
                  style: TextStyle(
                    fontSize: 24,
                  ),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 7.5,
              child: VerticalDivider(
                width: 6,
                thickness: 6,
                indent: 20,
                endIndent: 0,
                color: Colors.black12,
              ),
            ),
            Column(
              children: [
                Text(
                  "Weight",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  weight.toString(),
                  style: TextStyle(
                    fontSize: 24,
                  ),
                )
              ],
            ),
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
      height: MediaQuery.of(context).size.height / 2.4,
    );
  }
}
