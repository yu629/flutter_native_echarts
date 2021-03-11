library flutter_native_echart;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'echart_js.dart' show echartJS;
import 'echarts_script.dart' show echartsScript;

const htmlBase64 =
    'data:text/html;base64,PCFET0NUWVBFIGh0bWw+PGh0bWw+PGhlYWQ+PG1ldGEgY2hhcnNldD0idXRmLTgiPjxtZXRhIG5hbWU9InZpZXdwb3J0IiBjb250ZW50PSJ3aWR0aD1kZXZpY2Utd2lkdGgsIGluaXRpYWwtc2NhbGU9MS4wLCBtYXhpbXVtLXNjYWxlPTEuMCwgbWluaW11bS1zY2FsZT0xLjAsIHVzZXItc2NhbGFibGU9MCwgdGFyZ2V0LWRlbnNpdHlkcGk9ZGV2aWNlLWRwaSIgLz48c3R5bGUgdHlwZT0idGV4dC9jc3MiPmJvZHksaHRtbCwjY2hhcnR7aGVpZ2h0OiAxMDAlO3dpZHRoOiAxMDAlO21hcmdpbjogMHB4O31kaXYgey13ZWJraXQtdGFwLWhpZ2hsaWdodC1jb2xvcjpyZ2JhKDI1NSwyNTUsMjU1LDApO308L3N0eWxlPjwvaGVhZD48Ym9keT48ZGl2IGlkPSJjaGFydCIgLz48L2JvZHk+PC9odG1sPg==';

class ECharts extends StatefulWidget {
  ECharts({Key key, @required this.option}) : super(key: key);

  final String option;

  @override
  _EChartsState createState() => _EChartsState();
}

class _EChartsState extends State<ECharts> {
  WebViewController _controller;
  String _currentOption;

  @override
  void initState() {
    super.initState();
    _currentOption = widget.option;
  }

  void update(String preOption) async {
    _currentOption = widget.option;
    if (_currentOption != preOption) {
      await _controller?.evaluateJavascript('''
        try {
          chart.setOption($_currentOption, true);
        } catch(e) {
        }
      ''');
    }
  }

  @override
  void didUpdateWidget(ECharts oldWidget) {
    super.didUpdateWidget(oldWidget);
    update(oldWidget.option);
  }

  void init() async {
    final extensionsStr = '';
    final themeStr = 'null';
    await _controller?.evaluateJavascript('''
      $echartJS
      $echartsScript
      var chart = echarts.init(document.getElementById('chart'), $themeStr);
      ${''}
      chart.setOption(${this.widget.option}, true);
    ''');
    // if (widget.onLoad != null) {
    //   widget.onLoad();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: htmlBase64,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller = webViewController;
      },
      onPageFinished: (String url) {
        init();
      },
      javascriptChannels: <JavascriptChannel>[
        JavascriptChannel(
            name: 'Messager',
            onMessageReceived: (JavascriptMessage javascriptMessage) {
              // widget?.onMessage(javascriptMessage.message);
            }),
      ].toSet(),
    );
  }
}
