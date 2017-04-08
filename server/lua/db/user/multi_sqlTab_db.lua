local mysql = require "db.zs_sql"
local lua_db_help = require "db.lua_db_help"
local db_help = lua_db_help.new()
local _M = {}
_M._VERSION = '0.01'            
local mt = { __index = _M }                    

function _M.new()
    return setmetatable({}, mt)    
end

--[[
	接入用户的多表操作
	@parm userparm 用户表参数 
	@parm accountparm user_code_fk balance


--]]
function _M.acessThirdUser(userparm,accountParm)

	--封装主播SQL语句
	local sqlstr =db_help.insert_help("t_user",userparm)
	local balancesqlstr =db_help.insert_help("t_account",accountParm)
	--local username = ngx.quote_sql_str(user) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用
	local db = mysql:new()
	--事务操作
	db:query([[START TRANSACTION;]])
	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sqlstr)
	
	 if not res then
		 db:query([[ROLLBACK;]])
	 end
	
		 res, err, errno, sqlstate = db:query(balancesqlstr)
	
	 if not res then
		 db:query([[ROLLBACK;]])
	 end
	
	 db:query([[COMMIT;]])
	
	db:close()
	if not res then
		return nil,err
	end
	return res

end

--[[
	送礼记录
	@parm giftrecord 送礼记录
	@parm accountprocess 用户流水

--]]
function _M.sendGiftOperation(giftrecord,accountprocess)
	

	local giftrecordsqlstr =db_help.insert_help("t_gift_record",giftrecord)
	local accountprocesssqlstr =db_help.insert_help("t_account_process",accountprocess)
	--local username = ngx.quote_sql_str(user) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用
	local db = mysql:new()
	--事务操作
	db:query([[START TRANSACTION;]])
	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(giftrecordsqlstr)
	
	  if not res then
		--  db:query([[ROLLBACK;]])
	  end
	
	   res, err, errno, sqlstate = db:query(accountprocesssqlstr)
	
	  if not res then
		  db:query([[ROLLBACK;]])
	  end
	
	  db:query([[COMMIT;]])
	
	db:close()
	if not res then
		return nil,err
	end
	return res


end



return _M