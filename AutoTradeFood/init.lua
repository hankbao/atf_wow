---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hydra.
--- DateTime: 2020-01-05 13:11
---

local addonName, L = ...

L.addonName = addonName
L.F = {}
L.trade_hooks = {}

L.cmds = {}
L.cmds.retrieve_position = "pos"
L.cmds.scale_cmd = "查看比例"
L.cmds.help_cmd = "帮助"
L.cmds.invite_cmd = "水水水"
L.cmds.gate_help_cmd = "传送门"
L.cmds.busy_cmd = "高峰"
L.cmds.refill_cmd = "我要补货"
L.cmds.refill_help_cmd = "补货"
L.cmds.low_level_cmd = "宝宝餐"
L.cmds.low_level_help_cmd = "小号"
L.cmds.say_ack = "致谢"

L.items = {}
L.items.water_name = "魔法晶水"
L.items.food_name = "魔法甜面包"
L.items.stone_name = "传送门符文"
L.items.pet_name = "恶心的软泥怪"

L.buffs = {}
L.buffs.armor = "魔甲术"
L.buffs.intel = "奥术智慧"
L.buffs.wakeup = "唤醒"
L.buffs.drinking = "喝水"
L.items.pet_debuff_name = "软泥怪的恶心光环"

L.state = 1
-- states: 1 making, 2 watering? 3 gating, 4 buff

L.hotkeys = {}
L.hotkeys.interact_key = "CTRL-I"
L.hotkeys.atf_key = "CTRL-Y"
L.hotkeys.atfr_key = "ALT-CTRL-Y"

L.min_mana = 780
L.atfr_run = false

L.refill_timeout = 120

L.low_level_wait_timeout = 60

L.debug = {}
L.debug.white_list = {
    ["米豪的维修师"] = true
}
L.debug.enabled = false

--小号模式
--L.items.water_name = "魔法纯净水"
--L.items.food_name = "魔法黑面包"
--L.buffs.armor = "霜甲术"
--L.min_mana = 300


local frame = CreateFrame("FRAME", "InitFrame")
frame:RegisterEvent("ADDON_LOADED")

local function eventHandler(self, event, msg)
    if event == "ADDON_LOADED" and msg == "AutoTradeFood" then
        if PlayerDefinedScale == nil then
            PlayerDefinedScale = {}
        end
        if GateWhiteList == nil then
            GateWhiteList = {}
        end
        if BusyHistory == nil then
            BusyHistory = {}
        end
    end
end

frame:SetScript("OnEvent", eventHandler)
