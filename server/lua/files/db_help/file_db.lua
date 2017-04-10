--[[
-- files 文件系统的数据库独立模块，该模块主要通过mysql+redis的方式进行系统的文件记录和数据查询
-- 本期采用单数据库的方式
-- 二期系统需要采用分布式mysql+主从集群的方式提供基础的访问能力 
-- 即，系统采用分布式方式，分布式的节点采用主从的方案进行系统建设
--]]

local mysql     = require "resty.mysql"
local db_conf   = require "files.db_help.db_conf"
local redis     = require "files.db_help.file_redis_help"

local cjson = require "cjson"


local _M        = {VERSION="0.01"}

function _M.new_mysql(self)
    local db, err = mysql:new()
    if not db then
        return nil
    end
    db:set_timeout(1000) -- 1 sec
    
    local ok, err, errno, sqlstate = db:connect(db_conf.mysql_db_master)

    if not ok then
         ngx.log(ngx.ERR, "mysql connect error :", err)
        return nil
    end
    db.close = close
    return db
end

function close(self)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end
    if self.subscribed then
        return nil, "subscribed state"
    end
	-- put it into the connection pool of size 100,
    -- with 10 seconds max idle timeout
    return sock:setkeepalive(10000, 50)
end


function _M.new_redis()
    -- body
    return redis:new();
end

return _M