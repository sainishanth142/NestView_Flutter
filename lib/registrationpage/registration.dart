import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nestview/auth/login.dart';
import 'package:nestview/firebase_options.dart';
import 'package:nestview/registrationpage/signinpage.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  TextEditingController emailTF=TextEditingController();
  TextEditingController passwordTF=TextEditingController();
  var _passwordVisible;
  bool lod=false;
  @override
  void initState() {
    _passwordVisible = false;
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Nest View")),
      body:Center(child: Column(children: <Widget>[
    Container(
    margin: EdgeInsets.all(20),
    child: TextField(
    controller: emailTF,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
    border: OutlineInputBorder(),
    labelText: 'Email',
      hintText: "Enter Your Registered Email"
    ),
    onChanged: (text) {
    setState(() {

    });
    },
    )),
    Container(
    margin: EdgeInsets.all(20),
    child: TextFormField(
      keyboardType: TextInputType.text,
      controller: passwordTF,
      obscureText: !_passwordVisible,//This will obscure text dynamically
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
        hintText: 'Enter your password',
        // Here is key idea
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            _passwordVisible
                ? Icons.visibility
                : Icons.visibility_off,
            color: Theme.of(context).primaryColorDark,
          ),
          onPressed: () {
            // Update the state i.e. toogle the state of passwordVisible variable
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
    ),
    ),Container(
          margin: const EdgeInsets.all(10),
          child: ElevatedButton(child: lod?Container(padding:const EdgeInsets.all(2),child:const CircularProgressIndicator(color: Colors.white)):const Text("Login"),onPressed:() async {
            await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            );
            setState(() {
              lod=true;
            });
            var d=await Loginmethods().Loginwithep(emailTF.text, passwordTF.text,context);
            if(d!=""){
              setState(() {
                lod=false;
              });
            }
          },),
        ),

        Container(
          margin: EdgeInsets.all(20),
          child: TextButton(child: Text("Create a new account?"),onPressed: (){

            Navigator.of(context).pushAndRemoveUntil(_createRoute(), (Route route) => false);

          },),
        )
    ])));
  }
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const SigninPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return child;
      },
    );
  }
}

