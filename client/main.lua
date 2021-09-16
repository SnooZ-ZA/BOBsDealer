ESX        = nil

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
		Wait(100)
	end
	RequestAnimDict("amb@world_human_drug_dealer_hard@male@base")
	while not HasAnimDictLoaded("amb@world_human_drug_dealer_hard@male@base") do
		Wait(1)
	end
		dealer = CreatePed(5, modelped, dealerinfo.x, dealerinfo.y, dealerinfo.z, heading, true, false)
		TaskTurnPedToFaceEntity(dealer, ped, 2000)
			Citizen.Wait(1000)	
		TaskPlayAnim(dealer,"amb@world_human_drug_dealer_hard@male@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
		RemoveAnimDict('amb@world_human_drug_dealer_hard@male@base')
		Citizen.Wait(2000)
		FreezeEntityPosition(dealer,true)
		attachModel3 = GetHashKey('p_ld_heist_bag_s')
		boneNumber3 = 24818
		local bone3 = GetPedBoneIndex(dealer, boneNumber3)
		RequestModel(attachModel3)
			while not HasModelLoaded(attachModel3) do
			Wait(100)
			end
		attachedProp3 = CreateObject(attachModel3, 0.0, 0.0, 0.0, 90.0, 90.0, 25.0)
		AttachEntityToEntity(attachedProp3, dealer, bone3, -0.06, -0.08, -0.01, 0.0, 270.0, 180.0, 1, 1, 0, 0, 2, 1)
		SetEntityAsMissionEntity(object, true, false)
		SetEntityCollision(attachedProp3, false, true)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local player = PlayerPedId()
		local playercoords = GetEntityCoords(player)
		local pos = GetEntityCoords(dealer)
		local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, playercoords.x, playercoords.y, playercoords.z, true)
		if distance < 2 and DoesEntityExist(dealer) then
			drawText3D(pos.x, pos.y, pos.z + 1.0, '[~g~E~s~]~b~ Collect Money~s~<br>[~g~H~s~]~b~ Dismiss Dealer~s~')
			if IsControlJustPressed(1, 51)  then
				TriggerServerEvent('esx_dealer:collect')
				TriggerEvent('esx_dealer:GiveBag')
			elseif IsControlJustPressed(1, 74)  then
				TriggerServerEvent('esx_dealer:collect')
				TriggerEvent('esx_dealer:GiveBag')
				DeleteEntity(attachedProp3)
				TriggerServerEvent('esx_dealer:Dismiss')
				FreezeEntityPosition(dealer,false)	
				SetPedAsNoLongerNeeded(dealer)
				ESX.ShowNotification('~g~You dismissed your dealer!')
				Citizen.Wait(10000)				
				DeleteEntity(dealer)								
			end
		end		
	end
end)


function AddByer()
	local ped= dealer
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.9, 0.0)
    local heading = GetEntityHeading(ped)
	local pedcoords = GetEntityCoords(ped)
	local buyerinfo = {
            x= coords.x,
            y= coords.y,
            z= coords.z,
            h= heading,
            propid=0,
            }
	local modelped = GetHashKey('a_m_y_eastsa_02')
	RequestModel(modelped)
	while not HasModelLoaded(modelped) do
		Wait(100)
	end
	RequestAnimDict("mp_common")
	while not HasAnimDictLoaded("mp_common") do
		Wait(1)
	end
		local retval, buyercoords = GetClosestVehicleNode(coords.x, coords.y , coords.z, 1)
		buyer = CreatePed(5, modelped, buyercoords.x, buyercoords.y, buyercoords.z, 0.0, true, false)
		TaskGoToCoordAnyMeans(buyer, buyerinfo.x, buyerinfo.y, buyerinfo.z, 1.0, 0, 0, 786603, 1.0)		
end

Citizen.CreateThread(function()
	while true do
	Citizen.Wait(60000) -- every 60 seconds
		ESX.TriggerServerCallback('esx_dealer:getTimeLeft', function(timeleft)
			if timeleft ~= 0 then
				TriggerServerEvent('esx_dealer:updateTime') -- update the database time
			end
			if timeleft > 0 and timeleft < 4 and DoesEntityExist(dealer) then
				ShowAdvancedNotification('CHAR_MP_FAM_BOSS', 'Drug Dealer', '~g~Hey Boss', '~y~Come collect your money!')
			end
		end)
	end
end)

Citizen.CreateThread(function()
	while true do
		local sales = math.random(45000, 90000)
		Citizen.Wait(sales)
		ESX.TriggerServerCallback('esx_dealer:getTimeLeft', function(timeleft)
			if timeleft ~= 0 and DoesEntityExist(dealer) and not IsEntityDead(dealer) then
				AddByer()
				--TriggerServerEvent("esx_dealer:sellDrugs")
				callCops = math.random(1, 100)
				if callCops <= Config.callCops then	
				TriggerServerEvent('esx_dealer:callCops')
				end
			elseif timeleft == 0 and DoesEntityExist(dealer) then
				FreezeEntityPosition(dealer,false)	
				SetPedAsNoLongerNeeded(dealer)
				ClearPedTasks(dealer)
				ESX.ShowNotification('~y~Your Dealer Quit and ran off with the drugs and money!')
				TriggerServerEvent("esx_dealer:lost")
				Citizen.Wait(15000)
				DeleteEntity(dealer)
				DeleteEntity(attachedProp3)
			elseif	DoesEntityExist(dealer) and IsEntityDead(dealer) then
				ESX.ShowNotification('~r~Your Dealer Died and lost the drugs and money!')
				TriggerServerEvent("esx_dealer:lost")
				DeleteEntity(dealer)
				DeleteEntity(attachedProp3)
			end				

		end)	
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local buyerpos = GetEntityCoords(buyer)
		local dealerpos = GetEntityCoords(dealer)
		local distance = GetDistanceBetweenCoords(buyerpos.x, buyerpos.y, buyerpos.z, dealerpos.x, dealerpos.y, dealerpos.z, true)		
		if distance < 1.5 and DoesEntityExist(dealer) then
			Citizen.Wait(1500)
			TaskTurnPedToFaceEntity(buyer, dealer, 2000)
			Citizen.Wait(1500)	
				TaskPlayAnim(buyer,"mp_common","givetake2_a", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
				TaskPlayAnim(dealer,"mp_common","givetake2_a", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
				RemoveAnimDict('mp_common')
				ClearPedTasks(buyer)
				SetPedAsNoLongerNeeded(buyer)
				Citizen.Wait(1000)		
				RequestAnimDict("amb@world_human_drug_dealer_hard@male@base")
				while not HasAnimDictLoaded("amb@world_human_drug_dealer_hard@male@base") do
				Wait(1)
				end
				TaskPlayAnim(dealer,"amb@world_human_drug_dealer_hard@male@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
				RemoveAnimDict('amb@world_human_drug_dealer_hard@male@base')
				Citizen.Wait(3000)
				DeleteEntity(buyer)
				TriggerServerEvent("esx_dealer:sellDrugs")
		end
	end	
end)	
		

RegisterNetEvent('esx_dealer:GiveBag')
AddEventHandler('esx_dealer:GiveBag', function(id)
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
		RequestAnimDict('mp_action')
			while not HasAnimDictLoaded('mp_action') do
			Citizen.Wait(50)
			end
			TaskPlayAnim(PlayerPedId(), 'mp_action', 'thanks_male_06', 8.0, 8.0, -1, 50, 0, false, false, false)
			RemoveAnimDict('mp_action')			
        if skin.bags_1 ~= 45 then			
            TriggerEvent('skinchanger:change', "bags_1", 45)
            TriggerEvent('skinchanger:change', "bags_2", 0)
            TriggerEvent('skinchanger:getSkin', function(skin)
            TriggerServerEvent('esx_skin:save', skin)
            end)
        end
			Citizen.Wait(2000)
			ClearPedTasks(PlayerPedId())
    end)
end)

RegisterNetEvent('esx_dealer:DropBag')
AddEventHandler('esx_dealer:DropBag', function(id)
       TriggerEvent('skinchanger:change', "bags_1", 0)
       TriggerEvent('skinchanger:change', "bags_2", 0)
       TriggerEvent('skinchanger:getSkin', function(skin)
       TriggerServerEvent('esx_skin:save', skin)
	end)
end)

RegisterNetEvent('esx_dealer:callCops')
AddEventHandler('esx_dealer:callCops', function(suspect)
	dealerPos = GetEntityCoords(dealer)
	ShowAdvancedNotification('CHAR_MP_FAM_BOSS', 'Drug Sales', '~y~Dealer selling drugs.~s~', '~r~Alert! Shoot to kill!')
    local dealerLoc = AddBlipForCoord(dealerPos.x, dealerPos.y, dealerPos.z)
    SetBlipSprite(dealerLoc , 161)
    SetBlipScale(dealerLoc , 1.0)
    SetBlipColour(dealerLoc, 5)
    PulseBlip(dealerLoc)
	Wait(20*1000)
    RemoveBlip(dealerLoc)
end)

function ShowAdvancedNotification(icon, sender, title, text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    SetNotificationMessage(icon, icon, true, 4, sender, title, text)
    DrawNotification(false, true)
end