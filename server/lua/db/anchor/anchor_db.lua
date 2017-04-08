local mysql = require "db.zs_sql"
local lua_db_help = require "db.lua_db_help"
local cjson = require "cjson"
local db_help = lua_db_help.new()

local _M = {}
_M._VERSION = '0.01'            
local mt = { __index = _M }                    

function _M.new()
    return setmetatable({}, mt)    
end

function _M.getAnchorList()

	sql ="select t1.id_pk,t2.user_name,t1.anchor_title,t1.anchor_description from t_anchor t1 LEFT JOIN t_user t2 on t1.user_code_fk=t2.user_code "

	local db = mysql:new()	
	 db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		return err
	end
	return res
end
--设置主播上下线
function _M.updateAnchorOnOff(parm)
--主播状态更新
local parmanchor = {}
local parmanchorkey = {}
parmanchorkey.user_code_fk = parm.anchor_user_code
parmanchor.anchor_status = parm.anchor_status
--房间状态更新
local parmanchorroom = {}
local parmanchorroomkey = {}
parmanchorroom.room_type = parm.room_type
parmanchorroom.game_type = parm.game_type
parmanchorroom.room_status = parm.anchor_status
if parm.room_name and parm.room_name ~= "" then
	parmanchorroom.room_name = parm.room_name
end

if parm.password then
	parmanchorroom.password = parm.password
end	

parmanchorroomkey.id_pk = parm.room_id_pk


	--封装主播SQL语句
	local sqlstr =db_help.update_help("t_anchor",parmanchor,parmanchorkey)
	local roomsqlstr =db_help.update_help("t_anchor_room",parmanchorroom,parmanchorroomkey)
	--local username = ngx.quote_sql_str(user) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用
	local db = mysql:new()
	--事务操作
	db:query([[START TRANSACTION;]])
	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sqlstr)
	
	 if not res then
		 db:query([[ROLLBACK;]])
	 end
	
		 res, err, errno, sqlstate = db:query(roomsqlstr)
	
	 if not res then
		 db:query([[ROLLBACK;]])
	 end
	
	 db:query([[COMMIT;]])
	
	db:close()
	if not res then
		return nil,err
	end
	return res

end


function  _M.anchor_index_web(parm,order_parm,likeparm,dora,limit_star,limit_size)

		--删除所有空值	
	for i= table.getn(parm),1,-1 do
		local keyvalue = parm[i];
		if not keyvalue then
			table.remove(parm,i);
		end
	end
		--删除所有空值	
	for i= table.getn(order_parm),1,-1 do
		local keyvalue = order_parm[i];
		if not keyvalue then
			table.remove(order_parm,i);
		end
	end


		--组装数据库 xx=xx
	local sqlsuffix = ""
	if parm then 

		for k,v  in pairs(parm) do
			
				if sqlsuffix == "" then
				
					sqlsuffix = " where ".. k.." = "..ngx.quote_sql_str(v)
				
				else
					sqlsuffix = sqlsuffix.." and "..k.."="..ngx.quote_sql_str(v)
				end
		end
	end

	--组装数据库 order by xx,xx,xx desc 只能全部都asc或者全部都desc
	local orderfix = ""
	if table.getn(order_parm)~=0 then 
		for k,v  in pairs(order_parm) do
				if orderfix == "" then
				
					orderfix = " order by ".. ngx.quote_sql_str(v).." "..dora
				
				else
					orderfix = orderfix.." "..ngx.quote_sql_str(v).." "..dora
				end
		end
	end
	
	local sql=""
	if sqlsuffix == "" then  
		sql=string.format("SELECT t1.*,ta.gift_vl,t3.phone_number,t4.nickname,t4.head_icon,t5.id_pk as room_id FROM t_anchor t1 LEFT JOIN (SELECT sum(t2.gift_number*tt.gift_value)as gift_vl,t2.rec_user_code FROM t_gift_record t2 LEFT JOIN t_gift_type tt on t2.gift_type_id_fk=tt.id_pk where tt.is_join_share='1' GROUP by t2.rec_user_code)ta on t1.id_pk=ta.rec_user_code LEFT JOIN (select t_user.user_code as user_code,t_user.phone_number as phone_number from t_user)t3 on t3.user_code=t1.user_code_fk LEFT JOIN (SELECT t_user_ext_info.user_code_fk as user_code,t_user_ext_info.nickname as nickname,t_user_ext_info.head_icon as head_icon from t_user_ext_info)t4 on t1.user_code_fk=t4.user_code LEFT JOIN t_anchor_room t5 on t5.anchor_id_fk=t1.id_pk limit %s , %s",limit_star,limit_size)
	else
		sql=string.format("SELECT t1.*,ta.gift_vl,t3.phone_number,t4.nickname,t4.head_icon,t5.id_pk as room_id FROM t_anchor t1 LEFT JOIN (SELECT sum(t2.gift_number*tt.gift_value)as gift_vl,t2.rec_user_code FROM t_gift_record t2 LEFT JOIN t_gift_type tt on t2.gift_type_id_fk=tt.id_pk where tt.is_join_share='1' GROUP by t2.rec_user_code)ta on t1.id_pk=ta.rec_user_code LEFT JOIN (select t_user.user_code as user_code,t_user.phone_number as phone_number from t_user)t3 on t3.user_code=t1.user_code_fk LEFT JOIN (SELECT t_user_ext_info.user_code_fk as user_code,t_user_ext_info.nickname as nickname,t_user_ext_info.head_icon as head_icon from t_user_ext_info)t4 on t1.user_code_fk=t4.user_code LEFT JOIN t_anchor_room t5 on t5.anchor_id_fk=t1.id_pk %s limit %s ,%s",sqlsuffix,limit_star,limit_size)
	end


	if likeparm and likeparm~="" then
		if sqlsuffix=="" then 
			sql=sql.." where t4.nickname like '%"..likeparm.."%'"
		else
			sql=sql.." and t4.nickname like '%"..likeparm.."%'"
		end
	end

	if orderfix~="" then 
		sql=sql..orderfix
	end 


	local db = mysql:new()	
	 db.query("SET NAME utf8")
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		return err
	end

	return res
end

-- 计算anchor_index页面的总记录数
function  _M.anchor_index_web_count(parm,order_parm,likeparm,dora)

		--删除所有空值	
	for i= table.getn(parm),1,-1 do
		local keyvalue = parm[i];
		if not keyvalue then
			table.remove(parm,i);
		end
	end
		--删除所有空值	
	for i= table.getn(order_parm),1,-1 do
		local keyvalue = order_parm[i];
		if not keyvalue then
			table.remove(order_parm,i);
		end
	end


		--组装数据库 xx=xx
	local sqlsuffix = ""
	if parm then 

		for k,v  in pairs(parm) do
			
				if sqlsuffix == "" then
				
					sqlsuffix = " where ".. k.." = "..ngx.quote_sql_str(v)
				
				else
					sqlsuffix = sqlsuffix.." and "..k.."="..ngx.quote_sql_str(v)
				end
		end
	end

	--组装数据库 order by xx,xx,xx desc 只能全部都asc或者全部都desc
	local orderfix = ""
	if table.getn(order_parm)~=0 then 
		for k,v  in pairs(order_parm) do
				if orderfix == "" then
				
					orderfix = " order by ".. ngx.quote_sql_str(v).." "..dora
				
				else
					orderfix = orderfix.." "..ngx.quote_sql_str(v).." "..dora
				end
		end
	end
	
	local sql=""
	if sqlsuffix == "" then  
		sql=string.format("SELECT count(*) as all_clum FROM t_anchor t1 LEFT JOIN (SELECT sum(t2.gift_number*tt.gift_value)as gift_vl,t2.rec_user_code FROM t_gift_record t2 LEFT JOIN t_gift_type tt on t2.gift_type_id_fk=tt.id_pk where tt.is_join_share='1' GROUP by t2.rec_user_code)ta on t1.id_pk=ta.rec_user_code LEFT JOIN (select t_user.user_code as user_code,t_user.phone_number as phone_number from t_user)t3 on t3.user_code=t1.user_code_fk LEFT JOIN (SELECT t_user_ext_info.user_code_fk as user_code,t_user_ext_info.nickname as nickname,t_user_ext_info.head_icon as head_icon from t_user_ext_info)t4 on t1.user_code_fk=t4.user_code LEFT JOIN t_anchor_room t5 on t5.anchor_id_fk=t1.id_pk %s ","")
	else
		sql=string.format("SELECT count(*) as all_clum FROM t_anchor t1 LEFT JOIN (SELECT sum(t2.gift_number*tt.gift_value)as gift_vl,t2.rec_user_code FROM t_gift_record t2 LEFT JOIN t_gift_type tt on t2.gift_type_id_fk=tt.id_pk where tt.is_join_share='1' GROUP by t2.rec_user_code)ta on t1.id_pk=ta.rec_user_code LEFT JOIN (select t_user.user_code as user_code,t_user.phone_number as phone_number from t_user)t3 on t3.user_code=t1.user_code_fk LEFT JOIN (SELECT t_user_ext_info.user_code_fk as user_code,t_user_ext_info.nickname as nickname,t_user_ext_info.head_icon as head_icon from t_user_ext_info)t4 on t1.user_code_fk=t4.user_code LEFT JOIN t_anchor_room t5 on t5.anchor_id_fk=t1.id_pk %s ",sqlsuffix)
	end


	if likeparm and likeparm~="" then
		if sqlsuffix=="" then 
			sql=sql.." where t4.nickname like '%"..likeparm.."%'"
		else
			sql=sql.." and t4.nickname like '%"..likeparm.."%'"
		end
	end

	if orderfix~="" then 
		sql=sql..orderfix
	end 


	local db = mysql:new()	
	 db.query("SET NAME utf8")
	 ngx.log(ngx.ERR,"*********************sql****************************"..sql)
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		return err
	end

	return res
end





-- 增加一条主播信息的时候，自动生成一条房间信息
function  _M.add_anchor_room(anchot_tb_name,anchor_parm,room_tb_name,room_parm)
--删除所有空值	
	for i= table.getn(parm),1,-1 do
		local keyvalue = parm[i];
		if not keyvalue then
			table.remove(parm,i);
		end
	end

 	--封装SQL语句
	local sqlstr =db_help.insert_help(tablename,parm)
	local sql1=db_help.insert_help()
	
	--local username = ngx.quote_sql_str(user) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用
	local db = mysql:new()
	--事务操作
	db:query([[START TRANSACTION;]])
	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sqlstr)
	
	if not res then
		db:query([[ROLLBACK;]])
	end
	
		res, err, errno, sqlstate = db:query(sql1)
	
	if not res then
		db:query([[ROLLBACK;]])
	end
	
	db:query([[COMMIT;]])
	
	db:close()
	if not res then
		return nil,err
	end
	return res
end

-- 根据主播的id查看主播的收礼记录明细
-- function _M.gift_list_by_anchor(anchor_id,parm)

-- 	--删除所有空值	
-- 	for i= table.getn(parm),1,-1 do
-- 		local keyvalue = parm[i];
-- 		if not keyvalue then
-- 			table.remove(parm,i);
-- 		end
-- 	end

-- 	if not parm then 
-- 		return 
-- 	end

-- 	--组装数据库 xx=xx
-- 	local sqlsuffix = ""
-- 	if table.getn(parm)~=0 then 
-- 		for k,v  in pairs(parm) do
			
-- 				if sqlsuffix == "" then
				
-- 					sqlsuffix = " where ".. k.." = "..ngx.quote_sql_str(v)
				
-- 				else
-- 					sqlsuffix = sqlsuffix.." and "..k.."="..ngx.quote_sql_str(v)
-- 				end
-- 		end
-- 	end

-- 	local sql = ""

-- 	if sqlsuffix== "" then 
-- 		sql=string.format("SELECT
-- 							t3.nickname,
-- 							t1.send_user_code,
-- 							t1.gift_number,
-- 							t1.gift_time,
-- 							t1.gift_type_id_fk,
-- 							t2.gift_name,
-- 							t2.gift_value,t2.gift_logo,t2.is_join_share
-- 						FROM
-- 							t_gift_record t1
-- 						LEFT JOIN t_gift_type t2 ON t1.gift_type_id_fk = t2.id_pk
-- 						LEFT JOIN t_user_ext_info t3 ON t3.user_code_fk = t1.send_user_code ")


-- end


return _M