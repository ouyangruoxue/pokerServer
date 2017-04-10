--[[
	新增/保存主播
	@param id_pk  有id的是更新，没有id的是新增

	@param anchor_push_ur  主播推流地址
	@param anchor_url  主播流地址
	@param video_info  推流账户
	@param channel_business  所属渠道商
	@param anchor_status  主播状态
	@param user_code  用户编号
	@param anchor_title  直播标题
	@param anchor_description  直播描述
	@param anchor_live_time  直播时长
	@param signing_time  签约时间


]]


local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"

-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if  args.anchor_push_ur and args.anchor_push_ur ~= "" then 
user.anchor_push_ur=args.anchor_push_ur
end
if  args.anchor_url and args.anchor_url ~= "" then 
user.anchor_url=args.anchor_url
end
if  args.video_info and args.video_info ~= ""  then 
user.video_info=args.video_info
end
if  args.channel_business and args.channel_business ~= ""  then 
user.channel_business=args.channel_business
end
if  args.anchor_status and args.anchor_status ~= ""  then 
user.anchor_status=args.anchor_status
end
if  args.user_code and args.user_code ~= ""  then 
user.user_code_fk=args.user_code
end
if  args.anchor_title and args.anchor_title ~= ""  then 
user.anchor_title=args.anchor_title
end
if  args.anchor_description and args.anchor_description ~= ""  then 
user.anchor_description=args.anchor_description
end
if  args.anchor_live_time and args.anchor_live_time ~= ""  then 
user.anchor_live_time=args.anchor_live_time
end
if  args.signing_time and args.signing_time ~= ""  then 
user.signing_time=args.signing_time
end



local userDbOp	= userDb.new()

local temp={}
temp.id_pk=args.id_pk

if args.id_pk and args.id_pk ~= ""  then 
	local dbres,err = userDbOp.updateBaseFromSql("t_anchor",user,temp)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to update t_anchor")
		return 
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

else
	local dbres,err = userDbOp.insertBaseToSql("t_anchor",user)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to add t_anchor")
		return 
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

end
