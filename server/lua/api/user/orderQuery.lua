local cjson = require "cjson"
local baseDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"

local baseDbOP = baseDb.new();
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

if not args.order_number  then
	local result =  responeData.new_failed({},zhCn_bundles.db_parm_error)
	return ngx.say(cjson.encode(result))
end	



local temp = {} 
temp.order_number = args.order_number

local res ,err = baseDbOP.getBaseFromSql("select * from t_user_inout",temp)

if not res then
	local result =  responeData.new_failed({},err)
	return ngx.say(cjson.encode(result))
end

local reslength = table.getn(res)
	--判断是否查询到结果
	if reslength > 0 then
		local mapuser = res[1]
		local result = responeData.new_success(mapuser) 
		ngx.say(cjson.encode(result))
	

	else

	local result = responeData.new_failed({},"no data")
	ngx.say(cjson.encode(result))

end
