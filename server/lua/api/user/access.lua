local cjson = require "cjson"
local baseDb = require "db.base_db"
local userDb = require "db.user.multi_sqlTab_db"
local reqArgs = require "common.request_args"
local redis = require "redis.zs_redis"
local systemConf = require "common.systemconfig"
local str = require "resty.string"
local uuid = require 'resty.jit-uuid'
local responeData = require "common.api_data_help"
local redis_lock = require "common.redis_lock"
local red = redis:new()
local baseDbOP = baseDb.new();
local userDbOp = userDb.new();


local function normalLogin(loginparm,args)
local result = {}
local  responseBody = {}
local res ,err = baseDbOP.getBaseFromSql("select * from t_user",loginparm,"and",0,1)
if not res then
		result = responeData.new_failed({},err)
else
	if type(res) == "table" then
		if table.getn(res) > 0 then
			--已存在用户
			local mapuser = res[1]
   			 --生成唯一token
   			ngx.update_time()
 			 local t2 = ngx.now()
   			 uuid.seed(t2)
   			--账户更新
   			local balanceupdate = {}
   			--资金对比为1比100
   			balanceupdate.balance =  tonumber(args.money)*100 

   			local redisres ,rediserr = red:set("balance_"..mapuser["user_code"],balanceupdate.balance)
            if not redisres then
                 ngx.log(ngx.ERR, "failed to update redis balance info")
                 result = responeData.new_failed({},err)
                 return       
            end 
   			local  uuidst = uuid()
			local  token = uuid.generate_v3(uuidst,mapuser["user_code"])
		 	responseBody.user_code = mapuser["user_code"]
		 	responseBody.token = token


		 	local caputureAgrs = {}
   			caputureAgrs.accid = mapuser["user_code"]
   			caputureAgrs.token = token
   			local  captureRes = ngx.location.capture(
     				'/netease/user/update',
     				 { method = ngx.HTTP_POST,body = ngx.encode_args(caputureAgrs)}
 				)

   			local captureTab = cjson.decode(captureRes.body)

   			if tonumber(captureTab.code) ~= 200 then

   				result = responeData.new_failed(res,zhCn_bundles.login_connect_chatroom_error)
				ngx.say(cjson.encode(result))
				return
   			end	

			local extparm = {}
   			extparm.user_code_fk =  mapuser["user_code"]
			
			local resext ,errext = baseDbOP.getBaseFromSql("select * from t_user_ext_info",extparm,"and",0,1)
   			
   			if not resext then
   				ngx.log(ngx.ERR, "failed to get access userinfo")
   			else
   				reslength = table.getn(resext)
			--判断是否查询到结果
				if reslength > 0 then
   					responseBody.ext_info = resext[1]
				end
			end	
   			
   			resext ,err = baseDbOP.updateBaseFromSql("t_account",balanceupdate,extparm)
			if not resext then
				ngx.log(ngx.ERR, "failed to access userinfo")
			end

			if not responseBody.ext_info then
				responseBody.isNewUser = 0
			else
				if responseBody.ext_info.nickname then
					responseBody.isNewUser = 0	
				else
					responseBody.isNewUser = 1	
				end
			end	

			
   			responseBody.balance = balanceupdate.balance
   			result = responeData.new_success(responseBody)
		else
			
				local balanceinsert = {} 
				balanceinsert.balance = tonumber(args.money)*100
				balanceinsert.user_code_fk = loginparm.user_code

				ngx.update_time()
 			 	local t2 = ngx.now()
   				 uuid.seed(t2)
 				local  uuidst = uuid()
				local  token = uuid.generate_v3(uuidst,loginparm.user_code)
				
				local caputureAgrs = {}
   				caputureAgrs.accid = loginparm.user_code
   				caputureAgrs.token = token
   				local  captureRes = ngx.location.capture(
     				'/netease/user/create',
     				 { method = ngx.HTTP_POST,body = ngx.encode_args(caputureAgrs)}
 				)
   				local captureTab = cjson.decode(captureRes.body)
   				if tonumber(captureTab.code) ~= 200 then
   					result = responeData.new_failed(res,zhCn_bundles.login_connect_chatroom_error)
					ngx.say(cjson.encode(result))
					return
   				end	


				local redisres ,rediserr = red:set("balance_"..loginparm.user_code,balanceinsert.balance)
            	if not redisres then
                	 ngx.log(ngx.ERR, "failed to insert redis balance info")
                	 result = responeData.new_failed({},err)
                 	return       
          			end 
          		loginparm.is_real_user = 1	
				res ,err = userDbOp.acessThirdUser(loginparm,balanceinsert)
					if not res then
						ngx.log(ngx.ERR, "failed to access user")
							result = responeData.new_failed(res,zhCn_bundles.login_error)
							ngx.say(cjson.encode(result))
						return
					end	

		 --保存到redis 并设置时长
   					red:set(token,responseBody.user_code)
					red:expire(token,systemConf.monthTimeSec)

					responseBody.user_code = loginparm.user_code
					responseBody.balance = balanceinsert.balance 
					responseBody.isNewUser = 1
					responseBody.token = token
					result = responeData.new_success(responseBody)
			end	
	else 
		result = responeData.new_failed({},err)
	end	

end	 	
ngx.say(cjson.encode(result))
end 
	

function saveUserInRecord(parm)
	local temp = {} 
	temp.money = parm.money
	temp.user_code = parm.accounts

	ngx.update_time()
	local t2 = ngx.now()
	local ide = t2..parm.accounts
	local rels = ngx.md5(ide)
	temp.order_number = rels
	temp.in_out = 0

	local res ,err = baseDbOP.insertBaseToSql("t_user_inout",temp)

	if not res then
		return false,err
	end
	
	return true 	

end



local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

if not args.money  or not args.accounts then
	local result =  responeData.new_failed({},zhCn_bundles.db_parm_error)
	return ngx.say(cjson.encode(result))
end	

local isrecord,err = saveUserInRecord(args)

if not isrecord then
	local result =  responeData.new_failed({},err)
	return ngx.say(cjson.encode(result))
end

local userParm = {}
userParm.user_code = args["accounts"]			
normalLogin(userParm,args)







