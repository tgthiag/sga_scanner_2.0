import 'package:flutter/material.dart';
import 'main_activity.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyTest());
}

class MyTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainActivity();
}


