--[[
	banner的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()

local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local db = require "db.banner.banner_db_operation"
local bannerDbOp = db.new()

-- session必须开启缓存才能够使用，为了便捷开发，先不判断，而是直接跳转到index页面

-- if args.token == session.data.token then 
-- 	-- 从登陆跳过来，带了token才能跳转到html/index.html界面
-- 	local address="/html/index.html"
-- 	local model={}
-- 	template.render(address,model)
-- else
-- 	result = responeData.new_failed({},err)
-- end
local address="/html/client_management/banner_index.html"
	-- local model={index_address="http://localhost/api/html/index?token="..session.data.token}
local banner_type = ""
if  args.banner_type and args.banner_type~="" and args.banner_type~="nil" then 
	if args.banner_type=="0" then banner_type=0
		elseif args.banner_type=="1" then banner_type=1
			else banner_type=2
			end 
end 

local dbres,err = bannerDbOp.getListFromBannerSql_web("select * from t_banner")

if not dbres or type(dbres) ~= "table" then 
		local  result = responeData.new_failed({},err)
		ngx.print(cjson.encode(result))	
		return 
end



	-- 这里也是一样的，先用没有token的
	-- dataSource={{name="赵又廷",age="36",sex="男"},{name="高圆圆",age="46",sex="女"}}
	
		 banner_index_data=dbres


	local model={banner_index_data}

	template.render(address,model)