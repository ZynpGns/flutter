// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../foundation/leak_tracking.dart';

void main() {
  test('SearchViewThemeData copyWith, ==, hashCode basics', () {
    expect(const SearchViewThemeData(), const SearchViewThemeData().copyWith());
    expect(const SearchViewThemeData().hashCode, const SearchViewThemeData()
      .copyWith()
      .hashCode);
  });

  test('SearchViewThemeData lerp special cases', () {
    expect(SearchViewThemeData.lerp(null, null, 0), null);
    const SearchViewThemeData data = SearchViewThemeData();
    expect(identical(SearchViewThemeData.lerp(data, data, 0.5), data), true);
  });

  test('SearchViewThemeData defaults', () {
    const SearchViewThemeData themeData = SearchViewThemeData();
    expect(themeData.backgroundColor, null);
    expect(themeData.elevation, null);
    expect(themeData.surfaceTintColor, null);
    expect(themeData.constraints, null);
    expect(themeData.side, null);
    expect(themeData.shape, null);
    expect(themeData.headerTextStyle, null);
    expect(themeData.headerHintStyle, null);
    expect(themeData.dividerColor, null);

    const SearchViewTheme theme = SearchViewTheme(data: SearchViewThemeData(), child: SizedBox());
    expect(theme.data.backgroundColor, null);
    expect(theme.data.elevation, null);
    expect(theme.data.surfaceTintColor, null);
    expect(theme.data.constraints, null);
    expect(theme.data.side, null);
    expect(theme.data.shape, null);
    expect(theme.data.headerTextStyle, null);
    expect(theme.data.headerHintStyle, null);
    expect(theme.data.dividerColor, null);
  });

  testWidgetsWithLeakTracking('Default SearchViewThemeData debugFillProperties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const SearchViewThemeData().debugFillProperties(builder);

    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();

    expect(description, <String>[]);
  });

  testWidgetsWithLeakTracking('SearchViewThemeData implements debugFillProperties', (
      WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const SearchViewThemeData(
      backgroundColor: Color(0xfffffff1),
      elevation: 3.5,
      surfaceTintColor: Color(0xfffffff3),
      side: BorderSide(width: 2.5, color: Color(0xfffffff5)),
      shape: RoundedRectangleBorder(),
      headerTextStyle: TextStyle(fontSize: 24.0),
      headerHintStyle: TextStyle(fontSize: 16.0),
      constraints: BoxConstraints(minWidth: 350, minHeight: 240),
    ).debugFillProperties(builder);

    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();

    expect(description[0], 'backgroundColor: Color(0xfffffff1)');
    expect(description[1], 'elevation: 3.5');
    expect(description[2], 'surfaceTintColor: Color(0xfffffff3)');
    expect(description[3], 'side: BorderSide(color: Color(0xfffffff5), width: 2.5)');
    expect(description[4], 'shape: RoundedRectangleBorder(BorderSide(width: 0.0, style: none), BorderRadius.zero)');
    expect(description[5], 'headerTextStyle: TextStyle(inherit: true, size: 24.0)');
    expect(description[6], 'headerHintStyle: TextStyle(inherit: true, size: 16.0)');
    expect(description[7], 'constraints: BoxConstraints(350.0<=w<=Infinity, 240.0<=h<=Infinity)');
  });

  group('[Theme, SearchViewTheme, SearchView properties overrides]', () {
    const Color backgroundColor = Color(0xff000001);
    const double elevation = 5.0;
    const Color surfaceTintColor = Color(0xff000002);
    const BorderSide side = BorderSide(color: Color(0xff000003), width: 2.0);
    const OutlinedBorder shape = RoundedRectangleBorder(side: side, borderRadius: BorderRadius.all(Radius.circular(20.0)));
    const TextStyle headerTextStyle = TextStyle(color: Color(0xff000004), fontSize: 20.0);
    const TextStyle headerHintStyle = TextStyle(color: Color(0xff000005), fontSize: 18.0);
    const BoxConstraints constraints = BoxConstraints(minWidth: 250.0, maxWidth: 300.0, minHeight: 450.0);

    const SearchViewThemeData searchViewTheme = SearchViewThemeData(
      backgroundColor: backgroundColor,
      elevation: elevation,
      surfaceTintColor: surfaceTintColor,
      side: side,
      shape: shape,
      headerTextStyle: headerTextStyle,
      headerHintStyle: headerHintStyle,
      constraints: constraints,
    );

    Widget buildFrame({
      bool useSearchViewProperties = false,
      SearchViewThemeData? searchViewThemeData,
      SearchViewThemeData? overallTheme
    }) {
      final Widget child = Builder(
        builder: (BuildContext context) {
          if (!useSearchViewProperties) {
            return SearchAnchor(
              viewHintText: 'hint text',
              builder: (BuildContext context, SearchController controller) {
                return const Icon(Icons.search);
              },
              suggestionsBuilder: (BuildContext context, SearchController controller) {
                return <Widget>[];
              },
              isFullScreen: false,
            );
          }
          return SearchAnchor(
            viewHintText: 'hint text',
            builder: (BuildContext context, SearchController controller) {
              return const Icon(Icons.search);
            },
            suggestionsBuilder: (BuildContext context, SearchController controller) {
              return <Widget>[];
            },
            isFullScreen: false,
            viewElevation: elevation,
            viewBackgroundColor: backgroundColor,
            viewSurfaceTintColor: surfaceTintColor,
            viewSide: side,
            viewShape: shape,
            headerTextStyle: headerTextStyle,
            headerHintStyle: headerHintStyle,
            viewConstraints: constraints,
          );
        },
      );
      return MaterialApp(
        theme: ThemeData.from(
            colorScheme: const ColorScheme.light(), useMaterial3: true)
            .copyWith(
          searchViewTheme: overallTheme,
        ),
        home: Scaffold(
          body: Center(
            // If the SearchViewThemeData widget is present, it's used
            // instead of the Theme's ThemeData.searchViewTheme.
            child: searchViewThemeData == null ? child : SearchViewTheme(
              data: searchViewThemeData,
              child: child,
            ),
          ),
        ),
      );
    }

    Finder findViewContent() {
      return find.byWidgetPredicate((Widget widget) {
        return widget.runtimeType.toString() == '_ViewContent';
      });
    }

    Material getSearchViewMaterial(WidgetTester tester) {
      return tester.widget<Material>(find.descendant(of: findViewContent(), matching: find.byType(Material)).first);
    }

    Future<void> checkSearchView(WidgetTester tester) async {
      final Material material = getSearchViewMaterial(tester);
      expect(material.elevation, elevation);
      expect(material.color, backgroundColor);
      expect(material.surfaceTintColor, surfaceTintColor);
      expect(material.shape, shape);

      final SizedBox sizedBox = tester.widget<SizedBox>(find.descendant(of: findViewContent(), matching: find.byType(SizedBox)).first);
      expect(sizedBox.width, 250.0);
      expect(sizedBox.height, 450.0);

      final Text hintText = tester.widget(find.text('hint text'));
      expect(hintText.style?.color, headerHintStyle.color);
      expect(hintText.style?.fontSize, headerHintStyle.fontSize);

      await tester.enterText(find.byType(TextField), 'input');
      final EditableText inputText = tester.widget(find.text('input'));
      expect(inputText.style.color, headerTextStyle.color);
      expect(inputText.style.fontSize, headerTextStyle.fontSize);
    }

    testWidgets('SearchView properties overrides defaults', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(useSearchViewProperties: true));
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle(); // allow the animations to finish
      checkSearchView(tester);
    });

    testWidgets('SearchView theme data overrides defaults', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(searchViewThemeData: searchViewTheme));
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      checkSearchView(tester);
    });

    testWidgets('Overall Theme SearchView theme overrides defaults', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(overallTheme: searchViewTheme));
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      checkSearchView(tester);
    });

    // Same as the previous tests with empty SearchViewThemeData's instead of null.

    testWidgets('SearchView properties overrides defaults, empty theme and overall theme', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(useSearchViewProperties: true,
        searchViewThemeData: const SearchViewThemeData(),
        overallTheme: const SearchViewThemeData()));
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle(); // allow the animations to finish
      checkSearchView(tester);
    });

    testWidgets('SearchView theme overrides defaults and overall theme', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(searchViewThemeData: searchViewTheme,
          overallTheme: const SearchViewThemeData()));
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle(); // allow the animations to finish
      checkSearchView(tester);
    });

    testWidgets('Overall Theme SearchView theme overrides defaults and null theme', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(overallTheme: searchViewTheme));
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle(); // allow the animations to finish
      checkSearchView(tester);
    });
  });
}
