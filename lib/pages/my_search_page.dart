import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/user_model.dart';
import 'package:flutter_instaclone/services/data_service.dart';

class MySearchPage extends StatefulWidget {
  @override
  _MySearchPageState createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {
  bool isLoading = false;
  var searchEditingController = TextEditingController();
  List<USer> items = [];

  void _apiSearchUsers(String keyword) {
    setState(() {
      isLoading = true;
    });
    DataService.searchUsers(keyword).then((users) => {
      _respSearchUsers(users),
    });
  }

  void _respSearchUsers(List<USer> users) {
if(mounted) {
  setState(() {
    items = users;
    isLoading = false;
  });
}
  }

void _apiFollowUser(USer someone) async {
    setState(() {
      isLoading = true;
    });
    await DataService.followUser(someone);
    setState(() {
      someone.followed = true;
      isLoading = false;
    });
    await DataService.storePostsToMyFeed(someone);
}

void _apiUnfollowUser(USer someone) async {
    setState(() {
      isLoading = true;
    });
    await DataService.unfollowUser(someone);
    setState(() {
      someone.followed = false;
      isLoading = false;
    });
    DataService.removePostsFromMyFeed(someone);
}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiSearchUsers("");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Search",
            style: TextStyle(
                color: Colors.black, fontFamily: "Billabong", fontSize: 25),
          ),
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  //#search user
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.2),
                        borderRadius: BorderRadius.circular(7)),
                    height: 45,
                    child: TextField(
                      style: TextStyle(color: Colors.black87),
                      controller: searchEditingController,
                      onChanged: (input) {
                        print(input);
                        _apiSearchUsers(input);
                      },
                      decoration: InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _itemOfUser(items[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            isLoading ? Center(child: CircularProgressIndicator(color: Colors.red, backgroundColor: Colors.white,),) :
            SizedBox.shrink(),
          ],
        ));
  }

  Widget _itemOfUser(USer user) {
    return Container(
      height: 90,
      child: Row(
        children: [
          //#profile image
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(70),
                border: Border.all(
                    width: 1.5, color: Color.fromRGBO(193, 53, 132, 1))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.5),
              child: user.img_url.isEmpty ?  Image(
                image: AssetImage("assets/images/insta_icon.png"),
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ) : Image.network(
                user.img_url,
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 15),

          //#fullname email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user.fullname,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 3),
              Text(
                user.email,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: (){
                    if(user.followed) {
                      _apiUnfollowUser(user);
                    }else {
                      _apiFollowUser(user);
                    }
                  },
                  child: Container(
                    width: 90,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(width: 1, color: Colors.grey)
                    ),
                    child: Center(
                      child: user.followed ? Text("Following") : Text("Follow"),
                    ),
                  ),

                )

              ],
            ),
          ),
        ],
      ),
    );
  }
}
