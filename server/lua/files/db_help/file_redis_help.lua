--[[
-- 文件系统的redis封装，该文件需要在系统启动时在文件中进行一次加载和初始化--
--]]

local db_conf = require "files.db_help.db_conf"
local redis_c = require "resty.redis"

local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end

local _M = new_tab(0, 155)
_M._VERSION = '0.01'

local commands = {
    "append",            "auth",              "bgrewriteaof",
    "bgsave",            "bitcount",          "bitop",
    "blpop",             "brpop",
    "brpoplpush",        "client",            "config",
    "dbsize",
    "debug",             "decr",              "decrby",
    "del",               "discard",           "dump",
    "echo",
    "eval",              "exec",              "exists",
    "expire",            "expireat",          "flushall",
    "flushdb",           "get",               "getbit",
    "getrange",          "getset",            "hdel",
    "hexists",           "hget",              "hgetall",
    "hincrby",           "hincrbyfloat",      "hkeys",
    "hlen",
    "hmget",              "hmset",      "hscan",
    "hset",
    "hsetnx",            "hvals",             "incr",
    "incrby",            "incrbyfloat",       "info",
    "keys",
    "lastsave",          "lindex",            "linsert",
    "llen",              "lpop",              "lpush",
    "lpushx",            "lrange",            "lrem",
    "lset",              "ltrim",             "mget",
    "migrate",
    "monitor",           "move",              "mset",
    "msetnx",            "multi",             "object",
    "persist",           "pexpire",           "pexpireat",
    "ping",              "psetex",            "psubscribe",
    "pttl",
    "publish",          "punsubscribe",   "pubsub",
    "quit",
    "randomkey",         "rename",            "renamenx",
    "restore",
    "rpop",              "rpoplpush",         "rpush",
    "rpushx",            "sadd",              "save",
    "scan",              "scard",             "script",
    "sdiff",             "sdiffstore",
    "select",            "set",               "setbit",
    "setex",             "setnx",             "setrange",
    "shutdown",          "sinter",            "sinterstore",
    "sismember",         "slaveof",           "slowlog",
    "smembers",          "smove",             "sort",
    "spop",              "srandmember",       "srem",
    "sscan",
    "strlen",            "subscribe",      "sunion",
    "sunionstore",       "sync",              "time",
    "ttl",
    "type",             "unsubscribe",    "unwatch",
    "watch",             "zadd",              "zcard",
    "zcount",            "zincrby",           "zinterstore",
    "zrange",            "zrangebyscore",     "zrank",
    "zrem",              "zremrangebyrank",   "zremrangebyscore",
    "zrevrange",         "zrevrangebyscore",  "zrevrank",
    "zscan",
    "zscore",            "zunionstore",       "evalsha"
}

local mt = { __index = _M }

local function is_redis_null( res )
    if type(res) == "table" then
        for k,v in pairs(res) do
            if v ~= ngx.null then
                return false
            end
        end
        return true
    elseif res == ngx.null then
        return true
    elseif res == nil then
        return true
    end

    return false
end
-- 本地可以进行封装成分布式+主从的数据封装
-- 本版本采用的是单redis访问的方式，二期采用主从的方式进行，三期采用分布式+主从的架构
-- -------------------------------------------------------------------------------------------------------------------------
local redis_cf = db_conf.redis_master_main;
 
-- change connect address as you need
function _M.connect_mod( self, redis )
    redis:set_timeout(self.timeout)
    
    local ok, err = redis:connect(redis_cf.host, redis_cf.port)

    --[[ local res, errauth = redis:auth("123456")
    if not res then
        return nil ,errauth
    end --]]
    return ok,err
end

function _M.set_keepalive_mod( redis )
    -- put it into the connection pool of size 100, with 60 seconds max idle time
    return redis:set_keepalive(60000, 1000)
end

function _M.init_pipeline( self )
    self._reqs = {}
end

function _M.commit_pipeline( self )
    local reqs = self._reqs

    if nil == reqs or 0 == #reqs then
        return {}, "no pipeline"
    else
        self._reqs = nil
    end

    local redis, err = redis_c:new()
    if not redis then
        return nil, err
    end

    local ok, err = self:connect_mod(redis)
    if not ok then
        return {}, err
    end

    redis:init_pipeline()
    for _, vals in ipairs(reqs) do
        local fun = redis[vals[1]]
        table.remove(vals , 1)

        fun(redis, unpack(vals))
    end

    local results, err = redis:commit_pipeline()
    if not results or err then
        return {}, err
    end

    if is_redis_null(results) then
        results = {}
        ngx.log(ngx.WARN, "is null")
    end
    -- table.remove (results , 1)

    self.set_keepalive_mod(redis)

    for i,value in ipairs(results) do
        if is_redis_null(value) then
            results[i] = nil
        end
    end

    return results, err
end

function _M.subscribe( self, channel )
    local redis, err = redis_c:new()
    if not redis then
        return nil, err
    end

    local ok, err = self:connect_mod(redis)
    if not ok or err then
        return nil, err
    end

    local res, err = redis:subscribe(channel)
    if not res then
        return nil, err
    end

    local function do_read_func ( do_read )
        if do_read == nil or do_read == true then
            res, err = redis:read_reply()
            if not res then
                return nil, err
            end
            return res
        end

        redis:unsubscribe(channel)
        self.set_keepalive_mod(redis)
        return 
    end

    return do_read_func
end

local function do_command(self, cmd, ... )
    if self._reqs then
        table.insert(self._reqs, {cmd, ...})
        return
    end

    local redis, err = redis_c:new()
    if not redis then
        return nil, err
    end

    local ok, err = self:connect_mod(redis)
    if not ok or err then
        return nil, err
    end


    
    local fun = redis[cmd]
    local result, err = fun(redis, ...)
    if not result or err then
        -- ngx.log(ngx.ERR, "pipeline result:", result, " err:", err)
        return nil, err
    end

    if is_redis_null(result) then
        result = nil
    end

    self.set_keepalive_mod(redis)

    return result, err
end

function _M.new(self, opts)
    opts = opts or {}
    local timeout = (opts.timeout and opts.timeout * 1000) or 1000
    local db_index= opts.db_index or 0

    for i = 1, #commands do
        local cmd = commands[i]
        _M[cmd] =
                function (self, ...)
                    return do_command(self, cmd, ...)
                end
    end

    return setmetatable({
            timeout = timeout,
            db_index = db_index,
            _reqs = nil }, mt)
end

return _M


--[[

redis_factory.lua
 Redis factory method. 
 You can also find it at https://gist.github.com/karminski/33fa9149d2f95ff5d802


 @version 151019:5
 @author karminski 
 @license MIT

@changelogs
 151019:5 CLEAN test code.
 151016:4 REFACTORY spawn logic.
 151012:3 REWRITE redis proxy.
 151009:2 ADD connection mode feature.
 150922:1 INIT commit.


local redis_factory = function(h)

 local h = h

 h.redis = require('resty.redis')
 h.cosocket_pool = {max_idel = 10000, size = 200}

 h.commands = {
"append","auth","bgrewriteaof",
"bgsave","bitcount","bitop",
"blpop","brpop",
"brpoplpush","client","config",
"dbsize",
"debug","decr","decrby",
"del","discard","dump",
"echo",
"eval","exec","exists",
"expire","expireat","flushall",
"flushdb","get","getbit",
"getrange","getset","hdel",
"hexists","hget","hgetall",
"hincrby","hincrbyfloat","hkeys",
"hlen",
"hmget","hmset","hscan",
"hset",
"hsetnx","hvals","incr",
"incrby","incrbyfloat","info",
"keys",
"lastsave","lindex","linsert",
"llen","lpop","lpush",
"lpushx","lrange","lrem",
"lset","ltrim","mget",
"migrate",
"monitor","move","mset",
"msetnx","multi","object",
"persist","pexpire","pexpireat",
"ping","psetex","psubscribe",
"pttl",
"publish","punsubscribe","pubsub",
"quit",
"randomkey","rename","renamenx",
"restore",
"rpop","rpoplpush","rpush",
"rpushx","sadd","save",
"scan","scard","script",
"sdiff","sdiffstore",
"select","set","setbit",
"setex","setnx","setrange",
"shutdown","sinter","sinterstore",
"sismember","slaveof","slowlog",
"smembers","smove","sort",
"spop","srandmember","srem",
"sscan",
"strlen","subscribe","sunion",
"sunionstore","sync","time",
"ttl",
"type","unsubscribe","unwatch",
"watch","zadd","zcard",
"zcount","zincrby","zinterstore",
"zrange","zrangebyscore","zrank",
"zrem","zremrangebyrank","zremrangebyscore",
"zrevrange","zrevrangebyscore","zrevrank",
"zscan",
"zscore","zunionstore","evalsha",
 -- resty redis private command
"set_keepalive","init_pipeline","commit_pipeline", 
"array_to_hash","add_commands","get_reused_times",
}

 -- connect
 -- @param table connect_info, e.g { host="127.0.0.1", port=6379, pass="", timeout=1000, database=0}
 -- @return boolean result
 -- @return userdata redis_instance
 h.connect = function(connect_info)
 local redis_instance = h.redis:new()
redis_instance:set_timeout(connect_info.timeout)
 if not redis_instance:connect(connect_info.host, connect_info.port) then 
 return false, nil
end
 if connect_info.pass ~= '' then
redis_instance:auth(connect_info.pass)
end
redis_instance:select(connect_info.database)
 return true, redis_instance
end

 -- spawn_client
 -- @param table h, include config info
 -- @param string name, redis config name
 -- @return table redis_client
 h.spawn_client = function(h, name)

 local self = {}

 self.name =""
 self.redis_instance = nil
 self.connect = nil
 self.connect_info = {
 host ="", port = 0, pass ="", 
 timeout = 0, database = 0
}

 -- construct
 self.construct = function(_, h, name)
 -- set info
 self.name = name
 self.connect = h.connect
 self.connect_info = h[name]
 -- gen redis proxy client
 for _, v in pairs(h.commands) do
 self[v] = function(self, ...)
 -- instance test and reconnect 
 if (type(self.redis_instance) == 'userdata: NULL' or type(self.redis_instance) == 'nil') then
 local ok
 ok, self.redis_instance = self.connect(self.connect_info)
 if not ok then return false end
end
 -- get data
 return self.redis_instance[v](self.redis_instance, ...)
end
end
 return true
end

 -- do construct
 self:construct(h, name) 

 return self
end



 local self = {}

 self.pool = {} -- redis client name pool

 -- construct
 -- you can put your own construct code here.
 self.construct = function()
return
end

 -- spawn
 -- @param string name, redis database serial name
 -- @return boolean result
 -- @return userdata redis
 self.spawn = function(_, name)
 if self.pool[name] == nil then
 ngx.ctx[name] = h.spawn_client(h, name) 
 self.pool[name] = true
 return true, ngx.ctx[name]
else
 return true, ngx.ctx[name]
end
end

 -- destruct
 -- @return boolean allok, set_keepalive result
 self.destruct = function()
 local allok = true
 for name, _ in pairs(self.pool) do
 local ok, msg = ngx.ctx[name].redis_instance:set_keepalive(
 h.cosocket_pool.max_idel, h.cosocket_pool.size
)
 if not ok then allok = false end 
end
 return allok
end

 -- do construct
self.construct()

 return self
end


return redis_factory
]]--