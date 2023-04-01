

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Catagories{
  late String name,image;
}
class Popularimages{
  late String id;
  late String image;
}
class Product{
  late String id="",name="",image="";
  late List<String> images=[];
  late int mrp=0,cost=0;
  late List<Map<dynamic,dynamic>> overview=[];
  late List<String> videos=[];
  late List<YoutubePlayerController> youcon=[];
  loadvideos(){
    for(var i in videos){
      YoutubePlayerController controller = YoutubePlayerController(
        initialVideoId: i,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          loop:true,
          disableDragSeek: true,
          mute: false,
        ),
      );
      youcon.add(controller);
    }
  }
  resetvideos(){
    for(var i in youcon){
      i.reset();
    }
  }
}
class Catagorieproduct{
  late String name,id;
  late List<Product> products=[];
}
