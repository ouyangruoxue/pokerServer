local cjson = require "cjson"
local req = require "common.request_args"
local redis = require "redis.zs_redis"
local red = redis:new()
local respone = require"common.api_data_help"

local currentRequest = req.new();
local args = currentRequest:getArgs()
 --[[

	首先判断有无token,没有直接退出

 --]] 
local uri =  ngx.var.uri

if uri ~= "/api/user/login" or uri ~= "/api/user/register" or uri ~="/api/demo" or uri ~= "/api/user/access" or uri ~= "/api/user/leave" then


 if not args.token  then

 		   local  result = respone.new_failed({},zhCn_bundles.login_no_token_error)
 		   ngx.say(cjson.encode(result))
           ngx.exit(ngx.HTTP_FORBIDDEN)
           return
 end
 
  local ret = red:get(args.token)
       
   if not ret then
          
   local  result = respone.new_failed({},zhCn_bundles.login_token_outtime_error)
 		   ngx.say(cjson.encode(result))
           ngx.exit(ngx.HTTP_FORBIDDEN)
          return
    end

end

