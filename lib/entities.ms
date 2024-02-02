if globals.hasIndex("ensureImport") then
	ensureImport = @globals.ensureImport
else
	// from /sys/lib/importUtil.ms
	ensureImport = function(moduleName)
		if globals.hasIndex(moduleName) then return
		globals[moduleName] = "PENDING"	// (module is being imported now)
		import moduleName
		globals[moduleName] = locals[moduleName]
	end function
end if


ensureImport "mapUtil"


if globals.hasIndex("abort") then
	abort = @globals.abort
else
	abort = function(msg)
		print msg
		exit
	end function
end if

isInstance = function(x, T)
	if not @x isa T then return false
	if not @x isa map then return true
	_noVal = {}
	if refEquals(x.get("_inited", _noVal), _noVal) then return true
	return x._inited
end function

nextID = function(prevID="0", alphabet="0123456789")
	next = ""
	carryFlag = true
	for i in range(prevID.len - 1, 0, -1)
		digit = prevID[i]
		index = alphabet.indexOf(digit)
		if index == null then index = -1
		if carryFlag then
		    carryFlag = false
		    index += 1
		end if
		if index == alphabet.len then
			carryFlag = true
			index = 0
		end if
		next = alphabet[index] + next
	end for
	if carryFlag then next = alphabet[1] + next
	if next == "" then next = alphabet[0]
	return next
end function


Class = {}
Class._name = "Class"
Class._inited = false
Class.set = function(name, value)
	if not isInstance(self, Class) then abort "uninited " + self._name
	_noval = {}
	if refEquals(self.get(name, _noval), _noval) then abort "unable to set `" + name + "`"
	self[name] = @value
	return self
end function


World = new Class
World._name = "World"
World._inited = false
World.lastID = null
World.systems = null
World.components = null

World.init = function
	self._inited = true
	self.set "lastID", "0"
	self.set "systems", []      // [ { "system": , "componentName": } ]
	self.set "components", {}   // { componentName : { eid : component }}
	return self
end function

World.toComponentName = function(componentClass)
	if componentClass isa string then
		return componentClass
	else
		return componentClass._name
	end if
end function

World.createEntity = function
	if not isInstance(self, World) then abort "uninited World"
	self.set "lastID", nextID(self.lastID)
	return self.lastID
end function

World.setComponent = function(eid, component)
	if not isInstance(self, World) then abort "uninited World"
	if not isInstance(eid, string) then abort "eid should be a string"
	component.set "eid", eid
	if not self.components.hasIndex(component._name) then self.components[component._name] = {}
	self.components[component._name][eid] = component
end function

World.getComponent = function(eid, componentClass, default=null)
	if not isInstance(self, World) then abort "uninited World"
	if not isInstance(eid, string) then abort "eid should be a string"
	componentName = self.toComponentName(componentClass)
	return self.components.get(componentName, {}).get(eid, default)
end function

World.getComponents = function(eid)
	if not isInstance(self, World) then abort "uninited World"
	if not isInstance(eid, string) then abort "eid should be a string"
	components = {}
	for kv in self.components
		if not kv.value.hasIndex(eid) then continue
		components[kv.key] = kv.value[eid]
	end for
	return components
end function

World.removeComponent = function(eid, componentClass)
	if not isInstance(self, World) then abort "uninited World"
	if not isInstance(eid, string) then abort "eid should be a string"
	componentName = self.toComponentName(componentClass)
	components = self.components.get(componentName, {})
	if components.hasIndex(eid) then
		component = components[eid]
		components.remove eid
		return component
	end if
end function

World.iterComponents = function(componentClass, callback)
	if not isInstance(self, World) then abort "uninited World"
	componentName = self.toComponentName(componentClass)
	for kv in self.components.get(componentName, {})
		callback kv.value
	end for
end function

World.addSystem = function(system, componentClass)
	if not isInstance(self, World) then abort "uninited World"
	sysEntry = {"componentName": self.toComponentName(componentClass)}
	if @system isa funcRef then
		sysEntry.system = {}
		sysEntry.system.update = @system
	else
		sysEntry.system = system
	end if
	self.systems.push sysEntry
end function

World.update = function(dt=null)
	if not isInstance(self, World) then abort "uninited World"
	for sysEntry in self.systems
		components = self.components.get(sysEntry.componentName)
		if components == null then continue
		for kv in components
			sysEntry.system.update dt, kv.value, self
		end for
	end for
end function
