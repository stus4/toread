import 'package:flutter/material.dart';
import 'package:toread/data/items.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../auth/login_screen.dart'; // Імпортуємо сторінку входу
import 'package:auto_size_text/auto_size_text.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<Widget> slides = items
      .map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCBB896).withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        item['image'],
                        fit: BoxFit.fitWidth,
                        width: 240.0,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F0E8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5D8C8),
                              width: 1,
                            ),
                          ),
                          child: AutoSizeText(
                            item['header'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5D4E42),
                              height: 1.3,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            minFontSize: 20,
                            maxFontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AutoSizeText(
                          item['description'],
                          style: const TextStyle(
                            color: Color(0xFF7A6B5D),
                            letterSpacing: 0.8,
                            fontSize: 16.0,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          minFontSize: 14,
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
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: currentPage.round() == index ? 12.0 : 8.0,
          width: currentPage.round() == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: currentPage.round() == index
                ? const Color(0xFFD4C4B0)
                : const Color(0xFFD4C4B0).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: currentPage.round() == index
                ? [
                    BoxShadow(
                      color: const Color(0xFFD4C4B0).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (currentPage > 0) {
          _pageViewController.previousPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
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
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      } else if (event.scrollDelta.dy < 0) {
        if (currentPage > 0) {
          _pageViewController.previousPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // М'який кремовий фон
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _onKey,
        child: Listener(
          onPointerSignal: _onScroll,
          child: Stack(
            children: <Widget>[
              // Декоративні елементи фону
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6D7C8).withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDACBBA).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Головний контент
              PageView.builder(
                controller: _pageViewController,
                itemCount: slides.length,
                itemBuilder: (BuildContext context, int index) {
                  return slides[index];
                },
              ),

              // Індикатори
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 70.0),
                  padding: const EdgeInsets.symmetric(vertical: 50.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0E8).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE5D8C8),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCBB896).withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: indicator(),
                    ),
                  ),
                ),
              ),

              // Кнопка входу
              if (currentPage.round() == slides.length - 1)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4C4B0).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6D7C8),
                          foregroundColor: const Color(0xFF5D4E42),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60.0,
                            vertical: 18.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Color(0xFFD4C4B0),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AutoSizeText(
                              'Увійти',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              minFontSize: 14,
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Color(0xFF5D4E42),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Підказка про навігацію
              if (currentPage.round() < slides.length - 1)
                Positioned(
                  bottom: 30,
                  right: 30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0E8).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE5D8C8),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Гортайте',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A6B5D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.swipe,
                          size: 16,
                          color: const Color(0xFF7A6B5D),
                        ),
                      ],
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
