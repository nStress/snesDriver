/*

 * snesDriver - It is a translator between MySQL drivers
 * LUA Version 5.4 
 *
 * @see https://snes.tebex.io/
 *
 * @author    nStress
 * @copyright 2022  SNES HUB
 * @license   https://github.com/nStress/snesDriver/blob/main/LICENSE MIT License


 */


local dataLibrary = {
	-- MySQL Async 
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
}
local dataResource = {}
local resourceNumberCounter = {}
local resourceCounter = {}
local resources = {}

function __manifest(ResourceName)
	if LoadResourceFile(ResourceName, "__resource.lua") then 
		return '__resource.lua'
	elseif LoadResourceFile(ResourceName, "fxmanifest.lua") then 
		return 'fxmanifest.lua'
	end
	return nil 
end

function __resourceVerifyer(_ResourceName,input)
    return LoadResourceFile(_ResourceName, input) or false
end

function __rewriteData(_ResourceName,__fileName)
    if not __resourceVerifyer(_ResourceName,__fileName) then return end
    file = __resourceVerifyer(_ResourceName,__fileName)
	for k,v in pairs(dataLibrary) do
        if string.find(file,k) then
			if not resources[_ResourceName] then resourceCounter[_ResourceName] = true end 
			resources[_ResourceName] = _ResourceName
		    file = file:gsub(k, v or "exports.snesDriver:query")	
        end
	end
		SaveResourceFile(_ResourceName,__fileName, file,-1)
end

function countTable(table)
	local counter = 0
	if type(table) == 'table' then 
		for __,__ in pairs(table) do
			counter = counter + 1
		end
	end
	return counter
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

function ResourceTranslator()
    for resources = 0, GetNumResources() - 1 do
        resourceIndex = GetResourceByFindIndex(resources)
        dataResource[resourceIndex] = resources
        if __manifest(resourceIndex) then 
            for i=1,GetNumResourceMetadata(resourceIndex,'server_script')-1 do 
                local data = GetResourceMetadata(resourceIndex,'server_script', i)
                if not string.find(data,"@") and not string.find(data,'*') then 
                    __rewriteData(resourceIndex,data)
                end
            end
        end
    end
end


RegisterCommand("snesDriver",function(source)
	if source ~= 0 then return end;
		ResourceTranslator()
		for k,v in pairs(resourceCounter) do print('^0Resource ^1'..k..'^0 has been successfully translated ') end
		print('^3snesDriver^0 translated  ^3'..countTable(resourceCounter)..'^0 resource into the ^3'..Config.DatabaseDriver..'^0 driver')
end)


exports('query', dbQuery)



