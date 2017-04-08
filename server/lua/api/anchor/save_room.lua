--[[
	新增/保存房间信息
	@param id_pk  有id的是更新，没有id的是新增
	@param password  房间密码
	@param limit_players  最多游戏人数
	@param limit_money  下注最高金额
	@param game_type  游戏类型
	@param anchor_id  主播id
	@param room_name 房间名称
	@param room_status	房间状态  


]]


local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"

-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if  args.password and args.password ~= "" then 
user.password=args.password
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

if args.is_rel_room and args.is_rel_room ~="" then 
user.is_rel_room = args.is_rel_room
end

if args.access_count and args.access_count ~="" then 
user.access_count = args.access_count
end



local userDbOp	= userDb.new()

local temp={}
temp.id_pk=args.id_pk

if args.id_pk and args.id_pk ~= ""  then 
	local dbres,err = userDbOp.updateBaseFromSql("t_anchor_room",user,temp)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to update t_anchor_room")
		return 
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

else
	local dbres,err = userDbOp.insertBaseToSql("t_anchor_room",user)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to add t_anchor_room")
		return 
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

end