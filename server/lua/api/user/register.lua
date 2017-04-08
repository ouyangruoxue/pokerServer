local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local redis_lock = require "common.redis_lock"
local redis = require "redis.zs_redis"
local red = redis:new()

--参数表
local user = {}	
--判断用户是否存在
local existUser = {}

local userDbOp = userDb.new();
--获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()


if not  args["user_name"] or not args["password"] then

	local result =  responeData.new_failed({},zhCn_bundles.db_parm_error)
	return ngx.say(cjson.encode(result))

end	


if args["user_name"] then
	existUser.user_name = args["user_name"];
end

if args["email"] then
	existUser.email = args["email"];
end	

if args["phone_number"] then

	existUser.phone_number = args["phone_number"];

end
ngx.say(cjson.encode(existUser))


local res ,err = userDbOp.getBaseFromSql("select * from t_user",existUser,"or",0,1)
	
	if not res then
		local result =  responeData.new_failed({},zhCn_bundles.db_parm_error)
		return ngx.say(cjson.encode(result))
	else

		if table.getn(res) > 0 then
			local result =  responeData.new_failed({},"已结存在")
			return ngx.say(cjson.encode(result))
		end
	end		
			

if args["user_name"] then
	user.user_name = args["user_name"];
end

if args["email"] then
	user.email = args["email"];
end	

if args["phone_number"] then
	user.phone_number = args["phone_number"];
end

if args["password"] then
	user.password = ngx.md5(args["password"]);
end


user.status = 1;
user.user_code = redis_lock.generateUniqueUserCode("wj_game_user_code",1) 

 res ,err = userDbOp.insertBaseToSql("t_user",user)

if not res then

	   ngx.say(cjson.encode(responeData.new_failed({},err)))
	else
	   ngx.say(cjson.encode(responeData.new_success({})))
end

 