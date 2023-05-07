-----------------------------------------------------
-- saving/loading of variables saved on a json file 
-----------------------------------------------------

local json = require "json"

local function jsonFile(file,base)

	local path = system.pathForFile(file,base)	
    local f,err = io.open(path, "r")
    if f==nil then
        return f,err
    else
        local content = f:read("*all")
        f:close()
        return content
    end
end

local M = {}

function M.init(options)

	local foo = {}
	foo.jsonFileName = options.jsonFileName
	foo.path = options.path 

	function foo:load()

		local jsonTable,pos,msg = json.decode(jsonFile(self.jsonFileName,self.path))
		if not jsonTable then
			print( "Decode failed at "..tostring(pos)..": "..tostring(msg) )
		end
		
		return jsonTable
		
	end

	function foo:save(jsonTable)

		local jsonString = json.encode( jsonTable )
		local path = system.pathForFile(self.jsonFileName, self.path)
		local file = io.open(path, "w")
		if ( file ) then
		  local contents = jsonString
		  file:write( contents )
		  io.close( file )
		  return true
		else
		  print( "Error: could not read ".. self.jsonFileName )
		  return false
		end
		
	end

	return foo 
	
end 

return M