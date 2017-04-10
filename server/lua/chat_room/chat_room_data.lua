--[[
--  作者:zuoxiaolin 
--  日期:2017-03-10
--  文件名:err_redirect.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  定义socket 传递的数据格式

--]]
local JSON = require("cjson")

local _M = {};

local message_enmu = {
    --普通弹幕消息
    type_Barrage_message = 0,
    --礼物消息
    type_gifts_message = 1,
    --封禁消息
    type_ban_message = 2,
    --房管变更
    type_housing_management_message = 3,
    --用户下注信息
    type_user_bet = 4,
    --用户中奖信息
    type_user_winning = 5,
    --主播开播消息
    type_anchor_show  = 6,
    --主播关播 
    type_anchor_close = 7,
    --牌局状态变更消息 
    type_game_status = 8     

    --牌局历史记录 
    type_game_status = 9  
}

--[[
    普通弹幕
    local message = {
    --用户编号
    usercode = "",
    --昵称
    nickname = "",
    --消息内容
    content = ""
}
--]]
--消息
function _M.message_barrage_event(message)
    return JSON.encode(
        {
            type= message_enmu.type_Barrage_message,
            data=message
        }
    );
end

--送礼

--[[
    礼物消息
    local message = {
    --送礼人用户编号
    send_user_code = "",
    
    anchorId = "",

    --收礼人用户编号
    rec_user_code = "",

    --送礼人昵称
    nickname = "",
    --礼物类型
    gift_type_id_fk = "",

    --礼物价值
    gift_value = "",

    gift_total_value = "",
    --礼物名称
    gift_name = "",
    --礼物数量
    gift_number = "" 
}
--]]

function _M.message_gifts_event(message)
    return JSON.encode(
        {
            type=message_enmu.type_gifts_message,
            data=message
        }
    );
end

--[[
    封禁消息
    local message = {
    
    --被操作人用户编号
    user_code = "",

    --被操作人昵称
    nickname = "",
    --禁言or解除禁言
    desc = ""

}
--]]
function _M.message_ban_event(message)
    return JSON.encode(
        {
            type=message_enmu.type_ban_message,
            data=message
        }
    );
end

--[[
    --房管消息变更
    local message = {
    
    --被操作人用户编号
    user_code = "",

    --被操作人昵称
    nickname = "",
    --设为房管or取消房管
    desc = ""
}
--]]
function _M.message_housing_management_event(message)
    return JSON.encode(
        {
            type=message_enmu.type_housing_management_message,
            data=message
        }
    );
end


--[[
    --用户下注消息
    local message = {
    
    --被下注玩家id
    game_player_id = "",
    --被下注玩家昵称
    game_player_nickname ="",

    --下注人用户编号
    user_code = "",

    --这里要跟第三方通信
    third_user_id = ""

    thidrd_channel_business_id = "",
    --下注人昵称
    nickname = "",
    --下注金额
    bet_num = "",
    --0下注失败 1下注成功
    bet_status = 0,
    --下注前余额
    pre_bet_balance ="",
    --下注后余额
    sub_bet_balance ="",
    --投注结果0赢1输
    bet_result = ""
}
--]]
function _M.message_user_bet_event(message)
    return JSON.encode(
        {
            type=message_enmu.type_user_bet,
            data=message
        }
    );
end

--[[
    --用户中奖消息
    local message = {
    
    --被下注玩家编号
    game_player_id = "",
    
    --被下注玩家昵称
    game_player_nickname ="",

    --中奖人用户编号
    user_code = "",

    --中奖人昵称
    nickname = "",
    --中奖金额
    refund_amount  = ""
}
--]]
function _M.message_user_winning_event(message)
    return JSON.encode(
        {
            type=message_enmu.type_user_winning,
            data=message
        }
    );
end

--[[
    --主播开播
    local message = {
    
    --主播id
    anchorId = "",
    liveStatus = 1,

    --主播用户编号
    user_code = ""
    --游戏类型1德州扑克2牛牛3vip
    gameType = "",

}
--]]
function _M.message_anchor_show_event(message)
    return JSON.encode(
        {
            type=message_enmu.type_anchor_show,
            data=message
        }
    );
end

--[[
    --主播关播
    local message = {
    
     --主播id
    anchorId = "",

    liveStatus = 0,

    --主播用户编号
    user_code = ""
}
--]]

function _M.message_anchor_close_event(message)
    return JSON.encode(
        {
            type=message_enmu.type_anchor_close,
            data=message
        }
    );
end

--[[
    --牌局信息
    local message = {
    
     --牌局状态 2准备开始游戏3等待下注（15秒）4停止下注5发牌6结束显示牌局结果
    gameStatus = "",

    playerlist={player1,player2....}


    player = {
    
     --用户id
    id = -1,
    --昵称
    name = "",
    --1男2女，默认男
    sex  = 1,
    --头像
    icon = "",
    --是否是庄家0否1是
    isBanker = 0,
    --手牌
    handCards = {},
    --组合最大牌
    cards = {},

    action = -1, 
    --牌型
    cardType = nil

    }
}
--]]

function _M.message_game_status_event(message)
    return JSON.encode(
        {
            type=message_enmu.type_game_status,
            data=message
        }
    );
end




function _M.decode_emit_events(recv)
    local ok,json = pcall(JSON.decode,recv);
    if ( ok ) then
        return true,json['type'],json['data'];
    end
    return false;
end

return _M;