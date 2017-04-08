--[[
	获取房间列表
	@param id_pk
	@param limit_players 最高人数
	@param limit_money 最高金额
	@param game_type 游戏类型
	@param anchor_id 主播id
	@param room_name 房间名称
	@param room_status 房间状态

]]--


local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"
-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if args.id_pk and args.id_pk~="" then 
user.id_pk=args.id_pk
end 

if  args.limit_players and args.limit_players ~= "" then 
user.limit_players=args.limit_players
end

if  args.limit_money and args.limit_money ~= "" then 
user.limit_money=args.limit_money
end


if  args.game_type and args.game_type ~= "" then 
user.game_type=args.game_type
end


if  args.anchor_id and args.anchor_id ~= "" then 
user.anchor_id_fk=args.anchor_id
end

if  args.room_name and args.room_name ~= "" then 
user.room_name=args.room_name
end

if  args.room_status and args.room_status ~= "" then 
user.room_status=args.room_status
end


	-- 从数据库中查询
	ngx.log(ngx.INFO,"now query by database...")
	local userDbOp = userDb.new()
	local dbres,err = userDbOp.getBaseFromSql("select * from t_anchor_room",user,"and")
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return err
	end


local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))
