import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerInteractivityCallback(backgroundCallback);
  runApp(const MyApp());
}

// Called when Doing Background Work initiated from Widget
@pragma('vm:entry-point') // required so Flutter keeps this function alive
Future<void> backgroundCallback(Uri? uri) async {
  // Read the current counter stored for the widget
  int counter =
      await HomeWidget.getWidgetData('_counter', defaultValue: 0) ?? 0;
  if (uri?.host == 'increment') {
    counter++;
  } else if (uri?.host == 'decrement') {
    counter--;
  }
  // Save the updated value so both app and widget can access it
  await HomeWidget.saveWidgetData('_counter', counter);
  // Refresh the widget UI
  await HomeWidget.updateWidget(
    name: 'HomeScreenWidgetProvider',
    iOSName: 'HomeScreenWidgetProvider',
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HomeWidget.widgetClicked.listen((Uri? uri) => loadData());
    loadData(); // This will load data from widget every time app is opened
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadData(); // App is back → refresh from widget storage
    }
  }

  /// Loads counter from widget storage safely
  void loadData() async {
    final storedValue = await HomeWidget.getWidgetData(
      '_counter',
      defaultValue: 0,
    );
    setState(() {
      _counter = storedValue ?? 0;
    });
  }

  /// Saves counter + refreshes home widget
  Future<void> _syncCounterToWidget() async {
    await HomeWidget.saveWidgetData('_counter', _counter);
    await HomeWidget.updateWidget(
      name: 'HomeScreenWidgetProvider',
      iOSName: 'HomeScreenWidgetProvider',
    );
  }

  /// UI increment
  void _incrementCounter() {
    setState(() => _counter++);
    _syncCounterToWidget();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
