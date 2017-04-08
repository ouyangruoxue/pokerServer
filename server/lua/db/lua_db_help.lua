--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:lua_db_help.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  本文件主要用于扩展部分lua 组装mysql 语句的扩展函数
--]]


local cjson = require "cjson"
local _M ={start_index=0,offset=20}
_M.__index = _M;


function _M.new()
	return setmetatable({},_M)
end
--[[
-- 组装mysql 动态sql语句
-- example
    local srcSql = " select * from t_user_files "
    local db_help = require "db.lua_db_help"
    local param = db_help.new_param();
    param.user_code_fk="user_code_1"
    param.file_name="file"
	local start_index = args["start_index"] and args["start_index"] or 0;
	local offset = args["offset"] and args["offset"] or 20;
	local strsql = db_help.select_help(srcSql,param,"and")

-- @param srcSql sql 前半部分语句
-- @param param 用户需要组装的数据参数表,其中record 的元素信息必须为key=value的格式
				key为表的字段名
-- @param condition 搜索语句的条件,主要表现为字符串	
-- @param start_index,offset 用于分页查询 该参数可优化

--]]

function _M.select_help(srcSql,param,condition,start_index,offset)
	local desSql = srcSql;
	local tempstr = " "
	local len = table.getn(param)
	local index = 0;

	for k, v in pairs( param ) do
		if v then 
			if index > 0 then
			 tempstr = tempstr .. condition;
			end
			if type(v) == 'string' then
				tempstr = tempstr .. string.format(" %s = '%s' ",k,v)
			else
				tempstr = tempstr .. string.format(" %s = %d ",k,v)
			end
			index = index+1;
		end
		
	end
	if index >0 then  
		desSql = desSql.. ' where '..tempstr;
	end
	
		if start_index ~= nil and offset ~= nil then

			desSql = desSql..string.format(" limit %d , %d",start_index,offset)

		end

	return desSql;
end

--[[
	调用此方法生成MYSQL插入语句
	local db_help = require "db.lua_db_help"
    local strsql = db_help.insert_help(tbname,tbname)
	tbname表示数据库对应表的名称，如t_user
	param代表插入的参数  比如一个table parm=db_help.new_param()
	param.user_code_fk="user_code_1"
    param.file_name="file"


]]--
function _M.insert_help(tbname,param)
	local key=""
	local value = ""

	for k,v  in pairs(param) do
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
	return sql;
end

--[[
	调用此方法可以生成更新的sql语句
	tbname表示数据库对应表的名称，如t_user
	--example
	local db_help = require "db.lua_db_help"
    
	param.user_code_fk="user_code_1"
    param.file_name="file"

	PKname.id=1
	PKname.code="001"
	local strsql = db_help.update_help("t_user",param,pkname)
    @param代表更改的键值对（除掉条件键值对）  
	@PKname条件的table
	
]]

function _M.update_help(tbname,param,PKname)
	

	--组装数据库(根据PKname修改其他字段)
	local sqlsuffix = ""
	local sqlwheresuffix = ""
	for k,v  in pairs(param) do
			if sqlsuffix == "" then
				sqlsuffix = k.."="..ngx.quote_sql_str(v)
			else
				sqlsuffix = sqlsuffix..", "..k.."="..ngx.quote_sql_str(v)
			end
	end

	for k,v in pairs(PKname) do
		if sqlwheresuffix == "" then
			sqlwheresuffix ="where".." "..k.."="..ngx.quote_sql_str(v)
		else
			sqlwheresuffix = sqlwheresuffix.."and "..k.."="..ngx.quote_sql_str(v)
		end
	end
		
	local sql = string.format("update "..tbname.." set %s  %s",sqlsuffix,sqlwheresuffix)	
	return sql
end


--[[
	调用此方法可以生成删除的sql语句
	--example
	local db_help = require "db.lua_db_help"
    
	param.user_code_fk="user_code_1"
    param.file_name="file"
	local strsql = db_help.delete_help("t_user",param)
	@tablename表示数据库表名如"t_user"
	@param表示参数{id=1,username="zuo"}
]]
function _M.delete_help(tablename,param)

	-- 组装查询语句

	-- local tablename = ngx.quote_sql_str(tablename)

	local sqlwheresuffix = ""
	for k,v in pairs(param) do
		if sqlwheresuffix == "" then
			sqlwheresuffix = "where".." "..k.."="..ngx.quote_sql_str(v)
		else
			sqlwheresuffix = sqlwheresuffix.."and "..k.."="..ngx.quote_sql_str(v)
		end
	end

	-- local username = ngx.quote_sql_str(usercode) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用
	local sql = string.format("delete from "..tablename.." %s",sqlwheresuffix) 
	return sql
end 

return _M