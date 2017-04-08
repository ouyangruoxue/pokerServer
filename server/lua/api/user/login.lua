local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local redis = require "redis.zs_redis"
local systemConf = require "common.systemconfig"
local str = require "resty.string"
local uuid = require 'resty.jit-uuid'
local responeData = require"common.api_data_help"
local red = redis:new()
local userDbOp = userDb.new();

--设置删除时间15秒
-- local res2 err2 = red:expire("dog",15)

--[[
---一般登录（用户名，邮箱，电话）

--]]

local function normalLogin(loginparm)
local result = {}
local res ,err = userDbOp.getBaseFromSql("select * from t_user",loginparm,"and",0,1)

if not res then
	
		result = responeData.new_failed({},err)
		return 
else

	if type(res) == "table" then

		local reslength = table.getn(res)
		--判断是否查询到结果
		if reslength > 0 then

			local mapuser = res[1]
   			--判断用户是否为空

   			local responebody = {}
   			 --生成唯一token
   			 ngx.update_time()
 			 local t2 = ngx.now()
   			 uuid.seed(t2)
   			 local  uuidst = uuid()
			 local  token = uuid.generate_v3(uuidst,mapuser["user_code"])
			 responebody.user_code = mapuser["user_code"]
			 responebody.token = token

			local extparm = {}
   			extparm.user_code_fk =  mapuser["user_code"]
   			local resext ,errext = userDbOp.getBaseFromSql("select * from t_user_ext_info",extparm,"and",0,1)
   			 reslength = table.getn(resext)
			--判断是否查询到结果
			if reslength > 0 then
   				responebody.ext_info = resext[1]
			end

   			local resaccount ,erraccount = userDbOp.getBaseFromSql("select * from t_account",extparm,"and",0,1)

   			 reslength = table.getn(resaccount)
			--判断是否查询到结果
			if reslength > 0 then
   				responebody.account = resaccount[1]
			end
   			--如果是主播查询主播信息

   			--if mapuser["status"] == "2" then
   			local resanchor ,erranchor = userDbOp.getBaseFromSql("SELECT a.*,b.id_pk AS room_id_pk,b.limit_money,b.password,b.limit_players,c.roomid as neteaseChatRoomId FROM t_anchor  a LEFT JOIN t_anchor_room b ON b.anchor_id_fk = a.id_pk LEFT JOIN t_netease_chat_room c ON c.anchor_user_code = a.user_code_fk",extparm,"and",0,1)
   				 reslength = table.getn(resanchor)
			--判断是否查询到结果
			local anchor = nil
				if reslength > 0 then
					anchor = resanchor[1]
   					responebody.anchor = anchor
				end
   			--end	

   			if not anchor then
   				result = responeData.new_failed({},err)
   				ngx.say(cjson.encode(result))
   				return 
   			end	
   		

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



   			 --保存到redis 并设置时长
   			 red:set(token,responebody.user_code)
			 red:expire(token,systemConf.monthTimeSec)
			 
			 result = responeData.new_success(responebody)

		else
				
			 result = responeData.new_failed(res,zhCn_bundles.login_error)
		end
	else 
		result = responeData.new_failed({},err)
	end		
	
end	 	
ngx.say(cjson.encode(result))

end 


				
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()



		local userParm = {}
		userParm.user_name = args["user_name"];
		userParm.password = args["password"];

		if not userParm.user_name or not userParm.password then
			local result =  responeData.new_failed({},zhCn_bundles.login_error)
			return ngx.say(cjson.encode(result))
		end
		
		normalLogin(userParm)

