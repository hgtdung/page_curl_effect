# Cookbook

All the snippets are from the [example project](https://github.com/hgtdung/page_curl_effect/tree/main/example).

## Simple Usage
```dart
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
```

## Using pageBuilder to create list of pages

```dart

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

    _pageCurlController = PageCurlController(
        Size(_pageSize.width, _pageSize.height),
        pageCurlIndex: 1,
        /// A number of pages
        numberOfPage: 5);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page builder"),),
      body: SafeArea(
        child: PageCurlEffect(
          pageCurlController: _pageCurlController,
          pageBuilder: (context, index) {
            return  Container(
              alignment: Alignment.center,
              color: const Color(0xffF5DEB3),
              width: _pageSize.width,
              height: _pageSize.height,
              child: Text("Page $index"),
            );
          },
          onForwardComplete: () { },
          onBackwardComplete: () { },
          // pages: buildPages(),
        ),
      ),
    );
  }
}
```
