import 'package:flutter/material.dart';

/// A generic draggable wrapper that carries its own GlobalKey in the payload so onboarding can reference it.
class ObDraggable<T> extends StatelessWidget {
  final GlobalKey keyRef;
  final T data;
  final Widget child;
  final Widget feedback;
  final Widget? childWhenDragging;
  final bool enabled;

  const ObDraggable({
    super.key,
    required this.keyRef,
    required this.data,
    required this.child,
    required this.feedback,
    this.childWhenDragging,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final wrappedChild = KeyedSubtree(key: keyRef, child: child);

    if (!enabled) return Opacity(opacity: 0.4, child: wrappedChild);

    return Draggable<_Payload<T>>(
      data: _Payload<T>(data: data, keyRef: keyRef),
      child: wrappedChild,
      childWhenDragging:
          childWhenDragging ?? Opacity(opacity: 0.2, child: wrappedChild),
      feedback: feedback,
    );
  }
}

/// A generic drag target wrapper with a GlobalKey to be used as destination by onboarding.
class ObDragTarget<T> extends StatelessWidget {
  final GlobalKey keyRef;
  final bool Function(T data)? canAccept;
  final void Function(T data)? onAccept;
  final Widget Function(
      BuildContext context, List<T> candidates, Widget? rejected)? builder;

  const ObDragTarget({
    super.key,
    required this.keyRef,
    this.canAccept,
    this.onAccept,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<_Payload<T>>(
      onWillAccept: (p) {
        final payload = p; // local to help promotion across SDKs
        if (payload == null) return false;
        final acceptFn = canAccept;
        if (acceptFn == null) return true;
        return acceptFn(payload.data);
      },
      onAcceptWithDetails: (details) {
        final payload = details.data; // non-null
        final acceptCb = onAccept;
        if (acceptCb != null) acceptCb(payload.data);
      },
      builder: (context, cands, rej) {
        final typed = <T>[];
        for (final item in cands) {
          final payload = item;
          if (payload != null) typed.add(payload.data);
        }
        return KeyedSubtree(
          key: keyRef,
          child: builder?.call(context, typed, null) ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _Payload<T> {
  final T data;
  final GlobalKey keyRef;
  _Payload({required this.data, required this.keyRef});
}
