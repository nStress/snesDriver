local dataLibrary = {
	-- MARE RETARDAT
	["MySQL.Sync.fetchAll"] = false,
	['MySQL.Async.fetchAll'] = false,
	["MySQL.Sync.execute"] = false,
	["MySQL.Sync.fetchScalar"] = false,
	['MySQL.Async.fetchScalar'] = false,
	["MySQL.ready"] = "pcall",
	['MySQL.update.await'] = false,
	['MySQL.Async.update'] = false,
	['MySQL.Async.execute'] = false,
	['MySQL.Async.insert'] = false,
	['MySQL.Async.store']  = false,
	['MySQL.Async.transaction'] = false,
	['MySQL.Sync.prepare'] = false,
	['MySQL.single'] = false,
	['MySQL.single.await'] = false,
	['MySQL.scalar'] = false,
	['MySQL.scalar.await'] = false,
	['MySQL.prepare.await'] = false,
	['MySQL.prepare'] = false,
	['MySQL.insert'] = false,
	['MySQL.insert.await'] = false,


	-- ghmattimysql
	['exports.ghmattimysql:execute'] = false,
	['exports.ghmattimysql:executeSync'] = false,
	['exports["ghmattimysql"]:execute'] = false,
	['exports["ghmattimysql"]:executeSync'] = false,

	-- oxmysql

	['exports.oxmysql.execute_async'] = false,
	['exports.oxmysql.execute'] = false,
	['exports.oxmysql.executeSync'] = false,
	['exports.oxmysql.update'] = false,
	['exports.oxmysql:transaction'] = false,
	['exports.oxmysql:transactionSync'] = false,
	['exports.oxmysql.scalar'] = false,
	['exports.oxmysql.query'] = false,
	['exports.oxmysql.insert'] = false,
	['exports.oxmysql.fetch'] = false,
	['exports.oxmysql.fetchSync'] = false,

	['exports["oxmysql"]:execute'] = false,
	['exports["oxmysql"]:executeSync'] = false,
	['exports["oxmysql"]:fetchSync'] = false,
	['exports["oxmysql"]:fetch'] = false,
	['exports.snesDriver:query'] = false
}

local dataResource = {}

function __manifest(__path)
	if LoadResourceFile(__path, "__resource.lua") then 
		return '__resource.lua'
	elseif LoadResourceFile(__path, "fxmanifest.lua") then 
		return 'fxmanifest.lua'
	end
	return nil 
end

function dbQuery(queryString, queryParams, callback)
    if callback then 
        local exportName = 'execute'
        if Config.DatabaseDriver:lower() == 'oxmysql' then exportName = 'query' end
        exports[Config.DatabaseDriver][exportName](exports[Config.DatabaseDriver], queryString, queryParams, callback)
    else
        return exports[Config.DatabaseDriver]['executeSync'](exports[Config.DatabaseDriver], queryString, queryParams)
    end
end

function canRead(_path,input)
    return LoadResourceFile(_path, input) or false
end

function setupMySQLFiles(_path,imputfile)
    if not canRead(_path,imputfile) then return end
     file = canRead(_path,imputfile)
	for k,v in pairs(dataLibrary) do
        if string.find(file,k) then 
		    file = file:gsub(k, v or "exports.snesDriver:query")	
        end
	end
	translationFiles(_path,imputfile, file)
	dataResource[_path] = nil
end

function translationFiles(_path,imputfile, file)
	if dataResource[_path] then
		print(_path..' was checked')
		return SaveResourceFile(_path,imputfile, file,-1)
	end
end

function ResourceTranslator()
    for resources = 0, GetNumResources() - 1 do
        resourceIndex = GetResourceByFindIndex(resources)
        dataResource[resourceIndex] = resources
        if __manifest(resourceIndex) then 
            for i=1,GetNumResourceMetadata(resourceIndex,'server_script')-1 do 
                local data = GetResourceMetadata(resourceIndex,'server_script', i)
                if not string.find(data,"@") and not string.find(data,'*') then 
                    setupMySQLFiles(resourceIndex,data)
                end
            end
        end
    end
end
RegisterCommand("snesDriver",function(source)
	if source ~=0 then return end;
		ResourceTranslator()
end)

exports('query', dbQuery)