local messageData = require "chat_room_data"

function Messagehandling(room,message)
	
	if not room or not message then return end

	local rs,type,data = messageData.decode_emit_events(data);
        if  not rs  then
        	return
        end	

        --房管变更 普通弹幕 封禁消息不需要处理，直接转发即可
       	if 	tonumber(type) == 0 or tonumber(type) == 2 or tonumber(type) == 3 then
				room:sendMsg(message)
    	--主播开播，关播消息
        elseif tonumber(type) == 6 or tonumber(type) == 7  then
            	room["liveStatus"] = data["liveStatus"]
            	room["gameType"] = data["gameType"]  
         --用户下注消息   	
        elseif tonumber(type) == 4 then
            	room:bet(data["game_player_id"],data)   	
       
        elseif tonumber(type) == 1 then
            	room:anchorReceiveGifts(data)   

        else
        	return    	
        end


    

end
