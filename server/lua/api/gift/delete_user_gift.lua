--[[
	删除用户礼物  根据用户code或者已知id_pk来删
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

-- if args.user_code and args.user_code~="" then 
-- user.user_code=args.user_code
-- end


local userDbOp = userDb.new()
local res,error=userDbOp.deleteBasefromSql("t_user_gift",user)
if not res then 
	local  result = responeData.new_failed({},error)
	ngx.say(cjson.encode(result))
	return 
end

local  result = responeData.new_success({})
ngx.say(cjson.encode(result))