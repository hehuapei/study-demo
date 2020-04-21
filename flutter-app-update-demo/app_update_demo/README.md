### 安卓app应用内升级demo

---

1. 使用 **package_info** 获取本地版本信息,然后与线上版本对比,看是否需要更新  
``` dart
import 'package:package_info/package_info.dart';

//获取当前版本
PackageInfo packageInfo = await PackageInfo.fromPlatform();
String version = packageInfo.version;
```  

2. 使用 **permission_handler** 来获取读写权限  
```dart
import 'package:permission_handler/permission_handler.dart';

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
```  

3. 使用 **flutter_downloader** 下载最新版本的安装包  
```dart
import 'package:flutter_downloader/flutter_downloader.dart';

 /// 下载
Future<String> executeDownload(String url) async {
    final path = await BackUpdate()._apkLocalPath();
    
    //发起请求
    final taskId = await FlutterDownloader.enqueue(
        url: url,
        fileName: 'update.apk',
        savedDir: path,
        showNotification: false,
        openFileFromNotification: false);
    
    FlutterDownloader.registerCallback((id, status, progress) {
      //更新下载进度
      setState(() => this.progress = progress);
    
      // 当下载完成时，调用安装
      if (taskId == id && status == DownloadTaskStatus.complete) {
        //关闭更新进度框
        Navigator.of(context).pop();
        //安装下载完的apk
        BackUpdate()._installApk();
      }
    });

  return taskId;
}
```

4. 使用 **install_plugin** 打开下载好的安装包
```dart
import 'package:install_plugin/install_plugin.dart';

/// 安装
Future<Null> _installApk() async {
    try {
      final path = await _apkLocalPath();
    
      //这里使用的包名要跟/android/app/build.gradle 里面的applicationId一致
      InstallPlugin.installApk(path + '/update.apk', 'com.example.app_update_demo') 
          .then((result) {
        print('install apk $result');
      }).catchError((error) {
        print('install apk error: $error');
      });
    } on PlatformException catch (_) {}
}
```