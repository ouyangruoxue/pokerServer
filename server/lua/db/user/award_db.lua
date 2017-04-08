local mysql = require "db.zs_sql"

local _M = {}
_M._VERSION = '0.01'            
local mt = { __index = _M }                    

function _M.new(self)
    return setmetatable({}, mt)    
end

function _M.getTBDataByUsercode(user_code_fk,startindex,offset)

local usercode = ngx.quote_sql_str(user_code_fk) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用

local  sqlsrc = string.format("select t_member_reward.get_time,
			 t_member_reward.reward_numbers,
			 t_member_reward.has_received,
			 t_member_reward.is_del,
			 t_activity_reward.reward_title,
			 t_reward_type.type_name,
			 t_reward_descripe.description,
			 t_reward_descripe.goods_code
			from t_member_reward
			LEFT JOIN t_activity_reward ON t_activity_reward.reward_code = t_member_reward.reward_code_fk
			LEFT JOIN t_reward_type ON t_reward_type.id = t_member_reward.reward_type_id_fk
		LEFT JOIN t_reward_descripe ON t_reward_descripe.descripe_code = t_member_reward.descripe_code_fk WHERE t_member_reward.user_code_fk = %s",usercode)


	
if startindex ~= nil and offset ~= nil then

		sqlsrc = sqlsrc..string.format(" limit %d , %d",startindex,offset)

	else
		
		sqlsrc = sqlsrc..string.format(" limit %d , %d",0,20)

	end
	
	local db = mysql:new()	
	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sqlsrc)
	db:close()
	if not res then
		return err
	end
	return res
end

return _M