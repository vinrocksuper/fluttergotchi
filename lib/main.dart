// ignore_for_file: prefer_const_constructors, non_constant_identifier_names
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project3/my_flutter_app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool debug = true;
  bool isAlive = true;
  bool isAsleep = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    init();
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
          timeUntilNextFeeding = 0;
          canEat = true;
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        loadStats();
        break;
      case AppLifecycleState.inactive:
        saveStats();
        break;
      case AppLifecycleState.paused:
        saveStats();
        break;
      default: // detached
        saveStats();
        break;
    }
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

  void init() async {
    prefs = await SharedPreferences.getInstance();
    loadStats();
  }

  void loadStats() {
    setState(() {
      int? hun = prefs.getInt('hunger');
      if (hun != null) {
        hunger = hun;
      }
      int? c = prefs.getInt('cleanliness');
      if (c != null) {
        cleanliness = c;
      }
      int? en = prefs.getInt('energy');
      if (en != null) {
        energy = en;
      }
      int? hap = prefs.getInt('happiness');
      if (hap != null) {
        happiness = hap;
      }
      int? hea = prefs.getInt('health');
      if (hea != null) {
        health = hea;
      }

      final lastOpened = prefs.getInt('lastOpened');
      final now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      if (lastOpened != null) {
        final elapsedTime = now - lastOpened;

        // Decay (or increase) stats
        int toRun = (elapsedTime / 60 / 4).floor();
        hunger -= toRun;
        cleanliness -= toRun;

        final wasAsleep = prefs.getBool('wasSleeping');
        if (wasAsleep!) {
          energy += (toRun / 2).floor();
          happiness += (toRun / 4).floor();
        } else {
          energy -= toRun;
          happiness -= toRun;
        }

        adjustHealth(multiplier: (toRun / 4).floor());

        // Age up
        final toNext = prefs.getInt('timeToNextAge');
        if (toNext != null) {
          final toAge = (elapsedTime / 3600).floor();
          final toNextAge = (elapsedTime % 3600);
          age = toAge;
          timeUntilNextAge = toNextAge;
        }

        final nextFeeding = prefs.getInt('timeNextEat');
        if (nextFeeding != null) {
          timeUntilNextFeeding = nextFeeding - elapsedTime;
        }
        canEat = prefs.getBool('canEat')!;
      }
    });
  }

  void saveStats() {
    // Sets time last opened to compare so can decay stats
    final now = ((DateTime.now()).millisecondsSinceEpoch / 1000).floor();
    prefs.setInt('lastOpened', now);
    prefs.setBool('wasSleeping', isAsleep);
    prefs.setInt('age', age);
    prefs.setInt('timeToNextAge', timeUntilNextAge);
    prefs.setInt('hunger', hunger);
    prefs.setInt('cleanliness', cleanliness);
    prefs.setInt('energy', energy);
    prefs.setInt('happiness', happiness);
    prefs.setInt('health', health);
    prefs.setBool('canEat', canEat);
    prefs.setInt('timeNextEat', timeUntilNextFeeding);
  }

  /// Technically a misnomer since it also increases stats if the fluttergotchi is asleep
  /// 50% chance to decreases one of the main four stats randomly every 30 seconds
  /// Or if asleep, 1/8 chance to decrease fullness/cleanliness, 1/4 chance to increase energy, 1/40 chance to increase happiness
  void decayStat() {
    if (!isAsleep) {
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
    } else {
      if (rng.nextBool() && rng.nextBool()) {
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
        } else {
          energy++;
          if (toDecay > 90) {
            happiness++;
            if (happiness > 100) {
              happiness = 100;
            }
          }
          if (energy > 100) {
            energy = 100;
          }
        }
      }
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
              visible: index == 1,
              child: CleaningArea(),
            ),
            Visibility(
              visible: index == 2,
              child: SleepingArea(),
            ),
            Visibility(
              visible: index == 3,
              child: GameArea(),
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
                  hunger = 90;
                  cleanliness = 60;
                  energy = 70;
                  happiness = 40;
                  print(hunger);
                  print(cleanliness);
                  print(energy);
                  print(happiness);
                  print(health);
                  print(age);
                  print(timeUntilNextAge);
                  print(canEat);
                  print(timeUntilNextFeeding);
                },
                child: Text('Debug Reset'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget SleepingArea() {
    return Column(
      children: [
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
                  color: ProgressBarColor(energy),
                  minHeight: 25,
                  value: energy / 100,
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
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              isAsleep = !isAsleep;
            });
          },
          label: !isAsleep ? Text('Sleep') : Text('Wake Up'),
          icon: !isAsleep
              ? Icon(Icons.airline_seat_individual_suite_sharp)
              : Icon(Icons.sunny),
        ),
      ],
    );
  }

  Widget CleaningArea() {
    return Column(
      children: [
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
                  color: ProgressBarColor(cleanliness),
                  minHeight: 25,
                  value: cleanliness / 100,
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
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            adjustStat(toAdjust: 'cleanliness', amount: 100);
          },
          label: Text('Shower'),
          icon: Icon(Icons.shower_rounded),
        ),
      ],
    );
  }

  Widget FeedingArea() {
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
                  color: ProgressBarColor(hunger),
                  minHeight: 25,
                  value: hunger / 100,
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
          ),
        ),
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
            print('${canEat} bread');
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
          if (hunger > 100) {
            hunger = 100;
          }
        });
        break;
      case 'cleanliness':
        setState(() {
          cleanliness += amount as int;
          if (cleanliness > 100) {
            cleanliness = 100;
          }
        });
        break;
      case 'energy':
        setState(() {
          energy += amount as int;
          if (energy > 100) {
            energy = 100;
          }
        });
        break;
      case 'happiness':
        setState(() {
          happiness += amount as int;
          if (happiness > 100) {
            happiness = 100;
          }
        });
        break;
      default:
        break;
    }
  }

  void adjustHealth({multiplier = 1}) {
    setState(() {
      // Become sick if hungry/dirty/tired/depressed
      if (hunger <= 0) {
        health -= (2 * multiplier) as int;
      }

      if (cleanliness <= 33) {
        health -= (2 * multiplier) as int;
      } else if (cleanliness <= 66) {
        health -= (1 * multiplier) as int;
      }

      if (energy <= 20) {
        health -= (1 * multiplier) as int;
      }

      if (happiness < 33) {
        health -= (1 * multiplier) as int;
      }

      // Alternatively become healthier if the opposite
      if (hunger >= 85) {
        health += (2 * multiplier) as int;
      } else if (hunger > 66) {
        health += (1 * multiplier) as int;
      }

      if (cleanliness >= 75) {
        health += (1 * multiplier) as int;
      }

      if (energy > 50) {
        health += (1 * multiplier) as int;
      }

      if (happiness > 75) {
        health += (1 * multiplier) as int;
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

  Color ProgressBarColor(value) {
    if (value > 80) {
      return Colors.green;
    } else if (value > 60) {
      return Colors.yellow;
    } else if (value > 40) {
      return Colors.orange;
    }
    return Colors.red;
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
                  color: ProgressBarColor(hunger),
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
                  color: ProgressBarColor(cleanliness),
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
                  color: ProgressBarColor(energy),
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
                  color: ProgressBarColor(happiness),
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
                  color: ProgressBarColor(health),
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
        Visibility(
          visible: !debug,
          child: Row(
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
          ),
        )
      ],
    );
  }

  Widget GameArea() {
    return Column(
      children: [
        Row(
          children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(MyFlutterApp.gamepad)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  color: ProgressBarColor(happiness),
                  minHeight: 25,
                  value: happiness / 100,
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
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(MyFlutterApp.hand_rock),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(MyFlutterApp.hand_paper),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(MyFlutterApp.hand_scissors),
            ),
          ],
        ),
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
