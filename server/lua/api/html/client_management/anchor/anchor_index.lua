--[[
	anchor_index的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()
local db=require "db.anchor.anchor_db"

	function GetNodeWithKey(table, key)
		-- 这里之所以有个临时的temp，是因为从数据库中查询出来的不是一个table，而是一个array table，切记，即使是只查询出来一条，也是array table. 雷区拍照留念
		local temp={}
		temp=table[1]
	return temp[key]
	end


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local user={}
if args.anchor_status and args.anchor_status~="" then 
user.anchor_status=args.anchor_status
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

local ordertemp={}

local likeparm=""
if args.search and args.search~="" then 
	likeparm=args.search
end 

local anchorDbOp = db.new()

	local dbres1,err1 = anchorDbOp.anchor_index_web_count(user,ordertemp,likeparm,"desc")
	if not dbres1 then 
			local  result = responeData.new_failed({},err)
			return 
	end
	local maxClum=GetNodeWithKey(dbres1,"all_clum")
	-- 进行分页操作
	local common_page=require "common.pager"
	local temp_page = common_page.new()
	-- pager值的含义为startindex limit开始位置，offset limit结束位置，max_page 最大页数，curr_page，当前页数
	pager.startindex,pager.offset,pager.max_page,pager.curr_page=temp_page.newPager(maxClum,pageSize,temp_curr_page)


local dbres,err = anchorDbOp.anchor_index_web(user,ordertemp,likeparm,"desc",pager.startindex,pageSize)
if not dbres or type(dbres) ~= "table" then 
		local  result = responeData.new_failed({},err)
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
local address="/html/client_management/anchor/anchor_index.html"
local anchor_index_data
local anchor_index_pager

anchor_index_data=dbres
anchor_index_pager=pager

	local model={anchor_index_data=anchor_index_data,anchor_index_pager=anchor_index_pager}

	template.render(address,model)