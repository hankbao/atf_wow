---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hydra.
--- DateTime: 2020-01-17 23:01
---

local addonName, L = ...


local timeout = L.reset_instance_timeout

local reseter_context = {
    player=nil,
    request_ts=nil,
}


function L.F.drive_reset_instance()
    if reseter_context.player then
        if GetTime() - reseter_context.request_ts > timeout then
            SendChatMessage("未能重置，您未在规定时间内下线。", "WHISPER", "Common", reseter_context.player)
            reseter_context = {}
        elseif not(UnitInParty(reseter_context.player)) then
            SendChatMessage("未能重置，您已离队。", "WHISPER", "Common", reseter_context.player)
            reseter_context = {}
        elseif not UnitIsConnected(reseter_context.player) then
            ResetInstances()
            UninviteUnit(reseter_context.player)
            reseter_context = {}
        end
    end
end


function L.F.reset_instance_request(player)
    if not (L.F.watch_dog_ok()) then
        SendChatMessage(
                "米豪的驱动程序出现故障，重置副本功能暂时失效，请等待米豪的维修师进行修复。十分抱歉！",
                "WHISPER", "Common", player)
        return
    end

    if reseter_context.player then
        if reseter_context.player == player then
            SendChatMessage("您已请求重置，请在"..timeout.."秒内下线。", "WHISPER", "Common", player)
        else
            SendChatMessage("目前正有其他玩家请求，请一会儿尝试。", "WHISPER", "Common", player)
        end
    else
        if UnitInParty(player) then
            reseter_context = {
                player = player,
                request_ts = GetTime(),
            }
            SendChatMessage("请求成功，请在"..timeout.."秒内下线。", "WHISPER", "Common", player)
        else
            SendChatMessage("请求失败，您未在队伍中。请接受组队邀请，或M我【"..L.cmds.invite_cmd.."】进组后重试。", "WHISPER", "Common", player)
            L.F.invite_player(player)
        end
    end
end


function L.F.say_reset_instance_help(to_player)
    SendChatMessage("重置副本功能可以帮您迅速传送至副本门口，并对副本内怪物进行重置。请按如下步骤操作", "WHISPER", "Common", to_player)
    SendChatMessage("1. 首先M我【"..L.cmds.invite_cmd.."】进组", "WHISPER", "Common", to_player)
    SendChatMessage("2. 然后M我【"..L.cmds.reset_instance_cmd.."】进行重置请求，我会向您回复请求确认消息。", "WHISPER", "Common", to_player)
    SendChatMessage("3. 请您在"..timeout.."秒内下线，一旦您下线，我会立即重置副本，并将您移出队伍。", "WHISPER", "Common", to_player)
    SendChatMessage("4. 如果您未爆本，下次上线您将会出现在副本门口，且副本内怪物已重置。", "WHISPER", "Common", to_player)
end
