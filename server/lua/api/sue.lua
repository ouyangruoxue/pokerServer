--[[
	获取玩家礼物列表
	@param id 
	
]]--
local cjson = require "cjson"
-- local reqArgs = require "common.request_args"
-- local responeData = require "common.api_data_help"

-- local fileSys = require "common.lua_file_help"
-- local project_dir = fileSys.getCurPath()
-- ngx.say("*************"..project_dir.."**********")
-- 获取参数
-- local currentRequestArgs = reqArgs.new()
-- local getArgs,postArgs = currentRequestArgs.getArgs()


-- if getArgs.userCode=="1" then 
-- 	ngx.print("sue")
-- else
-- 	ngx.print("mud")
-- end


-- for n in pairs(_G) do ngx.say(n) end
-- local cjson = require "cjson"

-- local header = ngx.req.get_headers();

-- 	ngx.req.read_body()  
--   local  post_arg = ngx.req.get_post_args()  
 

-- ngx.say(cjson.encode(header))
-- ngx.say(cjson.encode(post_arg))


local files_api = require "files.common.file_apis"

	local path = files_api.handle_uploading()
	local completely_path = "http://"..ip..":"..port.."/uploadfile/"..path

    ngx.print(completely_path)

