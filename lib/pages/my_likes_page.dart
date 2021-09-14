import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyLikesPage extends StatefulWidget {


  @override
  _MyLikesPageState createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage> {
  bool isLoading = false;
  List<Post> items = [];

  void _apiLoadLikes() {
    setState(() {
      isLoading = true;
    });
    DataService.loadLikes().then((value) => {
      _resLoadLikes(value),
    });
  }

  void _resLoadLikes(List<Post> posts) {
    if(mounted){
      setState(() {
        items = posts;
        isLoading = false;
      });
    }
  }

  void _apiPostUnlike(Post post) {
    setState(() {
      isLoading = true;
      post.liked = false;
    });
    DataService.likePost(post, false).then((value) => {
      _apiLoadLikes(),
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
        _apiLoadLikes(),
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadLikes();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Likes", style: TextStyle(color: Colors.black, fontFamily: "Billabong", fontSize: 30),),

      ),
      body: Stack(
        children: [
          items.length > 0 ?
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index){
              return _itemOfPost(items[index]);
            },
          )
          : Center(child: Text("No liked posts")),
          isLoading ? Center(child: CircularProgressIndicator(color: Colors.red, backgroundColor: Colors.white,),) :
          SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _itemOfPost(Post post) {
    return Container(
      child: Column(
        children: [
          Divider(),

          //#user info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image(
                        image: AssetImage("assets/images/insta_icon.png"),
                        width: 40,
                        height: 40,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.fullname, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                        Text(post.date.toString(), style: TextStyle(fontWeight: FontWeight.normal),),
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
                ) : SizedBox.shrink()
              ],
            ),
          ),

          //#image
          //  Image.network(post.postImage),

          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            imageUrl: post.img_post,
            placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Colors.red, backgroundColor: Colors.white)),
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
                        if(post.liked) {
                          _apiPostUnlike(post);
                        }
                      },
                      icon: post.liked ?  Icon(FontAwesomeIcons.solidHeart, color: Colors.red) : Icon(FontAwesomeIcons.heart)
                  ),
                  IconButton(onPressed: (){}, icon: Icon(FontAwesomeIcons.solidPaperPlane))
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

