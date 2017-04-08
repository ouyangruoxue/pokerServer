--[[
	banner的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()
local db = require "db.base_db"
local bannerDbOp = db.new()

local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local user={}

	function GetNodeWithKey(table, key)
		-- 这里之所以有个临时的temp，是因为从数据库中查询出来的不是一个table，而是一个array table，切记，即使是只查询出来一条，也是array table. 雷区拍照留念
		local temp={}
		temp=table[1]
	return temp[key]
	end

local temp={}
local pager={}
local pageSize=20
local temp_curr_page
if not args.page then 
	temp_curr_page=1
else
	temp_curr_page=args.page
end

local dbres1,err1 = bannerDbOp.getBaseFromSql("select COUNT(*) as all_clum from t_banner",user,"and")
if not dbres1 then 
		local  result = responeData.new_failed({},err1)
		ngx.print(cjson.encode(result))	
		return 
end
local maxClum=GetNodeWithKey(dbres1,"all_clum")

-- 进行分页操作
local common_page=require "common.pager"
local temp_page = common_page.new()
-- pager值的含义为startindex limit开始位置，offset limit结束位置，max_page 最大页数，curr_page，当前页数
	pager.startindex,pager.offset,pager.max_page,pager.curr_page=temp_page.newPager(maxClum,pageSize,temp_curr_page)


local dbres,err = bannerDbOp.getBaseFromSql("select * from t_banner",user,"and",pager.startindex,pageSize)
if not dbres or type(dbres) ~= "table" then 
		local  result = responeData.new_failed({},err)
		ngx.print(cjson.encode(result))	
		return 
end

local address="/html/client_management/banner/banner_index.html"
	
local banner_index_data
local banner_index_pager

	banner_index_data=dbres
	banner_index_pager=pager
	
	local model={banner_index_data=banner_index_data,banner_index_pager=banner_index_pager}

	template.render(address,model)