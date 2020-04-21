import 'dart:async';

import 'package:app_update_demo/download_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:collection';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info/package_info.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '应用内升级demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '应用内升级demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Text('点击下方按钮检测更新'),
      ),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return FloatingActionButton(//更新按钮
            onPressed: () {
              //检查是否有新版本
              var update = checkUpdate();

              update.then((value){
                if(value == null){
                  //显示已是最新
                  final mySnackBar = SnackBar(
                    content: new Text('已是最新版本'),
                    backgroundColor: Colors.blue,
                    duration: Duration(milliseconds: 500),

                  );
                  Scaffold.of(context).showSnackBar(mySnackBar);
                }else{
                  //显示更新内容
                  showUpdate(value['ver'], value['data'], value['url']);
                }
              });
            },
            tooltip: '点击检测更新',
            child: Text(
              '更新',
            ),
        );
      }),
    );
  }

  ///检查是否有更新
  Future<Map> checkUpdate() async{

    //获取当前版本
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    //获取服务器上最新版本
    Map map = new HashMap();
    map['data'] = '1.新增app应用内升级\n2.修复若干个bug';
    map['ver'] = '1.0.1';
    map['url'] = 'https://github.com/hehuapei/flutter-demo/raw/master/resource/app.apk';

    //判断如果服务器上版本比当前版本新,则返回最新版本信息
    if((Random().nextInt(10)) > 3){
      print('当前版本: ' + version + ',最新版本: ' + map['ver']);
      return map;
    }
    return null;
  }

  ///显示更新内容
  ///[version] 最新版本号
  ///[data] 更新内容
  Future<void> showUpdate(String version, String data, String url) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('发现新版本'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(version),
                Text(''),
                Text('更新内容'),
                Text(data),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('确认'),
              onPressed: ()=>doUpdate(version,url)
              ,
            ),
          ],
        );
      },
    );
  }

  ///执行更新操作
  ///[version] 最新版本号
  doUpdate(String version,String url) async {

    //关闭更新内容提示框
    Navigator.of(context).pop();

    //获取权限
    var per = await checkPermission();
    if(per != null && !per){
      return null;
    }

    //开始更新
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      child: DownloadProgressDialog(version,url),
    );
  }


  ///检查是否有权限
  checkPermission() async {
    //检查是否已有读写内存权限
    PermissionStatus status = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);

    //判断如果还没拥有读写权限就申请获取权限
    if(status != PermissionStatus.granted){
      var map = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      if(map[PermissionGroup.storage] != PermissionStatus.granted){
        return false;
      }
    }
  }

}


