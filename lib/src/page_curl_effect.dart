import 'package:flutter/material.dart';
import 'package:page_curl_effect/src/constants.dart';
import 'package:page_curl_effect/src/state_management/page_curl_controller.dart';
import 'package:page_curl_effect/src/widget/clip_shadow_path.dart';
import 'package:page_curl_effect/src/widget/page_curl_clipper.dart';
import 'package:page_curl_effect/src/widget/page_curl_painter.dart';
import 'package:provider/provider.dart';


class PageCurlEffect extends StatefulWidget {
  const PageCurlEffect(
      {super.key,
        required this.pageCurlController,
        this.pages,
        this.pageBuilder,
        this.onForwardComplete,
        this.onBackwardComplete});

  /// The controller control page curl effect
  final PageCurlController pageCurlController;

  /// The page that PageCurlEffect is applied
  final List<Widget>? pages;

  /// The page builder for creating a number of pages
  /// Only [pages] or [pageBuilder] can be used
  final Widget Function(BuildContext, int)? pageBuilder;

  /// The callback is call after the page curl animation move forward
  final VoidCallback? onForwardComplete;

  /// The callback is call after the page curl animation move backward
  final VoidCallback? onBackwardComplete;

  @override
  State<PageCurlEffect> createState() => _PageCurlEffectState();
}

class _PageCurlEffectState extends State<PageCurlEffect>
    with SingleTickerProviderStateMixin {
  PageCurlController get pageCurlCtrl => widget.pageCurlController;
  late final AnimationController _animationController;

  @override
  void initState() {
    assert(
    (widget.pages != null && widget.pageBuilder == null ||
        widget.pages == null && widget.pageBuilder != null),
    "[Only set one of [pages] or [pageBuilder]");

    _animationController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: pageCurlCtrl,
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: GestureDetector(
          onPanUpdate: (dragUpdateDetails) {
            pageCurlCtrl.onPanUpdate(dragUpdateDetails);
          },
          onPanStart: (dragStartDetails) {
            pageCurlCtrl.onPanStart(dragStartDetails);
          },
          onPanEnd: (dragEndDetails) {
            if (pageCurlCtrl.startPoint != null &&
                pageCurlCtrl.startPoint!.x > PCConstants.turnPageBarrier &&
                !pageCurlCtrl.isLastPage()) {
              var forwardAnimation = Tween(
                  begin: pageCurlCtrl.touchPoint!.x,
                  end: -(MediaQuery.of(context).size.width))
                  .animate(_animationController);

              /// Keep turning the page from the touch point to the end
              var lastTouchPoint = pageCurlCtrl.touchPoint;
              forwardAnimationListener() {
                pageCurlCtrl.onAutoPanUpdate(
                    Offset(forwardAnimation.value, lastTouchPoint!.y));
              }

              forwardAnimation.addListener(forwardAnimationListener);

              /// Reset pageCurlCtrl after completing animation
              statusListener1(status) {
                if (status == AnimationStatus.completed) {
                  pageCurlCtrl.reset();
                  pageCurlCtrl.onForwardComplete();
                  widget.onForwardComplete?.call();
                  forwardAnimation.removeListener(forwardAnimationListener);
                  _animationController.removeStatusListener(statusListener1);
                }
              }

              _animationController.value = 0;
              _animationController.addStatusListener(statusListener1);
              _animationController.forward();
            } else if (pageCurlCtrl.startPoint != null &&
                pageCurlCtrl.startPoint!.x <= PCConstants.turnPageBarrier &&
                !pageCurlCtrl.isFirstPage()) {
              var backwardAnimation = Tween(
                  begin: pageCurlCtrl.touchPoint!.x,
                  end: (MediaQuery.of(context).size.width))
                  .animate(_animationController);

              /// /// Keep turning the page from the touch point to the end
              var lastTouchPoint = pageCurlCtrl.touchPoint;
              backwardAnimationListener() {
                pageCurlCtrl.onAutoPanUpdate(
                    Offset(backwardAnimation.value, lastTouchPoint!.y));
              }

              statusListener2(status) {
                if (status == AnimationStatus.completed) {
                  pageCurlCtrl.reset();
                  pageCurlCtrl.onBackwardComplete();
                  widget.onBackwardComplete?.call();
                  backwardAnimation.removeListener(backwardAnimationListener);
                  _animationController.removeStatusListener(statusListener2);
                }
              }

              backwardAnimation.addListener(backwardAnimationListener);
              _animationController.value = 0;
              _animationController.addStatusListener(statusListener2);
              _animationController.forward();
            } else {
              /// startPoint is not touched from the edge
              pageCurlCtrl.onPanEnd(dragEndDetails);
            }
            pageCurlCtrl.isEdgeDragging = false;
          },
          child: Consumer<PageCurlController>(
            builder: (context, pageCurlCtlr, child) {
              final nextPageIndex = pageCurlCtlr.getNextPageIndex();
              final previousPageIndex = pageCurlCtlr.getPreviousPageIndex();
              final currentPageIndex = pageCurlCtlr.pageCurlIndex;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  /// Using page list
                  if (widget.pages != null && nextPageIndex != null)
                    widget.pages![nextPageIndex],
                  if (widget.pages != null &&
                      pageCurlCtlr.startPoint != null &&
                      pageCurlCtlr.startPoint!.x <
                          PCConstants.turnPageBarrier)
                    widget.pages![currentPageIndex],

                  /// Using page builder
                  if (widget.pageBuilder != null && nextPageIndex != null)
                    widget.pageBuilder!(context, nextPageIndex),
                  if (widget.pageBuilder != null &&
                      pageCurlCtlr.startPoint != null &&
                      pageCurlCtlr.startPoint!.x <
                          PCConstants.turnPageBarrier)
                    widget.pageBuilder!(context, currentPageIndex),
                  AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return ClipShadowPath(
                          shadow: const BoxShadow(
                              color: Colors.black45,
                              offset: Offset(8, 8),
                              blurRadius: 7,
                              spreadRadius: 8),
                          clipper: PageCurlClipper(
                              nullableCylinder: pageCurlCtlr.cylinder,
                              nullableHorizontalPageCurve:
                              pageCurlCtlr.horizontalPageCurve,
                              nullableMiddlePageCurve:
                              pageCurlCtlr.middlePageCurve),
                          child: SizedBox(
                            height: pageCurlCtlr.paperSize.height,
                            width: pageCurlCtlr.paperSize.width,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                /// Using pages
                                if (widget.pages != null)
                                  widget.pages![currentPageIndex],
                                if (widget.pages != null &&
                                    pageCurlCtlr.startPoint != null &&
                                    pageCurlCtlr.startPoint!.x <
                                        PCConstants.turnPageBarrier &&
                                    previousPageIndex != null)
                                  if (widget.pages != null)
                                    widget.pages![previousPageIndex],

                                /// Using page builder
                                if (widget.pageBuilder != null)
                                  widget.pageBuilder!(
                                      context, currentPageIndex),
                                if (widget.pageBuilder != null &&
                                    pageCurlCtlr.startPoint != null &&
                                    pageCurlCtlr.startPoint!.x <
                                        PCConstants.turnPageBarrier &&
                                    previousPageIndex != null)
                                  if (widget.pageBuilder != null)
                                    widget.pageBuilder!(
                                        context, previousPageIndex),
                                if (pageCurlCtrl.startPoint != null)
                                  CustomPaint(
                                    painter: PageCurlPainter(
                                        nullableCylinder: pageCurlCtlr.cylinder,
                                        nullableHorizontalPageCurve:
                                        pageCurlCtlr.horizontalPageCurve,
                                        nullableMiddlePageCurve:
                                        pageCurlCtlr.middlePageCurve),
                                    child: SizedBox.expand(),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
