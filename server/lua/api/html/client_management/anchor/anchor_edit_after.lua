--[[
	anchor_edit修改后提交的文件
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

local change_anchor={}
local change_user={}
local change_user_info={}

-- 用户表
   if args.nickname and args.nickname~="" then 
   		change_user.nickname=args.nickname
	end 

	 if args.head_icon and args.head_icon~="" then 
	 	change_user.head_icon=args.head_icon
	end 

-- 用户扩展表
	 if args.phone_number and args.phone_number~="" then 
	 	change_user_info.phone_number= args.phone_number
	end 

	 if args.password and args.password~="" then 
	 	change_user_info.password= args.password
	end 

-- 主播表
	 if args.anchor_push_ur and args.anchor_push_ur~="" then 
	 	change_anchor.anchor_push_ur= args.anchor_push_ur
	end 

	 if args.anchor_url and args.anchor_url~="" then 
	 	change_anchor.anchor_url= args.anchor_url
	end 

	 if args.cut_ratio and args.cut_ratio~="" then 
	 	change_anchor.cut_ratio= args.cut_ratio
	end 

	

-- 根据获取的主播id，修改几个表中的信息
	if change_anchor then 
		local dbress1,err1 =userDbOp.updateBaseFromSql("t_anchor",change_anchor,temp_anchor)
		if not dbress1 then 
			return err1
		end
		ngx.log(ngx.ERR,"dbress1的值是"..cjson.encode(dbress1))
	end
	-- local user_code=GetNodeWithKey(dbress1,"user_code_fk")


	-- temp_user.user_code=user_code
	-- local dbress2,err2 =userDbOp.updateBaseFromSql("t_user",change_user,temp_user)
	-- if not dbress2 then 
	-- 	return err2
	-- end

	-- temp_user_info.user_code_fk=user_code
	-- local dbress3,err3 =userDbOp.updateBaseFromSql("t_user_ext_info",change_anchor,temp_user_info)
	-- if not dbress3 then 
	-- 	return err3
	-- end


	-- local result = responeData.new_success({})
	-- return result