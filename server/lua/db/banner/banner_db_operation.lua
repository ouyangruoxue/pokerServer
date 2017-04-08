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
 
--[[
	调用此方法可以根据条件有效的banner
	--example

	srcsql = "select * from t_banner"

	begintime="2017-01-02 12:33:24"
    bannerstatus="1"

		local base_db = require "db.base_db"
    local basedbOp = base_db.new();
	local res,err = basedbOp.getBaseFromSql(srcsql,begintime,bannerstatus)
	@srcsql 数据库前半语句"select * from t_user"
    @param代表更改的键值对（除掉条件键值对）  
	@andor 查询条件"and"或者"or"
	@startindex 起始位置
	@offset 查询量
]]

function _M.getListFromBannerSql(srcsql,begintime,bannerstatus)
	local time = ngx.quote_sql_str(begintime) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用

	if not begintime or not bannerstatus then

		return nil

	end	

	local sqlsubfix = string.format(" where online_time < %s and banner_status = %d",time,bannerstatus)

	local sqlstr = srcsql .. sqlsubfix

	local db = mysql:new()	
	 db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sqlstr)
	db:close()
	if not res then
		return err
	end
	return res
end

return _M