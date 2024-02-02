ensureImport "qa"
ensureImport "entities"


enhanceStringsEqualityCheck qa


testClass = function
	
	M = new entities.Class
	M._name = "M"
	M.x = null
	M.init = function(x)
		self._inited = true
		self.set "x", x
		return self
	end function
	
	qa.assertEqual (new M).init(42).x, 42
	
end function
