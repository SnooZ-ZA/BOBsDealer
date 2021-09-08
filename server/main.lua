ESX = nil

Config = {}

Config.dealerTime = 20 --time a dealer stand and sell

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand("dealer", function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	local source  = source
	local weed = xPlayer.getInventoryItem('weed').count
	local coke = xPlayer.getInventoryItem('coke').count
	local meth = xPlayer.getInventoryItem('meth').count
	if weed > 0 or coke > 0  or meth > 0 then
		local result = MySQL.Sync.fetchScalar("SELECT * FROM dealers WHERE identifier = @identifier", {['@identifier'] = identifier})
		if not result then
			MySQL.Sync.execute("INSERT INTO dealers (`identifier`, `timeleft`) VALUES (@identifier, @timeleft)",{['@identifier'] = identifier, ['timeleft'] = Config.dealerTime})
		end
		local timeleft = MySQL.Sync.fetchAll("SELECT timeleft FROM dealers WHERE identifier = @identifier", {['@identifier'] = identifier})
		data = timeleft[1].timeleft
		if data == 0 then
			TriggerClientEvent('esx_dealer:spawnDealer', source)
			MySQL.Sync.execute("UPDATE dealers SET timeleft=@timeleft WHERE identifier=@identifier", {['@identifier'] = identifier, ['@timeleft'] = Config.dealerTime}) 
		else
			TriggerClientEvent("esx:showNotification", source, "Wait ~r~" .. data .. "~s~ minutes.")
		end
	else
	TriggerClientEvent("esx:showNotification", source, "You need ~b~Drugs~s~ to employ a ~y~Dealer")
	end
end, false)

RegisterServerEvent('esx_dealer:updateTime')
AddEventHandler('esx_dealer:updateTime', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	MySQL.Async.fetchScalar('SELECT timeleft FROM dealers WHERE identifier=@identifier',{['@identifier'] = identifier}, function(timeleft)
		if timeleft ~= 0 then
			local newtime = timeleft - 1
			MySQL.Async.execute("UPDATE dealers SET timeleft=@timeleft WHERE identifier=@identifier", {['@identifier'] = identifier, ['@timeleft'] = newtime})
		end
	end)
end)

ESX.RegisterServerCallback('esx_dealer:getTimeLeft', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	MySQL.Async.fetchScalar('SELECT timeleft FROM dealers WHERE identifier=@identifier',{['@identifier'] = identifier}, function(timeleft)
		cb(timeleft)
	end)
end)

RegisterServerEvent("esx_dealer:sellDrugs")
AddEventHandler("esx_dealer:sellDrugs", function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local weed = xPlayer.getInventoryItem('weed').count
	local coke = xPlayer.getInventoryItem('coke').count
	local meth = xPlayer.getInventoryItem('meth').count
	local drugamount = 0
	local price = 0
	local drugType = nil
	if weed > 0 then
		drugType = 'weed'
		if weed == 1 then
			drugamount = 1
		elseif weed == 2 then
			drugamount = math.random(1,2)
		elseif weed == 3 then	
			drugamount = math.random(1,3)
		elseif weed >= 4 then	
			drugamount = math.random(1,4)
		end	
	elseif coke > 0 then
		drugType = 'coke'
		if coke == 1 then
			drugamount = 1
		elseif coke == 2 then
			drugamount = math.random(1,2)
		elseif coke >= 3 then	
			drugamount = math.random(1,3)
		end
	elseif meth > 0 then
		drugType = 'meth'
		if meth == 1 then
			drugamount = 1
		elseif meth == 2 then
			drugamount = math.random(1,2)
		elseif meth >= 3 then	
			drugamount = math.random(1,3)
		end	
	else
		TriggerClientEvent('esx:showNotification', _source, "Your Dealer have ~r~no more~r~ ~y~drugs~s~ to sell")
		return
	end	
	if drugType=='weed' then
		price = math.random(100,120) * 2 * drugamount		
	elseif drugType=='coke' then
		price = math.random(140,160) * 2 * drugamount
	elseif drugType=='meth' then
		price = math.random(120,140) * 2 * drugamount
	end	
	if drugType ~= nil then
		xPlayer.removeInventoryItem(drugType, drugamount)
	end
	xPlayer.addAccountMoney('black_money', price)
	 --xPlayer.addMoney(price)
	if drugType=='weed' then
	TriggerClientEvent('esx:showNotification', _source, "Your Dealer sold ~b~"..drugamount.."x~s~ ~y~Weed~s~ for ~r~$" .. price)
	elseif drugType=='coke' then
	TriggerClientEvent('esx:showNotification', _source, "Your Dealer sold~b~"..drugamount.."x~s~ ~y~Cocaine~s~ for ~r~$" .. price)
	elseif drugType=='meth' then
	TriggerClientEvent('esx:showNotification', _source, "Your Dealer sold~b~"..drugamount.."x~s~ ~y~Meth~s~ for ~r~$" .. price)
	end
end)
