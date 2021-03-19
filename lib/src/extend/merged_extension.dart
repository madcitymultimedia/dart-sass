// Copyright 2019 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import '../exception.dart';
import '../utils.dart';
import 'extender.dart';
import 'extension.dart';

/// An [Extension] created by merging two [Extension]s with the same extender
/// and target.
///
/// This is used when multiple mandatory extensions exist to ensure that both of
/// them are marked as resolved.
class MergedExtension extends Extension {
  /// One of the merged extensions.
  final Extension left;

  /// The other merged extension.
  final Extension right;

  /// Returns an extension that combines [left] and [right].
  ///
  /// Throws a [SassException] if [left] and [right] have incompatible media
  /// contexts.
  ///
  /// Throws an [ArgumentError] if [left] and [right] don't have the same
  /// extender and target.
  static Extension merge(Extension left, Extension right) {
    if (left.extender.selector != right.extender.selector ||
        left.target != right.target) {
      throw ArgumentError("$left and $right aren't the same extension.");
    }

    if (left.extender.mediaContext != null &&
        right.extender.mediaContext != null &&
        !listEquals(left.extender.mediaContext, right.extender.mediaContext)) {
      throw SassException(
          "From ${left.span.message('')}\n"
          "You may not @extend the same selector from within different media "
          "queries.",
          right.span);
    }

    // If one extension is optional and doesn't add a special media context, it
    // doesn't need to be merged.
    if (right.isOptional && right.extender.mediaContext == null) return left;
    if (left.isOptional && left.extender.mediaContext == null) return right;

    return MergedExtension._(left, right);
  }

  MergedExtension._(this.left, this.right)
      : super(
            Extender(left.extender.selector, left.extender.span,
                mediaContext:
                    left.extender.mediaContext ?? right.extender.mediaContext,
                specificity: left.extender.specificity,
                original:
                    left.extender.isOriginal && right.extender.isOriginal),
            left.target,
            left.span,
            optional: true);

  /// Returns all leaf-node [Extension]s in the tree of [MergedExtension]s.
  Iterable<Extension> unmerge() sync* {
    var left = this.left;
    if (left is MergedExtension) {
      yield* left.unmerge();
    } else {
      yield left;
    }

    var right = this.right;
    if (right is MergedExtension) {
      yield* right.unmerge();
    } else {
      yield right;
    }
  }
}
