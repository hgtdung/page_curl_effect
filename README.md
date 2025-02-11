# Page Curl Effect
Package simulate 3D page curl effect by 2D effect.

![ezgif.com-optimize.gif](..%2F..%2F..%2FDesktop%2Fezgif.com-optimize.gif)

## Usage
### Case 1: Binding list of widget
```dart

class PageCurlEffectExample extends StatefulWidget {
  @override
  State<PageCurlEffectExample> createState() => _PageCurlEffectExampleState();
}

class _PageCurlEffectExampleState extends State<PageCurlEffectExample> {
    
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
      ),
    );
  }
}
```

### Case 2: Using page builder to create list of page
```dart

class PageCurlEffectExample extends StatefulWidget {
  @override
  State<PageCurlEffectExample> createState() => _PageCurlEffectExampleState();
}

class _PageCurlEffectExampleState extends State<PageCurlEffectExample> {
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
    return SafeArea(
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
      ),
    );
  }
}
```
 