QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

QBCore.Functions.CreateCallback("Ks-multicharacter:server:GetUserCharacters", function(source, cb)
    local steamId = GetPlayerIdentifier(source, 0)

    exports['ghmattimysql']:execute('SELECT * FROM players WHERE steam = @steam', {['@steam'] = steamId}, function(result)
        cb(result)
    end)
end)

QBCore.Functions.CreateCallback("Ks-multicharacter:server:GetServerLogs", function(source, cb)
    exports['ghmattimysql']:execute('SELECT * FROM server_logs', function(result)
        cb(result)
    end)
end)

QBCore.Functions.CreateCallback("test:yeet", function(source, cb)
    local steamId = GetPlayerIdentifiers(source)[1]
    local plyChars = {}
    
    exports['ghmattimysql']:execute('SELECT * FROM players WHERE steam = @steam', {['@steam'] = steamId}, function(result)
        for i = 1, (#result), 1 do
            result[i].charinfo = json.decode(result[i].charinfo)
            result[i].money = json.decode(result[i].money)
            result[i].job = json.decode(result[i].job)

            table.insert(plyChars, result[i])
        end
        cb(plyChars)
    end)
end)

QBCore.Functions.CreateCallback("Ks-multicharacter:server:getSkin", function(source, cb, cid, inf)
    local src = source
    local info = inf
    local char = {}

    exports.ghmattimysql:execute("SELECT * FROM `character_current` WHERE citizenid = '" .. cid .. "'", {}, function(character_current)
        char.model = '1885233650'
        char.drawables = json.decode('{"1":["masks",0],"2":["hair",0],"3":["torsos",0],"4":["legs",0],"5":["bags",0],"6":["shoes",1],"7":["neck",0],"8":["undershirts",0],"9":["vest",0],"10":["decals",0],"11":["jackets",0],"0":["face",0]}')
        char.props = json.decode('{"1":["glasses",-1],"2":["earrings",-1],"3":["mouth",-1],"4":["lhand",-1],"5":["rhand",-1],"6":["watches",-1],"7":["braclets",-1],"0":["hats",-1]}')
        char.drawtextures = json.decode('[["face",0],["masks",0],["hair",0],["torsos",0],["legs",0],["bags",0],["shoes",2],["neck",0],["undershirts",1],["vest",0],["decals",0],["jackets",11]]')
        char.proptextures = json.decode('[["hats",-1],["glasses",-1],["earrings",-1],["mouth",-1],["lhand",-1],["rhand",-1],["watches",-1],["braclets",-1]]')

        if character_current[1] and character_current[1].model then
            char.model = character_current[1].model
            char.drawables = json.decode(character_current[1].drawables)
            char.props = json.decode(character_current[1].props)
            char.drawtextures = json.decode(character_current[1].drawtextures)
            char.proptextures = json.decode(character_current[1].proptextures)
        end

        exports.ghmattimysql:execute("SELECT * FROM `character_face` WHERE citizenid = '" .. cid .. "'", {}, function(character_face)
            if character_face[1] and character_face[1].headBlend then
                char.headBlend = json.decode(character_face[1].headBlend)
                char.hairColor = json.decode(character_face[1].hairColor)
                char.headStructure = json.decode(character_face[1].headStructure)
                char.headOverlay = json.decode(character_face[1].headOverlay)
            end

            cb(char, info)
        end)
    end)
end)


RegisterServerEvent('Ks-multicharacter:server:disconnect')
AddEventHandler('Ks-multicharacter:server:disconnect', function()
    local src = source
    DropPlayer(src, "You have disconnected from ht Store Roleplay")
end)


RegisterServerEvent('Ks-multicharacter:server:loadUserData')
AddEventHandler('Ks-multicharacter:server:loadUserData', function(cData)
    local src = source
    if QBCore.Player.Login(src, false, cData.dat[1]) then
        print('^2[core]^7 '..GetPlayerName(src)..' (Citizen ID: '..cData.dat[1]..') has succesfully loaded!')
        QBCore.Commands.Refresh(src)
        TriggerClientEvent('Ks-spawn:client:choose:spawn', src)

        TriggerEvent('Ks-logs:server:createLog', GetCurrentResourceName(), 'Ks-multicharacter:server:loadUserData', "Loaded citizenID " .. cData.dat[1] .. ".", src)
        TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
	end
end)

RegisterServerEvent('Ks-multicharacter:server:createCharacter')
AddEventHandler('Ks-multicharacter:server:createCharacter', function(data, cid)
    local src = source
    local newData = {}
    newData = data
    newData.cid = cid
    if QBCore.Player.Login(src, true, false, newData) then
        print('^2[core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
        TriggerClientEvent('Ks-spawn:client:choose:appartment', src, newData)
        TriggerClientEvent("Ks-multicharacter:client:closeNUI", src)
		QBCore.Commands.Refresh(src)
        GiveStarterItems(src)
        TriggerEvent('Ks-logs:server:createLog', GetCurrentResourceName(), 'Ks-multicharacter:server:createCharacter', "Created new character.", src)
	end
end)

RegisterServerEvent('Ks-multicharacter:server:deleteCharacter')
AddEventHandler('Ks-multicharacter:server:deleteCharacter', function(citizenid)
    local src = source
    QBCore.Player.DeleteCharacter(src, citizenid)

    TriggerEvent('Ks-logs:server:createLog', GetCurrentResourceName(), 'Ks-multicharacter:server:createCharacter', "Deleted character.", src)
end)

function GiveStarterItems(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    for k, v in pairs(QBCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "A1-A2-A | AM-B | C1-C-CE"
        end
        Player.Functions.AddItem(v.item, 1, false, info)
    end
end

-- function loadHouseData()
--     local HouseGarages = {}
--     local Houses = {}
-- 	QBCore.Functions.ExecuteSql(false, "SELECT * FROM `houselocations`", function(result)
-- 		if result[1] ~= nil then
-- 			for k, v in pairs(result) do
-- 				local owned = false
-- 				if tonumber(v.owned) == 1 then
-- 					owned = true
-- 				end
-- 				local garage = v.garage ~= nil and json.decode(v.garage) or {}
-- 				Houses[v.name] = {
-- 					coords = json.decode(v.coords),
-- 					owned = v.owned,
-- 					price = v.price,
-- 					locked = true,
-- 					adress = v.label, 
-- 					tier = v.tier,
-- 					garage = garage,
-- 					decorations = {},
-- 				}
-- 				HouseGarages[v.name] = {
-- 					label = v.label,
-- 					takeVehicle = garage,
-- 				}
-- 			end
-- 		end
-- 		TriggerClientEvent("Ks-garages:client:houseGarageConfig", -1, HouseGarages)
-- 		TriggerClientEvent("Ks-houses:client:setHouseConfig", -1, Houses)
-- 	end)
-- end

QBCore.Commands.Add("char", "Log-Uit door Admin", {}, false, function(source, args)
    QBCore.Player.Logout(source)
    TriggerClientEvent('Ks-multicharacter:client:chooseChar', source)
    TriggerEvent('mumble:infinity:server:mutePlayer')
    TriggerEvent('Ks-logs:server:createLog', GetCurrentResourceName(), 'command char', "Used the command **char**", source)
end, "god")

QBCore.Commands.Add("closeNUI", "Close NUI", {}, false, function(source, args)
    TriggerClientEvent('Ks-multicharacter:client:closeNUI', source)
end)