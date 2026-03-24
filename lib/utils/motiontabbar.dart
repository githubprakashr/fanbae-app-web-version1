import 'package:flutter/material.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

typedef MotionTabBuilder = Widget Function();

class MotionTabBar extends StatefulWidget {
  final Color? tabIconColor,
      tabIconSelectedColor,
      tabSelectedColor,
      tabBarColor;
  final LinearGradient? selectedTabColor;
  final double? tabIconSize, tabIconSelectedSize, tabBarHeight, tabSize;
  final TextStyle? textStyle;
  final Function? onTabItemSelected;
  final String initialSelectedTab;

  final List<String?> labels;
  final List<String>? icons;
  final bool useSafeArea;
  final MotionTabBarController? controller;

  // badge
  final List<Widget?>? badges;

  MotionTabBar({
    this.textStyle,
    this.tabIconColor = Colors.black,
    this.tabIconSize = 24,
    this.tabIconSelectedColor = Colors.white,
    this.selectedTabColor,
    this.tabIconSelectedSize = 24,
    this.tabSelectedColor = Colors.black,
    this.tabBarColor = Colors.white,
    this.tabBarHeight = 65,
    this.tabSize = 60,
    this.onTabItemSelected,
    required this.initialSelectedTab,
    required this.labels,
    this.icons,
    this.useSafeArea = true,
    this.badges,
    this.controller,
  })  : assert(labels.contains(initialSelectedTab)),
        assert(icons != null && icons.length == labels.length),
        assert((badges != null && badges.length > 0)
            ? badges.length == labels.length
            : true);

  @override
  _MotionTabBarState createState() => _MotionTabBarState();
}

class _MotionTabBarState extends State<MotionTabBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Tween<double> _positionTween;
  late Animation<double> _positionAnimation;

  late AnimationController _fadeOutController;
  late Animation<double> _fadeFabOutAnimation;
  late Animation<double> _fadeFabInAnimation;

  late List<String?> labels;
  late Map<String?, String> icons;

  get tabAmount => icons.keys.length;
  get index => labels.indexOf(selectedTab);

  double fabIconAlpha = 1;
  String? activeIcon;
  String? selectedTab;

  bool isRtl = false;
  List<Widget>? badges;
  Widget? activeBadge;

  double getPosition(bool isRTL) {
    double pace = 2 / (labels.length - 1);
    double position = (pace * index) - 1;

    if (isRTL) {
      // If RTL, reverse the position calculation
      position = 1 - (pace * index);
    }

    return position;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isRtl = Directionality.of(context).index == 0;
    });

    if (widget.controller != null) {
      widget.controller!.onTabChange = (index) {
        setState(() {
          activeIcon = widget.icons![index];
          selectedTab = widget.labels[index];
        });
        _initAnimationAndStart(_positionAnimation.value, getPosition(isRtl));
      };
    }
    labels = widget.labels;
    icons = Map.fromIterable(
      labels,
      key: (label) => label,
      value: (label) => widget.icons![labels.indexOf(label)],
    );

    selectedTab = widget.initialSelectedTab;
    activeIcon = icons[selectedTab];

    // init badge text
    int selectedIndex =
        labels.indexWhere((element) => element == widget.initialSelectedTab);
    activeBadge = (widget.badges != null && widget.badges!.length > 0)
        ? widget.badges![selectedIndex]
        : null;

    _animationController = AnimationController(
      duration: Duration(milliseconds: ANIM_DURATION),
      vsync: this,
    );

    _fadeOutController = AnimationController(
      duration: Duration(milliseconds: (ANIM_DURATION ~/ 5)),
      vsync: this,
    );

    _positionTween = Tween<double>(begin: getPosition(isRtl), end: 1);

    _positionAnimation = _positionTween.animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });

    _fadeFabOutAnimation = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {
          fabIconAlpha = _fadeFabOutAnimation.value;
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            activeIcon = icons[selectedTab];
            int selectedIndex =
                labels.indexWhere((element) => element == selectedTab);
            activeBadge = (widget.badges != null && widget.badges!.length > 0)
                ? widget.badges![selectedIndex]
                : null;
          });
        }
      });

    _fadeFabInAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.8, 1, curve: Curves.easeOut)))
      ..addListener(() {
        setState(() {
          fabIconAlpha = _fadeFabInAnimation.value;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.tabBarColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        bottom: widget.useSafeArea,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              height: widget.tabBarHeight,
              decoration: BoxDecoration(
                color: widget.tabBarColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: generateTabItems(),
              ),
            ),
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(color: Colors.transparent),
                child: Align(
                  heightFactor: 0,
                  alignment: Alignment(_positionAnimation.value, 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / tabAmount,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: widget.tabSize!,
                          width: widget.tabSize!,
                          child: ClipRect(
                            clipper: HalfClipper(),
                            child: Container(
                              child: Center(
                                child: Container(
                                  width: widget.tabSize!,
                                  height: widget.tabSize!,
                                  decoration: BoxDecoration(
                                    color: widget.tabBarColor,
                                    borderRadius: BorderRadius.circular(80),
                                    //   shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: widget.tabSize! + 15,
                          width: widget.tabSize! + 35,
                          child: CustomPaint(
                              painter: HalfPainter(color: widget.tabBarColor)),
                        ),
                        SizedBox(
                          height: widget.tabSize,
                          width: widget.tabSize,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: widget.selectedTabColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Opacity(
                                opacity: fabIconAlpha,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    MyImage(
                                      imagePath: activeIcon!,
                                      color: widget.tabIconSelectedColor,
                                      width: widget.tabIconSelectedSize!,
                                      height: widget.tabIconSelectedSize!,
                                    ),
                                    activeBadge != null
                                        ? Positioned(
                                            top: 0,
                                            right: 0,
                                            child: activeBadge!,
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> generateTabItems() {
    bool isRtl = Directionality.of(context).index == 0;
    return labels.map((tabLabel) {
      String? icon = icons[tabLabel];

      int selectedIndex = labels.indexWhere((element) => element == tabLabel);
      Widget? badge = (widget.badges != null && widget.badges!.length > 0)
          ? widget.badges![selectedIndex]
          : null;

      return MotionTabItem(
        selected: selectedTab == tabLabel,
        iconData: icon,
        title: tabLabel,
        textStyle: widget.textStyle ?? TextStyle(color: Colors.black),
        tabIconColor: widget.tabIconColor ?? Colors.black,
        tabIconSize: widget.tabIconSize,
        badge: badge,
        callbackFunction: () {
          setState(() {
            activeIcon = icon;
            selectedTab = tabLabel;
            widget.onTabItemSelected!(index);
          });
          _initAnimationAndStart(_positionAnimation.value, getPosition(isRtl));
        },
      );
    }).toList();
  }

  _initAnimationAndStart(double from, double to) {
    _positionTween.begin = from;
    _positionTween.end = to;

    _animationController.reset();
    _fadeOutController.reset();
    _animationController.forward();
    _fadeOutController.forward();
  }
}

class HalfPainter extends CustomPainter {
  final Color? color;
  HalfPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double curveSize = 10;
    final double xStartingPos = 0;
    final double yStartingPos = (size.height / 2);
    final double yMaxPos = yStartingPos - curveSize;
    final path = Path();
    path.moveTo(xStartingPos, yStartingPos);
    path.lineTo(size.width - xStartingPos, yStartingPos);
    path.quadraticBezierTo(size.width - (curveSize), yStartingPos,
        size.width - (curveSize + 5), yMaxPos);
    path.lineTo(xStartingPos + (curveSize + 5), yMaxPos);
    path.quadraticBezierTo(
        xStartingPos + (curveSize), yStartingPos, xStartingPos, yStartingPos);
    path.close();
    canvas.drawPath(path, Paint()..color = color ?? Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width, size.height / 2);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}

class MotionTabBarController extends TabController {
  MotionTabBarController({
    int initialIndex = 0,
    Duration? animationDuration,
    required int length,
    required TickerProvider vsync,
  }) : super(
            initialIndex: initialIndex,
            animationDuration: animationDuration,
            length: length,
            vsync: vsync);

  // programmatic tab change
  set index(int index) {
    super.index = index;
    _changeIndex!(index);
  }

  // callback for tab change
  Function(int)? _changeIndex;
  set onTabChange(Function(int)? fx) {
    _changeIndex = fx;
  }
}

const double ICON_OFF = -3;
const double ICON_ON = 0;
const double TEXT_OFF = 3;
const double TEXT_ON = 1;
const double ALPHA_OFF = 0;
const double ALPHA_ON = 1;
const int ANIM_DURATION = 300;

class MotionTabItem extends StatefulWidget {
  final String? title;
  final bool selected;
  final String? iconData;
  final TextStyle textStyle;
  final Function callbackFunction;
  final Color tabIconColor;
  final double? tabIconSize;
  final Widget? badge;

  MotionTabItem({
    required this.title,
    required this.selected,
    required this.iconData,
    required this.textStyle,
    required this.tabIconColor,
    required this.callbackFunction,
    this.tabIconSize = 24,
    this.badge,
  });

  @override
  _MotionTabItemState createState() => _MotionTabItemState();
}

class _MotionTabItemState extends State<MotionTabItem> {
  double iconYAlign = ICON_ON;
  double textYAlign = TEXT_OFF;
  double iconAlpha = ALPHA_ON;

  @override
  void initState() {
    super.initState();
    _setIconTextAlpha();
  }

  @override
  void didUpdateWidget(MotionTabItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setIconTextAlpha();
  }

  _setIconTextAlpha() {
    setState(() {
      iconYAlign = (widget.selected) ? ICON_OFF : ICON_ON;
      textYAlign = (widget.selected) ? TEXT_ON : TEXT_OFF;
      iconAlpha = (widget.selected) ? ALPHA_OFF : ALPHA_ON;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
            child: AnimatedAlign(
              duration: Duration(milliseconds: ANIM_DURATION),
              alignment: Alignment(0, textYAlign),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Text(''),
              ),
            ),
          ),
          InkWell(
            onTap: () => widget.callbackFunction(),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: AnimatedAlign(
                duration: const Duration(milliseconds: ANIM_DURATION),
                curve: Curves.easeIn,
                alignment: Alignment(0, iconYAlign),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: ANIM_DURATION),
                  opacity: iconAlpha,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        padding: EdgeInsets.all(0),
                        alignment: Alignment(0, 0),
                        icon: MyImage(
                          imagePath: widget.iconData!,
                          color: widget.tabIconColor,
                          width: widget.tabIconSize!,
                          height: widget.tabIconSize!,
                        ),
                        onPressed: () => widget.callbackFunction(),
                      ),
                      widget.badge != null
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: widget.badge!,
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
