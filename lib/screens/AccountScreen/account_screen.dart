import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_ui_only/globals/myFonts.dart';
import 'package:insta_ui_only/globals/mySpaces.dart';
import 'package:insta_ui_only/globals/sizeConfig.dart';
import 'package:insta_ui_only/screens/AddPostScreen/add_post.dart';
import 'package:insta_ui_only/screens/IntroScreen/login_screen.dart';
import 'package:insta_ui_only/screens/MainPageScreen_Feeds/homeBar_screen.dart';
import 'package:insta_ui_only/widgets/BottomNavBar/bottomNavBar_main.dart';
import 'package:insta_ui_only/widgets/PostWidget/profilePhoto_widget.dart';
import 'package:insta_ui_only/widgets/StoriesWidget/grey_ring_widget.dart';
import 'package:insta_ui_only/widgets/StoriesWidget/stories_widget.dart';

import 'package:insta_ui_only/widgets/MiscWidgets/followButton_widget.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'editProfile_screen.dart';

class AccountPage extends StatelessWidget {
  static const route = '/account_screen';

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = ModalRoute.of(context).settings.arguments as String;
    return StreamBuilder2(
      streams: Tuple2(
        _db
            .collection('posts')
            .where('addedBy', isEqualTo: _db.doc('/users/$currentUser'))
            .snapshots(),
        _db.collection('users').doc(currentUser).snapshots(),
      ),
      builder: (context, snapshots) {
        if (snapshots.item1.connectionState == ConnectionState.waiting &&
            snapshots.item2.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.pink),
          );
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor:
                MediaQuery.of(context).platformBrightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
            actionsIconTheme: IconThemeData(
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
            ),
            centerTitle: true,
            elevation: 1.0,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).popAndPushNamed(InstaHome.route);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.18),
                Icon(
                  Icons.lock_rounded,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
                MySpaces.hSmallGapInBetween,
                Container(
                  child: Text(
                    // data.displayname,
                    // FirebaseAuth.instance.currentUser.displayName,
                    snapshots.item2.data['user_name'],
                    style: TextStyle(
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.black
                          : Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                MySpaces.hSmallGapInBetween,
                Icon(
                  Icons.keyboard_arrow_down,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            (currentUser == _auth.currentUser.uid)
                                ? ProfilePhoto(
                                    imageUrl: snapshots
                                            .item2.data['imageUrl'] ??
                                        "https://raw.githubusercontent.com/jash-desai/insta-clone/main/assets/images/user-default-grey.png",
                                  )
                                : CircleAvatar(
                                    radius: SizeConfig.horizontalBlockSize * 12,
                                    backgroundImage: NetworkImage(
                                      snapshots.item2.data['imageUrl'],
                                    ),
                                  ),
                            MySpaces.hGapInBetween,
                            Expanded(
                              child: DefaultTextStyle(
                                style: MyFonts.medium.size(18).setColor(
                                      MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                            "${snapshots.item1.data.docs.length}" ??
                                                ''),
                                        Text("Posts"),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                            "${snapshots.item2.data['followers'].length}"),
                                        Text("Followers"),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                            "${snapshots.item2.data['following'].length}"),
                                        Text("Following"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        MySpaces.vGapInBetween,
                        Text(
                          // data.displayname,
                          // FirebaseAuth.instance.currentUser.displayName,
                          snapshots.item2.data['user_name'] ?? 'Nil',
                          style: MyFonts.light.size(15),
                        ),
                        Text(
                          // 'I had all and then most of you, some and now none of you!',
                          snapshots.item2.data['bio'],
                          style: MyFonts.light.size(15),
                        ),
                        MySpaces.vGapInBetween,
                        (currentUser == _auth.currentUser.uid)
                            ? Column(
                                children: [
                                  // edit profile button
                                  Container(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed(EditProfile.route);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                          MySpaces.hGapInBetween,
                                          Text(
                                            "Edit Profile",
                                            style: MyFonts.light
                                                .setColor(MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black)
                                                .size(17),
                                          ),
                                        ],
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.grey.shade900,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.dark
                                                ? Colors.white.withOpacity(0.5)
                                                : Colors.black.withOpacity(0.5),
                                            width: 0.5,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // space in between
                                  MySpaces.vSmallestGapInBetween,
                                  // log out button
                                  Container(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () {
                                        _auth.signOut();
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                          LogIn.route,
                                          (route) => false,
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.logout_outlined,
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                          MySpaces.hGapInBetween,
                                          Text(
                                            "Log Out",
                                            style: MyFonts.light
                                                .setColor(MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black)
                                                .size(17),
                                          ),
                                        ],
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.grey.shade900,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.dark
                                                ? Colors.white.withOpacity(0.5)
                                                : Colors.black.withOpacity(0.5),
                                            width: 0.5,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : (snapshots.item2.data['followers'] as List)
                                    .contains(_auth.currentUser.uid)
                                ? FollowButton("Following", currentUser,
                                    snapshots.item2.data['followers'] as List)
                                : FollowButton("Follow", currentUser,
                                    snapshots.item2.data['followers'] as List),
                        MySpaces.vGapInBetween,
                        Container(
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                height: 90,
                                width: 1000,
                                child: new ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 1,
                                  itemBuilder: (context, index) => Stack(
                                    alignment: Alignment.topLeft,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          StoryWidget(
                                            storyImage: AssetImage(
                                                "assets/images/user-default-grey.png"),
                                            storyName: 'Foods',
                                            onTapFunction: null,
                                          ),
                                          StoryWidget(
                                            storyImage: AssetImage(
                                                "assets/images/user-default-grey.png"),
                                            storyName: 'Homies',
                                            onTapFunction: null,
                                          ),
                                          StoryWidget(
                                            storyImage: AssetImage(
                                                "assets/images/user-default-grey.png"),
                                            storyName: 'Travels',
                                            onTapFunction: null,
                                          ),
                                          StoryWidget(
                                            storyImage: AssetImage(
                                                "assets/images/user-default-grey.png"),
                                            storyName: 'Parties',
                                            onTapFunction: null,
                                          ),
                                          StoryWidget(
                                            storyImage: AssetImage(
                                                "assets/images/user-default-grey.png"),
                                            storyName: 'Clubs',
                                            onTapFunction: null,
                                          ),
                                          StoryWidget(
                                            storyImage: AssetImage(
                                                "assets/images/user-default-grey.png"),
                                            storyName: 'Sports',
                                            onTapFunction: null,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ((snapshots.item2.data['followers'] as List)
                              .contains(_auth.currentUser.uid) ||
                          currentUser == _auth.currentUser.uid)
                      ? (snapshots.item1.data.docs.length == 0)
                          ? SingleChildScrollView(
                              child: Container(
                                height: 300,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: GreyRing(
                                        padding: 15,
                                        width: 1,
                                        child: Center(
                                          child: IconButton(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AddPost(
                                                    ImageSource.gallery),
                                              ),
                                            ),
                                            icon: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Image.asset(
                                                    "assets/icons/camera_light.png")
                                                : Image.asset(
                                                    "assets/icons/camera_dark.png"),
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.black
                                                : Colors.white,
                                            iconSize: 55,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 18),
                                      child: Text(
                                        "Share Photos",
                                        style: MyFonts.light.size(25),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 18),
                                      child: Text(
                                        "When you share photos, they will appear on your profile.",
                                        style: MyFonts.light.size(13),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Share your first photo.',
                                            style: TextStyle(
                                              color: Colors.blue[500],
                                              fontSize: 16,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddPost(ImageSource
                                                              .gallery),
                                                    ),
                                                  ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5,
                              ),
                              itemCount: snapshots.item1.data.docs.length,
                              itemBuilder: (ctx, index) {
                                final data = snapshots.item1.data.docs[index]
                                    .data() as Map<String, dynamic>;
                                return Image.network(
                                  data['imageUrl'],
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                      : Center(
                          child: Container(
                            height: 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: GreyRing(
                                    padding: 5,
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.lock,
                                        size:
                                            SizeConfig.horizontalBlockSize * 8,
                                      ),
                                      color: Colors.white,
                                      iconSize: 50,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: Text(
                                    "This account is Private",
                                    style: MyFonts.light.size(15),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: Text(
                                    "Follow to see their photos and videos.",
                                    overflow: TextOverflow.ellipsis,
                                    style: MyFonts.light.size(15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavBarMain(),
        );
      },
    );
  }
}
