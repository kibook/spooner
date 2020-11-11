RegisterNetEvent('spooner:toggle')
RegisterNetEvent('spooner:openDatabaseMenu')
RegisterNetEvent('spooner:openSaveDbMenu')

AddEventHandler('spooner:toggle', function()
	if IsPlayerAceAllowed(source, 'spooner') then
		TriggerClientEvent('spooner:toggle', source)
	end
end)

AddEventHandler('spooner:openDatabaseMenu', function()
	if IsPlayerAceAllowed(source, 'spooner') then
		TriggerClientEvent('spooner:openDatabaseMenu', source)
	end
end)

AddEventHandler('spooner:openSaveDbMenu', function()
	if IsPlayerAceAllowed(source, 'spooner') then
		TriggerClientEvent('spooner:openSaveDbMenu', source)
	end
end)
