local mysql = require "db.zs_sql"
local lua_db_help = require "db.lua_db_help"
local cjson = require "cjson"
local db_help = lua_db_help.new()
local _M = {}
_M._VERSION = '0.01'            
local mt = { __index = _M }                    

function _M.new(self)
    return setmetatable({}, mt)    
end

--[[
	--根据插入新的牌局记录
--]]
function _M.insertNewPoker(newgameparm)
	
	if not newgameparm.game_room_id_fk or not newgameparm.game_record_id_fk then
	 	return nil,"parm err"
	 end	

	newgameparm.game_time = os.date("%Y-%m-%d %H:%M:%S")
	--封装主播SQL语句
	local sqlstr =db_help.insert_help("t_game_record",newgameparm)

	local db = mysql:new()

	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sqlstr)
	
	db:close()
	if not res then
		return nil,err
	end
	return res
end


--[[
	--根据插入新的牌局玩家记录
--]]
function _M.insertNewPokerPlayer(playerList,game_type)
	

	local goodsdbkey = "game_record_id_fk,user_code,cards_type,game_info,game_result,is_virtual_player"

	--获取所有值
	local sqlvalue = ""
	
	
	for i,v in ipairs(playerList) do
		local player = playerList[i]
		local cards = ngx.quote_sql_str(cjson.encode(player["cards"]))
		local goodsvalue =  string.format("(%s,%s,%s,%s,%s,%s)",player["game_record_id_fk"],player["game_player_id"],player["cardType"],cards,player["game_result"],player["is_virtual_player"])

		if (sqlvalue == "") then

			sqlvalue = string.format("%s",goodsvalue)
		else
				
			sqlvalue = sqlvalue..",".. string.format("%s",goodsvalue)

		end	

	end
		

	local ordermemsql = string.format("insert into t_player_game (%s) values %s",goodsdbkey,sqlvalue)
	local db = mysql:new()
	--事务操作
	--db:query([[START TRANSACTION;]])
	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(ordermemsql)
	
	db:close()
	if not res then
		return nil,err
	end
	return res
end


--[[
	@parm playerlist押注列表
	@parm stake_type 押注类型
--]]
function _M.insertPlayerStake(playerlist,stake_type)
	local pokeStakekey = nil 
	if tonumber(stake_type) == 1 then
		pokeStakekey = {"stake_user_code","stake","player_account_balance","multiple","stake_win_or_lose","win_or_lose","game_record_id_fk","game_record_vplayer","stake_type","statemented"}
	else
		pokeStakekey =	{"stake_user_code","stake","player_account_balance","multiple","stake_win_or_lose","win_or_lose","game_record_id_fk","game_record_vplayer","stake_type","poker_type","statemented"}
	end 
	 
	local pokeDbkey = ""
	for i=1,table.getn(pokeStakekey),1 do
			local keyvalue = pokeStakekey[i]
			if pokeDbkey == "" then
			 pokeDbkey	=  keyvalue
			else
			 pokeDbkey = pokeDbkey..","..keyvalue
			end	
	end

	 --获取所有值
	local sqlvalue = ""
	for i,v in ipairs(playerlist) do
		local player = playerlist[i]
			
		local goodsvalue = ""
		for i=1,table.getn(pokeStakekey),1 do
			local keyvalue = pokeStakekey[i]

			if goodsvalue == "" then
			 goodsvalue	=  ngx.quote_sql_str(player[keyvalue])
			else
			 goodsvalue = goodsvalue..","..ngx.quote_sql_str(player[keyvalue])
			end	

		end
		 

		if (sqlvalue == "") then

			sqlvalue = string.format("(%s)",goodsvalue)
		else
				
			sqlvalue = sqlvalue..",".. string.format("(%s)",goodsvalue)

		end	

	end
		

	local ordermemsql = string.format("insert into t_player_stake (%s) values %s",pokeDbkey,sqlvalue)


	local db = mysql:new()
	--事务操作
	--db:query([[START TRANSACTION;]])
	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(ordermemsql)
	
	db:close()
	if not res then
		return nil,err
	end
	return res

end

--[[
	插入押注流水
	@parm playerlist 押注列表

--]]
function _M.insertPlayerAccountProcess(playerlist)
	local pokeStakekey = {"anchor_user_code","user_code","variable","balance","increase","consume"}

	
	 
	local pokeDbkey = ""
	for i=1,table.getn(pokeStakekey),1 do
			local keyvalue = pokeStakekey[i]
			if pokeDbkey == "" then
			 pokeDbkey	=  keyvalue
			else
			 pokeDbkey = pokeDbkey..","..keyvalue
			end	
	end

	 --获取所有值
	local sqlvalue = ""
	for i,v in ipairs(playerlist) do
		local player = playerlist[i]
			
		local goodsvalue = ""
		for i=1,table.getn(pokeStakekey),1 do
			local keyvalue = pokeStakekey[i]

			if goodsvalue == "" then
			 goodsvalue	=  ngx.quote_sql_str(player[keyvalue])
			else
			 goodsvalue = goodsvalue..","..ngx.quote_sql_str(player[keyvalue])
			end	

		end
		 

		if (sqlvalue == "") then

			sqlvalue = string.format("(%s)",goodsvalue)
		else
				
			sqlvalue = sqlvalue..",".. string.format("(%s)",goodsvalue)

		end	

	end
		

	local ordermemsql = string.format("insert into t_account_process (%s) values %s",pokeDbkey,sqlvalue)
	local db = mysql:new()
	--事务操作
	--db:query([[START TRANSACTION;]])
	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(ordermemsql)
	
	db:close()
	if not res then
		return nil,err
	end
	return res

end



return _M