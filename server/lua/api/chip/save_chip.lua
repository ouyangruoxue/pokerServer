--[[
	新增/保存筹码
	@param id_pk  有id的是更新，没有id的是新增

	@param chip_name 筹码名称
	@param chip_icon 筹码图标
	@param chip_value 筹码价值
	@param chip_level 筹码等级
	@param chip_explain 筹码说明
	@param room_id_fk 对应房间号 如果是系统默认的，为0
	@param is_publish 是否发布
]]


local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"

-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if  args.chip_name and args.chip_name ~= "" then 
user.chip_name=args.chip_name
end
if  args.chip_icon and args.chip_icon ~= "" then 
user.chip_icon=args.chip_icon
end
if  args.chip_value and args.chip_value ~= ""  then 
user.chip_value=args.chip_value
end
if  args.chip_level and args.chip_level ~= ""  then 
user.chip_level=args.chip_level
end
if  args.chip_explain and args.chip_explain ~= ""  then 
user.chip_explain=args.chip_explain
end
if  args.room_id_fk and args.room_id_fk ~= ""  then 
user.room_id_fk=args.room_id_fk
end
if  args.is_publish and args.is_publish ~= ""  then 
user.is_publish=args.is_publish
end


local userDbOp	= userDb.new()

local temp={}
temp.id_pk=args.id_pk

if args.id_pk and args.id_pk ~= ""  then 
	local dbres,err = userDbOp.updateBaseFromSql("t_chip",user,temp)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to update t_chip")
		return 
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

else
	local dbres,err = userDbOp.insertBaseToSql("t_chip",user)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to add t_chip")
		return 
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

end
