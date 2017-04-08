local delay = 3  -- in seconds
local new_timer = ngx.timer.at
local log = ngx.log
local ERR = ngx.ERR
local check

local ngx_worker_id = ngx.worker.id()


local chat_room = require "chat_room.init_chat_room"





local function rootinit()
   -- 系统初始化
    chat_room:init_rooms();
end

require "chat_room.anchors_chat_rooms"

-- check = function(premature)
--  if not premature then

--     -- 执行需要处理的业务 然后继续创建新的定时器,保证定时器一直成功
--     -- log(ERR, "on check!!!!----- ", ngx_worker_id)    

--      -- do the health check or other routine work
--      local ok, err = new_timer(delay, check)
--      if not ok then
--          log(ERR, "failed to create timer: ", err)
--          return
--      end
--  end
    
-- end

-- local ok, err = new_timer(delay, check)
-- if not ok then
--     log(ERR, "failed to create timer: ", err)
--     return
-- end


local ok, err = new_timer(3, rootinit)
if not ok then
    log(ERR, "failed to init_rooms: ", err)
    return
end

