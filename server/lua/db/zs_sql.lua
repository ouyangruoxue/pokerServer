local db_conf= require "db.db_conf"
local mysql = require "resty.mysql"

local _M = {}

function _M.new(self)
    local db, err = mysql:new()
    if not db then
        return nil
    end
    db:set_timeout(1000) -- 1 sec

    local ok, err, errno, sqlstate = db:connect(db_conf.mysql_master)

    if not ok then
        ngx.log(ngx.ERR,"createDb fail ----------------:",err)
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

return _M