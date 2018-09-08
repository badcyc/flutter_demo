import 'package:flutter/material.dart';
import 'package:layout_demo/tabs/first.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Second extends StatefulWidget {
  @override
  SecondState createState() => new SecondState();
}

class NewsTab {
  String text;
  NewsList newsList;
  NewsTab(this.text, this.newsList);
}

class SecondState extends State<Second> with SingleTickerProviderStateMixin {
  TabController controller;

  final List<NewsTab> newsTabs = <NewsTab>[
    new NewsTab(
        '头条',
        new NewsList(
          newsType: 'toutiao',
        )),
    new NewsTab(
        '社会',
        new NewsList(
          newsType: 'shehui',
        )),
  ];

  TabBar getTabBar() {
    return new TabBar(
      /*tabs: <Tab>[
        new Tab(
          icon: new Icon(Icons.adb),
        ),
        new Tab(icon: new Icon(Icons.favorite))
      ],
      controller: controller,*/
      tabs: newsTabs.map((NewsTab item) {
        return new Tab(
          text: item.text,
        );
      }).toList(),
      controller: controller,
    );
  }

  TabBarView getTabBarView(var tabs) {
    return new TabBarView(
      children: newsTabs.map((item) {
        return item.newsList;
      }).toList(),
      controller: controller,
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      //  children: <Widget>[
      //  getTabBar(),
      //  getTabBarView(<Widget>[new First(), new First()]),
      //  ],
      // mainAxisAlignment: MainAxisAlignment.center,
      appBar: new AppBar(
        title: getTabBar(),
        backgroundColor: Colors.blue,
      ),
      // bottom: getTabBar()),
      body: getTabBarView(<Widget>[new First(), new First()]),
    );
    // new Container(
    //  child:new Center(
    // child:new Column(
    // mainAxisAlignment:MainAxisAlignment.center,
    // children:<Widget>[
//
    // new Icon(
    // Icons.adb,
    // size:160.0,
    // color:Colors.red,
    // ),
    // new Text("Second Tab"),
    // ]
    // )
    // )
    // );
  }
}

class NewsList extends StatefulWidget {
  final String newsType;

  @override
  NewsList({Key key, this.newsType}) : super(key: key);

  @override
  NewsListState createState() {
    // TODO: implement createState
    return new NewsListState();
  }
}

class NewsListState extends State<NewsList> {
  final String url = 'http://v.juhe.cn/toutiao/index?';
  List data;
  Future<String> get(String category) async {
    var httpClient = new HttpClient();
    var request = await httpClient.getUrl(
        Uri.parse('${url}type=$category&key=3a86f36bd3ecac8a51135ded5eebe862'));
    var response = await request.close();
    return await response.transform(utf8.decoder).join();
  }

  Future<Null> loadData() async {
    await get(widget.newsType);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new RefreshIndicator(
      child: new FutureBuilder(
        //用于懒加载的FutureBuilder对象
        future: get(widget.newsType), //HTTP请求获取数据，将被AsyncSnapshot对象监视
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none: //get未执行时
            case ConnectionState.waiting: //get正在执行时
              return new Center(
                child: new Card(
                  child: new Text('loading...'), //在页面中央显示正在加载
                ),
              );
            default:
              if (snapshot.hasError) //get执行完成但出现异常
                return new Text('Error: ${snapshot.error}');
              else //get正常执行完成
                // 创建列表，列表数据来源于snapshot的返回值，而snapshot就是get(widget.newsType)执行完毕时的快照
                // get(widget.newsType)执行完毕时的快照即函数最后的返回值。
                return createListView(context, snapshot);
          }
        },
      ),
      onRefresh: loadData,
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    // print(snapshot.data);
    List values;
    values = jsonDecode(snapshot.data)['result'] != null
        ? jsonDecode(snapshot.data)['result']['data']
        : [''];
    switch (values.length) {
      case 1: //没有获取到数据，则返回请求失败的原因
        return new Center(
          child: new Card(
            child: new Text(jsonDecode(snapshot.data)['reason']),
          ),
        );
      default:
        return new ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(6.0),
            // itemCount: data == null ? 0 : data.length,
            itemCount: values == null ? 0 : values.length,
            itemBuilder: (context, i) {
              // return _newsRow(data[i]);//把数据项塞入ListView中
              return _newsRow(values[i]);
            });
    }
  }

  //新闻列表单个item
  Widget _newsRow(newsInfo) {
    return new Padding(
      padding: new EdgeInsets.all(2.0),
        child: new Card(
            child: new Column(
      children: <Widget>[
        new Container(
          child: new ListTile(
            title: new Text(
              newsInfo["title"],
              textScaleFactor: 1.5,
            ),
          ),
          margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        _generateItem(newsInfo), //根据图片数量返回对应样式的图片
        new Container(
            padding: const EdgeInsets.fromLTRB(25.0, 10.0, 0.0, 10.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Expanded(
                  child: new Text(newsInfo["author_name"]),
                ),
                new Expanded(
                  child: new Text(newsInfo["date"]),
                ),
              ],
            )),
      ],
    )));
  }

  //根据获取到的图片数量控制图片的显示样式
  _generateItem(Map newsInfo) {
    if (newsInfo["thumbnail_pic_s"] != null &&
        newsInfo["thumbnail_pic_s02"] != null &&
        newsInfo["thumbnail_pic_s03"] != null) {
      return _generateThreePicItem(newsInfo);
    } else {
      return _generateOnePicItem(newsInfo);
    }
  }

  //仅有一个图片时的效果
  _generateOnePicItem(Map newsInfo) {
    return new Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new Expanded(
            child: new Container(
                padding: const EdgeInsets.all(3.0),
                child: new SizedBox(
                  child: new Image.network(
                    newsInfo['thumbnail_pic_s'],
                    fit: BoxFit.fitWidth,
                  ),
                  height: 200.0,
                )))
      ],
    );
  }

  //有三张图片时的效果
  _generateThreePicItem(Map newsInfo) {
    return new Row(
      children: <Widget>[
        new Expanded(
            child: new Container(
                padding: const EdgeInsets.all(4.0),
                child: new Image.network(newsInfo['thumbnail_pic_s']))),
        new Expanded(
            child: new Container(
                padding: const EdgeInsets.all(4.0),
                child: new Image.network(newsInfo['thumbnail_pic_s02']))),
        new Expanded(
            child: new Container(
                padding: const EdgeInsets.all(4.0),
                child: new Image.network(newsInfo['thumbnail_pic_s03'])))
      ],
    );
  }
}
