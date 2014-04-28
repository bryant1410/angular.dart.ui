// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.pagination;

import 'dart:html' as dom;

import 'package:angular/angular.dart';
import "package:angular/core_dom/module_internal.dart";
import "package:angular/core/parser/syntax.dart";

import "package:angular_ui/utils/utils.dart";

class PaginationModule extends Module {

  PaginationModule() {
    value(PagerConfig, new PagerConfig(itemsPerPage:10, previousText: '« Previous', nextText:'Next »', align: true));
    type(PagerComponent);
  }
}


class PagerConfig {
  int itemsPerPage;
  String previousText;
  String nextText;
  bool align;

  PagerConfig({this.itemsPerPage, this.previousText, this.nextText, this.align});
}

@Component(
    selector: 'pager[ng-model]',
    templateUrl: 'packages/angular_ui/pagination/pager.html',
    publishAs: 'ctrl',
    applyAuthorStyles: true,
    map: const {
    'total-items' : '@totalItems',
    'items-per-page': '@itemsPerPage',
    'num-pages': '&setNumPages',
    'on-select-page': '&onSelectChange'
})

class PagerComponent implements AttachAware, DetachAware {
  final NgModel ngModel;
  final Scope scope;

  BoundExpression _setNumPages;

  set setNumPages(value) {
    _setNumPages = value;

    if(_setNumPages != null && _setNumPages.expression.isAssignable) {
      _setNumPages.assign(_totalPages);
    }
  }

  BoundExpression onSelectChange;

  Watch _totalItemsWatch;
  Watch _itemsPerPageWatch;

  int _currentPage = 0;
  int _totalItems = 0;
  int _itemsPerPage;

  int _totalPages;

  PagerComponent(this.ngModel, this.scope) {
    ngModel.render = _render;
  }

  set totalItems(String value) {
    _totalItemsWatch = scope.parentScope.watch(value, (newValue, previousValue) {
      _totalItems = newValue;
      _calculatePages();
    });
  }

  set itemsPerPage(String value) {
    if (value == null) {
      return;
    }
    _itemsPerPageWatch = scope.parentScope.watch(value, (newValue, previousValue) {
      _itemsPerPage = newValue;
      _calculatePages();
    });
  }

  int get totalPages => _totalPages;

  int get currentPage => _currentPage;

  void attach() {
    _itemsPerPage = 10;
    _calculatePages();
  }

  void detach() {
    if (_totalItemsWatch != null)_totalItemsWatch.remove();
    if (_itemsPerPageWatch != null)_itemsPerPageWatch.remove();
  }

  void selectPage(int selectedPage) {
    if (_currentPage != selectedPage && selectedPage > 0 && selectedPage <= totalPages) {
      _currentPage = selectedPage;
      scope.apply(() => ngModel.viewValue = selectedPage);
      onSelectChange(null);
    }
  }

  void _calculatePages() {
    _totalPages = (_totalItems / _itemsPerPage).ceil();
    if(_setNumPages != null && _setNumPages.expression.isAssignable) {
      _setNumPages.assign(_totalPages);
    }

    if (_currentPage > _totalPages) {
      _currentPage = _totalPages;
      ngModel.viewValue = _currentPage;
    }
  }


  void _render(value) {
    int intValue = toInt(value);
    if (intValue != _currentPage) {
      _currentPage = intValue;
    }
  }

}