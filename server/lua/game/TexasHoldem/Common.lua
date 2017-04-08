-- region *.lua
-- Date 2017-03-07
-- 此文件由[BabeLua]插件自动生成


Common = { }


function Common:printCardSet(text, cards, desc)
    local len = table.getn(cards)
    local str = ""

    if text ~= nil then
        str = str .. text
    end
    str = str .. " ===> size=" .. len

    local strCardSuit = ""
    local strCardId = ""


    for i = 1, len, 1 do
        if (1 == i) then
            strCardSuit = " ["
            strCardId = " ["
        end

        strCardSuit = strCardSuit .. cards[i].cardSuit
        strCardId = strCardId .. cards[i].cardId

        if (i ~= len) then
            strCardSuit = strCardSuit .. ","
            strCardId = strCardId .. ","
        else
            strCardSuit = strCardSuit .. "] "
            strCardId = strCardId .. "] "
        end
    end
    str = str .. strCardSuit .. strCardId
    if desc ~= nil then
        str = str .. desc
    end
    print(str)
end


-- 皇家同花顺(royal flush)：由AKQJ10五张组成，并且这5张牌花色相同 　　
-- 同花顺(straight flush)：由五张连张同花色的牌组成 　　
-- 4条(four of a kind)：4张同点值的牌加上一张其他任何牌 　　
-- 满堂红(full house)（又称“葫芦”）：3张同点值加上另外一对 　　
-- 同花(flush)：5张牌花色相同，但是不成顺子 　　
-- 顺子(straight)：五张牌连张，至少一张花色不同 　　
-- 3条(three of a kind)：三张牌点值相同，其他两张各异 　　
-- 两对(two pairs)：两对加上一个杂牌 　　
-- 一对(one pair)：一对加上3张杂牌 　　
-- 高牌(high card)：不符合上面任何一种牌型的牌型，由单牌且不连续不同花的组成
function Common:getCardDesc(typeId)
    if 1 == typeId then
        return "高牌(high card)：不符合上面任何一种牌型的牌型，由单牌且不连续不同花的组成"
    elseif 2 == typeId then
        return "一对(one pair)：一对加上3张杂牌"
    elseif 3 == typeId then
        return "两对(two pairs)：两对加上一个杂牌"
    elseif 4 == typeId then
        return "3条(three of a kind)：三张牌点值相同，其他两张各异"
    elseif 5 == typeId then
        return "顺子(straight)：五张牌连张，至少一张花色不同"
    elseif 6 == typeId then
        return "同花(flush)：5张牌花色相同，但是不成顺子"
    elseif 7 == typeId then
        return "满堂红(full house)（又称“葫芦”）：3张同点值加上另外一对"
    elseif 8 == typeId then
        return "4条(four of a kind)：4张同点值的牌加上一张其他任何牌"
    elseif 9 == typeId then
        return "同花顺(straight flush)：由五张连张同花色的牌组成 "
    elseif 10 == typeId then
        return "皇家同花顺(royal flush)：由AKQJ10五张组成，并且这5张牌花色相同"
    end
end

-- LessTen = "十小",	-- 10小
-- Bomb = "炸弹" ,   -- 炸弹
-- FiveJinhua = "五花", -- 五金花
-- FourJinhua = "四花", -- 银花
-- Ten_Niu = "牛10",
-- Nine_Niu = "牛9",
-- Eight_Niu = "牛8",
-- Seven_Niu = "牛7",
-- Six_Niu = "牛6",
-- Five_Niu = "牛5",
-- Four_Niu = "牛4",
-- Three_Niu = "牛3",
-- Tow_Niu = "牛2",
-- One_Niu = "牛1",
-- NoNiu = "无牛",		-- 没牛
function Common:getCardDescNiuNiu(typeId)
    if 0 == typeId then
        return "无牛"
    elseif 1 == typeId then
        return "牛1"
    elseif 2 == typeId then
        return "牛2"
    elseif 3 == typeId then
        return "牛3"
    elseif 4 == typeId then
        return "牛4"
    elseif 5 == typeId then
        return "牛5"
    elseif 6 == typeId then
        return "牛6"
    elseif 7 == typeId then
        return "牛7"
    elseif 8 == typeId then
        return "牛8"
    elseif 9 == typeId then
        return "牛9"
    elseif 10 == typeId then
        return "牛10"
    elseif 11 == typeId then
        return "四花"
    elseif 12 == typeId then
        return "五花"
    elseif 13 == typeId then
        return "炸弹"
    elseif 14 == typeId then
        return "五小"
    end
end

-- 发牌
math.randomseed(tostring(os.time()):reverse():sub(1, 7))
function Common:get(_cards)
    -- math.randomseed(os.time())
    -- math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    local index = math.random(1, table.getn(_cards))
    local card = _cards[index]
    -- print("取牌: " .. index, card.suit, card.id)
    table.remove(_cards, index)
    return card
end



-- 牌组大小规则：同花顺＞四条＞葫芦＞同花＞顺子＞三条＞两对＞一对＞单牌
CardLevel = {
    -- 单牌
    level1 = 1,
    -- 一对
    level2 = 2,
    -- 两对
    level3 = 3,
    -- 三条
    level4 = 4,
    -- 顺子
    level5 = 5,
    -- 同花
    level6 = 6,
    -- 葫芦
    level7 = 7,
    -- 四条
    level8 = 8,
    -- 同花顺
    level9 = 9
}


local CardType = {
    levle = CardLevel.level1,
    param1 = - 1,
    param1 = - 1,
    param1 = - 1,
}

function Common:getType(_cardSet)
    local level = -1
    local len = table.getn(_cardSet)
    if (len <= 1) then
        return level
    end

    local res = {
        -- 对子
        isLevel2 = false,

        -- 三条
        isLevel3 = false,

        -- 顺子
        isLevel5 = true,
        -- 同花
        isLevel6 = true,

        -- 四条
        isLevel8 = false
    }

    local sameCardid = -1
    local sameCardNum = 0

    for i = 2, len, 1 do
        local card1 = _cardSet[i]
        local card2 = _cardSet[i - 1]

        if card1.id == card2.id then
            sameCardNum = sameCardNum + 1
            if not res.isLevel2 then
                res.isLevel2 = true
                sameCardid = card2.id
                print("对子")
            elseif 3 == sameCardNum then
                res.isLevel3 = true
                print("三条")
            elseif 4 == sameCardNum then
                res.isLevel8 = true
                print("四条")
            end
        else

        end

        if res.isLevel6 then
            if _cardSet[i].color ~= _cardSet[i - 1].color then
                -- 不是同花
                res.isLevel6 = false
            end
        end

        if res.isLevel5 then
            if _cardSet[i].id - _cardSet[i - 1].id ~= 1 then
                -- 不是顺子
                res.isLevel5 = false
            end
        elseif _cardSet[i].id == _cardSet[i - 1].id then

        end
    end

end


function Common:getBestCards(_playerCards, _publicCards)
    local len1 = table.getn(_playerCards)
    local len2 = table.getn(_publicCards)

    if (len1 < 2 or len2 > 5) then
        return nil
    end

    local bestCards = { }
    if (len2 <= 3) then
        table.insert(bestCards, _playerCards[1])
        table.insert(bestCards, _playerCards[2])

        for i = 1, len2, 1 do
            table.insert(bestCards, _publicCards[i])
        end
    else
    end

    return bestCards
end

-- 取牌的花色和大小
function Common:getColorAndid(_cardId)
    local color, val = math.modf(413 / 100);
    return color, val * 100
end

-- 取牌的花色
function Common:getColor(_cardId)
    local color, val = math.modf(413 / 100);
    return color
end

-- 取牌的大小
function Common:getid(_cardId)
    local val = 413 % 100;
    return val
end


-- endregion
