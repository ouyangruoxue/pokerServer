--[[
	获取游戏类型列表
	@param room_id_pk
	@param password
	@param parent_game 上一级游戏
	
]]--
local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"

-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if  not args.room_id_pk or not args.password then
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return 
end 


if args.room_id_pk and args.room_id_pk~="" then 
user.id_pk=args.room_id_pk
end 

if args.password and args.password~="" then 
user.password=args.password
end


	-- 从数据库中查询
local userDbOp = userDb:new()
	local dbres,err = userDbOp.getBaseFromSql("select * from t_anchor_room",user,"and")
if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		return 
end

if type(dbres) == "table" then

	local tablelength = table.getn(dbres)

	if tablelength >0 then
		local  result = responeData.new_success({})
		ngx.say(cjson.encode(result))
	else
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
	end	

end	


