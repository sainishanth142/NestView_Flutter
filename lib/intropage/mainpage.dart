import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nestview/intropage/imagesdata.dart';
import 'package:nestview/intropage/imgpageitem.dart';
import 'package:nestview/registrationpage/registration.dart';
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double _page=0;
  int get _firstindex => _page.toInt();
  final _controller=PageController(
    viewportFraction: 1
  );

  late final _itemwidth=MediaQuery.of(context).size.width;
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {

      }else{

      }
    });
    _controller.addListener(() => setState(() {
      _page=_controller.page!;
    }));
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
        children:[Column(
          children: [
            Stack(children: [
              Positioned.fill(child: Align(alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: _itemwidth,
                  height: MediaQuery.of(context).size.height,
                  child: FractionallySizedBox(
                    child: ImgItem(index: _firstindex,width: _itemwidth,url: model[_firstindex],),
                  ),
                ),)),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: PageView.builder(
                    controller: _controller,
                    itemBuilder: (context,index){
                      return Opacity(opacity: index <=_firstindex ? 0:1,
                        child: ImgItem(index: index,width: _itemwidth,url: model[index],),);
                    }),
              )
            ],)
          ],
        ),Align(alignment: AlignmentDirectional.bottomEnd
            ,child:Container(padding: const EdgeInsets.all(20),child:ElevatedButton(onPressed: (){
              // Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context) => const Registration()));
              // Navigator.of(context, rootNavigator: true).push(
              //   CupertinoPageRoute<bool>(
              //     fullscreenDialog: true,
              //     builder: (BuildContext context) => const Registration(),
              //   ),
              // );
              Navigator.of(context).push(_createRoute());
        },child: const Text("Skip ->",))))],
    );

  }
}
Route _createRoute1() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const Registration(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);
      return child;
    },
  );
}
Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const Registration(),
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
