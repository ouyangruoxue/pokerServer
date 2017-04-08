-- region *.lua
-- Date 2017-03-07
-- 此文件由[BabeLua]插件自动生成


local _Poker = require "game.poker.Poker"
local CardSet = require "game.TexasHoldem.CardSet"
local _TexasHoldem = require "game.TexasHoldem.TexasHoldem"
require "game.TexasHoldem.Room"
local cjson = require "cjson"

local _NNPoker = require "game.niuniu.niuniu";



function playTexasHoldem(playerNum)
    local poker = _Poker:new(1, false)
    local room = Room:new(10608)
    for i = 1, playerNum, 1 do
        room:addPlayer("P")
    end

    -- 第一步：每个玩家发2张底牌
    for count = 1, 2, 1 do
        for i = 1, table.getn(room.playerList), 1 do
            room.playerList[i]:insertCard(_Poker.get(poker))
        end
    end

    --
    for count = 1, 5, 1 do
        room.publicCards:insert(_Poker.get(poker))
    end

    Common:printCardSet("公共牌：", room.publicCards)
    for i = 1, table.getn(room.playerList), 1 do
        Common:printCardSet(room.playerList[i].name, room.playerList[i].handCards)
    end

    room:compareCards()
    print("Winer: ", room.winer.name)
end

local counter = 0
function playNiuNiu(playerNum)

    local poker = _Poker:new(1, false)
    local room = Room:new(10608)
    for i = 1, playerNum, 1 do
        room:addPlayer("P")
    end

    for count = 1, 5, 1 do
        for i = 1, table.getn(room.playerList), 1 do
            room.playerList[i]:insertCard(_Poker.get(poker))
        end
    end

    local isPlayer1 = true
    for i = 1, table.getn(room.playerList), 1 do
        room.playerList[i].cardType, room.playerList[i].cards = _NNPoker.getCardsMaxType(room.playerList[i].handCards)
        Common:printCardSet(room.playerList[i].name, room.playerList[i].cards, Common:getCardDescNiuNiu(room.playerList[i].cardType))

        --        -- local a, b = _NNPoker.getCardsMaxType(room.playerList[i].handCards)
        --        -- print("")
        --        Common:printCardSet(room.playerList[i].name, room.playerList[i].handCards)

        --        if i >= 2 then
        --            isPlayer1 = _NNPoker.jugeCards(room.playerList[i - 1].handCards, room.playerList[i].handCards)
        --            if isPlayer1 then
        --                room.winer = room.playerList[i - 1]
        --            else
        --                room.winer = room.playerList[i]
        --            end
        --        end

        if room.playerList[i].cardType == 14 then
            print("哇塞, 五小")
            counter = 0
        end

        if room.playerList[i].cardType == 13 then
            print("哇塞, 炸弹")
        end

        if room.playerList[i].cardType > 10 then
            print("哇塞, 五花")
        end

        if room.playerList[i].cardType > 10 then
            print("哇塞, 四花")
        end

        counter = counter + 1
    end
    -- print("Winer: ", room.winer.name)
end

function getRandom(tb)
    local index = math.random(1, table.getn(tb))
    local val = tb[index]
    table.remove(tb, index)
    return val
end


while true do
    -- local room = playTexasHoldem(5)
    local room = playNiuNiu(5)
--    local cards = { }
--    for i = 1, 52, 1 do
--        cards[i] = i
--    end

--    print(getRandom(cards), getRandom(cards), getRandom(cards), getRandom(cards), getRandom(cards))
--    print(getRandom(cards), getRandom(cards), getRandom(cards), getRandom(cards), getRandom(cards))
--    print(getRandom(cards), getRandom(cards), getRandom(cards), getRandom(cards), getRandom(cards))
--    print(getRandom(cards), getRandom(cards), getRandom(cards), getRandom(cards), getRandom(cards))
--    print(getRandom(cards), getRandom(cards), getRandom(cards), getRandom(cards), getRandom(cards))

    --os.execute("pause")
end

-- print(cjson.encode(room));







-- room.playerList[1].cards = cards1
-- room.playerList[2].cards = cards2

-- local winer = _TexasHoldem.Juge(room.playerList)
-- print(winer.name)

print("=====================END")

-- require("game.TexasHoldem.Common")
-- require("game.TexasHoldem.TexasHoldem")
-- require("game.TexasHoldem.Player")
-- require("game.TexasHoldem.Room")
-- require("game.TexasHoldem.CardSet")

-- function testCompare()
--    local room = Room:new(10608)
--    room:addPlayer("P");
--    room:addPlayer("P");

--    local cards1 = CardSet:new()
--    cards1:insert(Card:new(1,14));
--    cards1:insert(Card:new(2,14));
--    cards1:insert(Card:new(1,3));
--    cards1:insert(Card:new(2,3));
--    cards1:insert(Card:new(1,9));

--    local cards2 = CardSet:new()
--    cards2:insert(Card:new(1,14));
--    cards2:insert(Card:new(2,14));
--    cards2:insert(Card:new(1,3));
--    cards2:insert(Card:new(2,3));
--    cards2:insert(Card:new(1,6));

--    room.playerList[1].cards = cards1
--    room.playerList[2].cards = cards2

--    local winer = TexasHoldem.Juge(room.playerList)
--    print(winer.name)
-- end

-- testCompare()

-- local room = Room:new(10001)
-- while true do
--    room:run()
--    print(room:toJson())
--    print("\n===============按任意键继续")
--    io.read()
-- end




---- 初始化扑克牌 (4种花色，每种花色13张牌，从2到14)
-- local poker = CardSet:new()
-- local playerList = { }
---- 公共牌，最多5张
-- local publicCards = CardSet:new()





-- function mainTest(num)
--    playerNum = num

--    poker = CardSet:new()
--    for suit = 1, 4, 1 do
--        for id = 1, 13, 1 do
--            poker[id + 13 *(suit - 1)] = Card:new(suit, id + 1)
--            -- poker[i + 13 *(suit - 1)] = i+1 + suit * 100
--        end
--    end

--    playerList = { }
--    -- 玩家列表
--    for i = 1, playerNum, 1 do
--        playerList[i] = Player:new(100010000 + i, "P" .. i, CardSet:new())
--    end
--    print("玩家数量：" .. table.getn(playerList))

--    -- 发牌下注步骤：发牌一般分为5个步骤，分别为，

--    -- STEP1 : Perflop—先下大小盲注，然后给每个玩家发2张底牌，大盲注后面第一个玩家选择跟注、加注或者盖牌放弃，
--    --              按照顺时针方向，其他玩家依次表态，大盲注玩家最后表态，如果玩家有加注情况，前面已经跟注的玩家需要再次表态甚至多次表态。

--    -- 第一步：每个玩家发2张底牌
--    for round = 1, 2, 1 do
--        for i = 1, table.getn(playerList), 1 do
--            playerList[i]:insertCard(Common:get(poker))
--        end
--    end


--    ---- 打印玩家的牌信息
--    for i = 1, table.getn(playerList), 1 do
--        Common:printCardSet("玩家" .. i .. "底牌", playerList[i].handCards)
--    end

--    -- STEP2 : Flop—同时发三张公牌，由小盲注开始（如果小盲注已盖牌，由后面最近的玩家开始，以此类推），按照顺时针方向依次表态，玩家可以选择下注、加注、或者盖牌放弃。
--    -- 第二步：发3张公共牌
--    publicCards = CardSet:new()
--    for round = 1, 3, 1 do
--        publicCards:insert(Common:get(poker))
--    end



--    -- STEP3 : Turn -- 发第4张牌，由小盲注开始，按照顺时针方向依次表态，玩家可以选择下注、加注、或者盖牌放弃。
--    -- 第三步：发第4张公共牌
--    publicCards:insert(Common:get(poker))

--    -- STEP4 : River—发第五张牌，由小盲注开始，按照顺时针方向依次表态，玩家可以选择下注、加注、或者盖牌放弃。
--    -- 第四步：发第5张公共牌
--    publicCards:insert(Common:get(poker))


--    -- STEP5 : 比牌 -- 经过前面4轮发牌和下注，剩余的玩家开始亮牌比大小，成牌最大的玩家赢取池底。
--    -- 第五步：比牌

--    Common:printCardSet("\n公共牌", publicCards)
--    print("\n")

--    for i = 1, table.getn(playerList), 1 do
--        playerList[i].cards, playerList[i].cardType = TexasHoldem.getUsersMaxCards(playerList[i].handCards, publicCards);
--        Common:printCardSet("玩家" .. i, playerList[i].cards, " (" .. playerList[i].cardType .. ") : " .. Common:getCardDesc(playerList[i].cardType))
--    end

--    print(getPlayersCards(playerList))
--    print(getCardsJson(publicCards))

--    -- 比牌
--    local p = TexasHoldem.Juge(playerList)
--    print("赢家" .. p.name)
--    print(cjson.encode(playerList))


--    local cards1 = CardSet:new()
--    cards1:insert(Card:new(1, 14))
--    cards1:insert(Card:new(2, 14))
--    cards1:insert(Card:new(1, 3))
--    cards1:insert(Card:new(2, 3))
--    cards1:insert(Card:new(1, 9))

--    local cards2 = CardSet:new()
--    cards2:insert(Card:new(1, 14))
--    cards2:insert(Card:new(2, 14))
--    cards2:insert(Card:new(1, 3))
--    cards2:insert(Card:new(2, 3))
--    cards2:insert(Card:new(1, 6))


--    local playerTempList = {
--        { cardType = nil, name = "p1", cards = cards1 },
--        { cardType = nil, name = "p2", cards = cards2 }
--    }

--    local winer = TexasHoldem.Juge(playerTempList)
--    print("\n==测试:赢家" .. winer.name)

--    local c, flag = TexasHoldem.JugeCards(cards1, cards2)

--    return getRoomInfo(p.id)
-- end
---- io.read()
-- mainTest(5)
os.execute("pause") 

-- endregion
