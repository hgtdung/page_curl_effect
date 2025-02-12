import 'package:flutter/material.dart';
import 'package:page_curl_effect/page_curl_effect.dart';

class ListPageWidgetScreen extends StatefulWidget {
  const ListPageWidgetScreen({super.key});
  @override
  State<ListPageWidgetScreen> createState() => _ListPageWidgetScreenState();
}

class _ListPageWidgetScreenState extends State<ListPageWidgetScreen> {
  late PageCurlController _pageCurlController;
  late Size _pageSize;
  late final List<Widget> _listPage;

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
        pageCurlIndex: 0,
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
    return Scaffold(
      appBar: AppBar(title: const Text("List page"),),
      body: SafeArea(
        child: PageCurlEffect(
          pageCurlController: _pageCurlController,
          pages: _listPage,
          onForwardComplete: () { },
          onBackwardComplete: () { },
          // pages: buildPages(),
        ),
      ),
    );
  }
}