// ignore_for_file: prefer_const_constructors, non_constant_identifier_names
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:project3/my_flutter_app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late Timer animationTimer;
  int age = 1;
  int timeUntilNextAge = 3600;
  int health = 100;
  int timeUntilNextFeeding = 0;
  bool canEat = true;

  //Main stats
  int hunger = 50;
  int cleanliness = 50;
  int energy = 50;
  int happiness = 50;

  //Navigation
  int currentIndex = 4;

  // Misc Tools
  Random rng = Random();
  bool debug = false;
  bool isAlive = true;
  bool isAsleep = false;
  late SharedPreferences prefs;
  int frameNum = 0;

  int animationFrame = 0;
  bool playingAnimation = false;

  int animationNum = 0;

  List<int> column1 = [0, 11, 22, 33, 44, 55, 66, 77];
  List<int> column2 = [1, 12, 23, 34, 45, 56, 67, 78];
  List<int> column3 = [2, 13, 24, 35, 46, 57, 68, 79];
  List<int> column4 = [3, 14, 25, 36, 47, 58, 69, 80];
  List<int> column5 = [4, 15, 26, 37, 48, 59, 70, 81];
  List<int> column6 = [5, 16, 27, 38, 49, 60, 71, 82];
  List<int> column7 = [6, 17, 28, 39, 50, 61, 72, 83];
  List<int> column8 = [7, 18, 29, 40, 51, 62, 73, 84];
  List<int> column9 = [8, 19, 30, 41, 52, 63, 74, 85];
  List<int> column10 = [9, 20, 31, 42, 53, 64, 75, 86];
  List<int> column11 = [10, 21, 32, 43, 54, 65, 76, 87];

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

    animationTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      animationFrame++;
      if (animationFrame > 11) {
        animationFrame = 0;
        if (playingAnimation) {
          playingAnimation = false;
        }

        animationNum = 0;
      }
    });

    ageTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        frameNum++;
        if (frameNum > 11) {
          frameNum = 0;
          animationNum = 0;
        }
        timeUntilNextFeeding--;
        if (isAlive) {
          timeUntilNextAge--;
        }

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

// Ages up the fluttergotchi
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

// Loads the stats 
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
          isAsleep = true;
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

// Saves the stats to be loaded in the next time.
// Autosaves when the app gets backgrounded,
// Alternatively the user can manually save the stats as well
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
              visible: currentIndex == 0,
              child: FeedingArea(),
            ),
            Visibility(
              visible: currentIndex == 2,
              child: SleepingArea(),
            ),
            Visibility(
              visible: currentIndex == 3,
              child: GameArea(),
            ),
            Visibility(
              visible: currentIndex == 4,
              child: StatusArea(
                hunger: hunger,
                cleanliness: cleanliness,
                energy: energy,
                happiness: happiness,
                age: age,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Should be simplifed into single button instead of entire view TBH
// Just like how shower is simplified
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
                child: Progressbar(energy),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(
            color: Colors.black12,
            thickness: 6,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              debug = !debug;
            });
          },
          child: Text('Debug Mode'),
        ),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (context, setState) {
                  return CreditsPopup();
                });
              },
            );
          },
          child: Text('Documentation'),
        ),
        Visibility(
          visible: debug,
          child: ElevatedButton(
            onPressed: () {
              hunger = 90;
              cleanliness = 60;
              energy = 70;
              happiness = 40;
              health = 70;
            },
            child: Text('Debug Reset'),
          ),
        ),
      ],
    );
  }

// Rounded LinearProgressIndicator bar
// Stolen from stackoverflow:
// https://stackoverflow.com/questions/57534160/how-to-add-a-border-corner-radius-to-a-linearprogressindicator-in-flutter
  Widget Progressbar(value) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: LinearProgressIndicator(
        color: ProgressBarColor(value),
        backgroundColor: ProgressBarColor(value).withOpacity(.5),
        minHeight: 25,
        value: value / 100,
      ),
    );
  }

// Interface for feeding the pet.
// Different foods have different effects
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
                child: Progressbar(hunger),
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

// Adjusts the main stats accordingly
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

// Adjusts the health accordingly, gets called once every 30 seconds
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

      if (health < 0) {
        health = 0;
      }
      if (health > 100) {
        health = 100;
      }
    });
  }

// The bottom "navbar"
  Widget StatusControls() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.black12,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.indigoAccent,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (value) {
          if (currentIndex != value) {
            currentIndex = value;
          }
          if (value == 1) {
            adjustStat(toAdjust: 'cleanliness', amount: 100);
            animationNum = 1;
            animationFrame = 0;
            currentIndex = 4;
            playingAnimation = true;
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
              Icons.info_outline,
            ),
            label: "",
          ),
        ],
      ),
    );
  }

// Determines the color of the various status bars
// Color refers to urgency of the stat
// Green > Amber > Orange > Red
  Color ProgressBarColor(value) {
    if (value > 80) {
      return Colors.green;
    } else if (value > 60) {
      return Colors.amberAccent;
    } else if (value > 40) {
      return Colors.orange;
    }
    return Colors.red;
  }

// The main screen of the game, lets you see all of the various stats aggregated on
// a single tab.
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
                child: Progressbar(hunger),
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
                child: Progressbar(cleanliness),
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
                child: Progressbar(energy),
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
                child: Progressbar(happiness),
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
                child: Progressbar(health),
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
                    isAlive ? "Age" : 'DEAD',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    isAlive ? age.toString() : 'Maybe Restart? =>',
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
                  ElevatedButton.icon(
                    onPressed: () {
                      saveStats();
                    },
                    icon: Icon(Icons.save),
                    label: Text('Save'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        hunger = 90;
                        cleanliness = 60;
                        energy = 70;
                        happiness = 40;
                        health = 70;
                        age = 1;
                        isAlive = true;
                        isAsleep = false;
                        timeUntilNextFeeding = 0;
                        timeUntilNextAge = 3600;
                        canEat = true;
                      });
                    },
                    icon: Icon(Icons.restart_alt_rounded),
                    label: Text('Restart'),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  // Determines what color I should use for each "Pixel"
  // (gridview.builder is sorta like a pixel grid if you don't think too hard)
  // Can definitely be used for a better 8 -> 16 bit pixel game if willing enough
  Color DeterminePixels(index) {
    if (animationNum == 1) {
      if (ShowerAnimation(index)) {
        return Colors.blue;
      }
    }
    if (isAlive && !isAsleep) {
      if (index == 81 || index == 84) {
        return Colors.amberAccent;
      }
      if (IdleAnimation(index)) {
        return Colors.lightBlueAccent;
      }
      if (index == 24 || (index == 23 && frameNum % 2 == 1)) {
        return Colors.amberAccent;
      }
      return Colors.white;
    } else if (isAlive && isAsleep) {
      if (SleepAnimation(index)) {
        return Colors.lightBlueAccent;
      }
      if (index == 52 || index == 78) {
        return Colors.amberAccent;
      }
    } else {
      if (Dead(index)) {
        return Colors.lightBlueAccent;
      }
      if (index == 52 || index == 78) {
        return Colors.amberAccent;
      }
    }

    return Colors.white;
  }

// It's a simple sleeping animation, about the peak of my artistic talent if you ask me
  bool SleepAnimation(index) {
    if (frameNum % 2 == 1) {
      if (index == 58 || index == 59) {
        return true;
      }
    }
    if (index == 63) {
      return true;
    }
    if (index == 74 || index == 75) {
      return true;
    }
    if (index >= 68 && index <= 71) {
      return true;
    }
    if (index >= 79 && index <= 86) {
      return true;
    }
    return false;
  }

  // OK this is a really bad name but don't worry about it
  bool Dead(index) {
    if (index == 63) {
      return true;
    }
    if (index == 74 || index == 75) {
      return true;
    }
    if (index >= 68 && index <= 71) {
      return true;
    }
    if (index >= 79 && index <= 86) {
      return true;
    }
    return false;
  }

  // OK this is definitely not a great solution here, but
  // it works and I'm too mentally tired to figure out the proper solution
  bool ShowerAnimation(index) {
    if (animationFrame == 0) {
      if (column11.contains(index)) {
        return true;
      }
    }
    if (animationFrame == 1) {
      if (column10.contains(index)) {
        return true;
      }
    }
    if (animationFrame == 2) {
      if (column9.contains(index)) {
        return true;
      }
    }
    if (animationFrame == 3) {
      if (column8.contains(index)) {
        return true;
      }
    }
    if (animationFrame == 4) {
      if (column7.contains(index)) {
        return true;
      }
    }
    if (animationFrame == 5) {
      if (column6.contains(index)) {
        return true;
      }
    }
    if (animationFrame == 6) {
      if (column5.contains(index)) {
        return true;
      }
    }
    if (animationFrame == 7) {
      if (column4.contains(index)) {
        return true;
      }
    }
    if (animationFrame == 8) {
      if (column3.contains(index)) {
        return true;
      }
    }
    if (animationFrame == 9) {
      if (column2.contains(index)) {
        return true;
      }
    }
    if (animationFrame == 10) {
      if (column1.contains(index)) {
        return true;
      }
    }

    return false;
  }

  // Again the animations are hardcoded, but that's on me for not
  // wanting to use a sprite and only using gridview.builder
  bool IdleAnimation(index) {
    if (frameNum % 2 == 0) {
      if (index == 8 || index == 9) {
        return true;
      }
      if (index >= 14 && index <= 16) {
        return true;
      }
      if (index == 18 || index == 19) {
        return true;
      }
      if (index == 24) {
        return false;
      }
      if (index > 24 && index <= 29) {
        return true;
      }
      if (index == 38 || index == 39) {
        return true;
      }
      if (index == 49 || index == 50) {
        return true;
      }
      if (index >= 60 && index <= 61) {
        return true;
      }
      if (index == 70 || index == 73) {
        return true;
      }
      if (index == 81 || index == 84) {
        return true;
      }
    }
    if (frameNum % 2 == 1) {
      if (index >= 13 && index <= 15) {
        return true;
      }
      if (index == 23) {
        return false;
      }
      if (index > 23 && index <= 31) {
        return true;
      }
      if (index >= 37 && index <= 39) {
        return true;
      }
      if (index == 48 || index == 49) {
        return true;
      }
      if (index >= 59 && index <= 60) {
        return true;
      }
      if (index == 69 || index == 72) {
        return true;
      }
      if (index == 81 || index == 84) {
        return true;
      }
    }

    return false;
  }

  // The area where the pet is displayed doing stuff
  // Or doing not doing stuff if dead
  Widget DisplayArea() {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2.4,
      child: GridView.builder(
        itemCount: 88,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 11,
        ),
        itemBuilder: ((context, index) {
          return GridTile(
            child: Container(
              decoration: BoxDecoration(color: DeterminePixels(index)),
              child: Visibility(
                visible: debug,
                child: Center(
                  child: Text(
                    index.toString(),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

// The screen where you can play Rock Paper Scissors with your pet!
// Uninspiring, I know, but again, finals and everything else going on means that I'm
// on a time crunch
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
                child: Progressbar(happiness),
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
              onPressed: () {
                if (rng.nextInt(3) == 1) {
                  adjustStat(toAdjust: 'happiness', amount: 15);
                }
              },
              icon: Icon(MyFlutterApp.hand_rock),
            ),
            IconButton(
              onPressed: () {
                if (rng.nextInt(3) == 1) {
                  adjustStat(toAdjust: 'happiness', amount: 15);
                }
              },
              icon: Icon(MyFlutterApp.hand_paper),
            ),
            IconButton(
              onPressed: () {
                if (rng.nextInt(3) == 1) {
                  adjustStat(toAdjust: 'happiness', amount: 15);
                }
              },
              icon: Icon(MyFlutterApp.hand_scissors),
            ),
          ],
        ),
      ],
    );
  }
}

// The credits page that can be found on the sleep tab
class CreditsPopup extends StatelessWidget {
  const CreditsPopup({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        children: [
          Center(
            child: Text("Fluttergotchi by Vincent Li for IGME 340"),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: Column(
              children: [
                Text("Documentation! (yay!)"),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    if (!await launchUrl(
                        Uri.parse(
                            "https://stackoverflow.com/questions/57534160/how-to-add-a-border-corner-radius-to-a-linearprogressindicator-in-flutter"),
                        mode: LaunchMode.externalApplication)) {}
                  },
                  child: Text(
                    textAlign: TextAlign.center,
                    "Border radius for a LinearProgressbarIndicator",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    if (!await launchUrl(Uri.parse("https://api.flutter.dev/"),
                        mode: LaunchMode.externalApplication)) {}
                  },
                  child: Text(
                    textAlign: TextAlign.center,
                    "Various Officially Supported Widgets",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    if (!await launchUrl(
                        Uri.parse(
                            "https://github.com/lucidchin/IGME-340-Shared"),
                        mode: LaunchMode.externalApplication)) {}
                  },
                  child: Text(
                    "IGME-340-Shared Repo",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    if (!await launchUrl(
                        Uri.parse(
                            "https://pub.dev/packages/shared_preferences"),
                        mode: LaunchMode.externalApplication)) {}
                  },
                  child: Text(
                    "Shared Preferences package",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    if (!await launchUrl(
                        Uri.parse("https://www.fluttericon.com/"),
                        mode: LaunchMode.externalApplication)) {}
                  },
                  child: Text(
                    "Custom Icons (RPS, Joystick, Cake)",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    if (!await launchUrl(Uri.parse("https://tamagotchi.com/"),
                        mode: LaunchMode.externalApplication)) {}
                  },
                  child: Text(
                    "Inspired by Tamagotchi",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    if (!await launchUrl(Uri.parse("https://github.com/vinrocksuper/flutter-anime-finder"),
                        mode: LaunchMode.externalApplication)) {}
                  },
                  child: Text(
                    "This credits page copied from flutter-anime-finder",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Divider(
                    color: Colors.black12,
                    thickness: 6,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(children: [
                      Text(
                          'So as you know, I originally was planning on building a chat app in conjunction with my IGME 430 class, but when I realized it was going to be unrealistic in scope, I had to cut back. I had always wanted to build a game about a virtual pet, and well the fact that the framework is called flutter makes it a good pun to build off of.'),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          'So I set out to build just that. A petcare sim, using realtime mechanics, much akin to a real pet, but digital.'),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          'Luckily for me, you actually covered just about everything that I needed to build the app- I was about to ask for instructions on how to implement a timer system and saving on detached/inactive states and you just so happened to go over both of those in a close timespan.'),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          'Then when you showed the Gridview with the Hunt the wumpus demo, I knew how I was going to make the visual portion. As for the quality of the display, well I think there is definitely room for improvement lol.'),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          "At that point, it was just a matter of putting everything together. Shared_prefs to save and load the important data like the last logged off time or the actual stats. BottomNavigationBar for pseduo-navigation."),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          "The most complicated portion of it all was figuring out how exactly I was going to decay the stats in the interim of non-playing and the next opening. I ended up doing something you suggested- saving the time since the app close and taking the difference between then and the new reopening."),
                      SizedBox(height: 10),
                      Text(
                          'Otherwise the entire project was pretty straightforward, albeit a lot of work. I am satisfied with how it turned out though.'),
                      SizedBox(height: 10),
                      Text(
                          'If I were to continue adding stuff to it, I would like to add more complex mini-games besides a fake rock paper scissors with no visual feedback.'),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          'Adding an actual age up mechanic like the original tamagotchis would also be really neat- depending on how you treated your pet it would grow up differently into different forms. Again, I deemed that to be a bit too ambitious for what I could reasonable accomplish with all my projects coalescing, so I stuck with this one form.'),
                    ]),
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
