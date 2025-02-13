import 'package:flutter/material.dart';
import 'package:page_curl_effect/page_curl_effect.dart';

class PageBuilderScreen extends StatefulWidget {
  const PageBuilderScreen({super.key});
  @override
  State<PageBuilderScreen> createState() => _PageBuilderScreenState();
}

class _PageBuilderScreenState extends State<PageBuilderScreen> {
  late PageCurlController _pageCurlController;
  late Size _pageSize;

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

    _pageCurlController =
        PageCurlController(Size(_pageSize.width, _pageSize.height),
            pageCurlIndex: 1,

            /// A number of pages
            numberOfPage: 5);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page builder"),
      ),
      body: SafeArea(
        child: PageCurlEffect(
          pageCurlController: _pageCurlController,
          pageBuilder: (context, index) {
            return Container(
              alignment: Alignment.center,
              color: const Color(0xffF5DEB3),
              width: _pageSize.width,
              height: _pageSize.height,
              child: Text("Page $index"),
            );
          },
          onForwardComplete: () {},
          onBackwardComplete: () {},
          // pages: buildPages(),
        ),
      ),
    );
  }
}
