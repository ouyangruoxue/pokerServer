local mysql = require "db.zs_sql"
local lua_db_help = require "db.lua_db_help"
local redis = require "redis.zs_redis" 
local red = redis:new()
local db_help = lua_db_help.new()
local _M = {}
_M._VERSION = '0.01'            
local mt = { __index = _M }                    

function _M.new()
    return setmetatable({}, mt)    
end
 


local function generateUniqueOrderCode(redisclientnum)

	
	local key = "ordercode"

	local watch = red:watch(key)
	if not watch then
		return "乐观锁出错"
	end
	local ordercode = red:get(key)
	if not ordercode  then
		ordercode = 1
	else
		ordercode = ordercode+1
	end
	
	local multi = red:multi();
	if not multi then
		return "乐观锁出错"
	end
	local ok, err = red:set(key, ordercode)
	if not ok then
	
		return "set value error"
	end
	local exec = red:exec()
	if not exec then
		return "乐观锁执行出错"
	end
	return ordercode
end 



--[[
	调用此方法可以根据条件查询
	--example

	srcsql = "select * from t_user"

	parm.user_code="user_code_1"
    parm.file_name="file"

		local base_db = require "db.base_db"
    local basedbOp = base_db.new();
	local res,err = basedbOp.getBaseFromSql(srcsql,parm,andor,startindex,offset)
	@srcsql 数据库前半语句"select * from t_user"
    @param代表更改的键值对（除掉条件键值对）  
	@andor 查询条件"and"或者"or"
	@startindex 起始位置
	@offset 查询量
]]

function _M.getBaseFromSql(srcsql,parm,andor,startindex,offset)
	--local name = ngx.quote_sql_str(username) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用

	--删除所有空值	
	for i= table.getn(parm),1,-1 do
		local keyvalue = parm[i];
		if not keyvalue then
			table.remove(parm,i);
		end
	end

	local sqlstr = db_help.select_help(srcsql,parm,andor,startindex,offset)

	local db = mysql:new()	
	 db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sqlstr)
	db:close()
	if not res then
		return err
	end
	return res
end
 
--[[
	调用此方法可以更新sql
	--example

	tablename = "t_user"
	parm.user_code="user_code_1"
    parm.file_name="file"

	local base_db = require "db.base_db"
    local basedbOp = base_db.new();
	local res,err = basedbOp.insertBaseToSql(tablename,parm)	

    @param代表更改的键值对（除掉条件键值对）  
	@Kparm条件的table
	
]]
 function _M.insertOrderToSql(parm)

 	local  goodsinfolist = parm.goodsinfolist

 	parm.goodsinfolist = nil
	--删除所有空值	
	for i= table.getn(parm),1,-1 do
		local keyvalue = parm[i];
		if not keyvalue then
			table.remove(parm,i);
		end
	end

	--获取商品的模型并获取所有key
	local goodsinfo = goodsinfolist][1];
	local revKeys = {}
	local goodsdbkey = ""
	for k,v in pairs(goodsinfo) do 
		revKeys[v] = k
		--获取所有key，并拼接
		if(goodsdbkey == "") then
			goodsdbkey= k
		else
			goodsdbkey = goodsdbkey..","..k
		end
	 end

	--获取所有值
	local sqlvalue = ""
	for i= table.getn(goodsinfolist),1,-1 do
		local tempvalue = goodsinfolist[i];
		
		
		if not tempvalue then
			
			table.remove(goodsinfolist,i);
			
		else
				local goodsvalue = ""

				for x= table.getn(revKeys),1,-1 do
					local goodskey = revKeys[x]
					local  goodsvalue = tempvalue[goodskey]
					--获取所有key，并拼接
					if(goodsvalue == "") then
						goodsvalue= ngx.quote_sql_str(goodsvalue)
					else
						goodsvalue = goodsvalue..","..ngx.quote_sql_str(goodsvalue)
					end 
				end	

				if (sqlvalue == "") then

					sqlvalue = string.format("(%s)",goodsvalue)

				else
				
					sqlvalue = sqlvalue..",".. string.format("(%s)",goodsvalue)

				end	


		end
	end
	--t_order_mem 订单内容数据库语句
	local ordermemsql = string.format("insert into t_order_mem (%s) values %s",goodsdbkey,sqlvalue)

 	--封装订单表SQL语句
	local sqlstr =db_help.insert_help("t_order",parm)
	
	--local username = ngx.quote_sql_str(user) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用
	local db = mysql:new()
	--事务操作,发生错误就回滚
	db:query("SET NAMES utf8")
	db:query([[START TRANSACTION;]])

	local res, err, errno, sqlstate = db:query(sqlstr)
	
	 if not res then
		 db:query([[ROLLBACK;]])
		 return res,err,errno
	 end
	
		 res, err, errno, sqlstate = db:query(ordermemsql)
	
	 if not res then
		 db:query([[ROLLBACK;]])
		 return res,err,errno
	 end
	
	 db:query([[COMMIT;]])
	
	db:close()
	if not res then
		return err
	end
	return res
end
 
--[[
	调用此方法可以更新sql
	--example
	tablename = "t_user"
	parm.user_code_fk="user_code_1"
    parm.file_name="file"

	Kparm.id=1
	Kparm.code="001"

	local base_db = require "db.base_db"
    local basedbOp = base_db.new();
	local res,err = basedbOp.updateBaseFromSql(tablename,parm,Kparm)	

    @param代表更改的键值对（除掉条件键值对）  
	@Kparm条件的table
	
]]
 
 function _M.updateBaseFromSql(tablename,parm,Kparm)
	
	--删除所有空值	
	for i= table.getn(parm),1,-1 do
		local keyvalue = param[i];
		if not keyvalue then
			table.remove(param,i);
		end
	end


	--删除所有空值	
	for i= table.getn(Kparm),1,-1 do
		local keyvalue = Kparm[i];
		if not keyvalue then
			table.remove(Kparm,i);
		end
	end

		--封装SQL语句
	local sqlstr =db_help.update_help(tablename,parm,Kparm)
		

	--local username = ngx.quote_sql_str(user) -- SQL 转义，将 ' 转成 \', 防SQL注入，并且转义后的变量包含了引号，所以可以直接当成条件值使用
	local db = mysql:new()
	db:query("SET NAMES utf8")
	local res, err, errno, sqlstate = db:query(sqlstr)
	db:close()
	if not res then
		return err
	end
	return res
end
--[[
	调用此方法可以删除sql数据
	--example
	tablename = "t_user"
	parm.usercode="user_code_1"

	local base_db = require "db.base_db"
    local basedbOp = base_db.new();
	local res,err = basedbOp.deleteBasefromSql(tablename,parm)	

    @param代表更改的键值对（除掉条件键值对）  
	
]]
function _M.deleteBasefromSql(parm)


	--删除所有空值	
	for i= table.getn(parm),1,-1 do
		local keyvalue = parm[i];
		if not keyvalue then
			table.remove(parm,i);
		end
	end

		--封装SQL语句
	local ordersqlstr =db_help.delete_help("t_order",parm)


	local ordermemsqlstr =db_help.delete_help("t_order_mem",parm)

	local db = mysql:new()
	--事务操作,发生错误就回滚
	db:query("SET NAMES utf8")
	db:query([[START TRANSACTION;]])

	local res, err, errno, sqlstate = db:query(ordersqlstr)
	
	 if not res then
		 db:query([[ROLLBACK;]])
		 return res,err,errno
	 end
	
		 res, err, errno, sqlstate = db:query(ordermemsqlstr)
	
	 if not res then
		 db:query([[ROLLBACK;]])
		 return res,err,errno
	 end
	
	 db:query([[COMMIT;]])
	db:close()
	if not res then
		return err
	end
	return res
end 
 




return _M