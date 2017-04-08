local mysql = require "db.zs_sql"
require "common.jsonHelp"

local _M = {}
_M._VERSION = '0.01'            
local mt = { __index = _M }                    

function _M.new(self)
    return setmetatable({}, mt)    
end
--根据用户名查询用户(andor"and 或者or")
function _M.getTBDataByTbNameAndParm(self,rootId)
	--local name = ngx.quote_sql_str(username) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用

	if not rootId then
		return "parm is not exist"
	end

	local sql_str= 'call pro_show_childlist('..rootId..');'
	local db = mysql:new()
	res, err, errcode, sqlstate = db:query(sql_str)
	db:close()
	    if not res then
	        ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errcode, ": ", sqlstate, ".")
	        return 
	    end
	    return res
end

return _M