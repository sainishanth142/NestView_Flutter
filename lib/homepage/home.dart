
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:nestview/homepage/data/data.dart';
import 'package:nestview/product/product.dart';
import 'package:nestview/registrationpage/registration.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  double _page = 0;
  final _controller = PageController(viewportFraction: 1);
  late List<Catagories> catogories = [];
  late List<Popularimages> popularimages = [];
  late List<Catagorieproduct> catagorieproducts = [];
  bool isloaded = false;
  _loadcatagories() async {
    late List<Catagories>? cat = [];
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('catogories').onValue.listen((event) {
      cat.clear();
      for (var i in event.snapshot.children) {
        Catagories ca = Catagories();
        ca.name = i.child("name").value as String;
        ca.image = i.child("image").value as String;
        cat.add(ca);
      }
      setState(() {
        catogories = cat;

      });
    });
  }


  _loadpopularimages() async {
    late List<Popularimages>? cat = [];
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('popular').onValue.listen((event) async {
      cat.clear();
      for (var i in event.snapshot.children) {
        Popularimages ca = Popularimages();

        ca.id = i.value as String;
        ca.image = await getimageofproduct(await i.value);
        cat.add(ca);
      }
      setState(() {
        popularimages = cat;
      });
    });
  }

  Future<bool> _loadcatagorieproducts() async {
    late List<Catagorieproduct>? cat = [];
    final ref = FirebaseDatabase.instance.ref('catagorieproducts');
    final refp = FirebaseDatabase.instance.ref("products");
    await ref.onValue.listen((event) async {
      cat.clear();
      for (var i in event.snapshot.children) {
        Catagorieproduct ca = Catagorieproduct();
        late List<Product> prod=[];
        for (int j=0;j<i.child("products").children.length;j++) {
          var dd=getproductdata(j,refp,i);
          ca.products.add(await dd);
        }
        ca.name = i.child("name").value as String;
        ca.id = i.key.toString();
        cat.add(ca);
      }
      setState((){
        catagorieproducts = cat;
        isloaded = true;
      });
    });
    return true;
  }

  @override
  void initState() {
    super.initState();
    _loadcatagories();
    _loadpopularimages();
    _loadcatagorieproducts();
    _controller.addListener(() => setState(() {
          _page = _controller.page!;
        }));
  }

  @override
  Widget build(BuildContext context) {
    var i = getcatagories(catogories);
    var ii = getpopularimages(popularimages,context);
    final PageController _popularpageController =
        PageController(initialPage: 0);
    return Scaffold(
      drawer: Drawer(child: Column(children: [Container(width:double.maxFinite,padding:const EdgeInsets.fromLTRB(4,50,4,5),child:ElevatedButton(child: const Text("Logout"),onPressed:() {
        FirebaseAuth.instance.signOut();
        Navigator.of(context).push(_createRoute1());
      },)),],)),
        appBar: AppBar(
          title: const Text("Nest View"),actions:[const Padding(padding: EdgeInsets.fromLTRB(3, 0, 7, 0),child: Icon(Icons.search),),Padding(padding: const EdgeInsets.fromLTRB(3, 0, 10, 0),child: PopupMenuButton(icon:const Icon(Icons.more_vert),itemBuilder:(context){
            return [
              const PopupMenuItem<int>(
                value: 0,
                child: Text("My Account"),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text("Settings"),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text("Logout"),
              ),
            ];
        },onSelected:(value){
          if(value == 0){
            print("My account menu is selected.");
          }else if(value == 1){
            print("Settings menu is selected.");
          }else if(value == 2){
            FirebaseAuth.instance.signOut();
            Navigator.of(context).push(_createRoute1());

          }
        }
        ),)],
        ),
        body: isloaded?ListView(
          padding: const EdgeInsets.all(1),
          children: <Widget>[
            SizedBox(
              height: 70,
              child:ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(1),
                      children: i,
                    )
            ),
            SizedBox(
                height: 250,
                child:
                    PageView(scrollDirection: Axis.horizontal, children: ii)),
          ]+(getproductscatagories(catagorieproducts)),
        ):const Center(child:CircularProgressIndicator()));
    // var l=i.then((value) => value.length).then((value) => value);
  }

  List<Column> getcatagories(List<Catagories> catogories) {
    late List<Column> data = [];
    for (var i in catogories) {
      var d = Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(1.0),
              child: Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(3.0),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(i.image),
                  ))),
          Text(i.name)
        ],
      );
      data.add(d);
    }
    return data;
  }

  getcatagorieschildren(List<String> data) {
    late List<Padding> list = [];
    for (var i in data) {
      list.add(Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
            width: 70,
            color: Colors.grey,
            padding: const EdgeInsets.all(1.0),
            child: Text(i)),
      ));
    }
    return list;
  }

  getpopularimages(List<Popularimages> data1, BuildContext context) {
    late List<GestureDetector> data = [];
    for (var i in data1) {
      var d = GestureDetector(onTap:(){
        openproduct(context,i.id);
      } ,child:Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(1),
              child: Container(
                height: 240,
                padding: const EdgeInsets.all(0),
                child: Image.network(
                  i.image,fit: BoxFit.fill,
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

  getproductscatagories(List<Catagorieproduct> data1) {
    late List<Container> data = [];
    for (var i in data1) {
      late List<Widget> c1=[];
      for(var j in i.products){
        c1.add(GestureDetector(onTap:(){
          openproduct(context, j.id);
        },child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(3.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,children: [
                  Container(
                      height: 120,
                      padding: const EdgeInsets.all(0),
                      child: Image.network(
                        j.image,fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(
                            child: CircularProgressIndicator(
                            ),
                          );
                        },
                      )),
                  Container(padding: EdgeInsets.all(3), child: Text(j.name),),
                  Container(padding: EdgeInsets.all(3), child: Text(j.cost.toString()),),
                  Container(padding: const EdgeInsets.all(3),
                    child: Text(j.mrp.toString(),
                        style: const TextStyle(decoration: TextDecoration.lineThrough)),),
                ],))),));
      }
      var d =
      Container(padding: const EdgeInsets.all(2),child: Container(color: Colors.grey[200],child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            child: Text(i.name),
          )
          ,GridView.count(
            primary: false,
            padding: const EdgeInsets.all(3),
            crossAxisSpacing: 3,
            physics: const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
            shrinkWrap: true,
            mainAxisSpacing: 2,
            crossAxisCount: 2,
            children: c1,
          )],
      )
        ,)
        ,);
      data.add(d);

    }
    return data;
  }

  Future<Product> getproductdata(int j, DatabaseReference refp, DataSnapshot i) async {
    var snp=i.child("products").child(j.toString());
    Product p=Product();
    bool done=false;
    var a=await refp.child(snp.value.toString()).get();
    Map<dynamic,dynamic> data=await a.value as Map<dynamic,dynamic>;
    p.id=data["id"];
    p.image=data["images"][0];
    p.name=data["name"];
    int b=0;
    for(var i in data["images"]){
      p.images.add(data["images"][b]);
      b+=1;
    }
    p.mrp=data["mrp"];
    p.cost=data["cost"];
    return p;
  }

  openproduct(BuildContext context,id){
    Navigator.of(context).push(_createRoute(id));
  }

  getimageofproduct(Object? value) async {
    final ref=FirebaseDatabase.instance.ref();
    var a=await ref.child("products").child(value.toString()).child("images").child("0").get();
    var data=await a.value as String;
    return data;
  }
  Route _createRoute1() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>const Registration(),
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
}
Route _createRoute(idd) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>Productpage(id:idd),
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
