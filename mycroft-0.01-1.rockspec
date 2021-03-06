package = "mycroft"
version = "0.01-1"
source = {
	url = "git://github.com/enkiv2/mycroft"
	--tag = "v0.01"
}

description = {
	summary = "A prolog-like language with composite truth values",
	detailed = [[
		Mycroft is a declarative logic language with prolog-like syntax and prolog-like semantics, supporing 
		composite truth values (a pair of floating point values for truth and confidence), distributed computing,
		and an interactive interpreter.
	]],
	homepage = "http://github.com/enkiv2/mycroft",
	license = "BSD-3"
}
dependencies = {
	"lua ~> 5.1",
	"luasocket ~> 3.0",
	"readline ~> 1.7"
}
build = {
	
	type = "none",
	install = {
		lua = {
			mycroft = "init.lua",
			["mycroft.mycBuiltins"] = "mycBuiltins.lua",
			["mycroft.mycCore"] = "mycCore.lua",
			["mycroft.mycErr"] = "mycErr.lua",
			["mycroft.mycNet"] = "mycNet.lua",
			["mycroft.mycParse"] = "mycParse.lua",
			["mycroft.mycPretty"] = "mycPretty.lua",
			["mycroft.mycTests"] = "mycTests.lua",
			["mycroft.mycType"] = "mycType.lua",
			["mycroft.hash"] = "hash.lua"
		},
		bin = {
			["mycroft"] = "mycroft.lua"
		}
	}
}
