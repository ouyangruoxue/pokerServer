--[[
	room_index的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()



local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user={}

	-- local userDbOp = userDb.new()
	-- local dbres,err = userDbOp.getBaseFromSql("select * from t_gift_type",user,"and")
	-- if not dbres then 
	-- 	local  result = responeData.new_failed({},err)
	-- 	ngx.log(ngx.ERR,"fail to query by database, err:",err)
	-- 	return 
	-- end


local mysql = require "db.zs_sql"
sqlstr="select * from t_gift_type ORDER BY gift_value desc limit 1,1"
local db=mysql:new()
 db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sqlstr)
	db:close()
	if not res then
		return nil,err
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
local address="/html/client_management/note/note_add.html"
local note_add_gift_type_data
note_add_gift_type_data=res
	local model={note_add_gift_type_data=note_add_gift_type_data}

	template.render(address,model)