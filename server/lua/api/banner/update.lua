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
local responeData = require"common.api_data_help"
--local redis = require "redis.zs_redis" 



-- 获取参数
local currentRequestArgs = reqArgs.new()
local getArgs,args = currentRequestArgs.getArgs()

--必须带的参数
if not args.id_pk  then	
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return	
end


local temp ={}

if  args.banner_icon and args.banner_icon ~= "" then 
  temp.password=args.banner_icon
end

if  args.banner_type and args.banner_type ~= "" then 
  temp.password=args.banner_type
end

if  args.banner_title and args.banner_title ~= "" then 
  temp.password=args.banner_title
end

if  args.banner_status and args.banner_status ~= "" then 
  temp.password=args.banner_status
end


--如果是改为下线状态则修改下线时间
if args.banner_status ~=nil then
  if args.banner_status =="0" then
      temp.offline_time = ngx.localtime()
  end

end

local basedbOp = basedb.new()
--更新
local kParm = {}
kParm.id_pk = args["id_pk"]
args["id_pk"] = nil
dbres,err = basedbOp.updateBaseFromSql("t_banner",temp,kParm)

if not dbres or type(dbres) ~= "table" then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		return 
	end
end

local  result = responeData.new_success({})
ngx.say(cjson.encode(result))
