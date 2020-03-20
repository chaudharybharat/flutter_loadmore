import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ConnectionStatusSingleton.dart';
import 'NetworkCheck.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeState();
}

class HomeState extends State<MyApp> {

  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  static int page = 0;
  ScrollController _sc = new ScrollController();
  bool isLoading = false;
  List users = new List();
  final dio = new Dio();
  @override
  void initState() {
    this._getMoreData(page);
    super.initState();
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(page);
      }
    });
    NetworkCheck networkCheck = new NetworkCheck();
    networkCheck.checkInternet(fetchPrefrence);

    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);

  }
  fetchPrefrence(bool isNetworkPresent) {
    if(isNetworkPresent){
      print("internate connection isNetworkPresent=>>${isNetworkPresent}");
    }else{
      print("internate connection not not=>>${isNetworkPresent}");

    }
  }
  void connectionChanged(dynamic hasConnection) {
    print("internate *********%%%%%%====>>${hasConnection}");
    setState(() {
      isOffline = !hasConnection;
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    _connectionChangeStream.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("Lazy Load Large List"),
      ),
      body: Container(
        child: _buildList(),
      ),
      resizeToAvoidBottomPadding: false,
    ));
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: users.length + 1, // Add one more item for progress indicator
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (BuildContext context, int index) {
        if (index == users.length) {
          return _buildProgressIndicator();
        } else {
          return new ListTile(
            leading: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage(
                users[index]['picture']['large'],
              ),
            ),
            title: Text((users[index]['name']['first'])),
            subtitle: Text((users[index]['email'])),
          );
        }
      },
      controller: _sc,
    );
  }

  void _getMoreData(int index) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var url = "https://randomuser.me/api/?page=" +
          index.toString() +
          "&results=20&seed=abc";
      print(url);
      // final response = await http
      //     .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
      // final mainrespon = json.decode(response.body);
      final response = await dio.get(url);
      print("response=>>${response}");
      print("results=>>${response.data['results'].length}");

      List tList = new List();
      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
      }
      print("size=>>${tList.length}");
      setState(() {
        isLoading = false;
        users.addAll(tList);
        page++;
      });
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }
}
