--[[
	 新增/修改 用户扩展信息，有id就是修改，没有id就是新增
	 @param id_pk
	 @param user_code_fk
	 @param nickname
	 @param head_icon
	 @param sex
	 @param signature
	 @param hometown
	 @param location
	 @param company
	 @param college
	 @param birthday
	 @param profession
	 @param blood_type
	 @param marriage
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

local caputureAgrs = {}
caputureAgrs.accid = args.user_code


local user ={}
if args.id_pk and args.id_pk~="" then 
	user.id_pk=args.id_pk
end 

if args.user_code and args.user_code~="" then 
	user.user_code_fk=args.user_code
end 

if args.nickname and args.nickname~="" then 
	user.nickname=args.nickname
	caputureAgrs.name = args.nickname
end 

if args.head_icon and args.head_icon~="" then 
	user.head_icon=args.head_icon
	caputureAgrs.icon = args.head_icon
end 

if args.sex and args.sex~="" then 
	user.sex=args.sex
	caputureAgrs.gender = args.sex
end 

if args.signature and args.signature~="" then 
	user.signature=args.signature
	caputureAgrs.sign = args.signature
end 
if args.hometown and args.hometown~="" then 
	user.hometown=args.hometown
end 

if args.location and args.location~="" then 
	user.location=args.location
end 

if args.company and args.company~="" then 
	user.company=args.company
end 

if args.college and args.college~="" then 
	user.college=args.college
end 

if args.birthday and args.birthday~="" then 
	user.birthday=args.birthday
end 

if args.profession and args.profession~="" then 
	user.profession=args.profession
end 

if args.blood_type and args.blood_type~="" then 
	user.blood_type=args.blood_type
end 

if args.marriage and args.marriage~="" then 
	user.marriage=args.marriage
end 


			local  captureRes = ngx.location.capture(
     			'/netease/user/updateUinfo',
     			 { method = ngx.HTTP_POST,body = ngx.encode_args(caputureAgrs)}
 			)

		local captureTab = cjson.decode(captureRes.body)

 			if tonumber(captureTab.code) ~= 200 then
  	 			result = responeData.new_failed(res,zhCn_bundles.set_chatroom_error)
					ngx.say(cjson.encode(result))
				return
 			end





local userDbOp = userDb.new()
local dbres = nil
local err = nil
if not args["id_pk"] then

--新增	
 dbres,err = userDbOp.insertBaseToSql("t_user_ext_info",user)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		return 
	end

else

	--更新
	local kParm = {}

	kParm.user_code_fk = args["user_code_fk"];
	kParm.id_pk = args["id_pk"];

	-- 将数据存放到数据库中去
	dbres,err = userDbOp.updateBaseFromSql("t_user_ext_info",user,kParm)

	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		return 
	end

end
	

local  result = responeData.new_success({})
ngx.say(cjson.encode(result))
-- 这里是修改




