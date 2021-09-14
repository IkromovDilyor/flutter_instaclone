import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/model/user_model.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';


class DataService {
  static final _firestore = FirebaseFirestore.instance;

  static String folder_users = "users"; //firebase da ocilegon papkani nomi
  static String folder_posts = "posts"; // firebasedegi buyam papkani  nomi faqat postlarga tegiwli malumotla turadi
  static String folder_feeds = "feeds"; // firebasedegi papkani nomi man follow qigan va uzimi postlarim turegon data fayl
  static String folder_following = "following";
  static String folder_followers = "followers";
// User Related

  static Future storeUser(USer user) async {
    user.uid = (await Prefs.loadUserId())!;
    Map<String, String> params = await Utils.deviceParams();
    print(params.toString());

    user.device_id  = params["device_id"]!;
    user.device_type = params["device_type"]!;
    user.device_token = params["device_token"]!;

    return _firestore.collection(folder_users).doc(user.uid).set(user.toJson());
  }

  static Future<USer> loadUser({required String id}) async {
    String? uid = await Prefs.loadUserId();
    var  value = await _firestore.collection("users").doc(uid).get();
    USer user = USer.fromJson(value.data()!);

    var querySnapshot1 = await _firestore.collection(folder_users).doc(uid).collection(folder_followers).get();
    user.followers_count = querySnapshot1.docs.length;

    var querySnapshot2 = await _firestore.collection(folder_users).doc(uid).collection(folder_following).get();
    user.following_count = querySnapshot2.docs.length;

    return user;
  }

  static Future updateUser(USer user) async {
    String? uid = await Prefs.loadUserId();
    return _firestore.collection(folder_users).doc(uid).update(user.toJson());
  }

  static Future<List<USer>> searchUsers(String keyword) async {
    List<USer> users = [];
    String? uid = await Prefs.loadUserId();

    var querySnapshot = await _firestore.collection(folder_users).orderBy(
        "email").startAt([keyword]).get();
    querySnapshot.docs.forEach((result) {
      USer newUser = USer.fromJson(result.data());
      if (newUser.uid !=
          uid) { // search page da uzimi profilim korinmasli ucun shart kirittim
        users.add(newUser);
      }

      // if(newUser.uid != uid) {
      //   users.add(newUser);
      // }
    });

    List<USer> following = [];
    var querySnapshot2 = await _firestore.collection(folder_users).doc(uid).collection(folder_following).get();
    querySnapshot2.docs.forEach((result) {
      following.add(USer.fromJson(result.data()));
    });

    for(USer user in users){
      if(following.contains(user)){
        user.followed = true;
      }else{
        user.followed = false;
      }
    }
    return users;
  }


  // Post Related
  static Future<Post> storePost(Post post) async {
    USer me = await loadUser(id: '');
    post.uid = me.uid;
    post.fullname = me.fullname;
    post.img_user = me.img_url;
    post.date = Utils.currentDate();


    String postId = _firestore
        .collection(folder_users)
        .doc(me.uid)
        .collection(folder_posts)
        .doc()
        .id;
    post.id = postId;

    await _firestore.collection(folder_users).doc(me.uid).collection(
        folder_posts).doc(postId).set(post.toJson());
    return post;
  }

  static Future<Post> storeFeed(Post post) async {
    String? uid = await Prefs.loadUserId();

    await _firestore.collection(folder_users).doc(uid)
        .collection(folder_feeds)
        .doc(post.id)
        .set(post.toJson());
    return post;
  }

  static Future<List<Post>> loadFeeds() async {
    List<Post> posts =  [];
    String? uid = await Prefs.loadUserId();
    var querySnapshot = await _firestore.collection(folder_users).doc(uid).collection(folder_feeds).get();
    querySnapshot.docs.forEach((result) {
      Post post = Post.fromJson(result.data());
      if(post.uid == uid) post.mine = true;
      posts.add(post);
    });
    return posts;
  }

  static Future<List<Post>> loadPosts({required String id}) async {
    List<Post> posts = [];
    String? uid = await Prefs.loadUserId();

    var querySnapshot = await _firestore.collection(folder_users).doc(uid).collection(folder_posts).get();

    querySnapshot.docs.forEach((result) {

      posts.add(Post.fromJson(result.data()));
    });
    return posts;
  }

  static Future<Post> likePost(Post post, bool liked) async {
    String? uid = await Prefs.loadUserId();
    post.liked = liked;

    await _firestore.collection(folder_users).doc(uid).collection(folder_feeds).doc(post.id).set(post.toJson());

    if(uid == post.uid) {
      await _firestore.collection(folder_users).doc(uid).collection(folder_posts).doc(post.id).set(post.toJson());
    }
    return post;
  }

  static Future<List<Post>> loadLikes() async {
    String? uid = await Prefs.loadUserId();
    List<Post> posts = [];
    var querySnapshot = await _firestore.collection(folder_users).doc(uid).collection(folder_feeds).where("liked", isEqualTo: true).get();

    querySnapshot.docs.forEach((result) {
      Post post = Post.fromJson(result.data());
      if(uid == post.uid) post.mine = true;
      posts.add(post);
    });
    return posts;
   }


   // Follower and Following Related

static Future<USer> followUser(USer someone) async {
    USer me = await loadUser(id: '');

    // I followed to someone
  await _firestore.collection(folder_users).doc(me.uid).collection(folder_following).doc(someone.uid).set(someone.toJson());

  // I am in someone's followers
  await _firestore.collection(folder_users).doc(someone.uid).collection(folder_followers).doc(me.uid).set(me.toJson());

  return someone;
}


  static Future<USer> unfollowUser(USer someone) async {
    USer me = await loadUser(id: '');

    // I un followed to someone
    await _firestore.collection(folder_users).doc(me.uid).collection(folder_following).doc(someone.uid).delete();

    // I am not in someone's followers
    await _firestore.collection(folder_users).doc(someone.uid).collection(folder_followers).doc(me.uid).delete();

    return someone;
  }

  static Future storePostsToMyFeed(USer someone) async {
    // Store someone's posts to my feed

    List<Post> posts = [];
    var querySnapshot = await _firestore.collection(folder_users).doc(someone.uid).collection(folder_posts).get();
    querySnapshot.docs.forEach((result) {
      var post = Post.fromJson(result.data());
      post.liked = false;
      posts.add(post);
    });

    for(Post post in posts) {
      storeFeed(post);
    }
  }

  static Future removePostsFromMyFeed(USer someone) async {
    // Remove someone's posts to my feed

    List<Post> posts = [];
    var querySnapshot = await _firestore.collection(folder_users).doc(someone.uid).collection(folder_posts).get();
    querySnapshot.docs.forEach((result) {
      posts.add(Post.fromJson(result.data()));
    });

    for(Post post in posts) {
      removeFeed(post);
    }
  }

  static Future removeFeed(Post post) async {
    String? uid = await Prefs.loadUserId();
    return await _firestore.collection(folder_users).doc(uid).collection(folder_feeds).doc(post.id).delete();
  }

  static Future removePost(Post post) async {
    String? uid = await Prefs.loadUserId();
    await removeFeed(post);
    return await _firestore.collection(folder_users).doc(uid).collection(folder_posts).doc(post.id).delete();
  }

}
