import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Productdata{
  late String id="",name="",image="";
  late List<String> images=[];
  late int mrp=0,cost=0,qty=1,initcost=cost,initmrp=mrp;
  late List<Map<dynamic,dynamic>> overview=[];
}
class Allproducts{

  late List<Productdata> products=[];
  late int cost=0,mrp=0;
  eval() {
    cost = 0;
    mrp = 0;
    for (var i in products) {
      cost += i.cost;
      mrp += i.mrp;
    }
  }
}