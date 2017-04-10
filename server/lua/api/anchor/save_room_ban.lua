--[[
	新增/保存禁言信息
	@param id_pk  有id的是更新，没有id的是新增

	@param anchor_id  主播id
	@param user_code  房管id



]]



local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"


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

	-- 新增，先判断是否在表中，即是否已经被禁言，已经被禁言则直接提示禁言，未被禁言则操作下一步
	local dbres1,err1 = userDbOp.getBaseFromSql("select * from t_room_ban",user,"and")
	if not dbres1 or table.getn(dbres1)==0 then 

	local caputureAgrs = {}
	caputureAgrs.roomid = args.roomid
	caputureAgrs.operator = args.operator
	caputureAgrs.target = args.user_code
	caputureAgrs.opt = -2 
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


		local dbres,err = userDbOp.insertBaseToSql("t_room_ban",user)
		if not dbres then 
			local  result = responeData.new_failed({},err)
			ngx.say(cjson.encode(result))
			ngx.log(ngx.ERR,"faild to add t_room_ban")
			return 
		end
		-- ngx.say(cjson.encode(dbres))
		local  result = responeData.new_success({message="禁言成功"})
		ngx.say(cjson.encode(result))
	else

		local caputureAgrs = {}
			caputureAgrs.roomid = args.roomid
			caputureAgrs.operator = args.operator
			caputureAgrs.target = args.user_code
			caputureAgrs.opt = -2 
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

		local res,error=userDbOp.deleteBasefromSql("t_room_ban",user)
		if not res then 
			local  result = responeData.new_failed({},error)
			ngx.say(cjson.encode(result))
			return 
		end
		local  result = responeData.new_success({message="取消禁言成功"})
		ngx.say(cjson.encode(result))
	end


