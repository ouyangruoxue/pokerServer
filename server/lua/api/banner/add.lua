--[[
    id_pk                bigint not null,
   anchor_id_fk         bigint,
   banner_icon          varchar(255),
   banner_type          int comment '0主播1视频2网页。',
   banner_title         varchar(255),
   online_time          datetime,
   offline_time         datetime,
   banner_status        int comment '0下线1上线',
   url					banner类型为网页的字段
   context				banner类型为视频/内容的字段
]]--
local cjson = require "cjson"
local basedb = require "db.base_db"
local reqArgs = require "common.request_args"
local redis = require "redis.zs_redis" 
local responeData = require"common.api_data_help"




-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

--必须带的参数
-- if not args.anchor_id_fk or
-- 	 not args.banner_type  or
-- 	 not args.banner_title or
-- 	 not args.online_time  or not args.banner_status then	
-- 	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
-- 	ngx.say(cjson.encode(result))
-- 	return	
-- end

if  not args.banner_type  or
	 not args.banner_title then	
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return	
end



local temp ={}
local user={}
if  args.anchor_id_fk and args.anchor_id_fk ~= "" then 
	temp.anchor_id_fk=args.anchor_id_fk
end

if  args.banner_icon and args.banner_icon ~= "" then 
	temp.banner_icon=args.banner_icon
end

if  args.banner_type and args.banner_type ~= "" then 
	temp.banner_type=args.banner_type
end

if  args.banner_title and args.banner_title ~= "" then 
	temp.banner_title=args.banner_title
end

if  args.online_time and args.online_time ~= "" then 
	temp.online_time=args.online_time
end

if  args.banner_status and args.banner_status ~= "" then 
	temp.banner_status=args.banner_status
end

if  args.offline_time and args.offline_time ~= "" then 
	temp.offline_time=args.offline_time
end

if  args.url and args.url ~= "" then 
	temp.url=args.url
end

if  args.context and args.context ~= "" then 
	temp.context=args.context
end


local basedbOp = basedb.new()

if args.id_pk and args.id_pk ~= ""  then 
user.id_pk=args.id_pk
	local dbres,err = basedbOp.updateBaseFromSql("t_banner",temp,user)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		return 
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))


else

	local dbres,err = basedbOp.insertBaseToSql("t_banner",temp)
	if not dbres then 
			local  result = responeData.new_failed({},err)
			ngx.say(cjson.encode(result))
			return err
		end

	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))
end