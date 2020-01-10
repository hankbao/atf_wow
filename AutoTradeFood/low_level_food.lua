---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hydra.
--- DateTime: 2020-01-07 12:35
---

local addonName, L = ...

local acquire_level_frame = L.F.create_macro_button("AcquireLevel", "/target targetname\n/atal")
local cook_frame = L.F.create_macro_button("CookLowLevel", "/castsequence a,b,c,d")

SLASH_AcquireLevelCmd1 = "/atal"

local low_level_spell = {
    {
        ["level_min"] = 25,
        ["level_max"] = 34,
        ["spell_bread"] = "造食术(等级 4)",
        ["bread_name"] = "魔法粗面包",
        ["spell_water"] = "造水术(等级 4)",
        ["water_name"] = "魔法泉水",
    },
    {
        ["level_min"] = 35,
        ["level_max"] = 44,
        ["spell_bread"] = "造食术(等级 5)",
        ["bread_name"] = "魔法酵母",
        ["spell_water"] = "造水术(等级 5)",
        ["water_name"] = "魔法矿泉水",
    },
    {
        ["level_min"] = 45,
        ["level_max"] = 54,
        ["spell_bread"] = "造食术(等级 6)",
        ["bread_name"] = "魔法甜面包",
        ["spell_water"] = "造水术(等级 6)",
        ["water_name"] = "魔法苏打水",
    },
}

local low_level_trade_context = {}
-- state: "requested", "level_acquired", "cooking", "cooked"


local function change_state(state)
    low_level_trade_context.state = state
    low_level_trade_context.state_ts = GetTime()
end


local function level_acquire_success(player, class, level, w, b, info)
    -- check if items are same as high level
    local real_w, real_b = w, b
    if info.bread_name == L.items.food_name then
        real_b = 0
    end
    if info.water_name == L.items.water_name then
        real_w = 0
    end
    low_level_trade_context.player = player
    low_level_trade_context.level = level
    low_level_trade_context.class = class
    low_level_trade_context.info = info
    low_level_trade_context.count = {
        ["water"] = w,
        ["bread"] = b,
    }
    if real_b + real_w == 0 then
        SendChatMessage("预约成功，您的需求与大号需求一致，请直接交易。", "WHISPER", "Common", player)
        low_level_trade_context.no_inform = true
        change_state("cooked")
    else
        change_state("level_acquired")
        SendChatMessage(
                "预约成功，您的职业为"..class..", 等级为"..level.."。烹饪完毕后，您将收到我的密语，请您收到密语后来我身边交易我。",
                "WHISPER", "Common", player
        )
        SendChatMessage(
                "将为您烹制"..w.."组"..info.water_name.."，"..b.."组"..info.bread_name.."。",
                "WHISPER", "Common", player
        )
    end
end


local function level_acquire_failed(player, reason)
    if reason == "oor" then
        SendChatMessage("预约失败，您不在附近。请在我附近进行预约哦！", "WHISPER", "Common", player)
    elseif reason == "lnir" then
        SendChatMessage("预约失败，您的等级不在小号服务范围【25--54】！", "WHISPER", "Common", player)
    end
    low_level_trade_context = {}
end


local function get_spell_info(level)
    for _, info in ipairs(low_level_spell) do
        if level >= info.level_min and level <= info.level_max then
            return info
        end
    end
    return nil
end


function SlashCmdList.AcquireLevelCmd(msg)
    local unit_name = UnitName("target")
    if unit_name == msg then
        local level = UnitLevel("target")
        local class = UnitClass("target")
        local info = get_spell_info(level)
        if info == nil then
            level_acquire_failed(msg, "lnir")
            return
        end
        local w, b = L.F.get_feed_count(class, msg) -- FIXME: Cycle import
        level_acquire_success(msg, class, level, w, b, info)
    else
        level_acquire_failed(msg, "oor")
    end
end


function L.F.target_level_to_acquire()
    if low_level_trade_context.state == "requested" then
        return low_level_trade_context.player
    else
        return nil
    end
end


function L.F.bind_acquire_target_level()
    local target = low_level_trade_context.player
    acquire_level_frame:SetAttribute("macrotext", string.format(
            "/target %s\n/atal %s", target, target
    ))
    SetBindingClick(L.hotkeys.interact_key, "AcquireLevel")
end


function L.F.bind_low_level_cook()
    local count = low_level_trade_context.count
    local info = low_level_trade_context.info
    local sequence = {}
    for _ = 1, count.water do
        table.insert(sequence, info.spell_water)
    end
    for _ = 1, count.bread do
        table.insert(sequence, info.spell_bread)
    end
    local macrotext = "/castsequence "..table.concat(sequence, ",")
    cook_frame:SetAttribute("macrotext", macrotext)
    SetBindingClick(L.hotkeys.interact_key, "CookLowLevel")
end


function L.F.low_level_food_request(player)
    -- if L.F.get_busy_state() then
    if false then
        SendChatMessage(
                "用餐高峰期，暂时不能为小号烹饪，请您等待高峰期结束，或寻求其他法师的帮助，谢谢！",
                "WHISPER", "Common", player
        )
    elseif low_level_trade_context.state == nil then
        low_level_trade_context.player = player
        SendChatMessage("预约已记录，请勿离开，我需要查询您的等级与职业。", "WHISPER", "Common", player)
        change_state("requested")
    else
        if low_level_trade_context.player == player then
            SendChatMessage("您已经预约了，请勿在交货完成前重复预约。", "WHISPER", "Common", player)
        else
            SendChatMessage("已有其他小号预约烹饪，请您稍后尝试。", "WHISPER", "Common", player)
        end
    end
end


local function destroy_some_food(count)
    for b = 0, 4 do
        for s = 1, 32 do
            local il = GetContainerItemLink(b, s)
            if il and (il:find(L.items.water_name) or il:find(L.items.food_name)) then
                count = count - 1
                L.F.delete_item_at(b, s)
            end
            if count <= 0 then
                return
            end
        end
    end
end


local function prepare_low_level_food()
    local should_destroy = 8 - L.F.get_free_slots()
    if should_destroy > 0 then
        destroy_some_food(should_destroy)
    end
end


function L.F.should_cook_low_level_food()
    return low_level_trade_context.state == "cooking"
end


local function player_is_low_level_requester(player)
    return player == low_level_trade_context.player
end


local function low_level_food_is_cooked()
    return low_level_trade_context.state == "cooked"
end


function L.F.feed_low_level_food()
    L.F.feed(low_level_trade_context.info.water_name, low_level_trade_context.count.water, 20)
    L.F.feed(low_level_trade_context.info.bread_name, low_level_trade_context.count.bread, 20)
end


local function low_level_cleanup()
    local food_name = low_level_trade_context.info.bread_name
    local water_name = low_level_trade_context.info.water_name
    for b = 0, 4 do
        for s = 1, 32 do
            local il = GetContainerItemLink(b, s)
            if il then
                if (not (food_name == L.items.food_name) and il:find(food_name)) or
                        (not (water_name == L.items.water_name) and il:find(water_name)) then
                    L.F.delete_item_at(b, s)
                end
            end
        end
    end
    low_level_trade_context = {}
end


function L.F.check_low_level_food()
    if low_level_trade_context.state == "level_acquired" then
        prepare_low_level_food()
        change_state("cooking")
    elseif low_level_trade_context.state == "cooking" then
        local low_level_bread_count = GetItemCount(low_level_trade_context.info.bread_name)
        local low_level_water_count = GetItemCount(low_level_trade_context.info.water_name)
        if low_level_bread_count >= low_level_trade_context.count.bread * 20 and
                low_level_water_count >= low_level_trade_context.count.water * 20 then
            SendChatMessage(
                    "您的小号食物已烹饪完成，请于"..L.low_level_wait_timeout.."秒内交易我，过期将自动摧毁。",
                    "WHISPER", "Common", low_level_trade_context.player
            )
            SendChatMessage(
                    low_level_trade_context.player.."，您的小号食物已制作完成，请取餐！", "yell"
            )
            change_state("cooked")
        end
    elseif low_level_trade_context.state == "cooked" then
        local timeleft = L.low_level_wait_timeout - (GetTime() - low_level_trade_context.state_ts)
        local player = low_level_trade_context.player
        local low_level_water_count = GetItemCount(low_level_trade_context.info.water_name)
        local low_level_bread_count = GetItemCount(low_level_trade_context.info.bread_name)

        if timeleft < 0 then
            CloseTrade()
            low_level_cleanup()
            if not low_level_trade_context.no_inform then
                SendChatMessage(
                        "您未在规定时间内取用小号食物，食物已摧毁。如果需要，请重新预约。",
                        "WHISPER", "Common", player
                )
            end
        elseif timeleft < L.low_level_wait_timeout / 4 and not(low_level_trade_context.reinformed) then
            if not low_level_trade_context.no_inform then
                SendChatMessage(
                        "您的小号食品即将在"..math.modf(timeleft).."秒后过期，请速来米豪身边取用。",
                        "WHISPER", "Common", player
                )
                SendChatMessage(
                        player.."，您的小号食品快要过期！请速来米豪身边取餐！", "yell", "Common"
                )
            end

            low_level_trade_context.reinformed = true
        end
    end
end


function L.F.say_low_level_help(to_player)
    SendChatMessage("米豪可以为【25-54】级小号烹饪符合小号等级的专属烹饪。请按如下步骤进行。", "WHISPER", "Common", to_player)
    SendChatMessage("1. 请位于我的视线内，M我【"..L.cmds.low_level_cmd.."】。", "WHISPER", "Common", to_player)
    SendChatMessage("2. 我将在成功获取您的等级信息后回复您，并开始烹饪。", "WHISPER", "Common", to_player)
    SendChatMessage("3. 【烹饪完毕后】，我将发送一条密语给您，请收到后立即前来取用。", "WHISPER", "Common", to_player)
    SendChatMessage("4. 我会为您保管烹饪完成的食物"..L.low_level_wait_timeout.."秒，过期将自动摧毁。", "WHISPER", "Common", to_player)
    SendChatMessage("注：如果需要自定义需要多少水，多少面包，请先M我需要多少水和多少面包，例如“来2组水，1组面包”。", "WHISPER", "Common", to_player)
    -- if L.F.get_busy_state() then
    if false then
        SendChatMessage("**现在是用餐高峰期，因此无法提供小号食品服务。**", "WHISPER", "Common", to_player)
    end
end


local function should_trade_low_level(trade)
    local level = trade.npc_level;
    local class = trade.npc_class;
    local name = trade.npc_name;
    if not L.F.can_feed_target(level, class, name) then
        if player_is_low_level_requester(name) then
            if low_level_food_is_cooked() then
                return true, false
            else
                SendChatMessage("您的小号食品还未烹饪完成，请您收到完成通知后再来取餐，谢谢！", "WHISPER", "Common", name)
                return true, true
            end
        else
            SendChatMessage(
                "米豪目前可为【25-54】级小号烹饪小号食品，但需要预约。请M我【"..L.cmds.low_level_cmd.."】进行预约。",
                "WHISPER", "Common", name
            )
            return true, true
        end
    end
    return false, false
end


local function feed_low_level_food(trade)
    L.F.feed(low_level_trade_context.info.water_name, low_level_trade_context.count.water, 20)
    L.F.feed(low_level_trade_context.info.bread_name, low_level_trade_context.count.bread, 20)
end


local function trade_complete(trade)
    low_level_cleanup()
    SendChatMessage(
            "小号食品交易完成，欢迎下次光临",
            "WHISPER", "Common", trade.npc_name
    )
end


L.trade_hooks.trade_low_level_food = {
  ["should_hook"] = should_trade_low_level,
  ["feed_items"] = feed_low_level_food,
  ["on_trade_complete"] = trade_complete,
  ["on_trade_cancel"] = nil,
  ["on_trade_error"] = nil,
  ["should_accept"] = L.F.check_food_trade_target_items,
  ["check_target_item"] = nil,
}
