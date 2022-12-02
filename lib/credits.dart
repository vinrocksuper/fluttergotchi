
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

// The credits page that can be found on the sleep tab
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
                    if (!await launchUrl(Uri.parse("https://fonts.google.com/specimen/Pangolin?category=Handwriting"),
                        mode: LaunchMode.externalApplication)) {}
                  },
                  child: Text(
                    "Pangolin Font",
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
