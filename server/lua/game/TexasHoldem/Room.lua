
local CardSet = require("game.TexasHoldem.CardSet")
local Card = require "game.TexasHoldem.Card"
require("game.TexasHoldem.Player")
local _TexasHoldem = require "game.TexasHoldem.TexasHoldem"
require("game.TexasHoldem.Common")
local cjson = require "cjson"


RoomStatue = {
    -- 房间关闭/没有玩家
    CLOSED = 0,

    -- 等待玩家(玩家数量不够)
    WAITTING = 1,

    -- 准备开始游戏
    READY = 2,

    -- 正在游戏中
    PLAYING = 3,

    -- 结束
    FINISHED = 4
}

GameSatus = {

}

Room = {
    -- 房间ID
    id = - 1,

    publicCards = nil,

    -- 房间玩家列表
    playerList = { },

    -- 扑克牌
    poker = { },

    -- 房间的状态
    status = RoomStatue.CLOSED,

    winer = nil
}

function Room:new(_id)
    local self = { }
    setmetatable(self, { __index = Room })
    self.id = _id
    self.playerList = { }
    self.status = RoomStatus
    self.publicCards = CardSet:new()

    -- 初始化扑克牌
    self.poker = CardSet:new()
    for suit = 1, 4, 1 do
        for id = 1, 13, 1 do
            self.poker[id + 13 *(suit - 1)] = Card:new(suit, id + 1)
            -- poker[i + 13 *(suit - 1)] = i+1 + suit * 100
        end
    end
    return self
end



function Room:prepare()
    self.publicCards = CardSet:new()
    self.playerList = { }
    self.poker = CardSet:new()
    self.winer = nil
    for suit = 1, 4, 1 do
        for id = 1, 13, 1 do
            self.poker[id + 13 *(suit - 1)] = Card:new(suit, id + 1)
            -- poker[i + 13 *(suit - 1)] = i+1 + suit * 100
        end
    end
end

function Room:addPlayer(_name)
    local curNum = table.getn(self.playerList) + 1
    table.insert(self.playerList, Player:new(100010000 + curNum, _name .. curNum, CardSet:new()))
end

-- 取牌
math.randomseed(tostring(os.time()):reverse():sub(1, 7))
function Room:getCard()
    -- math.randomseed(os.time())
    -- math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    local index = math.random(1, table.getn(self.poker))
    local card = self.poker[index]
    table.remove(self.poker, index)
    return card
end

-- 每个玩家发2张底牌
function Room:dealHandCard()
    for i = 1, table.getn(self.playerList), 1 do
        self.playerList[i]:insertCard(self:getCard())
    end
end

-- 发1张公共牌
function Room:dealPublicCard()
    self.publicCards:insert(self:getCard())
end


function Room:getPlayerNum()
    return table.getn(self.playerList)
end



function Room:compareCards()
    for i = 1, table.getn(self.playerList), 1 do
        self.playerList[i].cards, self.playerList[i].cardType = _TexasHoldem.getUsersMaxCards(self.playerList[i].handCards, self.publicCards);
        if table.getn(self.playerList[i].cards) < 5 then
            print("ERROR")
        end
        Common:printCardSet("最大牌: " .. self.playerList[i].name, self.playerList[i].cards, " (" .. self.playerList[i].cardType .. ") : " .. Common:getCardDesc(self.playerList[i].cardType))
    end

    self.winer = _TexasHoldem.Juge(self.playerList)
    if not self.winer then
        print("ERROR")
    end
    return self.winer 
end

function Room:run()
    self:prepare()

    for i = 1, 5, 1 do
        self:addPlayer("P")
    end

    for i = 1, 2, 1 do
        self:dealHandCard()
    end

    for i = 1, self:getPlayerNum(), 1 do
        Common:printCardSet(self.playerList[i].name .. " 底牌:", self.playerList[i].handCards)
    end

    for i = 1, 3, 1 do
        self:dealPublicCard()
    end

    self:dealPublicCard()
    self:dealPublicCard()

    Common:printCardSet("\n公共牌:", self.publicCards)

    self:compareCards()
    print("赢家： " .. self.winer.name)
end




-- {
--    "public":[{"suit":1, "points":12},{"suit":1, "points":12},{"suit":1, "points":12},{"suit":1, "points":12},{"suit":1, "points":12}],
--    "playerList":[
--    {
--        "id":"100010001",
--        "name":"P1",
--        "handCards":[{"suit":1, "points":12},{"suit":1, "points":12}],
--        "cards":[{"suit":1, "points":12},{"suit":1, "points":11},{"suit":1, "points":10},{"suit":1, "points":9},{"suit":1, "points":8}]
--    }],
--    "winerId":"100010001"
-- }

function getRoomInfo(_winerId)
    local str = "{"
    str = str .. "\"public\":" .. getCardsJson(publicCards) .. ","
    str = str .. "\"playerList\":" .. getPlayersCards(playerList) .. ","
    str = str .. "\"winerId\":\"" .. _winerId .. "\""
    str = str .. "}"
    return str
end



function getCardsJson(_cards)
    local str = "["
    local size = table.getn(_cards)
    for i = 1, size, 1 do
        str = str .. "{\"suit\":" .. _cards[i].suit.. ",\"points\":" .. _cards[i].points .. "}"
        if i < size then
            str = str .. ","
        end
    end
    str = str .. "]"
    return str
end

function getPlayersCards(_lstPlayers)
    local str = "["
    local size = table.getn(_lstPlayers)
    for i = 1, size, 1 do
        str = str .. "{"
        str = str .. "\"id\":\"" .. _lstPlayers[i].id .. "\","
        str = str .. "\"name\":\"" .. _lstPlayers[i].name .. "\","
        str = str .. "\"handCards\":" .. getCardsJson(_lstPlayers[i].handCards) .. ","
        str = str .. "\"cards\":" .. getCardsJson(_lstPlayers[i].cards) .. "}"

        if i < size then
            str = str .. ","
        end
    end
    str = str .. "]"
    return str
end


function Room:toJson()
    local str = "{"
    str = str .. "\"public\":" .. cjson.encode(self.publicCards) .. ","
    str = str .. "\"playerList\":" .. cjson.encode(self.playerList) .. ","
    str = str .. "\"winerId\":\"" .. self.winer.id .. "\""
    str = str .. "}"
    return str
end