--[[
	获取玩家礼物列表
	@param id 
	
]]--

local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"
-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if args.user_code and args.user_code~="" then 
user.user_code=args.user_code
end 

if args.id_pk and args.id_pk~="" then 
user.id_pk=args.id_pk
end

	-- 从数据库中查询
	ngx.log(ngx.INFO,"now query by database...")
	local userDbOp = userDb.new()
	local dbres,err = userDbOp.getBaseFromSql("select * from t_user_gift",user,"and")
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return err
	end


local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))

