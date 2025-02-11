import 'package:flutter/material.dart';
import 'package:page_curl_effect/page_curl_effect.dart';

class PageCurlEffectExample1 extends StatefulWidget {
  const PageCurlEffectExample1({super.key});
  @override
  State<PageCurlEffectExample1> createState() => _PageCurlEffectExample1State();
}

class _PageCurlEffectExample1State extends State<PageCurlEffectExample1> {
  late PageCurlController _pageCurlController;
  late Size _pageSize;
  late final _listPage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _pageSize = Size(
      MediaQuery.of(context).size.width,
      600,
    );

    _listPage = buildPages(_pageSize);

    _pageCurlController = PageCurlController(
        Size(_pageSize.width, _pageSize.height),
        pageCurlIndex: 1,
        numberOfPage: _listPage.length);

    super.didChangeDependencies();
  }

  List<Widget> buildPages(Size paperSize) {
    return [
      Container(
        alignment: Alignment.center,
        color: const Color(0xffF5DEB3),
        width: paperSize.width,
        height: paperSize.height,
        child: const Text("Page 1"),
      ),
      Container(
        alignment: Alignment.center,
        color: Colors.white,
        width: paperSize.width,
        height: paperSize.height,
        child: const Text("Page 2"),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageCurlEffect(
        pageCurlController: _pageCurlController,
        pages: _listPage,
        onForwardComplete: () { },
        onBackwardComplete: () { },
        // pages: buildPages(),
      ),
    );
  }
}