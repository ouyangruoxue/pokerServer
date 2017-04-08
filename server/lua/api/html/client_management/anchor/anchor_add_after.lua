--[[
	anchor_index的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()

local userDb = require "db.base_db"
local userDbOp = userDb.new()

local redis_lock = require "common.redis_lock"
local redis = require "redis.zs_redis"
local red = redis:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()


local anchor_tab={}
local user_tab={}
local user_info_tab = {}

local anchor_id
local room_id

-- 通用函数  从数据库查询的数据中截取第一条，根据key获取value
function GetNodeWithKey(table, key)
	-- 这里之所以有个临时的temp，是因为从数据库中查询出来的不是一个table，而是一个array table，切记，即使是只查询出来一条，也是array table. 雷区拍照留念
	local temp={}
	temp=table[1]
	return temp[key]
end

-- t_user
if args.phone_number and args.phone_number~="" then
	user_tab.phone_number=args.phone_number
end
if args.user_name and args.user_name~="" then
	user_tab.user_name=args.user_name
end
if args.password and args.password~="" then
	user_tab.password=args.password
end

-- t_anchor
if args.anchor_push_url and args.anchor_push_url~="" then
	anchor_tab.anchor_push_ur=args.anchor_push_url
end
if args.anchor_url and args.anchor_url~="" then
	anchor_tab.anchor_url=args.anchor_url
end
if args.channel_business and args.channel_business~="" then
	anchor_tab.channel_business=args.channel_business
end
if args.cut_ratio and args.cut_ratio~="" then
	anchor_tab.cut_ratio=args.cut_ratio
end
if args.signing_time and args.signing_time~="" then
	anchor_tab.signing_time=args.signing_time
end

-- t_user_ext_info
if args.nickname and args.nickname~="" then
	user_info_tab.nickname=args.nickname
end

if args.head_icon and args.head_icon~="" then
	user_info_tab.head_icon=args.head_icon
end



-- 先往用户表中插入数据，自动生成user_code后，将主播user_code作为参数插入主播表、扩展表中，
-- 主播表生成一个主播id,将这个主播id作为参数插入到房间表中 ,主播id要作为参数传给云信生成主播接口  user_create
-- 都完成后，使用capture重定向，走一遍云信 将主播id，房间id作为参数传给云信 create 
-- 将生成的房间保存到数据库中 netsxxxxx_room


user_tab.user_code = redis_lock.generateUniqueUserCode("wj_game_user_code",1) 

	-- insert用户表信息
	user_tab.is_real_user=1 --从后台创建的主播一定是真人用户
	local dbress1,err = userDbOp.insertBaseToSql("t_user",user_tab)
	if not dbress1 then 
		return result
	end

	-- insert用户扩展表信息
	user_info_tab.user_code_fk=user_tab.user_code
	local dbress2,err2 = userDbOp.insertBaseToSql("t_user_ext_info",user_info_tab)
		if not dbress2 then 
			return err2
	end

	-- insert主播表信息
	anchor_tab.user_code_fk=user_tab.user_code
	local dbress3,err3 = userDbOp.insertBaseToSql("t_anchor",anchor_tab)
		if not dbress3 then 
			return err3
		end
	anchor_id=dbress3.insert_id


	-- 云信主播的参数
	local caputureArgs1={}
	caputureArgs1.accid=user_tab.user_code
	-- 使用云信生成主播
	local  res2 = ngx.location.capture(
	     				'/netease/user/create',
	     				 { method = ngx.HTTP_POST,body = ngx.encode_args(caputureArgs1)}
	 				)

	ngx.log(ngx.ERR,"看看res2是什么"..cjson.encode(res2))
	local res2Tab = cjson.decode(res2.body)
	-- 主播生成失败将主播表，用户表,用户扩展信息表中对应的字段删了 并且返回
	if tonumber(res2Tab.code) ~= 200 then
		ngx.log(ngx.ERR,"开始删主播用户了")

		local del_anchor
		del_anchor.id_pk=anchor_id
		local del_res1,del_err1=deleteBasefromSql("t_anchor",del_anchor)
		local del_user

		del_user.user_code=user_tab.user_code
		local del_res2,del_err2=deleteBasefromSql("t_user",del_user)
		local del_user_info

		del_user_info.user_code_fk=user_tab.user_code
		local del_res3,del_err3=deleteBasefromSql("t_user_ext_info",del_user_info)

		return ngx.say("不能往云信添加主播")
    end	


-- insert房间表信息
local room_tab={}
room_tab.anchor_id_fk=anchor_id
room_tab.is_rel_room=1 --从主播创建过去的房间默认为真人房间
local dbress5,err5 = userDbOp.insertBaseToSql("t_anchor_room",room_tab)
	if not dbress5 then 
		return err5
	end
	 room_id=dbress5.insert_id


-- 云信聊天房间的参数
local caputureArgs = {}
caputureArgs.creator=user_tab.user_code
caputureArgs.name=room_id


-- 使用云信生成聊天室
local  res1 = ngx.location.capture(
     				'/netease/chatroom/create',
     				 { method = ngx.HTTP_POST,body = ngx.encode_args(caputureArgs)}
 				)

	-- 如果云信创建了聊天室失败，则把生成的主播和房间都删了，并且返回
	local res1Tab = cjson.decode(res1.body)
	if tonumber(res1Tab.code) ~= 200 then
		ngx.log(ngx.ERR,"开始删房间了")
			local del_anchor
			local del_user
			local del_user_info
			local del_room
			del_anchor.id_pk=anchor_id
			del_user.user_code=user_tab.user_code
			del_user_info.user_code_fk=user_tab.user_code
			del_room.id_pk=room_id
			local del_res1,del_err1=deleteBasefromSql("t_anchor",del_anchor)
			local del_res2,del_err2=deleteBasefromSql("t_user",del_user)
			local del_res3,del_err3=deleteBasefromSql("t_user_ext_info",del_user_info)
			local del_res3,del_err3=deleteBasefromSql("t_anchor_room",del_room)
			return 
	end

local chat_room={}
	chat_room.name=res1Tab.chatroom.name
	chat_room.roomid=res1Tab.chatroom.roomid
	if res1Tab.chatroom.muted=="true" then 
		chat_room.muted=1
	else
		chat_room.muted=0
    end
	chat_room.creator=res1Tab.chatroom.creator
	if res1Tab.chatroom.valid=="true" then 
		chat_room.valid=1
	else
		chat_room.valid=0
	end 
	
-- 这里是以上流程都成功，将生成的聊天室存放到本地数据库
	
	local dbress7,err7 = userDbOp.insertBaseToSql("t_netease_chat_room",chat_room)
		if not dbress7 then 
			return err7
		end

	local result = responeData.new_success({})
	return result
