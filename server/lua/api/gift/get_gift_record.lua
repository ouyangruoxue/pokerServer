--[[
	获取送礼纪录列表
	@param id_pk
	@param gift_name

	由于送礼纪录需要根据接收人code来分组，然后根据时间来排行，所以需要定制
	
]]--
local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"
-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if not args.page or not args.rec_user_code then	
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return	
end

if args.rec_user_code and args.rec_user_code~="" then 
user.rec_user_code=args.rec_user_code
end

if args.send_user_code and args.send_user_code~="" then 
user.send_user_code=args.send_user_code
end

if args.statemented and args.statemented~="" then 
user.statemented=args.statemented
end

if args.gift_time and args.gift_time~="" then 
user.gift_time=args.gift_time
end

local startindex = (tonumber(args.page)-1)*20

local offset = (tonumber(args.page))*20


	-- 从数据库中查询
	ngx.log(ngx.INFO,"now query by database...")
	local userDbOp = userDb.new()
	local dbres,err = userDbOp.getBaseFromSql("select a.*,b.gift_name,b.gift_logo,c.nickname from t_gift_record a LEFT JOIN t_gift_type b ON b.id_pk = a.gift_type_id_fk LEFT JOIN t_user_ext_info c ON c.user_code_fk = a.send_user_code",user,"and",startindex,offset)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return 
	end


local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))
