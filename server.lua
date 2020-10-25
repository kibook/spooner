RegisterNetEvent('spooner:toggle')

AddEventHandler('spooner:toggle', function()
	TriggerClientEvent('spooner:toggle', source)
end, false)
