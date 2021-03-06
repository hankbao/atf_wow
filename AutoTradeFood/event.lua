---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hydra.
--- DateTime: 2020-01-05 14:24
---

local addonName, L = ...

local frame = CreateFrame("FRAME", "ATFFrame")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("TRADE_ACCEPT_UPDATE")
frame:RegisterEvent("PARTY_INVITE_REQUEST")

local tclass_food = L.food.tclass_food
local fwd


local function say_pos(to_player)
  SendChatMessage(
    "我目前位于坐标"..L.F.my_position()..", 如不便查看，可M我“"..L.cmds.invite_cmd.."”进组", "WHISPER", "Common", to_player
  )
end


local function say_scale(to_player)
  L.F.whisper("食水分配比例如下：", to_player)
  for tclass, sc in pairs(tclass_food) do
    SendChatMessage(string.format("%s: 水%d 面包%d", tclass, sc[1], sc[2]), "WHISPER", "Common", to_player)
  end
  L.F.whisper("萨满: 6根寒冰箭", to_player)
end


local function player_want_trade_gold(msg)

  msg = string.gsub(string.lower(msg), "金", "g")
  msg = string.gsub(string.lower(msg), "钱", "g")
  msg = string.gsub(string.lower(msg), "要", "给")
  msg = string.gsub(string.lower(msg), "收", "给")
  if string.match(msg, "%dg") or string.match(msg, "给g") then
    return true
  else
    return false
  end
end


function L.F.set_msg_fwd(msg)
  if msg and not(msg == "") then
    fwd = msg
  else
    fwd = nil
  end
end


local function execute_command(msg, author)
  author = string.match(author, "([^-]+)")

  if L.atfr_run == true then
    if string.lower(msg) == L.cmds.help_cmd or msg == "1" or string.lower(msg) == "help" then
      L.F.say_help(author)
    elseif string.lower(msg) == L.cmds.retrieve_position then
      say_pos(author)
    elseif msg == L.cmds.busy_cmd then
      L.F.say_busy(author)
    elseif msg == L.cmds.reset_instance_help or msg == "2" then
      L.F.say_reset_instance_help(author)
    elseif msg == L.cmds.reset_instance_cmd then
      L.F.reset_instance_request_frontend(author)
    elseif msg == L.cmds.invite_cmd then
      L.F.whisper("【功能回归】重置副本功现已回归，请M我【"..L.cmds.reset_instance_cmd.."】重置副本，或M我【"..L.cmds.reset_instance_help.."】查看详情。", author)
      L.F.invite_player(author)
    elseif L.F.may_say_agent(msg, author) then
      -- agent speaking
    elseif msg == "3" then
      L.F.whisper("请M我【"..L.cmds.invite_cmd.."】进组，而不是M我3，zu，组，谢谢", author)
    elseif msg == "4" or msg == L.cmds.refill_help_cmd then
      L.F.refill_help(author)
    elseif L.F.search_str_contains(msg, {L.cmds.refill_cmd}) then
      L.F.refill_request(author)
    elseif msg == L.cmds.scale_cmd then
      say_scale(author)
    elseif msg == L.cmds.low_level_cmd then
      L.F.low_level_food_request(author)
    elseif msg == L.cmds.low_level_help_cmd or msg == "7" or L.F.search_str_contains(msg, {"45", "35", "25", "小水", "小面包"}) then
      L.F.say_low_level_help(author)
    elseif L.F.search_str_contains(msg, {"交易", "收到"}) then
      -- do nothing, auto sent by BurningTrade addons.
    elseif player_want_trade_gold(msg) then
      L.F.whisper("米豪不收取任何金币，需要开门，请M我【传送门】查看步骤；需要吃喝，请直接交易。详情M我【帮助】", author)
    elseif L.F.may_set_scale(msg, author) then
      -- do nothing
    elseif L.F.search_str_contains(msg, {"水", "面包"}) then
      L.F.whisper(
              "请问您要多少组水或面包？请这样回复：【2组水，3组面包】，或者【法师，可不可以来水3组，面包2组？】，或者【2水】等。", author)
    elseif msg == "5" then
      L.F.whisper(
              "请这样M我来设置比例： 【2组水，3组面包】，或者【法师，可不可以来水3组，面包2组？】或者，【2水】，等等，然后交易我。", author)
    elseif L.F.search_str_contains(msg, {"暴风城", "铁炉堡", "苏斯"}) then
      L.F.gate_request(author, msg)
    elseif L.F.search_str_contains(msg, {"门", "暴风", "铁", "精灵", L.cmds.gate_help_cmd}) or msg == "6" then
      L.F.say_gate_help(author)
    elseif msg == L.cmds.say_ack then
      L.F.say_acknowledgements(author)
    elseif msg == L.cmds.statistics then
      L.F.say_statistics(author)
    elseif L.F.search_str_contains(msg, {"脚本", "外挂", "机器", "自动", "宏"}) then
      L.F.whisper("是的，我是纯公益机器人，请亲手下留情，爱你哦！", author)
    elseif L.F.search_str_contains(msg, {"谢", "蟹", "xie", "3q"}, "left") then
      L.F.whisper("小事不言谢，欢迎随时回来薅羊毛！", author)
    else
      if not(author == UnitName("player")) then
        L.F.whisper(
                "【免费餐饮（请您直接交易）、传送门（请看帮助）？找米豪！跨位面，请M我【"
                        ..L.cmds.invite_cmd.."】查看完整帮助，请M我【"
                        ..L.cmds.help_cmd.."】】", author
        )
      end
    end
  elseif L.atfr_run == "maintain" then
    L.F.whisper("米豪正在停机维护，暂时无法为您提供服务……", author)
  end
end


local function eventHandlerFrontend(self, event, arg1, arg2, arg3, arg4, ...)
  if event == "CHAT_MSG_ADDON" and arg1 == "ATF" then
    local msg, author = arg2, arg4
    local sender, message = string.match(msg, "author:([^|]+)|(.*)")
    if sender then
      execute_command(message, sender)
    end
  elseif event == "CHAT_MSG_WHISPER" then
    local msg, author = arg1, arg2
    if fwd then
      local fwdstr = string.format("author:%s|%s", author, msg)
      local author_name = string.match(author, "([^-]+)")
      if author_name == fwd then
        return
      end
      L.F.whisper("您的密语已转发至-"..fwd, author)
      C_ChatInfo.SendAddonMessage("ATF", fwdstr, "WHISPER", fwd)
    else
      execute_command(msg, author)
    end
  elseif event == "PARTY_INVITE_REQUEST" then
    if L.atfr_run then
      DeclineGroup()
      StaticPopup_Hide("PARTY_INVITE")
      L.F.whisper("请勿邀请我进组，您可以M我【"..L.cmds.invite_cmd.."】进组，谢谢！", msg)
      L.F.invite_player(msg)
    end
  end
end


local function eventHandlerBackend(self, event, arg1, arg2, arg3, arg4, ...)
  if event == "PARTY_INVITE_REQUEST" then
    if L.atfr_run then
      DeclineGroup()
      StaticPopup_Hide("PARTY_INVITE")
    end
  elseif event == "CHAT_MSG_WHISPER" then
    if L.atfr_run then
      L.F.whisper("重置工具人不接受任何密语指令，请M我的大号FS们哦！", arg2)
    end
  end
end


if L.F.is_frontend() then
  frame:SetScript("OnEvent", eventHandlerFrontend)
else
  frame:SetScript("OnEvent", eventHandlerBackend)
end


local message_queue = {}


function L.F.queue_message(message)
  table.insert(message_queue, message)
end


function L.F.dequeue_say_messages()
  for _, message in ipairs(message_queue) do
    SendChatMessage(message, "say")
  end
  message_queue = {}
end


local easter_egg_frame = CreateFrame("FRAME")
easter_egg_frame:RegisterEvent("CHAT_MSG_SAY")
easter_egg_frame:RegisterEvent("CHAT_MSG_TEXT_EMOTE")


local emote_challenge = {
  ["给了你一个飞吻。"]="shy",
  ["舔了舔你。"]="lick",
  ["对你表示感谢。"]="blush",
  ["对着你吐口水"]="stink",
  ["向你鞠躬。"]="massage",
  ["感到很饿。也许在你那里可以找到一些食物。"]="ready",
  ["给你讲了一个笑话。"]="guffaw",
}


local function reply_to_emotes(message, player)

  local k = string.gsub(message, player, "")
  local challenge = emote_challenge[k]
  if challenge then
    DoEmote(challenge, player)
  end
end


local function easter_eggs(self, event, message, author, ...)
  if L.atfr_run then
    if event == "CHAT_MSG_SAY" then
      author = string.match(author, "([^-]+)")
      if author == UnitName("player") then
        return
      end
      L.F.may_forward_message_to_agent(message, author)
      if L.F.search_str_contains(message, {"卑微的侏儒"}) then
        L.F.queue_message("卑微？！伙计。我不在乎你是谁，没有人敢说强大的米尔豪斯是一个”卑微“的侏儒！")
      elseif L.F.search_str_contains(message, {"十点法力值", "10点法力值"}) then
        L.F.queue_message("愿青龙指引你钓上一整天的鱼")
      elseif L.F.search_str_contains(message, {"等死吧"}) then
        L.F.queue_message("等等，我要先准备一下。你们先上，我先来做点水")
      end
    elseif event == "CHAT_MSG_TEXT_EMOTE" then
      reply_to_emotes(message, author)
    end
  end
end

easter_egg_frame:SetScript("OnEvent", easter_eggs)
