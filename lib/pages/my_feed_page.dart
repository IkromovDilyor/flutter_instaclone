import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/pages/other_profile_page.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';

class MyFeedPage extends StatefulWidget {

  PageController pageController;
  MyFeedPage({required this.pageController});

  @override
  _MyFeedPageState createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {
  bool isLoading = false;
  List<Post> items = [];

  void _apiLoadFeeds() {
    setState(() {
      isLoading = true;
    });
    DataService.loadFeeds().then((value) => {
      _resLoadFeeds(value),
    });
  }

  void _resLoadFeeds(List<Post> posts) {
    setState(() {
      items = posts;
      isLoading = false;
    });
  }

  void _apiPostLike(Post post) async {
    setState(() {
      isLoading = true;

    });
    await DataService.likePost(post, true);
    setState(() {
      isLoading = false;
      post.liked = true;
    });
  }

  void _apiPostUnlike(Post post) async {
    setState(() {
      isLoading = true;
    });
    await DataService.likePost(post, false);
    setState(() {
      isLoading = false;
      post.liked = false;
    });
  }

  _actionRemovePost(Post post) async {
    var result = await Utils.dialogCommmon(
        context, "Instagram Clone", "Do you want to remove this post?", false);
    if (result != null && result) {
      setState(() {
        isLoading = true;
      });
      DataService.removePost(post).then((value) => {
        _apiLoadFeeds(),
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadFeeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Instagram", style: TextStyle(color: Colors.black, fontFamily: "Billabong", fontSize: 30),),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt, color: Color.fromRGBO(193, 53, 132, 1)),
            onPressed: (){
              widget.pageController.animateToPage(2, duration: Duration(milliseconds: 100), curve: Curves.linear);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index){
          return _itemOfPost(items[index]);
        },
      ),
    );
  }

  Widget _itemOfPost(Post post) {
    return Container(
      child: Column(
        children: [
          Divider(),



          //#user info
          GestureDetector(
            onTap: (){
              if (post.mine != true){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => OtherProfilePage(uid: post.id)));

              }
              else return;

            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: (post.img_user == null || post.img_user.isEmpty)? Image(
                          image: AssetImage("assets/images/insta_icon.png"),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ):Image.network(
                          post.img_user,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.fullname, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                          Text(post.date, style: TextStyle(fontWeight: FontWeight.normal),),
                        ],
                      ),
                    ],
                  ),
                  post.mine ?
                  IconButton(
                    icon: Icon(Icons.more_horiz),
                    onPressed: (){
                      _actionRemovePost(post);
                    },
                  ) : SizedBox.shrink(),
                ],
              ),
            ),
          ),

          //#image
          //  Image.network(post.postImage),

          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            imageUrl: post.img_post,
            placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Colors.red, backgroundColor: Colors.white,)),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
          ),

          //#like share
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: (){
                        if(!post.liked) {
                          _apiPostLike(post);
                        } else {
                          _apiPostUnlike(post);
                        }
                      },
                      icon: post.liked ?  Icon(FontAwesomeIcons.solidHeart, color: Colors.red) : Icon(FontAwesomeIcons.heart)
                  ),
                  IconButton(onPressed: (){
                    Share.share("Image: ${post.img_post} \n Caption: ${post.caption}");
                  }, icon: Icon(FontAwesomeIcons.solidPaperPlane))
                ],
              ),
            ],
          ),

          //#caption
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                  children: [ TextSpan(
                      text: "${post.caption}",
                      style: TextStyle(color: Colors.black)
                  )
                  ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}
