//packages/flutter_suika_game/lib/presenter/world_presenter.dart
import 'package:flame/components.dart';

class WorldPresenter {
  WorldPresenter(this.world);
  final World world;

  void add(Component component) {
    world.add(component);
  }

  void remove(Component component) {
    world.remove(component);
  }

  void update(double dt) {
    world.update(dt);
  }

  List<Component> getComponents() {
    return world.children.toList();
  }

  void clear() {
    final components = getComponents();
    world.removeAll(components);
  }
}
