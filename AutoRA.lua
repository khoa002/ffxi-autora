--Copyright (c) 2013, Banggugyangu
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


windower.register_event('load',function ()
	version = '2.1.2'
	delay = 0
	RW_delay = 0
	Ammo_delay = 0
	retrn = 0
	halt_on_tp = true
	halt_on_tp_value = 3000
	auto_start = true
	acting = false
	ws_to_use = false
	windower.send_command('unbind ^d')
	windower.send_command('unbind !d')
	windower.send_command('bind ^d ara start')
	windower.send_command('bind !d ara stop')
	windower.send_command('alias ara lua c autora')
end)

function start()
	windower.add_to_chat(17, 'AutoRA STARTING~~~~~~~~~~~~~~')
	player = windower.ffxi.get_player()
	if player.status == 1 then
		auto = 1
	elseif player.status == 0 then
		auto = 1
		windower.send_command('input /attack <t>')
	end
	shoot()
end

function stop()
	windower.add_to_chat(17, 'AutoRA STOPPING ~~~~~~~~~~~~~~')
	auto = 0
end

function shoot()
	windower.send_command('input /shoot <t>')
end

--Function Author:  Byrth
function split(msg, match)
	local length = msg:len()
	local splitarr = {}
	local u = 1
	while u <= length do
		local nextanch = msg:find(match,u)
		if nextanch ~= nil then
			splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
			if nextanch~=length then
				u = nextanch+match:len()
			else
				u = lengthlua
			end
		else
			splitarr[#splitarr+1] = msg:sub(u,length)
			u = length+1
		end
	end
	return splitarr
end

function split2(msg)
	local text = msg
	local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
	for str in text:gmatch("%S+") do
	  local squoted = str:match(spat)
	  local equoted = str:match(epat)
	  local escaped = str:match([=[(\*)['"]$]=])
	  if squoted and not quoted and not equoted then
	    buf, quoted = str, squoted
	  elseif buf and equoted == quoted and #escaped % 2 == 0 then
	    str, buf, quoted = buf .. ' ' .. str, nil, nil
	  elseif buf then
	    buf = buf .. ' ' .. str
	  end
	  if not buf then windower.add_to_chat(17, (str:gsub(spat,""):gsub(epat,""))) end
	end
	if buf then windower.add_to_chat(17, "Missing matching quote for "..buf) end
end

function haltontp()
	if halt_on_tp == true then
		windower.add_to_chat(17, 'AutoRA will no longer halt upon reaching ' .. halt_on_tp_value .. ' TP')
		halt_on_tp = false
	elseif halt_on_tp == false then
		windower.add_to_chat(17, 'AutoRA will halt upon reaching ' .. halt_on_tp_value .. ' TP')
		halt_on_tp = true
	end
end

function sethalttp(halttpvalue)
	if tonumber(halttpvalue) ~= nil then
		halttpvalue = tonumber(halttpvalue)
		if halttpvalue < 1000 or halttpvalue > 3000 then
			windower.add_to_chat(17, 'AutoRA Halt TP value must be between 1000 and 3000')
			return
		end;
		halt_on_tp_value = halttpvalue
		windower.add_to_chat(17, 'AutoRA Halt TP set to ' .. halt_on_tp_value)
	else
		windower.add_to_chat(17, 'AutoRA Halt TP value not valid')
	end;
end

windower.register_event('action',function (act)
	local actor = act.actor_id
	local category = act.category
	local player = windower.ffxi.get_player()

	if ((actor == (player.id or player.index))) then
		acting = true
		if category == 2 then
			acting = false
			if player.vitals['tp'] < halt_on_tp_value then
				if auto == 1 then
					if player.status == 1 then
						auto = 1
					elseif  player.status == 0 then
						auto = 0
						return
					end
				end
				if auto == 1 then
					windower.send_command('@wait 1.5;input /shoot <t>')
					acting = true
				elseif auto == 0 then
				end
			else
				if ws_to_use ~= false then
					windower.send_command('@wait 1.5;input /ws "' .. ws_to_use .. '" <t>')
					acting = true
				end
			end
		end
		if category == 3 then
			windower.send_command('@wait 2;input /shoot <t>')
			acting = true
		end
	else
		if (act.targets ~= nil) then
			for key, value in ipairs(act.targets) do
				if value.id == (player.id or player.index) then
					if auto == 1 and player.status == 1 and acting == false then
						windower.add_to_chat(17, 'attempting to attack again...')
						start()
						return
					end
				end
			end
		end
	end
end)

--Function Designer:  Byrth
windower.register_event('addon command',function (...)
    local term = table.concat({...}, ' ')
    local splitarr = split(term,' ')
	if splitarr[1]:lower() == 'start' then
		start()
	elseif splitarr[1]:lower() == 'stop' then
		stop()
	elseif splitarr[1]:lower() == 'shoot' then
		shoot()
	elseif splitarr[1]:lower() == 'reload' then
		setDelay()
	elseif splitarr[1]:lower() == 'haltontp' then
		haltontp()
	elseif splitarr[1]:lower() == 'sethalttp' then
		sethalttp(splitarr[2])
	elseif splitarr[1]:lower() == 'splittest' then
		split2(term)
	elseif splitarr[1]:lower() == 'help' then
		windower.add_to_chat(17, 'AutoRA  v'..version..'commands:')
		windower.add_to_chat(17, '//ara [options]')
		windower.add_to_chat(17, '  start - Starts auto attack with ranged weapon')
		windower.add_to_chat(17, '  stop - Stops auto attack with ranged weapon')
		windower.add_to_chat(17, '  haltontp - Toggles automatic halt upon reaching a set amount of TP')
		windower.add_to_chat(17, '  sethalttp [value from 1000 to 3000]	- Set the TP to stop AutoRA')
		windower.add_to_chat(17, '  help - Displays this help text')
		windower.add_to_chat(17, ' ')
		windower.add_to_chat(17, 'AutoRA will only automate ranged attacks if your status is "Engaged".  Otherwise it will always fire a single ranged attack.')
		windower.add_to_chat(17, 'To start auto ranged attacks without commands use the key:  Ctrl+d')
		windower.add_to_chat(17, 'To stop auto ranged attacks in the same manner:  Atl+d')
	end
end)
