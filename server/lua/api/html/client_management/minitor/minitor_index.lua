--[[
	room_index的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()
local userDb = require "db.base_db"
local minitorDB=require "db.user.minitor_db"


	function GetNodeWithKey(table, key)
		-- 这里之所以有个临时的temp，是因为从数据库中查询出来的不是一个table，而是一个array table，切记，即使是只查询出来一条，也是array table. 雷区拍照留念
		local temp={}
		temp=table[1]
	return temp[key]
	end
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local temp = {}

local pager={}
local pageSize=20
local temp_curr_page
if not args.page then 
	temp_curr_page=1
else
	temp_curr_page=args.page
end

local user = {}
local liker={}
local order={}


if args.channel_id_fk and args.channel_id_fk~="" then
	user.channel_id_fk=args.channel_id_fk
end


if args.search_word and args.search_word~="" then 
	liker.nickname=args.search_word
end
     --  <option value="1">按照用户的连胜次数倒序排列</option>
	 -- <option value="2">按照用户的连胜次数正序排列</option>
	 -- <option value="3">按照用户的登录次数倒序排列</option>
	 -- <option value="4">按照用户的登录次数正序排列</option>
if args.search_select and args.search_select~="" then 
	if args.search_select=="1" then 
			order.win_streak="desc"
	elseif args.search_select=="2" then 
			order.win_streak="asc"
	elseif args.search_select=="3" then
			order.login_count="desc"
	elseif args.search_select=="4" then
			order.login_count="asc"
	end
end



	-- 从数据库中查询  获取渠道商信息
	
	local userDbOp = userDb:new()
	local dbres,err = userDbOp.getBaseFromSql("select * from t_channel_business",temp,"and")
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return 
	end

	
	local minitorDBOp=minitorDB.new()

	local dbres1,errs1=minitorDBOp.getUserInfoBySearch_count(user,liker,order)
	if not dbres1 then 
		return errs1
	end

	local maxClum=GetNodeWithKey(dbres1,"all_clum")
	-- 进行分页操作
	local common_page=require "common.pager"
	local temp_page = common_page.new()
	-- pager值的含义为startindex limit开始位置，offset limit结束位置，max_page 最大页数，curr_page，当前页数
		pager.startindex,pager.offset,pager.max_page,pager.curr_page=temp_page.newPager(maxClum,pageSize,temp_curr_page)


	local res,errs=minitorDBOp.getUserInfoBySearch(user,liker,order,pager.startindex,pageSize)
	if not res then 
		return errs
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
local address="/html/client_management/minitor/minitor_index.html"
local channel_busine_data
local minitor_index_pager
local monitor_index_data
channel_busine_data=dbres
minitor_index_pager=pager
monitor_index_data=res
	local model={channel_busine_data=channel_busine_data,monitor_index_data=monitor_index_data,minitor_index_pager=minitor_index_pager}
	template.render(address,model)