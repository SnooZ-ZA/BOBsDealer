ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand("dealer", function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	local source  = source
	local weed = xPlayer.getInventoryItem('weed').count
	local coke = xPlayer.getInventoryItem('coke').count
	local meth = xPlayer.getInventoryItem('meth').count
	if weed > 0 or coke > 0  or meth > 0 then
		local totalcount = weed + coke + meth
		local result = MySQL.Sync.fetchScalar("SELECT * FROM dealers WHERE identifier = @identifier", {['@identifier'] = identifier})
		if not result then			
			TriggerClientEvent("esx:showNotification", source, "You gave your dealer ~r~" .. totalcount .. "~s~ drugs.")
			TriggerClientEvent('esx_dealer:spawnDealer', source)
			MySQL.Sync.execute("INSERT INTO dealers (`identifier`, `timeleft`, `weed`, `meth`, `coke`) VALUES (@identifier, @timeleft, @weed, @meth, @coke)",{['@identifier'] = identifier, ['@timeleft'] = Config.dealerTime, ['@weed'] = weed, ['@meth'] = meth, ['@coke'] = coke})			
			if weed > 0 then
			xPlayer.removeInventoryItem("weed", weed)
			end
			if meth > 0 then
			xPlayer.removeInventoryItem("meth", meth)
			end
			if coke > 0 then
			xPlayer.removeInventoryItem("coke", coke)
			end
			
		end
		local timeleft = MySQL.Sync.fetchAll("SELECT timeleft FROM dealers WHERE identifier = @identifier", {['@identifier'] = identifier})
		data = timeleft[1].timeleft
		if data == 0 then
			TriggerClientEvent("esx:showNotification", source, "You gave your dealer ~r~" .. totalcount .. "~s~ drugs.")
			TriggerClientEvent('esx_dealer:spawnDealer', source)
			MySQL.Sync.execute("UPDATE dealers SET timeleft=@timeleft, weed=@weed, meth=@meth, coke=@coke WHERE identifier=@identifier", {['@identifier'] = identifier, ['@timeleft'] = Config.dealerTime, ['@weed'] = weed, ['@meth'] = meth, ['@coke'] = coke}) 
			if weed > 0 then
			xPlayer.removeInventoryItem("weed", weed)
			end
			if meth > 0 then
			xPlayer.removeInventoryItem("meth", meth)
			end
			if coke > 0 then
			xPlayer.removeInventoryItem("coke", coke)
			end
		else
			TriggerClientEvent("esx:showNotification", source, "Wait ~r~" .. data .. "~s~ minutes before employing another dealer.")
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

RegisterServerEvent('esx_dealer:lost')
AddEventHandler('esx_dealer:lost', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	MySQL.Async.fetchScalar('SELECT money FROM dealers WHERE identifier=@identifier',{['@identifier'] = identifier}, function(money)
		if money ~= 0 then
			local lostmoney = 0
			MySQL.Async.execute("UPDATE dealers SET money=@money WHERE identifier=@identifier", {['@identifier'] = identifier, ['@money'] = lostmoney})
		end
	end)
end)

RegisterServerEvent('esx_dealer:collect')
AddEventHandler('esx_dealer:collect', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	local  _source = source
	MySQL.Async.fetchScalar('SELECT money FROM dealers WHERE identifier=@identifier',{['@identifier'] = identifier}, function(money)
		if money ~= 0 then
			xPlayer.addAccountMoney('black_money', money)
			TriggerClientEvent('esx:showNotification', _source, "You collected $ ~b~"..money)
			local colmoney = 0
			MySQL.Async.execute("UPDATE dealers SET money=@money WHERE identifier=@identifier", {['@identifier'] = identifier, ['@money'] = colmoney})
		else
		TriggerClientEvent('esx:showNotification', _source, "Your dealer doesn't have money")
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
	local xPlayer = ESX.GetPlayerFromId(source)
	local _source = source
	local identifier = xPlayer.identifier
	local drugs = MySQL.Async.fetchAll('SELECT weed, meth, coke FROM dealers WHERE identifier=@identifier',{['@identifier'] = identifier}, function(drugs)
	local drugamount = 0
	local price = 0
	local drugType = nil
	if drugs[1].weed > 0 then
		drugType = 'weed'
		if drugs[1].weed == 1 then
			drugamount = 1
		elseif drugs[1].weed == 2 then
			drugamount = math.random(1,2)
		elseif drugs[1].weed == 3 then	
			drugamount = math.random(1,3)
		elseif drugs[1].weed >= 4 then	
			drugamount = math.random(1,4)
		end	
	elseif drugs[1].coke > 0 then
		drugType = 'coke'
		if drugs[1].coke == 1 then
			drugamount = 1
		elseif drugs[1].coke == 2 then
			drugamount = math.random(1,2)
		elseif drugs[1].coke >= 3 then	
			drugamount = math.random(1,3)
		end
	elseif drugs[1].meth > 0 then
		drugType = 'meth'
		if drugs[1].meth == 1 then
			drugamount = 1
		elseif drugs[1].meth == 2 then
			drugamount = math.random(1,2)
		elseif drugs[1].meth >= 3 then	
			drugamount = math.random(1,3)
		end	
	else
		TriggerClientEvent('esx:showNotification', _source, "Your Dealer have ~r~no more~r~ ~y~drugs~s~ to sell")
		return
	end	
	if drugType=='weed' then
		price = math.random(100,120) * 2 * drugamount
		newweed = drugs[1].weed - drugamount
	MySQL.Async.execute("UPDATE dealers SET weed=@weed WHERE identifier=@identifier", {['@identifier'] = identifier, ['@weed'] = newweed})		
	elseif drugType=='coke' then
		price = math.random(140,160) * 2 * drugamount
		newcoke = drugs[1].coke - drugamount
	MySQL.Async.execute("UPDATE dealers SET coke=@coke WHERE identifier=@identifier", {['@identifier'] = identifier, ['@coke'] = newcoke})	
	elseif drugType=='meth' then
		price = math.random(120,140) * 2 * drugamount
		newmeth = drugs[1].meth - drugamount
	MySQL.Async.execute("UPDATE dealers SET meth=@meth WHERE identifier=@identifier", {['@identifier'] = identifier, ['@meth'] = newmeth})		
	end	
	--[[if drugType ~= nil then
		xPlayer.removeInventoryItem(drugType, drugamount)
	end]]--
	local money = MySQL.Async.fetchAll('SELECT money FROM dealers WHERE identifier=@identifier',{['@identifier'] = identifier}, function(money)
	newmoney = money[1].money + price
	MySQL.Async.execute("UPDATE dealers SET money=@money WHERE identifier=@identifier", {['@identifier'] = identifier, ['@money'] = newmoney})
	--xPlayer.addAccountMoney('black_money', price)
	 --xPlayer.addMoney(price)
	if drugType=='weed' then
	TriggerClientEvent('esx:showNotification', _source, "Your Dealer sold ~b~"..drugamount.."x~s~ ~y~Weed~s~ for ~r~$" .. price)
	elseif drugType=='coke' then
	TriggerClientEvent('esx:showNotification', _source, "Your Dealer sold~b~"..drugamount.."x~s~ ~y~Cocaine~s~ for ~r~$" .. price)
	elseif drugType=='meth' then
	TriggerClientEvent('esx:showNotification', _source, "Your Dealer sold~b~"..drugamount.."x~s~ ~y~Meth~s~ for ~r~$" .. price)
	end
	end)
	end)
end)

RegisterCommand("bag", function(source, args, rawCommand)
     TriggerClientEvent('esx_dealer:DropBag', source)
end, false)

RegisterServerEvent('esx_dealer:callCops')
AddEventHandler('esx_dealer:callCops', function()
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			TriggerClientEvent('esx_dealer:callCops', xPlayers[i], suspect)
		end
	end
end)