import 'package:flutter/material.dart';
import 'package:layout_demo/tabs/first.dart';
import 'package:layout_demo/tabs/second/second.dart';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Genetor',
      home: MyHome(),
    );
  }
  //...
}

class MyHome extends StatefulWidget {
  @override
  MyHomeState createState() {
    // TODO: implement createState
    return new MyHomeState();
  }
}


class NewsTab{
  String text;
  NewsList newsList;
  NewsTab(this.text,this.newsList);
}
class MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {

  
  TabController controller;
  TabBar getTabBar() {
    return new TabBar(
      tabs: <Tab>[
        new Tab(
          // set icon to the tab
          icon: new Icon(Icons.favorite,color: Colors.red,)
        ),
        new Tab(
          //icon: new Icon(Icons.adb),
          child:new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(
                  Icons.favorite,
                 // size: 160.0,
                  color: Colors.red,
                ),
                new Text(
                  "First Tab",
                  style: new TextStyle(
                   color: Colors.red
                 ),),
              ]),
        ),
        new Tab(
          icon: new Icon(Icons.airport_shuttle),
        ),
      ],
      // setup the controller
      // tabs: newsTabs.map((NewsTab item){
        // return new Tab(text: item.text,);
      // }).toList(),
      controller: controller
       
    );
  }

  TabBarView getTabBarView(var tabs) {
    return new TabBarView(
      // Add tabs as widgets
      children: tabs,
      // set the controller
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Using Tabs"),
        backgroundColor: Colors.blue,
      ),
      body: getTabBarView(<Widget>[new First(), new Second()]),
      bottomNavigationBar: getTabBar(),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }
}

