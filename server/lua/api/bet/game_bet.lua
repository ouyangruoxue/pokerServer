--[[
	
   id_pk                bigint not null,
   stake_user_code      varchar(0),下注人
   stake                double, 下注金额
   multiple             double,	 翻倍倍数
   win_or_lose          int comment '0输1赢',
   game_record_vplayer  varchar(255),牌局玩家编号
   stake_type           int comment '押注类型1输赢2牌型',
   poker_type           int,		下注的牌型
   statemented          int comment '0未结算1已经结算',
--]]


local cjson = require "cjson"
local baseDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local anchors = require "chat_room.anchors_chat_rooms"
local redis = require "redis.zs_redis"
local baseDbOp = baseDb.new();
local red = redis:new()
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

if not args.stake_user_code  or not args.stake 
  or not args.game_record_vplayer 
	or not args.stake_type or not args.multiple or not args.room_id_pk then
	local result =  responeData.new_failed({},zhCn_bundles.db_parm_error)
	return ngx.say(cjson.encode(result))
end	

if tonumber(args.stake_type) == 2 and not args.poker_type then
	local result =  responeData.new_failed({},zhCn_bundles.db_parm_error)
	return ngx.say(cjson.encode(result))
end	

if tonumber(args.stake_type) == 1 and not args.stake_win_or_lose then
  local result =  responeData.new_failed({},zhCn_bundles.db_parm_error)
  return ngx.say(cjson.encode(result))
end 





local sqlbetArgs = {}
local roomBetArgs = {}
sqlbetArgs.game_record_vplayer = args.game_record_vplayer
sqlbetArgs.stake = args.stake
--默认未结算，比较牌局结果后批量更新
sqlbetArgs.statemented = 0
if args.poker_type and args.poker_type ~= "" then
	sqlbetArgs.poker_type = args.poker_type
  if tonumber(sqlbetArgs.stake_type) == 1 then
    local result =  responeData.new_failed({},zhCn_bundles.db_parm_error)
    return ngx.say(cjson.encode(result))
  end  
end


if args.stake_win_or_lose and args.stake_win_or_lose ~="" then
  sqlbetArgs.stake_win_or_lose = args.stake_win_or_lose
  if tonumber(sqlbetArgs.stake_type) == 2 then
    local result =  responeData.new_failed({},zhCn_bundles.db_parm_error)
    return ngx.say(cjson.encode(result))
  end  
end  


--默认为0结果出来后批量更新数据库	
sqlbetArgs.win_or_lose = 0

sqlbetArgs.multiple = args.multiple
	
sqlbetArgs.stake_type = args.stake_type
sqlbetArgs.stake_user_code = args.stake_user_code

if args.nickname then

  sqlbetArgs.nickname = args.nickname

end  


--寻找对应房间
local chat_room = nil
if args.room_id_pk then
	chat_room = anchors:getChatRoom(args.room_id_pk)
end

if not chat_room then
	local result =  responeData.new_failed({},zhCn_bundles.db_parm_error)
	return ngx.say(cjson.encode(result))
end	
local currentBalance = 0
 local balance ,err = red:get("balance_"..sqlbetArgs.stake_user_code)
  if balance then
      currentBalance = tonumber(balance) - tonumber(sqlbetArgs.stake)
     if currentBalance > 0 then
        sqlbetArgs.player_account_balance = currentBalance
        local res ,err = red:set("balance_"..sqlbetArgs.stake_user_code,currentBalance)
          if not res then
             local  result = responeData.new_failed({},err)
             ngx.say(cjson.encode(result))
            return
         end 
      else
       
        local  result = responeData.new_failed({},"balance is not enough")
          ngx.say(cjson.encode(result))
          return
      end

  else

    	local  result = responeData.new_failed({},err)
		  ngx.say(cjson.encode(result))
		  return
  end 
--加入房间押注内存中
local ok =  chat_room:bet(sqlbetArgs)
if ok ~= 0 then
--失败的话返回扣除的金额
 local balance ,err = red:get("balance_"..sqlbetArgs.stake_user_code)
  if balance then
      currentBalance = tonumber(balance) + tonumber(sqlbetArgs.stake)
       local res ,err = red:set("balance_"..sqlbetArgs.stake_user_code,currentBalance)
 	   if not res then
       		ngx.log(ngx.ERR,"return stake fail")
	   return
	   end
  end 

	local  result = responeData.new_failed({},"bet fail")
		ngx.say(cjson.encode(result))
	return
end	

local reponse = {}
reponse.balance  = currentBalance
local  result = responeData.new_success(reponse)
ngx.say(cjson.encode(result))
