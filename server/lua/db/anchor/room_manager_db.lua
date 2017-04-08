local mysql = require "db.zs_sql"

local _M = {}
_M._VERSION = '0.01'            
local mt = { __index = _M }                    

function _M.new()
    return setmetatable({}, mt)    
end

function _M.getRoomManager(anchor_user_code)

	sql ="select t2.nickname,t2.head_icon,t2.user_code_fk FROM t_room_management t1 LEFT JOIN t_user_ext_info t2 ON t2.user_code_fk = t1.user_code_fk WHERE t1.anchor_user_code = "..anchor_user_code

	local db = mysql:new()	
	 db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sql)
	db:close()
	if not res then
		return err
	end
	return res
end

return _M