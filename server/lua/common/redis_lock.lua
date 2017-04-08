local redis = require "redis.zs_redis"
local _M = {}
function _M.generateUniqueUserCode(key,redisclientnum)

	local red = redis:new()
	local watch = red:watch(key)
	if not watch then
		return "乐观锁出错"
	end
	local usercode = red:get(key)
	if not usercode  then
		usercode = 1
	else
		usercode = usercode + 1
	end
	local multi = red:multi();
	if not multi then
		return "乐观锁出错"
	end
	local ok, err = red:set(key, usercode)
	if not ok then
	
		return "set value error"
	end
	local exec = red:exec()
	if not exec then
		return "乐观锁执行出错"
	end
	return usercode
end 

return _M