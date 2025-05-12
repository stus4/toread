import 'package:flutter/material.dart';
import 'package:toread/items.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'login_screen.dart'; // Імпортуємо сторінку входу
import 'package:auto_size_text/auto_size_text.dart';

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
                        AutoSizeText(
                          item['header'],
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Color(0XFF633A14),
                              height: 2.0),
                          maxLines: 1, // максимальна кількість рядків
                          minFontSize: 24, // мінімальний розмір шрифту
                        ),
                        AutoSizeText(
                          item['description'],
                          style: TextStyle(
                              color: Colors.grey,
                              letterSpacing: 1.2,
                              fontSize: 16.0,
                              height: 1.3),
                          textAlign: TextAlign.center,
                          maxLines: 3, // максимальна кількість рядків
                          minFontSize: 16, // мінімальний розмір шрифту
                        ),
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
                ? Color(0XFF955627)
                : Color(0XFF955627).withOpacity(0.2),
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
              // Кнопка для переходу на сторінку входу
              if (currentPage.round() ==
                  slides.length - 1) // Check if on last slide
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: AutoSizeText(
                        'Увійти',
                        style: TextStyle(fontSize: 18),
                        maxLines: 1, // максимальна кількість рядків
                        minFontSize: 12, // мінімальний розмір шрифту
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0XFF955627),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 15.0),
                      ),
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
