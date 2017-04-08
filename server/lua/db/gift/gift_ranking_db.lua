local mysql = require "db.zs_sql"

local _M = {}
_M._VERSION = '0.01'            
local mt = { __index = _M }                    

function _M.new(self)
    return setmetatable({}, mt)    
end
--根据用户名查询用户(andor"and 或者or")
function _M.getGiftRankingByCondition(usercode,begintime,endtime)
	if not usercode then 
		return "not param "
	end 

	if begintime and endtime and begintime~="" and endtime~="" then
		sql = "SELECT t1.*,t2.user_name FROM t_gift_record t1 LEFT JOIN t_user t2 ON t1.send_user_code = t2.user_code WHERE t1.rec_user_code='"..usercode.."' and t1.gift_time BETWEEN '"..begintime.."' and '"..endtime.."' ORDER BY gift_number desc ,gift_time desc"
	else
		sql = "SELECT t1.*,t2.user_name FROM t_gift_record t1 LEFT JOIN t_user t2 ON t1.send_user_code = t2.user_code WHERE t1.rec_user_code='"..usercode.." ORDER BY gift_number desc ,gift_time desc"
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

return _M