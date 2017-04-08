local mysql = require "db.zs_sql"

local _M = {}
_M._VERSION = '0.01'            
local mt = { __index = _M }                    

function _M.new(self)
    return setmetatable({}, mt)    
end
--根据用户名查询用户(andor"and 或者or")
function _M.getTBDataByTbNameAndParm(self,tbname,user,andor)
	--local name = ngx.quote_sql_str(username) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用

	if not user then
		return "parm is not exist"
	end

	--删除所有空值	
	for i= table.getn(user),1,-1 do
		local keyvalue = user[i];
		if not keyvalue then
		table.remove(user,i);
		end
	end

	--组装数据库(根据usercode修改其他字段)
	local sqlsuffix = ""
	for k,v  in pairs(user) do
		
			if sqlsuffix == "" then
			
				sqlsuffix = k.."="..ngx.quote_sql_str(v)
			
			else
				sqlsuffix = sqlsuffix.." "..andor.." "..k.."="..ngx.quote_sql_str(v)
			end
		
		
	end

	local sql =""
	if sqlsuffix =="" then
		return "parm is not exist"
	else
		sql = string.format("select * from "..tbname.." where %s ",sqlsuffix)
	end
	
	local db = mysql:new()	
	 
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		return err
	end
	return res
end
 
 --插入用户
 function _M.insertTBDate(self,tbname,user)
	
	if not user then
		return "parm is not exist"
	end
	
	local key=""
	local value = ""

	--删除所有空值	
	for i= table.getn(user),1,-1 do
		local keyvalue = user[i];
		if not keyvalue then
		table.remove(user,i);
		end
	end


	for k,v  in pairs(user) do
	--获取所有key，并拼接
	if(key == "") then
		key= k
	else
		key = key..","..k
	end
	
	--获取所有key，并拼接
	if(value == "") then
	  value= ngx.quote_sql_str(v)
	else
	  value = value..","..ngx.quote_sql_str(v)
	end 
	 
	end 
	local sql = string.format("insert into "..tbname.. "(%s) values(%s)",key,value)

		
	--local username = ngx.quote_sql_str(user) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用
	local db = mysql:new()
	
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		return err
	end
	return res
end
 
 --更新用户
 
 function _M.updateTBDate(self,tbname,user)
	
	if not user then
		return "parm is not exist"
	end
	
	if not user.userCode then
		return "userCode is not exist"
	end
	
	
	
	
	--删除所有空值	
	for i= table.getn(user),1,-1 do
		local keyvalue = user[i];
		if not keyvalue then
		table.remove(user,i);
		end
	end

	--组装数据库(根据usercode修改其他字段)
	local sqlsuffix = ""
	local sqlwheresuffix = ""
	for k,v  in pairs(user) do
		if k == "userCode" then
		
			sqlwheresuffix = k.."="..ngx.quote_sql_str(v)
		
		else
			if sqlsuffix == "" then
			
				sqlsuffix = k.."="..ngx.quote_sql_str(v)
			
			else
				sqlsuffix = sqlsuffix..","..k.."="..ngx.quote_sql_str(v)
			end
		end
		
	end
		
	local sql = string.format("update "..tbname.." set %s where %s",sqlsuffix,sqlwheresuffix)	
	--local username = ngx.quote_sql_str(user) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用
	local db = mysql:new()
	
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		return err
	end
	return res
end
 
 
 
return _M