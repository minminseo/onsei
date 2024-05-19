import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart'; // 未実装



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFFE4E1)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'アルバム'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<String> _titles = ['アルバム', '追加', '管理者設定'];

  static const List<Widget> _widgetOptions = <Widget>[
    Text('ここにアップロードした写真を新しい順で横3枚で縦に並べていく'),
    Text('追加の画面'),
    Text('管理者設定の画面'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        upload();
      }
    });
  }

  File? image;
  // 画像をスマホの写真アプリから選択してFirebaseStorageにアップロードする関数
  Future upload() async {
  // 画像をスマホのギャラリーから取得
  final image = await ImagePicker().pickImage(source: ImageSource.gallery);
  // 画像を取得できた場合はFirebaseStorageにアップロードする
  if (image != null) {
    final imageFile = File(image.path);
    FirebaseStorage storage = FirebaseStorage.instance;
    try {
      await storage.ref('sample.png').putFile(imageFile);
    } catch (e) {
      print(e);
    }
    _showBottomSheet(context);// imageに画像が入っている場合（画像選択後に関数”_showBottomSheet”を実行）
  }
  return;
}

//新しく追加したファイルを開いてファイルを選択する関数
//これ見たほうが良いhttps://chatgpt.com/share/c0fd1285-08fb-4f1d-8322-a8d4bb19f090
  Future<FilePickerResult?> pickFile() async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: false,
  );
  if (result != null) {
    final filePath = result.files.first.path;
    if (filePath != null) {
      final audioFile = File(filePath);
      FirebaseStorage storage = FirebaseStorage.instance;
      try {
        await storage.ref('sample.mp3').putFile(audioFile);
      } catch (e) {
        print(e);
      }
    }  // ここにもしresultに音声ファイルが入っている場合に実行したい関数を書く
  }
  return result;
}

// 画像選択後に実行する関数
/*
未実装
1.ファイルを選択ボタンを押したらファイルアプリとかにアクセスして音声ファイルを選択できる機能
2.音声ファイル選択後、Firebase cloud strageにアップロードする関数を実行するコードの追加
→画像を選択する関数が別のスコープにあるから、どうやって音声ファイルとセットでアップロードするかが課題
*/
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.33, // だいたい画面の3分の1くらい占める感じ
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.mic),
                title: Text('録音'),
                onTap: () {
                  // 録音を開始するボタン
                },
              ),
              ListTile(
                leading: Icon(Icons.file_upload),
                title: Text('ファイルを選択'),
                onTap: () {
                  pickFile();// ファイルを選択するボタン 新しく追加
                },
              ),
              
            ],
          ),
        );
      },
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_titles[_selectedIndex]),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            label: 'アルバム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '追加',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '管理者設定',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}