RegisterNetEvent('spooner:toggle')
RegisterNetEvent('spooner:openDatabaseMenu')
RegisterNetEvent('spooner:openSaveDbMenu')

AddEventHandler('spooner:toggle', function()
	TriggerClientEvent('spooner:toggle', source)
end)

AddEventHandler('spooner:openDatabaseMenu', function()
	TriggerClientEvent('spooner:openDatabaseMenu', source)
end)

AddEventHandler('spooner:openSaveDbMenu', function()
	TriggerClientEvent('spooner:openSaveDbMenu', source)
end)
