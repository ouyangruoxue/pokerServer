--[[
	bonus_pool_index的渲染文件
	展示奖金池操作的历史记录
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()

local db = require "db.base_db"
local userDbOp = db.new()


	function GetNodeWithKey(table, key)
		-- 这里之所以有个临时的temp，是因为从数据库中查询出来的不是一个table，而是一个array table，切记，即使是只查询出来一条，也是array table. 雷区拍照留念
		local temp={}
		temp=table[1]
	return temp[key]
	end


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local temp = {}
local user={}
local pager={}
local pageSize=20
if args.game_id and args.game_id ~="" then 
	user.game_type_id =args.game_id
end
local temp_curr_page
if not args.page then 
	temp_curr_page=1
else
	temp_curr_page=args.page
end

-- 获取总的字段数
local dbres1,err1 = userDbOp.getBaseFromSql("SELECT count(*) as all_clum  FROM t_bonus_pool_history t1 left join t_game_type t2 on t1.game_type_id=t2.id_pk",user,"and")
if not dbres1  then 
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


local dbres,err = userDbOp.getBaseFromSql("SELECT t1.*,t2.game_name from t_bonus_pool_history t1 left join t_game_type t2 on t1.game_type_id=t2.id_pk",user,"and",pager.startindex,pageSize)

if not dbres or type(dbres) ~= "table" then 
		local  result = responeData.new_failed({},err)
		ngx.print(cjson.encode(result))	
		return 
end



local res,errs = userDbOp.getBaseFromSql("SELECT * FROM t_game_type",temp,"and")

if not res or type(res) ~= "table" then 
		local  result = responeData.new_failed({},errs)
		ngx.print(cjson.encode(result))	
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
local address="/html/client_management/bonus_pool/bonus_pool_index.html"
local bonus_pool_index_data
local game_type_data
local bonus_pool_index_pager
bonus_pool_index_data=dbres
game_type_data=res
bonus_pool_index_pager=pager
	local model={bonus_pool_index_data=bonus_pool_index_data,game_type_data=game_type_data,bonus_pool_index_pager=bonus_pool_index_pager}

	template.render(address,model)