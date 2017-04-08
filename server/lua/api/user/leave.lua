local cjson = require "cjson"
local baseDb = require "db.base_db"
local reqArgs = require "common.request_args"
local redis = require "redis.zs_redis"
local responeData = require "common.api_data_help"

local red = redis:new()
local baseDbOP = baseDb.new();


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

if not args.user_code  then
	local result =  responeData.new_failed({},zhCn_bundles.db_parm_error)
	return ngx.say(cjson.encode(result))
end	


function saveUserOutRecord(parm)
	local temp = {} 
	temp.money = parm.money
	temp.user_code = parm.accounts

	ngx.update_time()
	local t2 = ngx.now()
	local ide = t2..parm.accounts
	local rels = ngx.md5(ide)
	temp.order_number = rels
	temp.in_out = 1

	local res ,err = baseDbOP.insertBaseToSql("t_user_inout",temp)

	if not res then
		return false,err
	end
	
	return true , rels 	

end

local redisres ,rediserr = red:get("balance_"..args.user_code)
if not redisres then
	ngx.log(ngx.ERR, "failed to insert redis balance info")
	result = responeData.new_failed({},err)
	return       
end

local outParm = {}
outParm.accounts = args.user_code
outParm.money = tonumber(redisres)/100


local userleave = {}
userleave.money = outParm.money
userleave.accounts = args.user_code

local isrecord,info = saveUserOutRecord(outParm)
if not isrecord then
	local result =  responeData.new_failed({},err)
	return ngx.say(cjson.encode(result))

else
	outParm.order_number = info
end

ngx.say(cjson.encode(userleave))
--获取access_token
-- local res, err = httpc:request_uri("https://api.weixin.qq.com/sns/oauth2/access_token", {
--         method = "GET",
--         query = {
--                 grant_type = "authorization_code",
--                 appid = "wx5dd7a03e3fe86262", --填写自己的appid
--                 secret = "9b47297518f953376dec0c5b0697dd42", -- 填写自己的secret
--                 code = args["code"],
--         },
--         ssl_verify = false, -- 需要关闭这项才能发起https请求
--         headers = {["Content-Type"] = "application/x-www-form-urlencoded" },
--       })

-- if not res then
--         local  result = respone.new_failed({},err)
--         ngx.say(cjson.encode(result))
--         return
-- end