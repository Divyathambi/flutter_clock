import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_clock_helper/model.dart';



enum _UserInterface {
  background,
  shadow,
  stackColor,
  iconColor
 }

 final  _darkMode = {
   _UserInterface.background: Colors.black,
   _UserInterface.shadow: Colors.white,
   _UserInterface.stackColor: Colors.black,
   _UserInterface.iconColor: Colors.white
 };

 final _lightMode = {
   _UserInterface.background : Colors.white,
   _UserInterface.shadow: Colors.black,
  _UserInterface.stackColor: Colors.white,
  _UserInterface.iconColor: Color(0xff034E87)
 };



class DigitalClock extends StatefulWidget {

  const DigitalClock( this.model );
  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

 class _DigitalClockState extends State<DigitalClock> with SingleTickerProviderStateMixin{ 
  DateTime _dateTime = DateTime.now();
  Timer _timer; 
  static AnimationController _controller;

  final Shader lightModeText = LinearGradient(
    colors:<Color>[Color(0xff034E87),
                   Color(0xff056DAA),
                   Color(0xff069EDE),
                   Color(0xff02B4EC),
                   Color(0xff02C1F7)
                   ],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)
  );
  final Shader darkModeText = LinearGradient(
    colors:<Color>[Color(0xff464646),
                   Color(0xff636363),
                   Color(0xff858585),
                   Color(0xffABABAB),
                   Color(0xffCACACA)
                   ],
                  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)
  );
  static const _setAnimationSettleValue = 0.9;
  Animation<Offset> _offsetAnimation;
  
  

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      value: _setAnimationSettleValue,
      vsync: this);
      _offsetAnimation = TweenSequence([
        TweenSequenceItem<Offset>(
          tween: Tween<Offset>(begin: Offset(30.0, 0.0), end: Offset.zero).
          chain(CurveTween(curve: Curves.easeInOut)),
          weight: _setAnimationSettleValue
        ),
        TweenSequenceItem<Offset>(
          tween: Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -30.0)).
          chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1 - _setAnimationSettleValue,
          )
      ]
      ).animate(_controller);
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }


  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    _controller.dispose();
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {

    });
  }

  void _updateTime() async {
    await _controller.forward();
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(minutes: 1) -
        Duration(seconds: _dateTime.second) -
        Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      _controller
      ..reset()
      ..animateTo(_setAnimationSettleValue);
    });
  }





  @override
  Widget build(BuildContext context) {
  final hours = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
  final minutes = DateFormat('mm').format(_dateTime);
  final uicolors = Theme.of(context).brightness == Brightness.light 
                   ? _lightMode : _darkMode;
  final textColor = uicolors == _lightMode? lightModeText : darkModeText;

  final defaultStyle = TextStyle(
    fontFamily: 'Opensans',
    fontSize: 80.0,
    fontWeight: FontWeight.bold,
    shadows:[
      Shadow(
        blurRadius: 10,
        color: uicolors[_UserInterface.shadow],
        offset: Offset(-5, 5),
        )
    ],
    foreground: Paint()..shader = textColor
  );
  
  



   return Container(
     color: uicolors[_UserInterface.background],
               child: Card(
                 elevation: 5,
              child:
                DefaultTextStyle(
               style: defaultStyle,
               child: SlideTransition(
                 position: _offsetAnimation,
                 child: Stack( 
                 alignment: Alignment.center,
                 children: <Widget>[
                 Positioned(left: 50, top: 50, child: Text(hours),),
                 Positioned(bottom: 62 ,child: Text(':'),),
                 Positioned(right: 50, top: 50, child: Text(minutes))
                 ],),
               ),
         ),
              ),
   );

  }
 }
