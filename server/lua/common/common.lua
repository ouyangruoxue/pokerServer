local cjson = require "cjson"
--[[
local redis=require "redis.zs_redis"

local redisClient = redis:new();
if(redisClient) then
	local res =redisClient:do_command("hgetall")
	ngx.say(cjson.encode(res))
else
	ngx.say('redis read error')
end

return
]]
-- mysql search test



--[[
if zhCn_bundles then
	for k,v in pairs(zhCn_bundles) do
		ngx.say(k..' '..v)
	end
else
	ngx.say('english bundle is nil')
end

local session = {
    _VERSION = "2.15"
}
]]

local abc={
	a=1,b=2,c=3
}
local mt = { __index = abc }   
local source={};

function abc.new()
	local source1={};
	return setmetatable(source1, mt)    
end
local cjson = require "cjson"


local test=abc.new();

ngx.say(cjson.encode(test))
--ngx.say(getmetatable(test))     -- nil
local t1=abc.new();
local t2=abc.new();
ngx.say("t1.a:"..t1.a)

ngx.say("t2："..cjson.encode(t2))
t2.a=3;
ngx.say("t2: "..cjson.encode(t2))

ngx.say("t2.a:"..t2.a)
ngx.say("t1.a:"..t1.a)
