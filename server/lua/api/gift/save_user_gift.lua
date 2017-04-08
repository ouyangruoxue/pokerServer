--[[
	新增/保存用户礼物
	@param id_pk  有id的是更新，没有id的是新增

	@param user_code  用户名code
	@param gift_id_fk  礼物类型
	@param gift_numbers  礼物数量
	@param ex_code  扩展字段

]]


local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"


-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if  args.user_code and args.user_code ~= "" then 
user.user_code=args.user_code
end
if  args.gift_id_fk and args.gift_id_fk ~= "" then 
user.gift_id_fk=args.gift_id_fk
end
if  args.gift_numbers and args.gift_numbers ~= ""  then 
user.gift_numbers=args.gift_numbers
end
if  args.ex_code and args.ex_code ~= ""  then 
user.ex_code=args.ex_code
end

local userDbOp	= userDb.new()

local temp={}
temp.id_pk=args.id_pk

if args.id_pk and args.id_pk ~= ""  then 
	local dbres,err = userDbOp.updateBaseFromSql("t_user_gift",user,temp)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to update t_user_gift")
		return err
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

else
	local dbres,err = userDbOp.insertBaseToSql("t_user_gift",user)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to add t_user_gift")
		return err
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

end
