--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:err_redirect.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  错误重定向的简单封装,用于系统的重定向错误处理,
--  重定向过来时,如果存在url 则直接跳向该连接;
			   如果不存在url根据编码约定返回;
			   如果都没有,则跳转到默认文件
--]]
-- 本文件进行重定向的管理

local cjson = require "cjson"

local _M={
	file_access_error = "/401.html", 
}
 
--[[
-- _M.redirect( _url ) 系统重定向的
--  如果不存在指定文件,将结果加入返回的数据表中
-- example

-- @param err_code 系统错误编号 参考init.error_ex.lua 文件的预定义,用户可以自定义自己的参数,起始数字为444
-- @param _data 	返回消息的主体
-- @param _desc 	描述信息

--]]

 function  _M.redirect_by_code( _redirect_code , _params)
 	-- body 
	if _redirect_code then 
		local url = _M[_redirect_code];
		if not url then ngx.exit(400) end;
	 
		if _params then
			local jsonStr=cjson.encode(_params);
			if jsonStr then 
				url = url.."?url="..ngx.decode_base64(jsonStr)
			end 
		end 
		return ngx.redirect(url) 
	else
		return ngx.exit(400) 
	end;
 end 
	
--[[废弃 但勿删除


 function  _M.redirect( _url )
 	-- body 
	if url then
	 	return ngx.redirect(url) 
	else
		return ngx.exit(400) 
	end;
 end
 --]]

return _M