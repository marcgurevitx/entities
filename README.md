# Entities

**Entities** is a library for the [MiniScript](https://miniscript.org/) language that implements [Entity component system](https://en.wikipedia.org/wiki/Entity_component_system) pattern.

Entities are mere IDs (`eid`).

Systems are any object that has an `.update(dt, component, world)` method.

Components are a map with a `._name` property. Also it should implement a `.set(property, value)` method which is only invoked once using arguments `"eid", eid` when the component is assigned to an entity. It might be as simple as `Comp.set = function(_, eid); self.eid = eid; end function`, or you could subclass your component from `entities.Class` and get it for free (in this case each component should also set `self._inited` to `true`).

Component instances and systems are stored inside an `entities.World` object.

## API

* `World .init` -- Initializes and returns a world.
* `World .createEntity` -- Returns ID (`eid`) of a new entity inside the world.
* `World .setComponent(eid, component)` -- Assigns a component to an entity.
* `World .getComponent(eid, componentClass, default=null)` -- Returns a component assigned to an entity. The `componentClass` argument may be either a map with the `._name` property or a string with a component name. If there's no component of the given class, the `default` argument is returned.
* `World .getComponents(eid)` -- Returns a map of all components assigned to an entity.
* `World .removeComponent(eid, componentClass)` -- Removes a component of a given class from an entity. No-op if there's no such component.
* `World .iterComponents(componentClass, callback)` -- Invokes the `callback` argument on each component of a given class.
* `World .addSystem(system, componentClass)` -- Installs a system inside the world. On each world's update its `.update(dt, component, world)` method is invoked for all components of the given class.
* `World .update(dt=null)` -- Executes one frame of the world.

## Example

```c
import "entities"

world = (new entities.World).init

Mob = {}
Mob._name = "Mob"
Mob.eid = null
Mob.x = null
Mob.y = null
Mob.set = function(_, eid)
	self.eid = eid
end function
Mob.init = function(x, y)
	self.x = x
	self.y = y
	return self
end function

catID = world.createEntity
world.setComponent catID, (new Mob).init(42, 43)

dogID = world.createEntity
world.setComponent dogID, (new Mob).init(44, 45)

print world.getComponent(catID, Mob).x  // prints 42

SysMoveMobs = {}
SysMoveMobs.update = function(dt, comp, world)
	comp.x += 1
end function

world.addSystem SysMoveMobs, Mob

world.update

print world.getComponent(catID, Mob).x  // prints 43

```
