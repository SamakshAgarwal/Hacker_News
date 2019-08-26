import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hacker News'),
        ),
        body: FutureBuilder(
            future: _getArticleList(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.separated(
                  itemCount: 200,
                  itemBuilder: (BuildContext context, int index) {
                    return FutureBuilder(
                      future: _getArticle(snapshot.data[index]),
                      builder: (BuildContext context,
                          AsyncSnapshot articleSnapshot) {
                        if (articleSnapshot.data == null)
                          return ListTile(
                            title: Text('Loading...'),
                          );
                        else
                          return ListTile(dense: false,
                            title: Text("${articleSnapshot.data['title']}"),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('${articleSnapshot.data['type']}'),
                                Text('by ${articleSnapshot.data['by']}')
                              ],
                            ),
                            onTap: () {
                              print('webview called');
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context)=>ArticleContent(articleSnapshot.data['url'])));
                            },
                          );
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                );
              }
            }),
      ),
    );
  }

  Future _getArticleList() async {
    String url = "https://hacker-news.firebaseio.com/v0/topstories.json";
    var html = await http.get(url);
    var json = jsonDecode(html.body);
    return json;
  }

  Future _getArticle(int articleId) async {
    String url = "https://hacker-news.firebaseio.com/v0/item/$articleId.json";
    var html = await http.get(url);
    var articleJSON = jsonDecode(html.body);
    return articleJSON;
  }
}

class ArticleContent extends StatelessWidget {
  final String url;

  ArticleContent(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: WebView(
      initialUrl: url,
    ),);
  }
}
