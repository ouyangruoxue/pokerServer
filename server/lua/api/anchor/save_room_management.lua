--[[
	新增/保存房管
	@param id_pk  有id的是更新，没有id的是新增

	@param anchor_id  主播id
	@param user_code  房管id



]]



local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"


-- 通用函数  从数据库查询的数据中截取第一条，根据key获取value
function GetNodeWithKey(table, key)
	-- 这里之所以有个临时的temp，是因为从数据库中查询出来的不是一个table，而是一个array table，切记，即使是只查询出来一条，也是array table. 雷区拍照留念
		local temp={}
		temp=table[1]
	return temp[key]
end

-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if args.operator and args.user_code and args.roomid then
	user.anchor_user_code = args.operator
	user.user_code_fk = args.user_code
else  
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return 
end 


	


local userDbOp	= userDb.new()

-- 新增，先判断是否在表中，即是否已经被该主播设为房管，如果设为房管了，就给予提示信息
local dbres1,err1 = userDbOp.getBaseFromSql("select * from t_room_management",user,"and")	
if not dbres1 or table.getn(dbres1)==0 then 


		local caputureAgrs = {}
   		caputureAgrs.roomid = args.roomid
   		caputureAgrs.operator = args.operator
   		caputureAgrs.target = args.user_code
   		caputureAgrs.opt = 1
   		caputureAgrs.optvalue = "true"

   		local  captureRes = ngx.location.capture(
     				'/netease/chatroom/setMemberRole',
     				 { method = ngx.HTTP_POST,body = ngx.encode_args(caputureAgrs)}
 				)

   			local captureTab = cjson.decode(captureRes.body)

   			if tonumber(captureTab.code) ~= 200 then

   				result = responeData.new_failed(res,zhCn_bundles.set_chatroom_error)
				ngx.say(cjson.encode(result))
				return
   			end		



		local dbres2,err2 = userDbOp.insertBaseToSql("t_room_management",user)
		if not dbres2 then 
			local  result = responeData.new_failed({},err2)
			ngx.say(cjson.encode(result))
			return 
		end

		local responeMsg = {}
		responeMsg.message = "设置房管成功"
		responeMsg.operation = 1

		local  result = responeData.new_success(responeMsg)
		ngx.say(cjson.encode(result))
	else
		
		local caputureAgrs = {}
   		caputureAgrs.roomid = args.roomid
   		caputureAgrs.operator = args.operator
   		caputureAgrs.target = args.user_code
   		caputureAgrs.opt = 1
   		caputureAgrs.optvalue = "false"

   		local  captureRes = ngx.location.capture(
     				'/netease/chatroom/setMemberRole',
     				 { method = ngx.HTTP_POST,body = ngx.encode_args(caputureAgrs)}
 				)

   		local captureTab = cjson.decode(captureRes.body)

   			if tonumber(captureTab.code) ~= 200 then

   				result = responeData.new_failed(res,zhCn_bundles.set_chatroom_error)
				ngx.say(cjson.encode(result))
				return
   		end		

		local res,error=userDbOp.deleteBasefromSql("t_room_management",user)
		if not res then 
			local  result = responeData.new_failed({},error)
			ngx.say(cjson.encode(result))
			return 
		end

		local responeMsg = {}
		responeMsg.message = "取消房管成功"
		responeMsg.operation = -1

		local  result = responeData.new_success(responeMsg)
		ngx.say(cjson.encode(result))
	
	end

