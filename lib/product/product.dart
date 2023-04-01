import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nestview/homepage/data/data.dart';
import 'package:nestview/keeporder/order.dart';
import 'package:nestview/payment/payment.dart';
import 'package:youtube_parser/youtube_parser.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Productpage extends StatefulWidget {

  const Productpage({Key? key,required this.id}) : super(key: key);
  final String id;
  @override
  State<Productpage> createState() => _ProductpageState(id);
}

class _ProductpageState extends State<Productpage> {
  late String id="";
  Product data=Product();
  _ProductpageState(idd){
    id=idd;
    _loaddata(idd);
  }
  _loaddata(idd) async {
    print(idd);
    data= await getproductdata(idd);
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    PageController pgc=PageController();

    return Scaffold(
      appBar: AppBar(title: const Text("Nest View"),
      ),
      body:ListView(
        padding: const EdgeInsets.all(0),
        children: <Widget>[
          SizedBox(
              height: 250,
              child: PageView(scrollDirection: Axis.horizontal,controller:pgc , children: getimages(data.images, context)+getvideos(data.youcon,context),onPageChanged:(index){
                data.resetvideos();
              },)),
          Padding(padding: const EdgeInsets.all(5),child: Text(data.name,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
          Row(children: [Container(padding: const EdgeInsets.fromLTRB(10, 10, 10, 3),child: Text('\u{20B9} ${data.cost}',style: const TextStyle(fontSize: 25,color: Colors.red,fontWeight: FontWeight.w700),)),Container(padding: const EdgeInsets.fromLTRB(10, 10, 10, 3),child: Text('MRP \u{20B9} ${data.mrp}',style: const TextStyle(fontSize: 20,color: Colors.black26,fontWeight: FontWeight.w300,decoration: TextDecoration.lineThrough),))],),
          Container(padding: const EdgeInsets.fromLTRB(10, 3, 0, 3),child: Text('Save \u{20B9} ${data.mrp-data.cost}',style: const TextStyle(fontSize: 23,color: Colors.red,fontWeight: FontWeight.w200),),),
          Container(padding: const EdgeInsets.fromLTRB(30, 2, 30, 10),child: OutlinedButton(
            onPressed: (){
              Navigator.of(context).push(_createRoutetobuy(id));
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blue)
            ),
            child: const Text("Order now",style: TextStyle(color: Colors.white),),
          ),),
          Container(padding: const EdgeInsets.fromLTRB(30, 2, 30, 10),child: OutlinedButton(
            onPressed: (){
              Navigator.of(context).push(_createRoute());
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
            ),
            child: const Text("Add to cart"),
          ),),const Divider(color: Colors.black26,),
          Container(padding: const EdgeInsets.all(5),width: double.maxFinite,child: const Text("Overview",textAlign: TextAlign.center,style: TextStyle(fontSize: 25),),)


        ]+getoverviewitems(data.overview, context),
      ),
    );
    
  }
  
  

  getimages(List<String> data1, BuildContext context) {
    late List<GestureDetector> data = [];
    for (var i in data1) {

      var d = GestureDetector(onTap:(){
        
      } ,child:Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                height: 250,
                padding: const EdgeInsets.all(0),
                child: Image.network(
                  i,fit: BoxFit.fill,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),))
        ],
      ));
      data.add(d);
    }
    return data;
  }
  getvideos(List<YoutubePlayerController> data1, BuildContext context) {
    late List<GestureDetector> data = [];
    for (var i in data1) {
      var d = GestureDetector(onTap:(){
      } ,child:Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                height: 250,
                padding: const EdgeInsets.all(0),
                child: YoutubePlayer(
                  controller: i,
                  showVideoProgressIndicator: true,
                  onReady: (){

                  },
                ),))
        ],
      ));
      data.add(d);
    }
    return data;
  }

  getoverviewitems(List<Map<dynamic,dynamic>> data1, BuildContext context) {
    late List<GestureDetector> data = [];
    for (var i in data1) {
      var d = GestureDetector(onTap:(){
      } ,child:Column(
        children: [
        Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Text(i["title"],style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
        ),
      ),
          Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                height: 250,
                padding: const EdgeInsets.all(0),
                child: Image.network(
                  i["image"],fit: BoxFit.fill,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),)),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Text(i["description"],style: const TextStyle(fontSize: 20),),
            ),
          ),
          const Divider(thickness: 3,color: Colors.black12)
        ],
      ));
      data.add(d);
    }
    return data;
  }

  Future<Product> getproductdata(String id) async {
    var snp=FirebaseDatabase.instance.ref().child("products").child(id);
    Product p=Product();
    bool done=false;
    var a=await snp.get();
    Map<dynamic,dynamic> data=await a.value as Map<dynamic,dynamic>;
    p.id=data["id"];
    p.image=data["images"][0];
    p.name=data["name"];
    for(var i in data["overview"]){
      p.overview.add(i);
    }
    int b=0;
    for(var i in data["images"]){
      p.images.add(data["images"][b]);
      b+=1;
    }
    int c=0;
    for(var i in data["videos"]){
      p.videos.add(getIdFromUrl(data["videos"][c]).toString());
      print(getIdFromUrl(data["videos"][c]).toString());
      c+=1;
    }
    p.loadvideos();
    p.mrp=data["mrp"];
    p.cost=data["cost"];
    return p;
  }

}
Route _createRoute() {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>PaymentScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      }
  );
}

Route _createRoutetobuy(String id) {
  List<String> ids=[];
  ids.add(id);
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>Order(items: ids,initialValue: 1,onQuantityChange:(value){

      }),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      }
  );
}