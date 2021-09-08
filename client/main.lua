ESX        = nil
Config              = {}

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(5)

		TriggerEvent("esx:getSharedObject", function(library)
			ESX = library
		end)
    end

    if ESX.IsPlayerLoaded() then
		ESX.PlayerData = ESX.GetPlayerData()
	end
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(response)
	ESX.PlayerData = response
end)

RegisterNetEvent('esx_dealer:spawnDealer')
AddEventHandler('esx_dealer:spawnDealer', function()
    AddDealer()
end)

function AddDealer()
	local ped= PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.2, 0.0)
    local heading = GetEntityHeading(ped)
	local pedcoords = GetEntityCoords(ped)

		local dealerinfo = {
            x= coords.x,
            y= coords.y,
            z= coords.z,
            h= heading,
            propid=0,
            }
	local modelped = GetHashKey('s_m_y_dealer_01')
	RequestModel(modelped)
	while not HasModelLoaded(modelped) do
		Citizen.Wait(100)
	end
	RequestAnimDict("amb@world_human_drug_dealer_hard@male@base")
	while not HasAnimDictLoaded("amb@world_human_drug_dealer_hard@male@base") do
		Wait(1)
	end
		pedNpc = CreatePed(5, modelped, dealerinfo.x, dealerinfo.y, dealerinfo.z, heading, true, false)
			dealer = pedNpc
		TaskTurnPedToFaceEntity(dealer, ped, 2000)
			Citizen.Wait(1000)	
		TaskPlayAnim(dealer,"amb@world_human_drug_dealer_hard@male@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
		RemoveAnimDict('amb@world_human_drug_dealer_hard@male@base')
		Citizen.Wait(2000)
		FreezeEntityPosition(dealer,true)
		--local dealerblip = CreateMissionBlip(dealerinfo)	
end

function AddByer()
	local ped= dealer
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.2, 0.0)
    local heading = GetEntityHeading(ped)
	local pedcoords = GetEntityCoords(ped)

		local buyerinfo = {
            x= coords.x,
            y= coords.y,
            z= coords.z,
            h= heading,
            propid=0,
            }
	local modelped = GetHashKey('a_m_y_epsilon_01')
	RequestModel(modelped)
	while not HasModelLoaded(modelped) do
		Citizen.Wait(100)
	end
	RequestAnimDict("mp_common")
	while not HasAnimDictLoaded("mp_common") do
		Wait(1)
	end
		pedNpc = CreatePed(5, modelped, buyerinfo.x, buyerinfo.y, buyerinfo.z - 0.8, heading - 180, true, false)
			buyer = pedNpc
		TaskTurnPedToFaceEntity(buyer, ped, 2000)
			Citizen.Wait(1000)	
		TaskPlayAnim(buyer,"mp_common","givetake2_a", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
		TaskPlayAnim(dealer,"mp_common","givetake2_a", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
		RemoveAnimDict('mp_common')
		Citizen.Wait(1000)
		ClearPedTasks(buyer)
		SetPedAsNoLongerNeeded(buyer)
		RequestAnimDict("amb@world_human_drug_dealer_hard@male@base")
		while not HasAnimDictLoaded("amb@world_human_drug_dealer_hard@male@base") do
		Wait(1)
		end
		TaskPlayAnim(dealer,"amb@world_human_drug_dealer_hard@male@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
		RemoveAnimDict('amb@world_human_drug_dealer_hard@male@base')	
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000) -- every 60 seconds
		ESX.TriggerServerCallback('esx_dealer:getTimeLeft', function(timeleft)
			if timeleft ~= 0 then
				TriggerServerEvent('esx_dealer:updateTime') -- update the database time				
			end
		end)
	end
end)

Citizen.CreateThread(function()
	while true do
		local sales = math.random(45000, 120000)
		Citizen.Wait(sales)
		ESX.TriggerServerCallback('esx_dealer:getTimeLeft', function(timeleft)
			if timeleft ~= 0 and DoesEntityExist(dealer) and not IsEntityDead(dealer) then
				AddByer()
				TriggerServerEvent("esx_dealer:sellDrugs")
			elseif timeleft == 0 and DoesEntityExist(dealer) or IsEntityDead(dealer) then
				FreezeEntityPosition(dealer,false)	
				SetPedAsNoLongerNeeded(dealer)
				ClearPedTasks(dealer)
				ESX.ShowNotification('~y~Your Dealer Quit!')
				Citizen.Wait(15000)
				DeleteEntity(dealer)
			end				

		end)	
	end
end)


--[[function CreateMissionBlip(dealerinfo)
	local dealerblip = AddBlipForCoord(dealerinfo.x, dealerinfo.y, dealerinfo.z)
	SetBlipSprite(blip, 310)
	SetBlipColour(blip, 1)
	AddTextEntry('MYDEALER', "Drug Dealer")
	BeginTextCommandSetBlipName('MYDEALER')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, 0.9) -- set scale
	SetBlipAsShortRange(blip, true)
	return blip
end]]--