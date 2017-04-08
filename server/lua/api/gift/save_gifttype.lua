--[[
	新增/保存礼物类型
	@param id_pk  有id的是更新，没有id的是新增

	@param gift_name  礼物名称
	@param gift_logo  礼物图标
	@param gift_description  礼物描述
	@param gift_value  礼物价值
	@param gift_effect  礼物特效模板
	@param gift_valid  礼物有效期
	@param gift_create_time  礼物创建时间
	@param gift_invalid_time  礼物过期时间
	@param is_join_share 是否参与主播分红结算


]]


local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"


-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if  args.gift_name and args.gift_name ~= "" then 
user.gift_name=args.gift_name
end
if  args.gift_logo and args.gift_logo ~= "" then 
user.gift_logo=args.gift_logo
end
if  args.gift_description and args.gift_description ~= ""  then 
user.gift_description=args.gift_description
end
if  args.gift_value and args.gift_value ~= ""  then 
user.gift_value=args.gift_value
end
if  args.gift_effect and args.gift_effect ~= ""  then 
user.gift_effect=args.gift_effect
end
if  args.gift_valid and args.gift_valid ~= ""  then 
user.gift_valid=args.gift_valid
end
if  args.gift_create_time and args.gift_create_time ~= ""  then 
user.gift_create_time=args.gift_create_time
end
if  args.gift_invalid_time and args.gift_invalid_time ~= ""  then 
user.gift_invalid_time=args.gift_invalid_time
end

if  args.is_join_share and args.is_join_share ~= ""  then 
user.is_join_share=args.is_join_share
end


local userDbOp	= userDb.new()

local temp={}
temp.id_pk=args.id_pk

if args.id_pk and args.id_pk ~= ""  then 
	local dbres,err = userDbOp.updateBaseFromSql("t_gift_type",user,temp)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to update t_gift_type")
		return err
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

else
	local dbres,err = userDbOp.insertBaseToSql("t_gift_type",user)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to add t_gift_type")
		return err
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

end
