import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freefeos/freefeos.dart';

/// 应用入口
/// 需使用异步
Future<void> main() async {
  // 初始化运行器
  final launch = FreeFEOSLauncher(
    runner: (app) async => runApp(app),
    plugins: <FreeFEOSPlugin>[CountdownPlugin()],
    initApi: (exec) async => Global.exec = exec,
    enabled: true,
  );
  // 使用运行器启动应用
  await launch(const MyApp());
}

/// Global全局类
class Global {
  const Global();

  static FreeFEOSExec exec = (
    String channel,
    String method, [
    dynamic arguments,
  ]) async {
    return await null;
  };

  static final ValueNotifier<String> skillsCountdown = ValueNotifier('');
  static final ValueNotifier<String> writtenCountdown = ValueNotifier('');

  static const String appName = '高考倒计时';
  static const String devveloper = 'wyq0918dev';
  static const String countdownChannel = 'countdown';
  static const String methodStart = 'start';
  static const String methodStop = 'stop';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Global.appName,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: MediaQuery.platformBrightnessOf(
            context,
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class CountdownPlugin implements FreeFEOSPlugin {
  final DateTime _skillsExamDate = DateTime(2025, 3, 9, 9);
  final DateTime _writtenExamDate = DateTime(2025, 5, 11, 9);
  late Timer _skillsTimer;
  late Timer _writtenTimer;

  @override
  String get pluginAuthor => Global.devveloper;

  @override
  String get pluginChannel => Global.countdownChannel;

  @override
  String get pluginDescription => Global.appName;

  @override
  String get pluginName => Global.appName;

  @override
  Widget pluginWidget(BuildContext context) {
    return Container();
  }

  @override
  Future<dynamic> onMethodCall(String method, [dynamic arguments]) async {
    switch (method) {
      case Global.methodStart:
        return _startTimer();
      case Global.methodStop:
        return _stopTimer();
      default:
        return await null;
    }
  }

  // 计算倒计时
  void _startTimer() {
    _skillsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      DateTime now = DateTime.now();
      Duration diff = _skillsExamDate.difference(now).abs();
      int days = diff.inDays;
      int hours = diff.inHours % 24;
      int minutes = diff.inMinutes % 60;
      int seconds = diff.inSeconds % 60;
      Global.skillsCountdown.value = '$days天$hours小时$minutes分$seconds秒';
    });
    _writtenTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      DateTime now = DateTime.now();
      Duration diff = _writtenExamDate.difference(now).abs();
      int days = diff.inDays;
      int hours = diff.inHours % 24;
      int minutes = diff.inMinutes % 60;
      int seconds = diff.inSeconds % 60;
      Global.writtenCountdown.value = '$days天$hours小时$minutes分$seconds秒';
    });
  }

  void _stopTimer() {
    _skillsTimer.cancel();
    _writtenTimer.cancel();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Global.exec(Global.countdownChannel, Global.methodStart);
  }

  @override
  void dispose() {
    Global.exec(Global.countdownChannel, Global.methodStop);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Global.appName),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 12,
                      bottom: 6,
                      right: 12,
                    ),
                    child: Center(
                      child: Text(
                        '距离2025年山东省春季高考',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 6,
                        ),
                        child: ListTile(
                          title: const Text('专业技能考试还有'),
                          subtitle: ValueListenableBuilder(
                            valueListenable: Global.skillsCountdown,
                            builder: (context, value, child) {
                              return Text(value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 6,
                        ),
                        child: ListTile(
                          title: const Text('文化课,专业课理论考试还有'),
                          subtitle: ValueListenableBuilder(
                            valueListenable: Global.writtenCountdown,
                            builder: (context, value, child) {
                              return Text(value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Powered by FreeFEOS\n官方示例应用',
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
