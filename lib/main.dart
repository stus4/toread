import 'package:flutter/material.dart';
import 'package:toread/items.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome Screen',
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<Widget> slides = items
      .map((item) => Container(
            padding: EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Image.asset(
                    item['image'],
                    fit: BoxFit.fitWidth,
                    width: 220.0,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          item['header'],
                          style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.w300,
                              color: Color(0XFF3F3D56),
                              height: 2.0),
                        ),
                        Text(
                          item['description'],
                          style: TextStyle(
                              color: Colors.grey,
                              letterSpacing: 1.2,
                              fontSize: 16.0,
                              height: 1.3),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ))
      .toList();

  List<Widget> indicator() => List<Widget>.generate(
        slides.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 3.0),
          height: 10.0,
          width: 10.0,
          decoration: BoxDecoration(
            color: currentPage.round() == index
                ? Color(0XFF256075)
                : Color(0XFF256075).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );

  double currentPage = 0.0;
  final _pageViewController = PageController();

  @override
  void initState() {
    super.initState();
    _pageViewController.addListener(() {
      setState(() {
        currentPage = _pageViewController.page ?? 0.0;
      });
    });
  }

  void _onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        if (currentPage < slides.length - 1) {
          _pageViewController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (currentPage > 0) {
          _pageViewController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        }
      }
    }
  }

  void _onScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (event.scrollDelta.dy > 0) {
        if (currentPage < slides.length - 1) {
          _pageViewController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        }
      } else if (event.scrollDelta.dy < 0) {
        if (currentPage > 0) {
          _pageViewController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _onKey,
        child: Listener(
          onPointerSignal: _onScroll,
          child: Stack(
            children: <Widget>[
              PageView.builder(
                controller: _pageViewController,
                itemCount: slides.length,
                itemBuilder: (BuildContext context, int index) {
                  return slides[index];
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 70.0),
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: indicator(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
