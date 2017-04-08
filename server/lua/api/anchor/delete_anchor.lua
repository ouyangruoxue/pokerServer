--[[
	删除主播  根据id_pk和user_code来删除主播
	@param id_pk
	@param user_code

]]

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
else 
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return 
end 

local userDbOp = userDb.new()
local res,error=userDbOp.deleteBasefromSql("t_anchor",user)
if not res then 
	local  result = responeData.new_failed({},error)
	ngx.say(cjson.encode(result))
	return 
end

local  result = responeData.new_success({})
ngx.say(cjson.encode(result))
