--[[
	获取bannerlist
]]-- 
local cjson = require "cjson"
local db = require "db.banner.banner_db_operation"
local req = require "common.request_args"
local responeData = require"common.api_data_help"


local bannerDbOp = db.new()
local dbres,err = bannerDbOp.getListFromBannerSql("select * from t_banner",ngx.localtime(),1)

if not dbres or type(dbres) ~= "table" then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))	
		return 
end

local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))
