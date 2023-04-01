import 'dart:collection';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nestview/keeporder/data/data.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Order extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onQuantityChange;
  final List<String> items;
  const Order(
      {Key? key,
      required this.items,
      required this.initialValue,
      required this.onQuantityChange})
      : super(key: key);
  @override
  State<Order> createState() => _OrderState(items);
}

class _OrderState extends State<Order> {
  Razorpay razorpay = Razorpay();
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobilenoController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipCodeController = TextEditingController();
  String _errorMessage="";

  int _selectedIndex = -1;
  int _quantity = 1;
  late List<String> items;
  late List<String> addresses=[];
  Allproducts prodata = Allproducts();

  _OrderState(this.items) {
    _registerPlatformInstance();
    _getd();
  }
  _getd() async {
    addresses=await getsavedaddress();
    if (await Permission.location.request().isGranted) {
      print("yes");
    }
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
    ].request();
    if (statuses[Permission.location] == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }

    // print(await getUserAddress());
    prodata = await _getdata(items);
  }

  Future<Allproducts> _getdata(List<String> items) async {
    Allproducts pdata = Allproducts();
    for (var i in items) {
      Productdata p = await getproductdata(i);
      pdata.products.add(p);
    }
    pdata.eval();
    setState(() {});
    return pdata;
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment success logic here
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Payment error logic here
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet logic here
  }
  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  void _openCheckout() async {
    var options = {
      'key': 'rzp_test_HtvWpdUBPwPEUN',
      'amount': 2000, // amount in paise, so 2000 paise = INR 20
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
    };
    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }
  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    super.dispose();
    razorpay.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Now")),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Flexible(child: Text("Orders"), flex: 1),
                Flexible(child: Text("Address"), flex: 1),
                Flexible(child: Text("Payment"), flex: 1)
              ],
            ),
          ),
          Expanded(
            child: PageView(
              scrollDirection: Axis.horizontal,
              children: [
                ListView(
                  children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: Text("No of Items : ${items.length}"),
                        ),
                      ] +
                      getproducts(prodata.products) +
                      [
                        Container(
                          child: Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(150, 6, 6, 0),
                                width: 220,
                                child: const Text("Total : ",
                                    style: TextStyle(fontSize: 20)),
                              ),
                              Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 3),
                                      child: Text(
                                        '\u{20B9} ${prodata.cost}',
                                        style: const TextStyle(
                                            fontSize: 25,
                                            color: Colors.red,
                                            fontWeight: FontWeight.w700),
                                      )),
                                  Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 3),
                                      child: Text(
                                        '\u{20B9} ${prodata.mrp}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black26,
                                            fontWeight: FontWeight.w300,
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
                Container(padding: EdgeInsets.all(20),child:  Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Expanded(child:
                      ListView.builder(
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(addresses[index]),
                            leading: Radio(
                              value: index,
                              groupValue: _selectedIndex,
                              onChanged: (value) {
                                setState(() {
                                  _selectedIndex = value!;
                                });
                              },
                            ),
                          );
                        },
                      )),

                      Container(padding: const EdgeInsets.all(10),alignment: Alignment.center,child: ElevatedButton(onPressed: (){getUserAddress1();},child: const Text("Get Location"),),),
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value=="") {
                            return 'Please enter your name';
                          }
                          return "";
                        },
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          hintText: 'Enter your Name',
                        ),
                      ),
                      TextFormField(
                        controller: _mobilenoController,
                        validator: (value) {
                          if (value=="") {
                            return 'Please enter your mobile number';
                          }
                          return "";
                        },
                        decoration: const InputDecoration(
                          labelText: 'Mobile number',
                          hintText: 'Enter your mobile number',
                        ),
                      ),
                      TextFormField(
                        controller: _streetController,
                        validator: (value) {
                          if (value=="") {
                            return 'Please enter your street address';
                          }
                          return "";
                        },
                        decoration: const InputDecoration(
                          labelText: 'Street Address',
                          hintText: 'Enter your street address',
                        ),
                      ),
                      TextFormField(
                        controller: _cityController,
                        validator: (value) {
                          if (value=="") {
                            return 'Please enter your city';
                          }
                          return "";
                        },
                        decoration: const InputDecoration(
                          labelText: 'City',
                          hintText: 'Enter your city',
                        ),
                      ),
                      TextFormField(
                        controller: _stateController,
                        validator: (value) {
                          if (value=="") {
                            return 'Please enter your state';
                          }
                          return "";
                        },
                        decoration: const InputDecoration(
                          labelText: 'State',
                          hintText: 'Enter your state',
                        ),
                      ),
                      TextFormField(
                        controller: _countryController,
                        validator: (value) {
                          if (value=="") {
                            return 'Please enter your country';
                          }
                          return "";
                        },
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          hintText: 'Enter your country',
                        ),
                      ),
                      TextFormField(
                        controller: _zipCodeController,
                        validator: (value) {
                          if (value=="") {
                            return 'Please enter your ZIP code';
                          }
                          return "";
                        },
                        decoration: const InputDecoration(
                          labelText: 'ZIP Code',
                          hintText: 'Enter your ZIP code',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _errorMessage ?? '',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 6),
                      Container(alignment: Alignment.center,child:ElevatedButton(
                        onPressed: () async {
                          saveaddress();
                          if (_formKey.currentState?.validate()==true) {

                            // All form fields are valid, submit the form
                            // if (address != null) {
                            //   // Address was successfully retrieved, navigate to the next screen
                            //   Navigator.pushNamed(context, '/next_screen', arguments: {
                            //     'address': address,
                            //   });
                            // } else {
                            //   // Address could not be retrieved, show an error message
                            //   setState(() {
                            //     _errorMessage = 'Could not retrieve your address. Please try again later.';
                            //   });
                            // }
                          }
                        },
                        child: Text('Save'),
                      )),
                    ],
                  ),
                ),),
                ElevatedButton(
                  onPressed: _openCheckout,
                  child: Text('Pay Now'),
                ),
              ],

            ),
          )
        ],

      ),
    );
  }
  Future<String?> getUserAddress1() async {
    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Reverse geocode the position to get the user's address
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      _streetController.text=placemark.street!;
      _cityController.text=placemark.subLocality!;
      _stateController.text=placemark.administrativeArea!;
      _countryController.text=placemark.country!;
      _zipCodeController.text=placemark.postalCode!;
      String address =
          "${_streetController.text}, ${placemark.subLocality}, ${_cityController.text}, ${_stateController.text}, ${_countryController.text} ${_zipCodeController.text}";
      return address;
    } else {
      return null;
    }
  }


  getproducts(List<Productdata> data1) {
    late List<Container> data = [];
    int _selectedQuantity = 1;
    for (var i in data1) {
      data.add(Container(
          child: GestureDetector(
        onTap: () {
          // openproduct(context, j.id);
        },
        child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(3.0),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                            height: 120,
                            width: 200,
                            padding: const EdgeInsets.all(0),
                            child: Image.network(
                              i.image,
                              fit: BoxFit.fill,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
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
                            )),
                        Container(
                          padding: const EdgeInsets.all(3),
                          child: Text(i.name),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                _quantity++;
                                widget.onQuantityChange(_quantity);
                                i.cost = i.initcost * (_quantity);
                                i.mrp = i.initmrp * (_quantity);
                                prodata.eval();
                                setState(() {});
                              },
                            ),
                            Text('$_quantity'),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (_quantity > 1) {
                                  _quantity--;
                                  widget.onQuantityChange(_quantity);
                                }
                                i.cost = i.initcost * (_quantity);
                                i.mrp = i.initmrp * (_quantity);
                                prodata.eval();
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 3),
                                child: Text(
                                  '\u{20B9} ${i.cost}',
                                  style: const TextStyle(
                                      fontSize: 25,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 3),
                                child: Text(
                                  '\u{20B9} ${i.mrp}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black26,
                                      fontWeight: FontWeight.w300,
                                      decoration: TextDecoration.lineThrough),
                                ))
                          ],
                        ),
                      ],
                    ),
                  ],
                ))),
      )));
    }
    return data;
  }
  Future<List<String>> getsavedaddress() async{
    List<String> d=[];
    var ds=await FirebaseDatabase.instance.ref("users").child(FirebaseAuth.instance.currentUser?.uid as String).child("address").onValue.listen((event) {
      d.clear();
      for(var i in  event.snapshot.children){
        d.add((i.value).toString());
      }
      setState(() {
        print("object");
      });
    });
    return d;


  }
  Future<Productdata> getproductdata(String id) async {
    var snp = FirebaseDatabase.instance.ref().child("products").child(id);
    Productdata p = Productdata();
    bool done = false;
    var a = await snp.get();
    Map<dynamic, dynamic> data = await a.value as Map<dynamic, dynamic>;
    p.id = data["id"];
    p.image = data["images"][0];
    p.name = data["name"];
    int b = 0;
    for (var i in data["images"]) {
      p.images.add(data["images"][b]);
      b += 1;
    }
    p.mrp = data["mrp"];
    p.cost = data["cost"];
    return p;
  }
  saveaddress() async{
    HashMap<String,String> address=HashMap();
    address["name"]=_nameController.text;
    address["mobile number"]=_mobilenoController.text;
    address["street"]=_streetController.text;
    address["city"]=_cityController.text;
    address["state"]=_stateController.text;
    address["country"]=_countryController.text;
    address["zipcode"]=_zipCodeController.text;
    FirebaseDatabase.instance.ref("users").child(FirebaseAuth.instance.currentUser?.uid as String).child("address").push().set(address);
  }
  void _registerPlatformInstance() {
    if (Platform.isAndroid) {
      GeolocatorAndroid.registerWith();
    } else if (Platform.isIOS) {
      GeolocatorApple.registerWith();
    }
  }
}

Future<String> getUserAddress() async {
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are disabled, show a dialog to enable them
    bool result = await Geolocator.openLocationSettings();
    if (!result) {
      return "Location services are disabled.";
    }
  }

  // Get the current position
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  // Reverse geocode the position to get the user's address
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  if (placemarks.isNotEmpty) {
    Placemark placemark = placemarks.first;
    String address =
        "${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
    return address;
  } else {
    return "No address found.";
  }
}
