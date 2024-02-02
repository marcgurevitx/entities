ensureImport "qa"
ensureImport "entities"


testIsInstance = function
	qa.assertEqual entities.isInstance(42, number), true
	qa.assertEqual entities.isInstance(42, string), false
	qa.assertEqual entities.isInstance("foo", string), true
	qa.assertEqual entities.isInstance("foo", list), false
	qa.assertEqual entities.isInstance([11, 12, 13], list), true
	qa.assertEqual entities.isInstance([11, 12, 13], map), false
	qa.assertEqual entities.isInstance({"foo": 42}, map), true
	qa.assertEqual entities.isInstance({"foo": 42}, funcRef), false
	qa.assertEqual entities.isInstance(@print, funcRef), true
	qa.assertEqual entities.isInstance(@print, number), false
	
	M = {}
	
	qa.assertEqual entities.isInstance({}, M), false
	qa.assertEqual entities.isInstance(new M, M), true
	qa.assertEqual entities.isInstance(new (new M), M), true
	
	M2 = {}
	M2._inited = false
	
	qa.assertEqual entities.isInstance({}, M2), false
	qa.assertEqual entities.isInstance(new M2, M2), false
	qa.assertEqual entities.isInstance({"__isa": M2, "_inited": true}, M2), true
end function


testNextID = function
	qa.assertEqual entities.nextID, "1"
	qa.assertEqual entities.nextID("1"), "2"
	qa.assertEqual entities.nextID("2"), "3"
	qa.assertEqual entities.nextID("9"), "10"
	qa.assertEqual entities.nextID("10"), "11"
	qa.assertEqual entities.nextID("19"), "20"
	qa.assertEqual entities.nextID("99"), "100"
	qa.assertEqual entities.nextID("109"), "110"
end function
