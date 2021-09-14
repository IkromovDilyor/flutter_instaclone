import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/file_service.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MyUploadPage extends StatefulWidget {
  PageController pageController;
  MyUploadPage({required this.pageController});

  @override
  _MyUploadPageState createState() => _MyUploadPageState();
}

class _MyUploadPageState extends State<MyUploadPage> {
  bool isLoading = false;
  var captionController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  _imgFromGallery() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {
      _image = File(image!.path);
    });
  }

  _imgFromCamera() async {
    final XFile? photo =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    setState(() {
      _image = File(photo!.path);
    });
  }

  _vidFromGallery() async {
    final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery, maxDuration: Duration(seconds: 60));
    setState(() {
      _image = File(video!.path);
    });
  }

  _vidFromCamera() async {
    final XFile? vidcam = await _picker.pickVideo(
        source: ImageSource.camera, maxDuration: Duration(seconds: 60));
    setState(() {
      _image = File(vidcam!.path);
    });
  }

  _upLoadNewPost() {
    String caption = captionController.text.toString().trim();
    if (caption.isEmpty) return;
    if (_image == null) return;
    //send post to server successfully
    _apiPostImage();

  }

  void _apiPostImage(){
    setState(() {
      isLoading = true;
    });
    FileService.uploadPostImage(_image!).then((downloadUrl) => {
      _resPostImage(downloadUrl!),
    });
  }

  void _resPostImage(String downloadUrl){
    String caption = captionController.text.toString().trim();
    Post post = new Post(caption: caption, img_post: downloadUrl);
    _apiStorePost(post);
  }

  void _apiStorePost(Post post) async {
    // Post to post
    Post posted = await DataService.storePost(post);
    // Post to feeds
    DataService.storeFeed(posted).then((value) => {
      _moveToFeed(),
    });
  }

  void _moveToFeed(){
    setState(() {
      isLoading = false;
    });
    captionController.text = "";
    _image = null;
    widget.pageController.animateToPage(0, duration: Duration(milliseconds: 100), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Upload",
            style: TextStyle(
                color: Colors.black, fontFamily: "Billabong", fontSize: 25),
          ),
          actions: [
            IconButton(
              onPressed: () {
                _upLoadNewPost();
              },
              icon: Icon(
                Icons.drive_folder_upload,
                color: Color.fromRGBO(245, 96, 64, 1),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showPicker,
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width,
                        color: Colors.grey.withOpacity(.4),
                        child: _image == null
                            ? Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              )
                            : Stack(
                                children: [
                                  Image.file(
                                    _image!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    color: Colors.black12,
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.highlight_remove),
                                          color: Colors.white,
                                          onPressed: () {
                                            setState(() {
                                              _image = null;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: TextField(
                        controller: captionController,
                        style: TextStyle(color: Colors.black),
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        // Normal textInputFile will be displayed
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Captions',
                          hintStyle: TextStyle(fontSize: 17, color: Colors.black38),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isLoading ? Center(child: CircularProgressIndicator(color: Colors.red, backgroundColor: Colors.white,),) :
            SizedBox.shrink(),
          ],
        ));
  }

  Future<dynamic> _showPicker() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: [
                  new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text("Photo Library"),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text("Photo Camera"),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.video_library),
                    title: new Text("Video Library"),
                    onTap: () {
                      _vidFromGallery();
                      Navigator.of(context).pop();
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.videocam),
                    title: new Text("Video Camera"),
                    onTap: () {
                      _vidFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
