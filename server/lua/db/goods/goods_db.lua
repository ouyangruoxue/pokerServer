local mysql = require "db.zs_sql"

local _M = {}
_M._VERSION = '0.01'            
local mt = { __index = _M }                    

function _M.new(self)
    return setmetatable({}, mt)    
end
--根据用户名查询用户(andor"and 或者or")
function _M.getTBDataByTbNameAndParm(self,user,andor,inname,invalue)
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

	--组装数据库 xx=xx
	local sqlsuffix = ""
	for k,v  in pairs(user) do
		
			if sqlsuffix == "" then
			
				sqlsuffix = k.."="..ngx.quote_sql_str(v)
			
			else
				sqlsuffix = sqlsuffix.." "..andor.." "..k.."="..ngx.quote_sql_str(v)
			end
	end



	-- 删掉所有的空值
	for j = table.getn(invalue),1,-1 do
			local keyvalue2 = invalue[j];
		if not keyvalue2 then
		table.remove(invalue,j);
		end
	end

	-- 组装数据库 xx in ()  括号里面的内容  invalue
	local sqlsuffix2=""
	for i,v in ipairs(invalue) do
		if i~= table.getn(invalue) then
		sqlsuffix2=sqlsuffix2..v..","
		else
			sqlsuffix2=sqlsuffix2..v
		end
	end



	local sql =""
	if sqlsuffix =="" then
		return "parm is not exist"
	else
		sql = string.format("select * from t_goods where "..inname.." in ("..sqlsuffix2..") and %s ",sqlsuffix)
	end
	
	local db = mysql:new()	
	 
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		return err
	end
	return res
end

return _M