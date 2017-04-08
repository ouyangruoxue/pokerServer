local cjson = require "cjson"
local redis = require "redis.zs_redis"
local resty_md5 = require "resty.md5"
local str = require "resty.string"
local uuid = require 'resty.jit-uuid'

local responeData = require "common.api_data_help"

local red = redis:new()
uuid.seed()
local  uuidst = uuid()
local  state =  ngx.md5(uuidst)
ngx.say(state)

local ok, err = red:set(state, "wechatlogin")
if not ok then
   local  result = responeData.new_failed({},err)
    ngx.say(cjson.encode(result))
    return
end
--设置删除时间60秒
red:expire(state,600)



local returnvalue = {}
returnvalue.states = state
local  result = responeData.new_success(returnvalue)
ngx.say(cjson.encode(result))





