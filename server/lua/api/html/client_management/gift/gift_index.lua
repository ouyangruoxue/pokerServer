--[[
	anchor_gift_list的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()
local userDb = require "db.base_db"

	function GetNodeWithKey(table, key)
		-- 这里之所以有个临时的temp，是因为从数据库中查询出来的不是一个table，而是一个array table，切记，即使是只查询出来一条，也是array table. 雷区拍照留念
		local temp={}
		temp=table[1]
	return temp[key]
	end


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local temp={}
local pager={}
local pageSize=20

local temp_curr_page
if not args.page then 
	temp_curr_page=1
else
	temp_curr_page=args.page
end

-- 查询总的字段数 为分页做准备
local userDbOp = userDb.new()
local dbres1,err1 = userDbOp.getBaseFromSql("select COUNT(*) as all_clum from t_gift_type",temp,"and")
	if not dbres1 then 
		local  result = responeData.new_failed({},err1)
		ngx.log(ngx.ERR,"fail to query by database, err:",err1)
		return 
	end
local maxClum=GetNodeWithKey(dbres1,"all_clum")

-- 进行分页操作
local common_page=require "common.pager"
local temp_page = common_page.new()
-- pager值的含义为startindex limit开始位置，offset limit结束位置，max_page 最大页数，curr_page，当前页数
	pager.startindex,pager.offset,pager.max_page,pager.curr_page=temp_page.newPager(maxClum,pageSize,temp_curr_page)
	-- 从数据库中查询
	local dbres,err = userDbOp.getBaseFromSql("select * from t_gift_type",temp,"and",pager.startindex,pageSize)
	

	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return 
	end
-- session必须开启缓存才能够使用，为了便捷开发，先不判断，而是直接跳转到index页面

-- if args.token == session.data.token then 
-- 	-- 从登陆跳过来，带了token才能跳转到html/index.html界面
-- 	local address="/html/index.html"
-- 	local model={}
-- 	template.render(address,model)
-- else
-- 	result = responeData.new_failed({},err)
-- end
local address="/html/client_management/gift/gift_index.html"
local gift_index_data
local gift_index_pager
gift_index_data=dbres
gift_index_pager=pager
	local model={gift_index_data=gift_index_data,gift_index_pager=gift_index_pager}

	template.render(address,model)