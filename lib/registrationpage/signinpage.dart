import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nestview/auth/login.dart';
import 'package:nestview/firebase_options.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  TextEditingController emailTF=TextEditingController();
  TextEditingController passwordTF=TextEditingController();
  TextEditingController usernameTF=TextEditingController();
  TextEditingController mobilenoTF=TextEditingController();
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
                controller: usernameTF,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User Name',
                    hintText: "Enter Your Name"
                ),
                onChanged: (text) {
                  setState(() {

                  });
                },
              )),
          Container(
              margin: EdgeInsets.all(20),
              child: TextField(
                controller: mobilenoTF,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mobile Number',
                    hintText: "Enter Your Mobile Number"
                ),
                onChanged: (text) {
                  setState(() {

                  });
                },
              )),
          Container(
              margin: EdgeInsets.all(20),
              child: TextField(
                controller: emailTF,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
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
            child: ElevatedButton(child: lod?Container(padding:const EdgeInsets.all(2),child:const CircularProgressIndicator(color: Colors.white)):const Text("Create Account"),onPressed:() async {
              await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              );
              setState(() {
                lod=true;
              });
              var login=Loginmethods();
              var d=await login.Signinwithep(emailTF.text, passwordTF.text,usernameTF.text,mobilenoTF.text,context);
              if(d!=""){
                setState(() {
                  lod=false;
                });
              }
            },),
          ),

          Container(
            margin: const EdgeInsets.all(20),
            child: TextButton(child: const Text("Already have an account?login here"),onPressed: (){
              Navigator.of(context).pop();
            },),
          )
        ])));


  }
}
