--[[
	anchor_edit的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()
local userDb = require "db.base_db"
local userDbOp = userDb.new()

-- 通用函数  从数据库查询的数据中截取第一条，根据key获取value
function GetNodeWithKey(table, key)
	-- 这里之所以有个临时的temp，是因为从数据库中查询出来的不是一个table，而是一个array table，切记，即使是只查询出来一条，也是array table. 雷区拍照留念
	local temp={}
	temp=table[1]
	return temp[key]
end

local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local temp_anchor={}
local temp_user={}
local temp_user_info={}
local temp_room={}
if args.id_pk and args.id_pk~="" then 
temp_anchor.id_pk=args.id_pk
else return 
end

-- 根据获取的主播id，在几个表中查询对应的信息

	local dbress1,err1 =userDbOp.getBaseFromSql("select * from t_anchor",temp_anchor)
	if not dbress1 then 
		return err1
	end
	local user_code=GetNodeWithKey(dbress1,"user_code_fk")


	temp_user.user_code=user_code
	local dbress2,err2 =userDbOp.getBaseFromSql("select * from t_user",temp_user)
	if not dbress2 then 
		return err2
	end

	temp_user_info.user_code_fk=user_code
	local dbress3,err3 =userDbOp.getBaseFromSql("select * from t_user_ext_info",temp_user_info)
	if not dbress3 then 
		return err3
	end

	temp_room.anchor_id_fk=temp_anchor.id_pk
	local dbress4,err4 =userDbOp.getBaseFromSql("select * from t_anchor_room",temp_room)
	if not dbress4 then 
		return err4
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
local address="/html/client_management/anchor/anchor_edit.html"

	local model={anchor_edit_anchor=dbress1,anchor_edit_user=dbress2,anchor_edit_user_info=dbress3,anchor_edit_room=dbress4}

	template.render(address,model)