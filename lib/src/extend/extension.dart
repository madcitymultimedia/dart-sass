// Copyright 2016 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:source_span/source_span.dart';

import '../ast/selector.dart';
import 'extender.dart';

/// The state of an extension for a given extender.
///
/// The target of the extension is represented externally, in the map that
/// contains this extender.
class Extension {
  /// The extender (such as `A` in `A {@extend B}`).
  final Extender extender;

  /// The selector that's being extended.
  final SimpleSelector target;

  /// Whether this extension is optional.
  final bool isOptional;

  /// The span for an `@extend` rule that defined this extension.
  ///
  /// If any extend rule for this is extension is mandatory, this is guaranteed
  /// to be a span for a mandatory rule.
  final FileSpan span;

  /// Creates a new extension.
  ///
  /// If [specificity] isn't passed, it defaults to `extender.maxSpecificity`.
  Extension(this.extender, this.target, this.span, {bool optional = false})
      : isOptional = optional;

  Extension withExtender(ComplexSelector newExtender) =>
      Extension(extender.withSelector(newExtender), target, span,
          optional: isOptional);

  String toString() =>
      "$extender {@extend $target${isOptional ? ' !optional' : ''}}";
}
