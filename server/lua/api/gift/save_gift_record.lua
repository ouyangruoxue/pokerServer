--[[
	新增/保存送礼纪录
	@param id_pk  有id的是更新，没有id的是新增

	@param rec_user_code  收礼人code
	@param send_user_code  送礼人code
	@param gift_type_id_fk  礼物类型
	@param gift_number  礼物数量
	@param gift_time  送礼时间
	@param statemented  是否结算



]]


local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"

-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if  args.rec_user_code and args.rec_user_code ~= "" then 
user.rec_user_code=args.rec_user_code
end
if  args.send_user_code and args.send_user_code ~= "" then 
user.send_user_code=args.send_user_code
end
if  args.gift_type_id_fk and args.gift_type_id_fk ~= ""  then 
user.gift_type_id_fk=args.gift_type_id_fk
end
if  args.gift_number and args.gift_number ~= ""  then 
user.gift_number=args.gift_number
end
if  args.gift_time and args.gift_time ~= ""  then 
user.gift_time=args.gift_time
end
if  args.statemented and args.statemented ~= ""  then 
user.statemented=args.statemented
end



local userDbOp	= userDb.new()

local temp={}
temp.id_pk=args.id_pk

if args.id_pk and args.id_pk ~= ""  then 
	local dbres,err = userDbOp.updateBaseFromSql("t_gift_record",user,temp)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to update t_gift_record")
		return err
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

else
	local dbres,err = userDbOp.insertBaseToSql("t_gift_record",user)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to add t_gift_record")
		return err
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

end
