import 'package:flutter/material.dart';
import 'dart:math';
import 'package:iot_l6/signin_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
final FirebaseAuth _auth = FirebaseAuth.instance;

List<Product> favItem = [];
List<Product> shoppingCart = [];

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final fieldText = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _allPages = [
      HomePage(),
      FavPage()
    ];

    return Scaffold(
      appBar: AppBar(
          title: Text("Product list"),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
            ),
            Builder(builder: (BuildContext context) {
              return FlatButton(
                textColor: Theme.of(context).buttonColor,
                onPressed: () async {
                  final User user = _auth.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No one has signed in')));
                    return;
                  }
                  await _signOut();
                  final String uid = user.uid;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$uid has successfully signed out.')));
                },
                child: const Text('Sign out'),
              );
            })
          ]
      ),
      body: Center(
        child: _allPages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.tealAccent,
        onTap: _onItemTapped,
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage()));
  }

}

class CustomSearchDelegate extends SearchDelegate{

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ' ';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        }
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for(var item in shoppingCart) {
      if(item.name.toLowerCase().contains(query.toLowerCase())){
        matchQuery.add(item.name);
      }
    }
    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];
          return ListTile(
            title: Text(result),
          );
        }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for(var item in shoppingCart) {
      if(item.name.toLowerCase().contains(query.toLowerCase())){
        matchQuery.add(item.name);
      }
    }
    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];
          return ListTile(
            title: Text(result),
          );
        }
    );
  }

}

class Product {
  final String name;

  const Product({@required this.name});
}

typedef void CartChangedCallback(Product product, bool inCart);

class ShoppingListItem extends StatelessWidget {
  final Product product;
  final inCart;
  final CartChangedCallback onCartChanged;

  ShoppingListItem({
    @required this.product,
    @required this.inCart,
    @required this.onCartChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      leading: CircleAvatar(
        backgroundColor: Colors.tealAccent,
        child: Text(product.name[0]),
      ),
      onTap: () {
        onCartChanged(product, inCart);
      },
    );
  }
}

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textFieldController = TextEditingController();
  List<String> price = ["200", "50", "10", "5", "20"];
  String currency = "RON";
  List<String> voucher = ["Yes", "No", "Unknown"];
  int day, month, year;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Image.asset(
                    "assets/toDo.png",
                    width: 50,
                    height: 50,
                  ),
                  Text(
                    "Products you have to buy",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xfff7b3c2),
                      fontSize: 25,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: shoppingCart.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction){
                          if(direction == DismissDirection.endToStart) {
                            setState(() {
                              shoppingCart.removeAt(index);
                            });
                          } else if(direction == DismissDirection.startToEnd){
                            favItem.add(Product(name: shoppingCart[index].name));
                            setState(() {
                              shoppingCart.removeAt(index);
                            });
                          }
                        },
                        secondaryBackground: Container(color: Color(0xfff7b3c2),
                          child: Text(
                            "Product has been deleted",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff74565c),
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        background: Container(color: Colors.tealAccent,
                          child: Text(
                            "Added to favorites",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        child: ShoppingListItem(
                          product: shoppingCart[index],
                          inCart: shoppingCart.contains(shoppingCart[index]),
                          onCartChanged: onCartChanged,
                        )
                    );
                  }),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => displayDialog(context),
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<AlertDialog> displayDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                "Add a new product to your list",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xfff7b3c2),
                )
            ),
            content: TextField(
              controller: textFieldController,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (textFieldController.text.trim() != "")
                    setState(() {
                      shoppingCart.add(Product(name: textFieldController.text));
                    });

                  textFieldController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Save",
                    style: TextStyle(
                      color: Colors.tealAccent,
                    )
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close",
                    style: TextStyle(
                      color: Colors.tealAccent,
                    )
                ),
              ),
            ],
          );
        });
  }

  void onCartChanged(Product product, bool inCart) {
    setState(() {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Product information",
                textAlign: TextAlign.center,
                style: TextStyle(
                  //style
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Product name : " + product.name),
                  Text("Product price  : " + getPrice(product, price) + " " + currency),
                  Text("Voucher eligibility : " + getVoucher(voucher)),
                  Text("Fabrication date : ${getDay(day)}/${getMonth(month)}/${getYear(year)} "),

                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"),

                )
              ],
            );
          }
      );
    });
  }

  String getPrice(Product product, List<String> price) {
    for (var i = 0; i < price.length; i++) {
      if (product.name[0] == "P" || product.name[0] == "p")
        return price[0];
      if (product.name[0] == "B" || product.name[0] == "b")
        return price[1];
      if (product.name[0] == "C" || product.name[0] == "c")
        return price[2];
      if (product.name[0] == "A" || product.name[0] == "a")
        return price[3];
      if (product.name[0] != "A" && product.name[0] != "B" && product.name[0] != "C" && product.name[0] != "P")
        return price[4];
    }
    return null;
  }

  String getVoucher(List<String> voucher){
    Random random = new Random();
    int ranNum = random.nextInt(3);
    return voucher[ranNum];
  }

  int getDay(int day){
    Random random = new Random();
    int ranNum = random.nextInt(31);
    day = ranNum;
    return day;
  }

  int getMonth(int month) {
    int c = 1;
    while (c == 1) {
      Random random = new Random();
      int ranNum = random.nextInt(12);
      if (ranNum == 0) {
        c = 1;
      } else {
        c = 0;
        month = ranNum;
        return month;
      }
    }
    return null;
  }

  int getYear(int year){
    int c = 1;
    while(c == 1){
      Random random = new Random();
      int ranNum = random.nextInt(2022);
      if(ranNum > 2000 && ranNum < 2022) {
        c = 0;
        year = ranNum;
        return year;
      }else{
        c = 1 ;
      }
    }
    return null;
  }

}

class FavPage extends StatefulWidget {
  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/toDo.png",
                          width: 50,
                          height: 50,
                        ),
                        Text(
                          "Favorite products",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xfff7b3c2),
                            fontSize: 25,
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                          itemCount: favItem.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction){
                                  if(direction == DismissDirection.endToStart) {
                                    favItem.removeAt(index);
                                  }
                                },
                                background: Container(color: Color(0xfff7b3c2),
                                  child: Text(
                                    "Product has been deleted",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff74565c),
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                child: ShoppingListItem(
                                  product: favItem[index],
                                  inCart: favItem.contains(favItem[index]),
                                  onCartChanged: onCartChanged,
                                )
                            );
                          }
                      )
                  )
                ]
            )
        )
    );
  }
  void onCartChanged(Product product, bool inCart) {

  }
}