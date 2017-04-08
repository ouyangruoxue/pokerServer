-- region *.lua
-- Date 2017-03-07
-- 此文件由[BabeLua]插件自动生成


require("game.TexasHoldem.Common")
require("game.TexasHoldem.TexasHoldem")
require("game.TexasHoldem.Player")

-- 卡牌集合
local CardSet = require("game.TexasHoldem.CardSet")


-- 打印TABLE的值
function printTable(text, obj)
    len = table.getn(obj)
    val = text .. "===> size=" .. len .. "  {"
    for i = 1, len, 1 do
        val = val ..(obj[i])
        if (i < len) then
            val = val .. ","
        end
    end
    val = val .. "}"
    print(val)
end





-- 初始化扑克牌 (4种花色，每种花色13张牌，从2到14)
local poker = CardSet:new()
local playerList = { }
-- 公共牌，最多5张
local publicCards = CardSet:new()


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
        str = str .. "{\"suit\":" .. _cards[i].Suit .. ",\"points\":" .. _cards[i].CardId .. "}"
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



function mainTest(num)
    playerNum = num

    poker = CardSet:new()
    for suit = 1, 4, 1 do
        for id = 1, 13, 1 do
            poker[id + 13 *(suit - 1)] = Card:new(suit, id + 1)
            -- poker[i + 13 *(suit - 1)] = i+1 + suit * 100
        end
    end

    playerList = { }
    -- 玩家列表
    for i = 1, playerNum, 1 do
        playerList[i] = Player:new(100010000 + i, "P" .. i, CardSet:new())
    end
    print("玩家数量：" .. table.getn(playerList))

    -- 发牌下注步骤：发牌一般分为5个步骤，分别为，

    -- STEP1 : Perflop—先下大小盲注，然后给每个玩家发2张底牌，大盲注后面第一个玩家选择跟注、加注或者盖牌放弃，
    --              按照顺时针方向，其他玩家依次表态，大盲注玩家最后表态，如果玩家有加注情况，前面已经跟注的玩家需要再次表态甚至多次表态。

    -- 第一步：每个玩家发2张底牌
    for round = 1, 2, 1 do
        for i = 1, table.getn(playerList), 1 do
            playerList[i]:insertCard(Common:get(poker))
        end
    end


    ---- 打印玩家的牌信息
    for i = 1, table.getn(playerList), 1 do
        Common:printCardSet("玩家" .. i .. "底牌", playerList[i].handCards)
    end

    -- STEP2 : Flop—同时发三张公牌，由小盲注开始（如果小盲注已盖牌，由后面最近的玩家开始，以此类推），按照顺时针方向依次表态，玩家可以选择下注、加注、或者盖牌放弃。
    -- 第二步：发3张公共牌
    publicCards = CardSet:new()
    for round = 1, 3, 1 do
        publicCards:insert(Common:get(poker))
    end



    -- STEP3 : Turn -- 发第4张牌，由小盲注开始，按照顺时针方向依次表态，玩家可以选择下注、加注、或者盖牌放弃。
    -- 第三步：发第4张公共牌
    publicCards:insert(Common:get(poker))

    -- STEP4 : River—发第五张牌，由小盲注开始，按照顺时针方向依次表态，玩家可以选择下注、加注、或者盖牌放弃。
    -- 第四步：发第5张公共牌
    publicCards:insert(Common:get(poker))


    -- STEP5 : 比牌 -- 经过前面4轮发牌和下注，剩余的玩家开始亮牌比大小，成牌最大的玩家赢取池底。
    -- 第五步：比牌

    Common:printCardSet("\n公共牌", publicCards)
    print("\n")

    for i = 1, table.getn(playerList), 1 do
        playerList[i].cards, playerList[i].cardType = TexasHoldem.getUsersMaxCards(playerList[i].handCards, publicCards);
        Common:printCardSet("玩家" .. i, playerList[i].cards, " (" .. playerList[i].cardType .. ") : " .. Common:getCardDesc(playerList[i].cardType))
    end

    print(getPlayersCards(playerList))
    print(getCardsJson(publicCards))

    -- 比牌
    local p = TexasHoldem.Juge(playerList)
    print("赢家" .. p.name)

    return getRoomInfo(p.id)

--    local cards1 = CardSet:new()
--    cards1:insert(Card:new(1, 12))
--    cards1:insert(Card:new(2, 12))
--    cards1:insert(Card:new(1, 14))
--    cards1:insert(Card:new(1, 13))
--    cards1:insert(Card:new(1, 10))

--    local cards2 = CardSet:new()
--    cards2:insert(Card:new(1, 12))
--    cards2:insert(Card:new(2, 12))
--    cards2:insert(Card:new(1, 14))
--    cards2:insert(Card:new(2, 13))
--    cards2:insert(Card:new(1, 6))


--    local playerTempList = {
--        { cardType = nil, name = "p1", cards = cards1 },
--        { cardType = nil, name = "p2", cards = cards2 }
--    }

--    local winer = TexasHoldem.Juge(playerTempList)
--    print("\n==测试:赢家" .. winer.name)

--    local c, flag = TexasHoldem.JugeCards(cards1, cards2)


end
-- io.read()

--os.execute("pause") 
ngx.say(mainTest(5));

-- endregion
