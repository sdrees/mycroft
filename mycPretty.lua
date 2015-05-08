-- Pretty-printing functions
function debugPrint(msg)
	if(verbose) then print(pretty("debug: "..serialize(msg))) end
end

function serialize(args) -- serialize in Mycroft syntax
	local ret, sep
	if(type(args)~="table") then
		ret=string.gsub(tostring(args), string.char(127), ",")
		ret=string.gsub(ret, string.char(128), "(")
		ret=string.gsub(ret, string.char(129), ")")
		ret=string.gsub(ret, string.char(130), "<")
		ret=string.gsub(ret, string.char(131), ">")
		ret=string.gsub(ret, "([^ ]+)", function(q) 
			if ("\\Y\\E\\S"==q) then return "YES" 
			elseif("\\N\\O"==q) then return "NO" 
			elseif("\\N\\C"==q) then return "NC" 
			else return q end 
		end)
		return ret
	end
	if(args.truth~=nil and args.confidence~=nil) then
		if(1==args.confidence) then
			if(1==args.truth) then
				return "YES"
			elseif (0==args.truth) then
				return "NO"
			else
				return "<"..tostring(args.truth).."|"
			end
		elseif(1==args.truth) then
			return "|"..args.confidence..">"
		elseif(0==args.truth and 0==args.confidence) then
			return "NC"
		else 
			return "<"..tostring(args.truth)..","..tostring(args.confidence)..">" 
		end
	elseif(nil~=args.name and nil~=args.arity) then
		return prettyPredID(args)
	end
	ret="("
	sep=""
	for k,v in ipairs(args) do
		ret=ret..sep
		if(type(v)=="table") then
			ret=ret..serialize(v)
		elseif(type(v)=="string") then
			ret=ret.."\""..v.."\""
		else
			ret=ret..tostring(v)
		end
		sep=","
	end
	for k,v in pairs(args) do
		if(type(k)~="number") then
			ret=ret..sep..tostring(k).."="
			if(type(v)=="table") then
				ret=ret..serialize(v)
			elseif(type(v)=="string") then
				ret=ret.."\""..v.."\""
			else
				ret=ret..tostring(v)
			end
			sep=","
		end
	end
	return ret..")"
end

function prettyPredID(p) -- serialize a predicate name, prolog-style
	debugPrint("Constructing pred id: "..serialize(p.name).."/"..serialize(p.arity))
	return p.name.."/"..p.arity
end

-- pretty-printing routines for predicate definition
function printWorld(world) -- print all preds
	print(pretty(strWorld(world)))
end

function strWorld(world) -- return the code for all predicates as a string
	local k, v
	ret=""
	debugPrint({"world:", world})
	if(world~=nil) then 
		for k,v in pairs(world) do
			ret=ret..strDef(world, k)
		end
	end
	return "# State of the world\n"..ret
end

function strDef(world, k) -- return the definition of the predicate k as a string
	local ret, argCount, args, hash, val, i, v, sep, pfx
	ret=""
	v=world[k]
	if(nil==v) then return ret end
	det=v.det
	if(nil==v.det or v.det) then det="det" else det="nondet" end
	pfx=det.." "..string.gsub(tostring(k), "/%d*$", "")
	if(nil~=v.facts) then
		for hash,val in pairs(v.facts) do
			ret=ret..pfx..serialize(hash).." :- "..serialize(val)..".\n"
		end
	end
	if(nil~=v.def) then
		argCount=0
		args={}
		for i=1,v.arity do
			args[i]="Arg"..tostring(i)
		end
		if(nil~=v.def.children) then
			if(nil~=v.def.children[1]) then
				ret=ret..pfx..serialize(args).." :- "
				ret=ret..v.def.children[1].name
				ret=ret..serialize(translateArgList(args, v.def.correspondences[1]))
				if(nil~=v.def.children[2]) then
					sep=", "
					if(v.def.op=="or") then
						sep="; "
					end
					ret=ret..sep..v.def.children[2].name
					ret=ret..serialize(translateArgList(args, v.def.correspondences[2]))
				end
				ret=ret..".\n"
			end
		end
	end
	return ret
end
-- ANSI color code handling
colors={black=0, red=1, green=2, yellow=3, blue=4, magenta=5, cyan=6, white=7, none=0}
function colorCode(bg, fg, bold) 
	if(bg==nil) then 
		return string.char(27).."[0m" 
	end 
	local b="0"
	if(bold~=nil) then b="1" end
	return string.char(27).."["..b..";"..tostring(30+colors[fg])..";"..tostring(40+colors[bg]).."m" 
end
function pretty(msg)
	if(ansi) then
		msg=string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(msg, 
			"(;)", function (c)
				return colorCode("black", "magenta", 1)..c..colorCode("black", "white")
			end), "(%w+)", function(c)
				if("YES"==c or "NO"==c or "NC"==c) then
					return colorCode("black", "yellow", 1)..c..colorCode("black", "white")
				else 
					return c
				end
			end),"(%w+ *%b())", function (c)
				return colorCode("black", "cyan", 1)..c..colorCode("black", "white")
			end), "([()])", function (c)
				return colorCode("black", "magenta", 1)..c..colorCode("black", "white")
			end), "([?:]%-)", function (c) 
				return colorCode("black", "green", 1)..c..colorCode("black", "white") 
			end), "([<|][0-9., ]+[|>])", function(c) 
				return colorCode("black", "yellow", 1)..c..colorCode("black", "white") 
			end), "%b\"\"", function(c)
				return colorCode("black", "red")..string.gsub(c, string.char(27).."%[".."[^m]+m", "")..colorCode("black", "white")
			end), "(#[^\n]*)", function(c)
				return colorCode("black", "blue", 1)..string.gsub(c, string.char(27).."%[".."[^m]+m", "")..colorCode("black", "white")
			end), "([.,])", function (c)
				return colorCode("black", "magenta", 1)..c..colorCode("black", "white")
			end)
		msg=colorCode("black", "white")..msg..colorCode("black", "white", 1)
	end
	return msg
end

