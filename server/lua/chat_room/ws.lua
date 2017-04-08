-- simple chat with redis
local server = require "resty.websocket.server"
local redis = require "resty.redis"
local semaphore = require "ngx.semaphore"
local anchors = require "chat_room.anchors_chat_rooms"
local reqArgs = require "common.request_args"

-- 读取玩家的信息包括主播名称,用户id,接入前需要提前判断一次,
-- 这里做一次判断,会比较多余
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
-- 查询当前的请求

-- usercode 表示用户编号,该文件会作为用户上传的文件存储在用户空间中
local userCode = args["userCode"]; 
local anchor_user_code = args["anchor_user_code"];

if not userCode or not anchor_user_code then
    ngx.log(ngx.INFO,"userCode is nil or anchordId is nil!")
    return ngx.exit(444)
end


local sema = semaphore.new()

--create connection
local wb, err = server:new{
  timeout = 100000,
  max_payload_len = 65535
}

--create success
if not wb then
  ngx.log(ngx.ERR, "failed to new websocket: ", err)
  return ngx.exit(444)
end
 
local close_flag = false;

-- 获得主播对象 加入主播的房间
-- 获得主播id 加入主播房间 返回房间id
local anchor = anchors:getAnchor(anchor_user_code);
if not anchor then
  ngx.log(ngx.ERR, "failed to anchors.getAnchor(anchor_user_code)",anchor_user_code)
  return ngx.exit(444)
end
 

local room = anchor:joinRoom(userCode,sema,"");
if not room then
  ngx.log(ngx.ERR, "failed to anchor:join(usercode,sema,)",anchor_user_code)
  return ngx.exit(444)
end


--[[
--  用户拥有权限加入聊天室之后,用户本地将存储聊天的信号量对象,push函数中激活之后
--  解析消息体对象,根据消息类型进行后续操作,
--  聊天室发送事件模式为,接收到用户的消息之后,用户将聊天内容组装完成发送到房间的共享内存中
--  
--]]

local isMemsgId = false;
local push = function()
     
     -- wb:send_text(tostring(msg_id).." "..item)
     --[[
    while true do
        if mark then
            ngx.log(ngx.ERR,"push here!!!!!");
            mark = nil
        end
    end
    ]]
    -- 建立连接之后,系统将会执行一次本函数
    ngx.log(ngx.ERR, "push --------------------1--------")
    local chat_room = ngx.shared.chat_room
    local jis = 1;
    while close_flag == false do
        local ok, err = sema:wait(1)
  
        if ok then
           if wb.fatal then
                ngx.log(ngx.ERR, "failed to receive frame: ", err)
                close_flag = true; 
            end
            -- 发送事件处理,系统采用共享内存进行文字发送,故本处从共享内存中读取文件
            -- 取出数据,发送事件即可 
            --ngx.log(ngx.ERR, "push -------------------2------ "..userCode)
            
            local value, flags  = chat_room:get("Message"..anchor_user_code)
            if value then
                wb:send_text(value);
            end
            -- wb:send_text("------msg from user "..userCode.." ".. userCode.."-------");
            -- wb:send_text("------msg from user "..userCode.." ".. userCode.."-------");
            
        else
            -- ngx.log(ngx.ERR, "push ---err ",err) 
        end
        
        if close_flag then
            -- socketMgr:destory(session_id)
            break
        end
    end

    
end


local co = ngx.thread.spawn(push)

--[[
local ngx_worker_id = ngx.worker.id()

local _incr_id = 0

local _gen_session_id = function()
    _incr_id = _incr_id + 1
    return (ngx_worker_id + 1) * 100000 + _incr_id
end
local seesionId = _gen_session_id();

]]
--main loop
while close_flag == false do
    -- 获取数据
    local data, typ, err = wb:recv_frame()

    -- 如果连接损坏 退出
    if wb.fatal then
        ngx.log(ngx.ERR, "failed to receive frame: ", err)
        close_flag = true;
        return ngx.exit(444)
    end

    if not data then
        local bytes, err = wb:send_ping()
        if not bytes then
          ngx.log(ngx.ERR, "failed to send ping: ", err)
          if room then
                room.playerMap[tostring(userCode)] = nil;
                room.playerS = room.playerS - 1
            end   
          close_flag = true;
          return ngx.exit(444)
        end
        -- ngx.log(ngx.ERR, "send ping: ", data)
    elseif typ == "close" then
        if room then
            room.playerMap[tostring(userCode)] = nil;
            room.playerS = room.playerS - 1
         end   
        close_flag = true;
        break
    elseif typ == "ping" then
        local bytes, err = wb:send_pong()
        if not bytes then
            ngx.log(ngx.ERR, "failed to send pong: ", err)
            close_flag = true;
            return ngx.exit(444)
        end
    elseif typ == "pong" then
        -- ngx.log(ngx.ERR, "client ponged")
    elseif typ == "text" then
        --[[ 
        -- bytes, err = wb:send_text("Hello world"..data)
        -- 发送通知
       

        if not bytes then
            ngx.log(ngx.ERR, "failed to send a text frame: ", err)
            close_flag = true;
            return ngx.exit(444)
        end 
        ]]
        ngx.log(ngx.ERR, "getMessage : ", data)
        if room then
            room:sendMsg(data)
        end

        -- sema:post(1);
        --syntax: wb:set_timeout(ms) 
     
    end
end

close_flag = true; 
wb:send_close()
ngx.thread.wait(co)

--[[
local server = require "resty.websocket.server"

    local wb, err = server:new{
        timeout = 5000,  -- in milliseconds
        max_payload_len = 65535,
    }
    if not wb then
        ngx.log(ngx.ERR, "failed to new websocket: ", err)
        return ngx.exit(444)
    end

    local data, typ, err = wb:recv_frame()

    if not data then
        ngx.log(ngx.ERR, "failed to receive a frame: ", err)
        return ngx.exit(444)
    end

    if typ == "close" then
        -- send a close frame back:

        local bytes, err = wb:send_close(1000, "enough, enough!")
        if not bytes then
            ngx.log(ngx.ERR, "failed to send the close frame: ", err)
            return
        end
        local code = err
        ngx.log(ngx.INFO, "closing with status code ", code, " and message ", data)
        return
    end

    if typ == "ping" then
        -- send a pong frame back:

        local bytes, err = wb:send_pong(data)
        if not bytes then
            ngx.log(ngx.ERR, "failed to send frame: ", err)
            return
        end
    elseif typ == "pong" then
        -- just discard the incoming pong frame

    else
        ngx.log(ngx.INFO, "received a frame of type ", typ, " and payload ", data)
    end

    wb:set_timeout(60000)  -- change the network timeout to 1 second

    bytes, err = wb:send_text("Hello world")
    if not bytes then
        ngx.log(ngx.ERR, "failed to send a text frame: ", err)
        return ngx.exit(444)
    end
--[[
    bytes, err = wb:send_binary("blah blah blah...")
    if not bytes then
        ngx.log(ngx.ERR, "failed to send a binary frame: ", err)
        return ngx.exit(444)
    end

    local bytes, err = wb:send_close(1000, "enough, enough!")
    if not bytes then
        ngx.log(ngx.ERR, "failed to send the close frame: ", err)
        return
    end

]]
