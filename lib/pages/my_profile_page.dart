import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/model/user_model.dart';
import 'package:flutter_instaclone/services/auth_service.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/file_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';
import 'package:image_picker/image_picker.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool isLoading = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();


  String fullname = "", email = "", img_url = "";
  int grid_view = 1;
  int count_posts = 0;
  int count_followers = 0;
  int count_following = 0;
  List<Post> items = [];


  _imgFromGallery() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {
      _image = File(image!.path);
    });
    _apiChangePhoto();
  }

  _imgFromCamera() async {
    final XFile? photo =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    setState(() {
      _image = File(photo!.path);
    });
    _apiChangePhoto();
  }

  void _apiChangePhoto() {
    if (_image == null) return;
    setState(() {
      isLoading = true;
    });
    FileService.uploadUserImage(_image!).then((downloadUrl) => {
          _apiUpdateUser(downloadUrl!),
        });
  }

  void _apiUpdateUser(String downloadUrl) async {
    USer user = await DataService.loadUser();
    user.img_url = downloadUrl;
    await DataService.updateUser(user);
    _apiLoadUser();
  }

  Future<dynamic> _showPicker() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text("Photo Library"),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text("Photo Camera"),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _apiLoadUser() {
    setState(() {
      isLoading = true;
    });
    DataService.loadUser().then((value) => {
          _showUserInfo(value),
        });
  }

  void _showUserInfo(USer user) {
    setState(() {
      isLoading = false;
      this.fullname = user.fullname;
      this.email = user.email;
      this.img_url = user.img_url;
      this.count_followers = user.followers_count;
      this.count_following = user.following_count;
    });
  }

  void _apiLoadPosts() {
    DataService.loadPosts().then((value) => {
      _resLoadPosts(value),
    });
  }

  void _resLoadPosts(List<Post> posts){
    setState(() {
      items = posts;
      count_posts = items.length;
    });
  }

  _actionLogOut() async {

   var result = await Utils.dialogCommmon(context, "Instagram Clone", "Do you want to logout?", false);
   if(result != null && result) {
     AuthService.signOutUser(context);
   }
  }

  
  _actionRemovePost(Post post) async {
    var result = await Utils.dialogCommmon(
        context, "Instagram Clone", "Do you want to remove this post?", false);
    if (result != null && result) {
      setState(() {
        isLoading = true;
      });
      DataService.removePost(post).then((value) => {
        _apiLoadPosts(),
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadUser();
    _apiLoadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontFamily: "Billabong"),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _actionLogOut();

              },
              icon: Icon(Icons.exit_to_app, color: Color.fromRGBO(193, 53, 132, 1)))
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                //#myphoto
                GestureDetector(
                  onTap: () {
                    _showPicker();
                  },
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(70),
                          border: Border.all(
                              width: 1.5,
                              color: Color.fromRGBO(193, 53, 132, 1)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: img_url == null || img_url.isEmpty
                              ? Image(
                                  image: AssetImage(
                                      "assets/images/insta_icon.png"),
                                  width: 70,
                                  height: 70,
                                )
                              : Image.network(
                                  img_url,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(Icons.add_circle, color: Colors.purple)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //#myinfos
                SizedBox(height: 10),
                Text(fullname.toUpperCase(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 3),
                Text(email,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.normal)),
                //#myCounts
                Container(
                  height: 80,
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(count_posts.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 3),
                              Text("Posts",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 20,
                          color: Colors.grey.withOpacity(0.5)),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(count_followers.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 3),
                              Text("FOLLOWERS",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 20,
                          color: Colors.grey.withOpacity(0.5)),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(count_following.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 3),
                              Text("FOLLOWING",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //# list or window
                Container(
                  height: 45,
                  child: Row(
                    children: [
                      Expanded(
                          child: Center(
                              child: GestureDetector(
                        child: Icon(Icons.list_alt),
                        onTap: () {
                          setState(() {
                            grid_view = 1;
                          });
                        },
                      ))),
                      Expanded(
                          child: Center(
                              child: GestureDetector(
                        child: Icon(Icons.grid_view),
                        onTap: () {
                          setState(() {
                            grid_view = 2;
                          });
                        },
                      ))),
                    ],
                  ),
                  color: Colors.white,
                ),
                //#post images
                Expanded(
                  child: GridView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _itemOfPost(items[index]);
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: grid_view),
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                    backgroundColor: Colors.white,
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _itemOfPost(Post post) {
    return GestureDetector(
      onLongPress: (){
        _actionRemovePost(post);
      },
      child: Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                width: double.infinity,
                imageUrl: post.img_post ,
                placeholder: (context, url) => CircularProgressIndicator(
                    color: Colors.red, backgroundColor: Colors.white),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 3),
            Text(post.caption,
                style: TextStyle(color: Colors.black87.withOpacity(0.7)),
                maxLines: 2)
          ],
        ),
      ),
    );
  }
}
