import 'package:flutter/material.dart';

class TechnicalScreen extends StatelessWidget {
  const TechnicalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, index, onDragStarted, onDragCompleted) {
              return Draggable<int>(
                data: index,
                onDragStarted: onDragStarted,
                onDragCompleted: onDragCompleted,
                feedback: Transform.scale(
                  scale: 1.2,
                  child: _buildIconContainer(
                    icon,
                    Colors.primaries[icon.hashCode % Colors.primaries.length],
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.4,
                  child: _buildIconContainer(
                    icon,
                    Colors.primaries[icon.hashCode % Colors.primaries.length]
                        .withOpacity(0.5),
                  ),
                ),
                child: _buildIconContainer(
                  icon,
                  Colors.primaries[icon.hashCode % Colors.primaries.length],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color,
      ),
      child: Center(
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T, int, VoidCallback, VoidCallback) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAccept: (data) => data != null,
      onAcceptWithDetails: (details) {
        final oldIndex = details.data!;
        final newIndex = _findNewIndex(details.offset);

        if (oldIndex != newIndex) {
          setState(() {
            final item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black12,
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_items.length, (index) {
              return widget.builder(
                _items[index],
                index,
                () {},
                () {},
              );
            }),
          ),
        );
      },
    );
  }

  int _findNewIndex(Offset dragOffset) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(dragOffset);
    final itemWidth = renderBox.size.width / _items.length;
    return (localPosition.dx / itemWidth).clamp(0, _items.length - 1).toInt();
  }
}
