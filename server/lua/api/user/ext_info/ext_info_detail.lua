--[[
	根据 userCode 获取 用户括展信息
	@param userCode
]]-- 
local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local redis = require "redis.zs_redis" 
local responeData = require"common.api_data_help"
-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()


if not args.user_code and args.user_code ~= "" then	
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return	
end

local user ={}
user.user_code_fk=args.user_code


	local userDbOp = userDb.new()
	local dbres,err = userDbOp.getBaseFromSql("select * from t_user_ext_info",user,"and")

	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))	
		return 
	end

local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))
