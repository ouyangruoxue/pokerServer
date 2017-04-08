--[[
  id_pk                bigint not null,
   anchor_id_fk         bigint,
   banner_icon          varchar(255),
   banner_type          int comment '0主播1视频2网页。',
   banner_title         varchar(255),
   online_time          datetime,
   offline_time         datetime,
   banner_status        int comment '0下线1上线',
]]--
local cjson = require "cjson"
local basedb = require "db.base_db"
local reqArgs = require "common.request_args"
local redis = require "redis.zs_redis" 
local responeData = require"common.api_data_help"

-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

if not args.id_pk then	
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return	
end

local temp = {}
temp.id_pk = args.id_pk

--删除
local basedbOp = basedb.new()
local dbres,err = basedbOp.deleteBasefromSql("t_banner",temp)

if not dbres then 
	local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
	return 
end


local  result = responeData.new_success({})
ngx.say(cjson.encode(result))
-- 这里是修改




