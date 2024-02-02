
// from /sys/lib/importUtil.ms
globals.ensureImport = function(moduleName)
	if globals.hasIndex(moduleName) then return
	globals[moduleName] = "PENDING"	// (module is being imported now)
	import moduleName
	globals[moduleName] = locals[moduleName]
end function


globals.enhanceStringsEqualityCheck = function(module)
	module.assertEqual = function(actual, expected, note)
		
		unbroken = function(sym)
			if sym.code == 10 then return "NEW-LINE"
			if sym.code == 13 then return "CARRIAGE-RETURN"
			return sym
		end function
		
		if @actual == @expected then return
		msg = "Assert failed"
		if note != null then msg = msg + " (" + note + ")"
		strDiff = ""
		if @actual isa string and @expected isa string then
			aLen = actual.len
			eLen = expected.len
			if aLen <= eLen then minLen = aLen else minLen = eLen
			for i in range(0, minLen - 1)
				aSym = actual[i]
				eSym = expected[i]
				if aSym != eSym then
					strDiff = "first difference at index " + i + ": " +
						"expected `" + unbroken(eSym) + "` (code: " + eSym.code + "), " +
						"actual `" + unbroken(aSym) + "` (code: " + aSym.code + ")"
					break
				end if
			end for
			if not strDiff then
				if aLen < eLen then
					eSym = expected[aLen]
					strDiff = "first difference at index " + aLen + ": " +
						"expected `" + unbroken(eSym) + "` (code: " + eSym.code + "), " +
						"actual END OF STRING"
				else
					aSym = actual[eLen]
					strDiff = "first difference at index " + eLen + ": " +
						"expected END OF STRING, " + 
						"actual `" + unbroken(aSym) + "` (code: " + aSym.code + ")"
				end if
			end if
		end if
		msg = msg + ": expected `" + @expected + "`, but got `" + @actual + "`"
		if strDiff then msg += "   >>>>>   " + strDiff
		module.abort msg
	end function
end function


getSpecs = function
	if env.hasIndex("cmdLineArgs") then
		args = env.cmdLineArgs
	else
		args = shellArgs
	end if
	specArgs = []
	i = 0
	while i < args.len
		arg = args[i]
		if arg[0] == "-" then
			i += 1
		else
			specArgs.push arg
		end if
		i += 1
	end while
	specArgs.pull  // drop program name
	specs = []
	specIndexes = {}
	for arg in specArgs
		sList = arg.split(":")
		testFile = sList[0]
		if specIndexes.hasIndex(testFile) then
			spec = specs[specIndexes[testFile]]
		else
			spec = {
				"testFile": testFile,
				"functions": [],
			}
			specs.push spec
			specIndexes[testFile] = specs.len - 1
		end if
		if sList.len > 1 then spec.functions.push sList[1]
	end for
	if specs.len == 0 then
		for testFile in file.children("tests")
			if testFile[:4] != "test" then continue
			specs.push {
				"testFile": file.child("tests", testFile),
				"functions": [],
			}
		end for
	end if
	return specs
end function


getExtDirs = function(path)
	extDirs = []
	if file.exists("dirs.txt") then
		for extDir in file.readLines("dirs.txt")
			if not extDir then continue
			for xd in [extDir] + getExtDirs(extDir)
				extDirs.push file.child(path, xd)
			end for
		end for
	end if
	return extDirs
end function


updateImportPaths = function
	extDirs = getExtDirs(".")
	if env.hasIndex("importPaths") then
		env.importPaths += ["lib", "tests"] + extDirs
	else
		env.MS_IMPORT_PATH += ":" + (["lib", "tests"] + extDirs).join(":")
	end if
	
	//
	if extDirs.len > 0 then
		print "additional libs:"
		for xd in extDirs
			print " " + xd
		end for
		print
	end if
	//
	
end function


importPathAndReturn = function(path)
	moduleName = file.name(path) - ".ms"
	import moduleName
	return locals[moduleName]
end function


testSpec = function(spec)
	
	//
	print " " + spec.testFile + " ", ""
	//
	
	if not file.exists(spec.testFile) then
		
		//
		print "(no such file!)"
		//
		
		return
	end if
	module = importPathAndReturn(spec.testFile)
	nTests = 0
	if spec.functions.len > 0 then
		
		//
		print "(" + spec.functions.len + ") ", ""
		//
		
		for funcName in spec.functions
			if not module.hasIndex(funcName) then
				
				//
				print "(no such function: `" + funcName + "`!)", ""
				//
				
			else
				func = module[funcName]
				func
				yield
				nTests += 1
				
				//
				print ".", ""
				//
				
			end if
		end for
	else
		for kv in module
			if kv.key[:4] != "test" then continue
			kv.value
			yield
			nTests += 1
			
			//
			print ".", ""
			//
			
		end for
	end if
	
	//
	print " " + nTests
	//
	
	return nTests
end function


main = function
	updateImportPaths
	specs = getSpecs
	nTests = 0
	for spec in specs
		nTests += testSpec(spec)
	end for
	
	//
	print nTests + " OK"
	//
	
end function


if refEquals(locals, globals) then main
