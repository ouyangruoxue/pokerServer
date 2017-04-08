local mysql = require "db.zs_sql"
local cjson = require "cjson"
local lua_db_help = require "db.lua_db_help"
local db_help = lua_db_help.new()
local _M = {}
_M._VERSION = '0.01'            
local mt = { __index = _M }                    

function _M.new()
    return setmetatable({}, mt)    
end
 




-- 将一个字符串通过空格分割成table 为了便捷模糊查询
function  splitStringByBlank(s)
	local temptable={}
	for w in string.gmatch(s, "%S+") do  
		table.insert(temptable,w)
	end
	return temptable
end



-- 用户监控管理首页  
-- user 代表的是where = 的参数集 ; table
-- like_param 代表的是模糊查询的参数集; table
-- order_param 代表的是排序的参数集; table
function _M.getUserInfoBySearch(user,like_param,order_param,limit_star,limit_size)


	--删除所有空值	
	for i= table.getn(user),1,-1 do
		local keyvalue = user[i];
		if not keyvalue then
		table.remove(user,i);
		end
	end

	--删除所有空值	
	for i= table.getn(like_param),1,-1 do
		local keyvalue = like_param[i];
		if not keyvalue then
		table.remove(like_param,i);
		end
	end

	--删除所有空值	
	for i= table.getn(order_param),1,-1 do
		local keyvalue = order_param[i];
		if not keyvalue then
		table.remove(order_param,i);
		end
	end

	-- 这就表示所有的table要么为空，要么有值

	--组装数据库 xx=xx
	local sqlsuffix = ""
	for k,v  in pairs(user) do
			if sqlsuffix == "" then
			
				sqlsuffix = " where "..k.."="..ngx.quote_sql_str(v)
			
			else

				sqlsuffix = sqlsuffix.." and "..k.."="..ngx.quote_sql_str(v)

			end
	end


	-- 组装数据库 xxx like %xxx%
	local  likesuffix = ""
	for k,v in pairs(like_param) do 
		if sqlsuffix=="" then 
			if likesuffix=="" then 
			likesuffix=" where "..k.." like '%"..v.."%'"
			else
			likesuffix=likesuffix.." and "..k.." like '%"..v.."%'"
			end 
		else
			if likesuffix=="" then
			likesuffix=" and "..k.." like '%"..v.."%'"
			else
			likesuffix=likesuffix.." and "..k.." like '%"..v.."'%"
			end
		end
	end

	-- 组装数据库 order by xxx
	local ordersuffix=""
	for k,v in pairs(order_param) do 
		if ordersuffix=="" then 
			ordersuffix=" order by "..k.." "..v
		else
			ordersuffix=ordersuffix .." , "..k.." "..v
		end
	end


	local sql =""

	sql = string.format("select t1.user_code,t3.nickname,t3.win_streak,t3.login_count,t2.channel_name from t_user t1 LEFT JOIN t_channel_business t2 on t1.channel_id_fk=t2.id_pk LEFT JOIN t_user_ext_info t3 on t1.user_code=t3.user_code_fk %s %s %s limit %s,%s ",sqlsuffix,likesuffix,ordersuffix,limit_star,limit_size)
	local db = mysql:new()	
	 db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		return nil,err
	end
	return res
end


-- 用户监控管理首页  获取总数量的
-- user 代表的是where = 的参数集 ; table
-- like_param 代表的是模糊查询的参数集; table
-- order_param 代表的是排序的参数集; table
function _M.getUserInfoBySearch_count(user,like_param,order_param)


	--删除所有空值	
	for i= table.getn(user),1,-1 do
		local keyvalue = user[i];
		if not keyvalue then
		table.remove(user,i);
		end
	end

	--删除所有空值	
	for i= table.getn(like_param),1,-1 do
		local keyvalue = like_param[i];
		if not keyvalue then
		table.remove(like_param,i);
		end
	end

	--删除所有空值	
	for i= table.getn(order_param),1,-1 do
		local keyvalue = order_param[i];
		if not keyvalue then
		table.remove(order_param,i);
		end
	end

	-- 这就表示所有的table要么为空，要么有值

	--组装数据库 xx=xx
	local sqlsuffix = ""
	for k,v  in pairs(user) do
			if sqlsuffix == "" then
			
				sqlsuffix = " where "..k.."="..ngx.quote_sql_str(v)
			
			else

				sqlsuffix = sqlsuffix.." and "..k.."="..ngx.quote_sql_str(v)

			end
	end


	-- 组装数据库 xxx like %xxx%
	local  likesuffix = ""
	for k,v in pairs(like_param) do 
		if sqlsuffix=="" then 
			if likesuffix=="" then 
			likesuffix=" where "..k.." like '%"..v.."%'"
			else
			likesuffix=likesuffix.." and "..k.." like '%"..v.."%'"
			end 
		else
			if likesuffix=="" then
			likesuffix=" and "..k.." like '%"..v.."%'"
			else
			likesuffix=likesuffix.." and "..k.." like '%"..v.."'%"
			end
		end
	end

	-- 组装数据库 order by xxx
	local ordersuffix=""
	for k,v in pairs(order_param) do 
		if ordersuffix=="" then 
			ordersuffix=" order by "..k.." "..v
		else
			ordersuffix=ordersuffix .." , "..k.." "..v
		end
	end


	local sql =""

	sql = string.format("select count(*) as all_clum from t_user t1 LEFT JOIN t_channel_business t2 on t1.channel_id_fk=t2.id_pk LEFT JOIN t_user_ext_info t3 on t1.user_code=t3.user_code_fk %s %s %s",sqlsuffix,likesuffix,ordersuffix)
	local db = mysql:new()	
	 db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		return nil,err
	end
	return res
end



return _M