ensureImport "qa"
ensureImport "entities"


enhanceStringsEqualityCheck qa


testBasic = function
	world = (new entities.World).init
	
	Mob = {}  // object on a map with health
	Mob._name = "Mob"
	Mob.eid = null
	Mob.x = null
	Mob.y = null
	Mob.health = null
	Mob.set = function(_, eid)
		self.eid = eid
	end function
	Mob.init = function(x, y, health)
		self.x = x
		self.y = y
		self.health = health
		return self
	end function
	
	Container = {}  // object containing items
	Container._name = "Container"
	Container.eid = null
	Container.items = []
	Container.set = function(_, eid)
		self.eid = eid
	end function
	Container.init = function(items)
		self.items = items
		return self
	end function
	
	SysMove = {}  // all mobs move
	SysMove._name = "SysMove"
	SysMove.update = function(dt, c, w)
		c.x += 10
		c.y -= 10
	end function
	world.addSystem SysMove, Mob
	
	SysHeal = {}  // all mobs restore health
	SysHeal._name = "SysHeal"
	SysHeal.update = function(dt, c, w)
		c.health += 1
	end function
	world.addSystem SysHeal, Mob
	
	SysAddApple = {}  // an apple is added to every container
	SysAddApple._name = "SysAddApple"
	SysAddApple.update = function(dt, c, w)
		c.items.push "apple"
	end function
	world.addSystem SysAddApple, Container
	
	catID = world.createEntity
	world.setComponent catID, (new Mob).init(0, 0, 9000)
	
	crateID = world.createEntity
	world.setComponent crateID, (new Container).init(["potion"])
	
	soldierID = world.createEntity
	world.setComponent soldierID, (new Mob).init(100, 100, 50)
	world.setComponent soldierID, (new Container).init(["shield", "sword"])
	
	world.update
	
	qa.assertEqual world.getComponent(catID, Mob).x, 10
	qa.assertEqual world.getComponent(catID, Mob).y, -10
	qa.assertEqual world.getComponent(catID, Mob).health, 9001
	
	qa.assertEqual world.getComponent(crateID, Container).items, ["potion", "apple"]
	
	qa.assertEqual world.getComponent(soldierID, Mob).x, 110
	qa.assertEqual world.getComponent(soldierID, Mob).y, 90
	qa.assertEqual world.getComponent(soldierID, Mob).health, 51
	qa.assertEqual world.getComponent(soldierID, Container).items, ["shield", "sword", "apple"]
end function

testGetComponentDefault = function
	world = (new entities.World).init
	
	Foo = {}
	Foo._name = "Foo"
	Foo.eid = null
	Foo.bar = null
	Foo.init = function(bar)
		self.bar = bar
		return self
	end function
	Foo.set = function(_, eid)
		self.eid = eid
		return self
	end function
	
	ent1 = world.createEntity
	ent2 = world.createEntity
	
	world.setComponent ent1, (new Foo).init("hello")
	
	qa.assertEqual world.getComponent(ent1, Foo).bar, "hello"
	qa.assertEqual world.getComponent(ent1, Foo, {"bar": "goodbye"}).bar, "hello"
	qa.assertEqual world.getComponent(ent2, Foo, {"bar": "goodbye"}).bar, "goodbye"
end function

testClass = function
	world = (new entities.World).init
	
	Foo = new entities.Class
	Foo._name = "Foo"
	Foo.eid = null
	Foo.bar = null
	Foo.init = function(bar)
		self._inited = true  // !
		self.bar = bar
		return self
	end function
	
	ent = world.createEntity
	world.setComponent ent, (new Foo).init("hello")
	qa.assertEqual world.getComponent(ent, Foo).bar, "hello"
end function

testGetComponents = function
	world = (new entities.World).init
	
	A = {}
	A._name = "A"
	A.eid = null
	A.set = function(_, eid)
		self.eid = eid
	end function
	
	B = {}
	B._name = "B"
	B.eid = null
	B.set = function(_, eid)
		self.eid = eid
	end function
	
	ent = world.createEntity
	cc = {}
	for kv in world.getComponents(ent)
		cc.push kv.key
	end for
	qa.assertEqual cc, {}
	
	ent = world.createEntity
	world.setComponent ent, new A
	cc = {}
	for kv in world.getComponents(ent)
		cc.push kv.key
	end for
	qa.assertEqual cc, {"A": true}
	
	ent = world.createEntity
	world.setComponent ent, new A
	world.setComponent ent, new B
	cc = {}
	for kv in world.getComponents(ent)
		cc.push kv.key
	end for
	qa.assertEqual cc, {"A": true, "B": true}
end function

testRemoveComponent = function
	world = (new entities.World).init
	
	A = {}
	A._name = "A"
	A.eid = null
	A.set = function(_, eid)
		self.eid = eid
	end function
	
	ent = world.createEntity
	qa.assertEqual world.getComponent(ent, A), null
	
	world.setComponent ent, new A
	qa.assertEqual world.getComponent(ent, A)._name, "A"
	
	comp = world.removeComponent(ent, A)
	qa.assertEqual world.getComponent(ent, A), null
	qa.assertEqual comp._name, "A"
end function

testIterComponents = function
	world = (new entities.World).init
	
	A = {}
	A._name = "A"
	A.eid = null
	A.foo = null
	A.set = function(_, eid)
		self.eid = eid
	end function
	A.init = function(foo)
		self.foo = foo
		return self
	end function
	
	ent1 = world.createEntity
	world.setComponent ent1, (new A).init(42)
	
	ent2 = world.createEntity
	world.setComponent ent2, (new A).init(43)
	
	ent3 = world.createEntity
	world.setComponent ent3, (new A).init(44)
	
	fooList = {}
	_each = function(c)
		fooList.push c.foo
	end function
	world.iterComponents A, @_each
	
	qa.assertEqual fooList, {42: true, 43: true, 44:true}
end function
