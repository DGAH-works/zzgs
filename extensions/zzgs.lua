--[[
	太阳神三国杀武将扩展包·重镇固守
	适用版本：V2 - 愚人版（版本号：20150401）清明补丁（版本号：20150405）
	武将总数：8
	武将一览：
		1、顽石城（坚城、合援）+（坚城·MAX）
		2、狼家堡（固防、突围）+（突围·MAX）
		3、灵心筑（池险、策应）+（池险·MAX、真容、绝击）
		4、光明台（要地、联络）+（联络·MAX、光明）
		5、战魂塔（屹立、鼓舞）+（屹立·MAX）
		6、紫云楼（飘渺、仙术）+（仙术·MAX）
		7、机关阵（秘法、疑云）+（秘法·MAX）
		8、戍卫营（忠诚、热血）+（热血·MAX）
	所需标记：
		1、@zzMaxVer（“强化”标记，来自画面效果）
		2、@zzKun（“困”标记，来自技能“坚城”，MAX版本）
		3、@zzJueJiMark（“绝击”标记，来自技能“绝击”）
		4、@zzSong（“耸”标记，来自技能“屹立”）
]]--
module("extensions.zzgs", package.seeall)
extension = sgs.Package("zzgs", sgs.Package_GeneralPack)
--技能暗将
zzAnJiang = sgs.General(extension, "zzAnJiang", "god", 5, true, true, true)
--强化开关
maxVersion = false		--强化开关开启
maxWanShiCheng = true	--顽石城强化开关
maxLangJiaPu = true		--狼家堡强化开关
maxLingXinZhu = true	--灵心筑强化开关
maxGuangMingTai = true	--光明台强化开关
maxZhanHunTa = true		--战魂塔强化开关
maxZiYunLou = true		--紫云楼强化开关
maxJiGuanZhen = true	--机关阵强化开关
maxShuWeiYing = true	--戍卫营强化开关
--翻译信息
sgs.LoadTranslationTable{
	["zzgs"] = "重镇固守",
}
--全局自定义函数：在攻击范围内（包括自己）
function inAttackRange(from, to)
	if from:inMyAttackRange(to) then
		return true
	elseif from:objectName() == to:objectName() then
		return true
	end
	return false
end
--[[****************************************************************
	编号：CASTLE - 001
	武将：顽石城
	称号：城坚难破
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
zzWanShiCheng = sgs.General(extension, "zzWanShiCheng", "wei")
--翻译信息
sgs.LoadTranslationTable{
	["zzWanShiCheng"] = "顽石城",
	["&zzWanShiCheng"] = "顽石城",
	["#zzWanShiCheng"] = "城坚难破",
	["designer:zzWanShiCheng"] = "DGAH",
	["cv:zzWanShiCheng"] = "无",
	["illustrator:zzWanShiCheng"] = "昵图网",
	["~zzWanShiCheng"] = "顽石城 的阵亡台词",
}
if maxVersion and maxWanShiCheng then
--[[
	技能：坚城·MAX（锁定技）
	描述：你受到伤害时，防止之；回合结束时，若所有其他角色均不在你的攻击范围内，你获得1枚“困”标记并失去X点体力（X为“困”标记的数量），否则你失去所有的“困”标记。
]]--
zzJianChengMAX = sgs.CreateTriggerSkill{
	name = "zzJianChengMAX",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageInflicted then
			local damage = data:toDamage()
			local msg = sgs.LogMessage()
			msg.type = "#zzJianChengMAX"
			msg.from = player
			msg.arg = "zzJianChengMAX"
			msg.arg2 = damage.damage
			room:sendLog(msg) --发送提示信息
			return true
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Finish then
				local others = room:getOtherPlayers(player)
				for _,p in sgs.qlist(others) do
					if inAttackRange(player, p) then
						if player:getMark("@zzKun") > 0 then
							player:loseAllMarks("@zzKun")
						end
						return false
					end
				end
				player:gainMark("@zzKun", 1)
				local count = player:getMark("@zzKun")
				room:loseHp(player, count)
			end
		end
		return false
	end,
}
--添加技能
zzWanShiCheng:addSkill(zzJianChengMAX)
--翻译信息
sgs.LoadTranslationTable{
	["zzJianChengMAX"] = "坚城",
	[":zzJianChengMAX"] = "<b><font color=\"blue\">锁定技</font></b>, 你受到伤害时，防止之；<b><font color=\"blue\">锁定技</font></b>, 回合结束时，若所有其他角色均不在你的攻击范围内，你获得1枚“困”标记并失去X点体力（X为“困”标记的数量），否则你失去所有的“困”标记。",
	["#zzJianChengMAX"] = "%from 的技能“%arg”被触发，防止了此 %arg2 点伤害",
	["@zzKun"] = "困",
}
else
--[[
	技能：坚城（锁定技）
	描述：一名角色对你造成伤害时，须弃置一张手牌，否则此伤害-1。
]]--
zzJianCheng = sgs.CreateTriggerSkill{
	name = "zzJianCheng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local source = damage.from
		if source then
			local room = player:getRoom()
			room:notifySkillInvoked(player, "zzJianCheng") --显示技能发动
			local prompt = string.format("@zzJianCheng:%s:", player:objectName())
			local card = room:askForCard(source, ".", prompt, data, "zzJianCheng")
			if not card then
				room:broadcastSkillInvoke("zzJianCheng") --播放配音
				local count = damage.damage
				local msg = sgs.LogMessage()
				msg.from = player
				msg.to:append(source)
				msg.arg = count
				count = count - 1
				msg.arg2 = count
				damage.damage = count
				data:setValue(damage)
				if count > 1 then
					msg.type = "#zzJianChengEffect"
				else
					msg.type = "#zzJianChengAvoid"
				end
				room:sendLog(msg) --发送提示信息
				return ( count <= 0 )
			end
		end
		return false
	end,
}
--添加技能
zzWanShiCheng:addSkill(zzJianCheng)
--翻译信息
sgs.LoadTranslationTable{
	["zzJianCheng"] = "坚城",
	[":zzJianCheng"] = "<b><font color=\"blue\">锁定技</font></b>, 一名角色对你造成伤害时，须弃置一张手牌，否则此伤害-1。",
	["@zzJianCheng"] = "坚城：请弃置一张手牌，否则 %src 本次受到的伤害-1",
	["#zzJianChengEffect"] = "%from 的技能“<b><font color=\"yellow\">坚城</font></b>”被触发，受到的伤害-1，由 %arg 点降至 %arg2 点",
	["#zzJianChengAvoid"] = "%from 的技能“<b><font color=\"yellow\">坚城</font></b>”被触发，防止了 %arg 点伤害",
}
end
--[[
	技能：合援
	描述：你于回合外获得牌时，你可以指定你攻击范围内的一名其他角色（来源除外），视为对其使用了一张【杀】。每阶段限一次。
]]--
zzHeYuan = sgs.CreateTriggerSkill{
	name = "zzHeYuan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			if player:getMark("zzHeYuanInvoked") > 0 then
				return false
			end
			local move = data:toMoveOneTime()
			local target = move.to
			if target and target:objectName() == player:objectName() then
				local dest = move.to_place
				if dest == sgs.Player_PlaceHand or dest == sgs.Player_PlaceEquip then
					local room = player:getRoom()
					if room:getTag("FirstRound"):toBool() then
						return false
					end
					local others = room:getOtherPlayers(player)
					local victims = sgs.SPlayerList()
					local source = move.from
					for _,p in sgs.qlist(others) do
						local flag = true
						if source and source:objectName() == p:objectName() then
							local from = move.from_places
							if from:contains(sgs.Player_PlaceHand) then
								flag = false
							elseif from:contains(sgs.Player_PlaceEquip) then
								flag = false
							end
						end
						if flag and inAttackRange(player, p) then
							if player:canSlash(p) then
								victims:append(p)
							end
						end
					end
					if victims:isEmpty() then
						return false
					end
					local victim = room:askForPlayerChosen(player, victims, "zzHeYuan", "@zzHeYuan", true, true)
					if victim then
						room:broadcastSkillInvoke("zzHeYuan") --播放配音
						room:notifySkillInvoked(player, "zzHeYuan") --显示技能发动
						room:setPlayerMark(player, "zzHeYuanInvoked", 1)
						local slash = sgs.Sanguosha:cloneCard("slash")
						slash:setSkillName("zzHeYuan")
						local use = sgs.CardUseStruct()
						use.from = player
						use.to:append(victim)
						use.card = slash
						room:useCard(use, false)
					end
				end
			end
		end
		return false
	end,
}
zzHeYuanClear = sgs.CreateTriggerSkill{
	name = "#zzHeYuanClear",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local alives = room:getAlivePlayers()
		for _,p in sgs.qlist(alives) do
			if p:getMark("zzHeYuanInvoked") > 0 then
				room:setPlayerMark(p, "zzHeYuanInvoked", 0)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
extension:insertRelatedSkills("zzHeYuan", "#zzHeYuanClear")
--添加技能
zzWanShiCheng:addSkill(zzHeYuan)
zzWanShiCheng:addSkill(zzHeYuanClear)
--翻译信息
sgs.LoadTranslationTable{
	["zzHeYuan"] = "合援",
	[":zzHeYuan"] = "你于回合外获得牌时，你可以指定你攻击范围内的一名其他角色（来源除外），视为对其使用了一张【杀】。每阶段限一次。",
	["@zzHeYuan"] = "您可以发动“合援”选择一名角色，视为对其使用一张【杀】",
}
--[[****************************************************************
	编号：CASTLE - 002
	武将：狼家堡
	称号：磐石利剑
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
zzLangJiaPu = sgs.General(extension, "zzLangJiaPu", "shu")
--翻译信息
sgs.LoadTranslationTable{
	["zzLangJiaPu"] = "狼家堡",
	["&zzLangJiaPu"] = "狼家堡",
	["#zzLangJiaPu"] = "磐石利剑",
	["designer:zzLangJiaPu"] = "DGAH",
	["cv:zzLangJiaPu"] = "无",
	["illustrator:zzLangJiaPu"] = "昵图网",
	["~zzLangJiaPu"] = "狼家堡 的阵亡台词",
}
--[[
	技能：固防（锁定技）
	描述：其他角色对你使用【过河拆桥】、【顺手牵羊】、【火攻】时，须弃置一张牌，否则此锦囊牌对你无效。
]]--
zzGuFang = sgs.CreateTriggerSkill{
	name = "zzGuFang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetConfirmed, sgs.CardEffect},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			local trick = use.card
			if trick:isKindOf("Dismantlement") or trick:isKindOf("Snatch") or trick:isKindOf("FireAttack") then
				if use.to:contains(player) then
					local source = use.from
					local card = nil
					if source and source:isAlive() then
						if source:objectName() == player:objectName() then
							return false
						end
						room:notifySkillInvoked(player, "zzGuFang") --显示技能发动
						local prompt = string.format("@zzGuFang:%s::%s:", player:objectName(), trick:objectName())
						card = room:askForCard(source, "..", prompt, data, "zzGuFang")
					else
						room:notifySkillInvoked(player, "zzGuFang") --显示技能发动
					end
					if not card then
						room:setCardFlag(trick, "zzGuFangInvoked")
						room:setPlayerProperty(player, "zzGuFangTrick", sgs.QVariant(trick:toString()))
					end
				end
			end
		elseif event == sgs.CardEffect then
			local effect = data:toCardEffect()
			local trick = effect.card
			if trick:hasFlag("zzGuFangInvoked") then
				local target = effect.to
				if target:objectName() == player:objectName() then
					local record = player:property("zzGuFangTrick"):toString()
					if record == trick:toString() then
						room:broadcastSkillInvoke("zzGuFang") --播放配音
						local msg = sgs.LogMessage()
						msg.type = "#zzGuFangAvoid"
						msg.from = player
						msg.arg = "zzGuFang"
						msg.arg2 = trick:objectName()
						room:sendLog(msg) --发送提示信息
						room:setPlayerProperty(player, "zzGuFangTrick", sgs.QVariant())
						return true
					end
				end
			end
		end
		return false
	end,
}
--添加技能
zzLangJiaPu:addSkill(zzGuFang)
--翻译信息
sgs.LoadTranslationTable{
	["zzGuFang"] = "固防",
	[":zzGuFang"] = "<b><font color=\"blue\">锁定技</font></b>, 其他角色对你使用【过河拆桥】、【顺手牵羊】、【火攻】时，须弃置一张牌，否则此锦囊牌对你无效。",
	["@zzGuFang"] = "固防：请弃置一张牌（包括装备），否则此【%arg】对 %src 无效",
	["#zzGuFangAvoid"] = "%from 的技能“%arg”被触发，此【%arg2】对其无效",
}
if maxVersion and maxLangJiaPu then
--[[
	技能：突围·MAX
	描述：回合开始时，若你已受伤，你可以视为使用一张【杀】；
		你的【杀】指定目标时，你可以选择一项：1、获得目标角色区域中的一张牌；2、令目标角色失去1点体力；
		锁定技，你的【杀】可以指定任意数目的角色为目标。
]]--
function twSlash()
	local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
	slash:setSkillName("zzTuWeiMAX")
	return slash
end
zzTuWeiMAXCard = sgs.CreateSkillCard{
	name = "zzTuWeiMAXCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		local slash = twSlash()
		slash:deleteLater()
		local selected = sgs.PlayerList()
		for _,p in ipairs(targets) do
			selected:append(p)
		end
		return slash:targetFilter(selected, to_select, sgs.Self)
	end,
	feasible = function(self, targets)
		local slash = twSlash()
		slash:deleteLater()
		local selected = sgs.PlayerList()
		for _,p in ipairs(targets) do
			selected:append(p)
		end
		return slash:targetsFeasible(selected, sgs.Self)
	end,
	on_validate = function(self, use)
		return twSlash()
	end,
}
zzTuWeiVSMAX = sgs.CreateViewAsSkill{
	name = "zzTuWeiMAX",
	n = 0,
	view_as = function(self, cards)
		return zzTuWeiMAXCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@zzTuWeiMAX"
	end,
}
zzTuWeiMAX = sgs.CreateTriggerSkill{
	name = "zzTuWeiMAX",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.CardUsed},
	view_as_skill = zzTuWeiVSMAX,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				if player:isWounded() then
					room:askForUseCard(player, "@@zzTuWeiMAX", "@zzTuWeiMAX") 
				end
			end
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			local slash = use.card
			if slash and slash:isKindOf("Slash") then
				local source = use.from
				if source and source:objectName() == player:objectName() then
					local targets = use.to
					for _,p in sgs.qlist(targets) do
						local choices = {}
						table.insert(choices, p:getGeneralName())
						if not p:isAllNude() then
							table.insert(choices, "obtain")
						end
						table.insert(choices, "losehp")
						table.insert(choices, "cancel")
						choices = table.concat(choices, "+")
						while true do
							local ai_data = sgs.QVariant()
							ai_data:setValue(p)
							local choice = room:askForChoice(player, "zzTuWeiMAX", choices, ai_data)
							if choice == "obtain" then
								local id = room:askForCardChosen(player, p, "hej", "zzTuWeiMAX")
								if id > 0 then
									room:broadcastSkillInvoke("zzTuWeiMAX") --播放配音
									room:notifySkillInvoked(player, "zzTuWeiMAX") --显示技能发动
									room:obtainCard(player, id)
								end
								break
							elseif choice == "losehp" then
								room:broadcastSkillInvoke("zzTuWeiMAX") --播放配音
								room:notifySkillInvoked(player, "zzTuWeiMAX") --显示技能发动
								room:loseHp(p, 1)
								break
							elseif choice == "cancel" then
								break
							end
						end
					end
				end
			end
		end
		return false
	end,
}
zzTuWeiModMAX = sgs.CreateTargetModSkill{
	name = "#zzTuWeiModMAX",
	extra_target_func = function(self, from, card)
		if from:hasSkill("zzTuWeiMAX") then
			if card:isKindOf("Slash") then
				return 1000
			end
		end
		return 0
	end,
}
extension:insertRelatedSkills("zzTuWeiMAX", "#zzTuWeiModMAX")
--添加技能
zzLangJiaPu:addSkill(zzTuWeiMAX)
zzLangJiaPu:addSkill(zzTuWeiModMAX)
--翻译信息
sgs.LoadTranslationTable{
	["zzTuWeiMAX"] = "突围",
	[":zzTuWeiMAX"] = "回合开始时，若你已受伤，你可以视为使用一张【杀】；你的【杀】指定目标时，你可以选择一项：1、获得目标角色区域中的一张牌；2、令目标角色失去1点体力；<b><font color=\"blue\">锁定技</font></b>，你的【杀】可以指定任意数目的角色为目标。",
	["@zzTuWeiMAX"] = "您可以发动“突围”视为使用一张【杀】",
	["~zzTuWeiMAX"] = "选择一些角色作为【杀】的目标->点击“确定”",
	["zzTuWeiMAX:obtain"] = "获得其区域中的一张牌",
	["zzTuWeiMAX:losehp"] = "令其失去1点体力",
	["zzTuWeiMAX:cancel"] = "不对其发动“突围”",
	["zztuweimax"] = "突围",
}
else
--[[
	技能：突围
	描述：你的【杀】指定目标时，你可以选择一项：1、为此【杀】额外指定一个目标；2、令目标角色须额外使用一张【闪】抵消此【杀】；3、令此【杀】命中后造成的伤害+1。若如此做，你失去1点体力并摸一张牌。
]]--
zzTuWei = sgs.CreateTriggerSkill{
	name = "zzTuWei",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.TargetConfirmed, sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			local slash = use.card
			if slash and slash:isKindOf("Slash") then
				local choices = {}
				local targets = use.to
				local alives = room:getAlivePlayers()
				local victims = sgs.SPlayerList()
				for _,p in sgs.qlist(alives) do
					if not use.to:contains(p) then
						if player:canSlash(p, slash, false) then
							victims:append(p)
						end
					end
				end
				if not victims:isEmpty() then
					table.insert(choices, "target")
				end
				table.insert(choices, "jink")
				table.insert(choices, "damage")
				table.insert(choices, "cancel")
				choices = table.concat(choices, "+")
				local choice = room:askForChoice(player, "zzTuWei", choices, data)
				if choice == "target" then
					local prompt = string.format("@zzTuWei:::%s:", slash:objectName())
					local victim = room:askForPlayerChosen(player, victims, "zzTuWei", prompt, true)
					if victim then
						room:broadcastSkillInvoke("zzTuWei") --播放配音
						room:notifySkillInvoked(player, "zzTuWei") --显示技能发动
						use.to:append(victim)
						room:sortByActionOrder(use.to)
						data:setValue(use)
						local msg = sgs.LogMessage()
						msg.type = "#zzTuWeiExtraTarget"
						msg.from = player
						msg.to:append(victim)
						msg.arg = "zzTuWei"
						msg.arg2 = slash:objectName()
						room:sendLog(msg) --发送提示信息
					end
				elseif choice == "jink" then
					room:setCardFlag(slash, "zzTuWeiExtraJink")
					local msg = sgs.LogMessage()
					msg.type = "#zzTuWeiExtraJink"
					msg.from = player
					msg.arg = "zzTuWei"
					msg.arg2 = slash:objectName()
					room:sendLog(msg) --发送提示信息
				elseif choice == "damage" then
					room:setCardFlag(slash, "zzTuWeiExtraDamage")
					local msg = sgs.LogMessage()
					msg.type = "#zzTuWeiExtraDamage"
					msg.from = player
					msg.arg = "zzTuWei"
					msg.arg2 = slash:objectName()
					room:sendLog(msg) --发送提示信息
				elseif choice == "cancel" then
					return false
				end
				room:loseHp(player, 1)
				if player:isAlive() then
					room:drawCards(player, 1, "zzTuWei")
				end
			end
		elseif event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			local slash = use.card
			if slash and slash:hasFlag("zzTuWeiExtraJink") then
				local source = use.from
				if source then
					local key = "Jink_"..slash:toString()
					local tag = source:getTag(key)
					local jinkList = tag:toIntList()
					local newJinkList = sgs.IntList()
					for _,jinknum in sgs.qlist(jinkList) do
						local num = jinknum + 1
						newJinkList:append(num)
					end
					tag:setValue(newJinkList)
					source:setTag(key, tag)
				end
			end
		elseif event == sgs.DamageCaused then
			local damage = data:toDamage()
			local slash = damage.card
			if slash and slash:hasFlag("zzTuWeiExtraDamage") then
				local count = damage.damage
				local msg = sgs.LogMessage()
				msg.type = "#zzTuWeiExtraDamageEffect"
				msg.from = player
				msg.to:append(damage.to)
				msg.arg = count
				count = count + 1
				msg.arg2 = count
				room:sendLog(msg) --发送提示信息
				damage.damage = count
				data:setValue(damage)
			end
		end
		return false
	end,
}
--添加技能
zzLangJiaPu:addSkill(zzTuWei)
--翻译信息
sgs.LoadTranslationTable{
	["zzTuWei"] = "突围",
	[":zzTuWei"] = "你的【杀】指定目标时，你可以选择一项：1、为此【杀】额外指定一个目标；2、令目标角色须额外使用一张【闪】抵消此【杀】；3、令此【杀】命中后造成的伤害+1。若如此做，你失去1点体力并摸一张牌。",
	["zzTuWei:target"] = "为此杀额外指定一个目标",
	["zzTuWei:jink"] = "令目标额外使用一张闪",
	["zzTuWei:damage"] = "令此杀造成的伤害+1",
	["zzTuWei:cancel"] = "不发动“突围”",
	["@zzTuWei"] = "突围：您可以选择一名角色作为此【%arg】的一个额外目标",
	["#zzTuWeiExtraTarget"] = "%from 发动了技能“%arg”为此【%arg2】添加了一个额外的目标：%to",
	["#zzTuWeiExtraJink"] = "%from 发动了技能“%arg”令 %to 须额外使用一张【闪】抵消此【%arg2】",
	["#zzTuWeiExtraDamage"] = "%from 发动了技能“%arg”令此【%arg2】造成伤害的基数+1",
	["#zzTuWeiExtraDamageEffect"] = "受技能“<b><font color=\"yellow\">突围</font></b>”的影响，%from 本次对 %to 造成的伤害+1，从 %arg 点上升至 %arg2 点",
}
end
--[[****************************************************************
	编号：CASTLE - 003
	武将：灵心筑
	称号：水中的阴谋
	势力：吴
	性别：女
	体力上限：2勾玉
]]--****************************************************************
zzLingXinZhu = sgs.General(extension, "zzLingXinZhu", "wu", 2, false)
--翻译信息
sgs.LoadTranslationTable{
	["zzLingXinZhu"] = "灵心筑",
	["&zzLingXinZhu"] = "灵心筑",
	["#zzLingXinZhu"] = "水中的阴谋",
	["designer:zzLingXinZhu"] = "DGAH",
	["cv:zzLingXinZhu"] = "无",
	["illustrator:zzLingXinZhu"] = "扬州二十四桥附近景观",
	["~zzLingXinZhu"] = "灵心筑 的阵亡台词",
}
if maxVersion and maxLingXinZhu then
--[[
	技能：池险·MAX（锁定技）
	描述：你不能被指定为与你距离为1的角色使用的【杀】的目标；你受到的火焰伤害-1；你的手牌上限+1。
]]--
zzChiXianMAX = sgs.CreateProhibitSkill{
	name = "zzChiXianMAX",
	is_prohibited = function(self, from, to, card)
		if to:hasSkill("zzChiXianMAX") then
			if card:isKindOf("Slash") then
				if from:distanceTo(to) == 1 then
					return true
				end
			end
		end
		return false
	end,
}
zzChiXianEffectMAX = sgs.CreateTriggerSkill{
	name = "#zzChiXianEffectMAX",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.nature == sgs.DamageStruct_Fire then
			local room = player:getRoom()
			room:broadcastSkillInvoke("zzChiXianMAX") --播放配音
			room:notifySkillInvoked(player, "zzChiXianMAX") --显示技能发动
			local count = damage.damage
			local msg = sgs.LogMessage()
			if count > 1 then
				msg.type = "#zzChiXianMAXEffect"
			else
				msg.type = "#zzChiXianMAXAvoid"
			end
			msg.from = player
			msg.arg = count
			count = count - 1
			msg.arg2 = count
			room:sendLog(msg) --发送提示信息
			damage.damage = count
			data:setValue(damage)
			return ( count <= 0 )
		end
		return false
	end,
}
zzChiXianKeepMAX = sgs.CreateMaxCardsSkill{
	name = "#zzChiXianKeepMAX",
	extra_func = function(self, player)
		if player:hasSkill("zzChiXianMAX") then
			return 1
		end
		return 0
	end,
}
extension:insertRelatedSkills("zzChiXianMAX", "#zzChiXianEffectMAX")
extension:insertRelatedSkills("zzChiXianMAX", "#zzChiXianKeepMAX")
--添加技能
zzLingXinZhu:addSkill(zzChiXianMAX)
zzLingXinZhu:addSkill(zzChiXianEffectMAX)
zzLingXinZhu:addSkill(zzChiXianKeepMAX)
--翻译信息
sgs.LoadTranslationTable{
	["zzChiXianMAX"] = "池险",
	[":zzChiXianMAX"] = "<b><font color=\"blue\">锁定技</font></b>, 你不能被指定为与你距离为1的角色使用的【杀】的目标；你受到的火焰伤害-1；你的手牌上限+1。",
	["#zzChiXianMAXEffect"] = "%from 的技能“<b><font color=\"yellow\">池险</font></b>”被触发，受到的火焰伤害-1，由 %arg 点降至 %arg2 点",
	["#zzChiXianMAXAvoid"] = "%from 的技能“<b><font color=\"yellow\">池险</font></b>”被触发，防止了 %arg 点火焰伤害",
}
else
--[[
	技能：池险（锁定技）
	描述：你不能被指定为与你距离为1的角色使用的【杀】的目标；你受到的火焰伤害-1；你受到的雷电伤害+1。
]]--
zzChiXian = sgs.CreateProhibitSkill{
	name = "zzChiXian",
	is_prohibited = function(self, from, to, card)
		if to:hasSkill("zzChiXian") then
			if card:isKindOf("Slash") then
				if from:distanceTo(to) == 1 then
					return true
				end
			end
		end
		return false
	end,
}
zzChiXianEffect = sgs.CreateTriggerSkill{
	name = "#zzChiXianEffect",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local nature = damage.nature
		local room = player:getRoom()
		if nature == sgs.DamageStruct_Fire then
			room:broadcastSkillInvoke("zzChiXian") --播放配音
			room:notifySkillInvoked(player, "zzChiXian") --显示技能发动
			local count = damage.damage
			local msg = sgs.LogMessage()
			if count > 1 then
				msg.type = "#zzChiXianEffect"
			else
				msg.type = "#zzChiXianAvoid"
			end
			msg.from = player
			msg.arg = count
			count = count - 1
			msg.arg2 = count
			room:sendLog(msg) --发送提示信息
			damage.damage = count
			data:setValue(damage)
			return ( count <= 0 )
		elseif nature == sgs.DamageStruct_Thunder then
			room:broadcastSkillInvoke("zzChiXian") --播放配音
			room:notifySkillInvoked(player, "zzChiXian") --显示技能发动
			local count = damage.damage
			local msg = sgs.LogMessage()
			msg.type = "#zzChiXianBadEffect"
			msg.from = player
			msg.arg = count
			count = count + 1
			msg.arg2 = count
			room:sendLog(msg) --发送提示信息
			damage.damage = count
			data:setValue(damage)
		end
		return false
	end,
}
extension:insertRelatedSkills("zzChiXian", "#zzChiXianEffect")
--添加技能
zzLingXinZhu:addSkill(zzChiXian)
zzLingXinZhu:addSkill(zzChiXianEffect)
--翻译信息
sgs.LoadTranslationTable{
	["zzChiXian"] = "池险",
	[":zzChiXian"] = "<b><font color=\"blue\">锁定技</font></b>, 你不能被指定为与你距离为1的角色使用的【杀】的目标；你受到的火焰伤害-1；你受到的雷电伤害+1。",
	["#zzChiXianEffect"] = "%from 的技能“<b><font color=\"yellow\">池险</font></b>”被触发，受到的火焰伤害-1，由 %arg 点降至 %arg2 点",
	["#zzChiXianAvoid"] = "%from 的技能“<b><font color=\"yellow\">池险</font></b>”被触发，防止了 %arg 点火焰伤害",
	["#zzChiXianBadEffect"] = "%from 的技能“<b><font color=\"yellow\">池险</font></b>”被触发，受到的雷电伤害+1，由 %arg 点上升至 %arg2 点",
}
end
--[[
	技能：策应
	描述：一名与你距离为1的角色的回合结束时，你可以令其选择一项：弃置一张【杀】，或受到你造成的1点伤害。
]]--
zzCeYing = sgs.CreateTriggerSkill{
	name = "zzCeYing",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:hasSkill("zzCeYing") then
					if player:distanceTo(source) == 1 then
						local ai_data = sgs.QVariant()
						ai_data:setValue(player)
						if source:askForSkillInvoke("zzCeYing", ai_data) then
							room:broadcastSkillInvoke("zzCeYing") --播放配音
							room:notifySkillInvoked(source, "zzCeYing") --显示技能发动
							local prompt = string.format("@zzCeYing:%s:", source:objectName())
							ai_data:setValue(source)
							local slash = room:askForCard(player, "Slash", prompt, ai_data, "zzCeYing")
							if not slash then
								local damage = sgs.DamageStruct()
								damage.from = source
								damage.to = player
								damage.damage = 1
								room:damage(damage)
							end
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
zzLingXinZhu:addSkill(zzCeYing)
--翻译信息
sgs.LoadTranslationTable{
	["zzCeYing"] = "策应",
	[":zzCeYing"] = "一名与你距离为1的角色的回合结束时，你可以令其选择一项：弃置一张【杀】，或受到你造成的1点伤害。",
	["@zzCeYing"] = "策应：请弃置一张【杀】，否则 %src 将对你造成1点伤害",
}
if maxVersion and maxLingXinZhu then
--[[
	技能：真容（觉醒技）
	描述：出牌阶段开始时，若场上人数为2，你失去技能“池险·MAX”和“策应”，增加2点体力上限并回复2点体力，获得技能“绝击”。
]]--
zzZhenRong = sgs.CreateTriggerSkill{
	name = "zzZhenRong",
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			local room = player:getRoom()
			if room:alivePlayerCount() == 2 then
				room:broadcastSkillInvoke("zzZhenRong") --播放配音
				room:notifySkillInvoked(player, "zzZhenRong") --显示技能发动
				room:setPlayerMark(player, "zzZhenRongWaked", 1)
				room:handleAcquireDetachSkills(player, "-zzChiXianMAX|-zzCeYing")
				local maxhp = player:getMaxHp() + 2
				room:setPlayerProperty(player, "maxhp", sgs.QVariant(maxhp))
				local recover = sgs.RecoverStruct()
				recover.who = player
				recover.recover = 2
				room:recover(player, recover)
				room:handleAcquireDetachSkills(player, "zzJueJi")
				player:gainMark("@waked", 1)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() then
			if target:hasSkill("zzZhenRong") then
				if target:getMark("zzZhenRongWaked") == 0 then
					return true
				end
			end
		end
		return false
	end,
}
--添加技能
zzLingXinZhu:addSkill(zzZhenRong)
--翻译信息
sgs.LoadTranslationTable{
	["zzZhenRong"] = "真容",
	[":zzZhenRong"] = "<b><font color=\"purple\">觉醒技</font></b>, 出牌阶段开始时，若场上人数为2，你失去技能“池险”和“策应”，增加2点体力上限并回复2点体力，获得技能“绝击”。\
\
★<b>绝击</b>: <b><font color=\"red\">限定技</font></b>, 出牌阶段，你可以选择一项：\
	1、对一名其他角色造成X点伤害（X为其体力上限）；\
	2、摸三张牌并令一名其他角色失去1点体力上限；\
	3、令一名其他角色失去一项技能并弃置其装备区的所有牌。\
	4、与一名其他角色拼点，没赢的一方立即阵亡。\
然后你失去所有技能。",
}
--[[
	技能：绝击（限定技）
	描述：出牌阶段，你可以选择一项：
		1、对一名其他角色造成X点伤害（X为其体力上限）；
		2、摸三张牌并令一名其他角色失去1点体力上限；
		3、令一名其他角色失去一项技能并弃置其装备区的所有牌。
		4、与一名其他角色拼点，没赢的一方立即阵亡。
		然后你失去所有技能。
]]--
zzJueJiCard = sgs.CreateSkillCard{
	name = "zzJueJiCard",
	skill_name = "zzJueJi",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		source:loseMark("@zzJueJiMark", 1)
		local choices = {"damage", "maxhp"}
		local skills = target:getVisibleSkillList()
		local can_detach = {}
		for _,skill in sgs.qlist(skills) do
			if skill:isAttachedLordSkill() then
			elseif skill:inherits("SPConvertSkill") then
			elseif skill:isLordSkill() then
				if target:hasLordSkill(skill:objectName()) then
					table.insert(can_detach, skill:objectName())
				end
			else
				table.insert(can_detach, skill:objectName())
			end
		end
		if #can_detach > 0 or target:hasEquip() then
			table.insert(choices, "skill")
		end
		if target:isKongcheng() then
		elseif source:isKongcheng() then
		else
			table.insert(choices, "pindian")
		end
		choices = table.concat(choices, "+")
		local ai_data = sgs.QVariant()
		ai_data:setValue(target)
		local choice = room:askForChoice(source, "zzJueJi", choices, ai_data)
		if choice == "damage" then
			local damage = sgs.DamageStruct()
			damage.from = source
			damage.to = target
			damage.damage = target:getMaxHp()
			room:damage(damage)
		elseif choice == "maxhp" then
			room:drawCards(source, 3, "zzJueJi")
			room:loseMaxHp(target, 1)
		elseif choice == "skill" then
			if #can_detach > 0 then
				local to_select = table.concat(can_detach, "+")
				local to_detach = room:askForChoice(source, "zzJueJiDetachSkill", to_select, ai_data)
				local handle_str = string.format("-%s", to_detach)
				room:handleAcquireDetachSkills(target, handle_str)
			end
			if target:hasEquip() then
				target:throwAllEquips()
			end
		elseif choice == "pindian" then
			local success = source:pindian(target, "zzJueJi")
			if success then
				room:killPlayer(target)
			else
				room:killPlayer(source)
				return 
			end
		end
		skills = source:getVisibleSkillList()
		for _,skill in sgs.qlist(skills) do
			if skill:isAttachedLordSkill() then
			elseif skill:inherits("SPConvertSkill") then
			elseif skill:isLordSkill() then
				if source:hasLordSkill(skill:objectName()) then
					room:handleAcquireDetachSkills(source, "-"..skill:objectName())
				end
			else
				room:handleAcquireDetachSkills(source, "-"..skill:objectName())
			end
		end
	end,
}
zzJueJiVS = sgs.CreateViewAsSkill{
	name = "zzJueJi",
	n = 0,
	view_as = function(self, cards)
		return zzJueJiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@zzJueJiMark") > 0
	end,
}
zzJueJi = sgs.CreateTriggerSkill{
	name = "zzJueJi",
	frequency = sgs.Skill_Limited,
	events = {},
	limit_mark = "@zzJueJiMark",
	view_as_skill = zzJueJiVS,
	on_trigger = function(self, event, player, data)
	end,
}
--添加技能
zzAnJiang:addSkill(zzJueJi)
zzLingXinZhu:addRelateSkill("zzJueJi")
--翻译信息
sgs.LoadTranslationTable{
	["zzJueJi"] = "绝击",
	[":zzJueJi"] = "<b><font color=\"red\">限定技</font></b>, 出牌阶段，你可以选择一项：\
	1、对一名其他角色造成X点伤害（X为其体力上限）；\
	2、摸三张牌并令一名其他角色失去1点体力上限；\
	3、令一名其他角色失去一项技能并弃置其装备区的所有牌。\
	4、与一名其他角色拼点，没赢的一方立即阵亡。\
然后你失去所有技能。",
	["@zzJueJiMark"] = "绝击",
	["zzJueJi:damage"] = "对其造成X点伤害（X为其体力上限）",
	["zzJueJi:maxhp"] = "摸三张牌令其失去1点体力上限",
	["zzJueJi:skill"] = "令其失去一项技能并弃置所有装备",
	["zzJueJi:pindian"] = "与其拼点，没赢的一方立即阵亡",
	["zzJueJiDetachSkill"] = "绝击",
}
end
--[[****************************************************************
	编号：CASTLE - 004
	武将：光明台
	称号：指挥中心
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
zzGuangMingTai = nil
if maxVersion and maxGuangMingTai then
	zzGuangMingTai = sgs.General(extension, "zzGuangMingTai$", "qun", 3)
else
	zzGuangMingTai = sgs.General(extension, "zzGuangMingTai", "qun")
end
--翻译信息
sgs.LoadTranslationTable{
	["zzGuangMingTai"] = "光明台",
	["&zzGuangMingTai"] = "光明台",
	["#zzGuangMingTai"] = "指挥中心",
	["designer:zzGuangMingTai"] = "DGAH",
	["cv:zzGuangMingTai"] = "无",
	["illustrator:zzGuangMingTai"] = "红动中国",
	["~zzGuangMingTai"] = "光明台 的阵亡台词",
}
--[[
	技能：要地（锁定技）
	描述：你与其他角色计算距离时，或其他角色与你计算距离时，始终-1。
]]--
zzYaoDi = sgs.CreateDistanceSkill{
	name = "zzYaoDi",
	correct_func = function(self, from, to)
		local fix = 0
		if from:hasSkill("zzYaoDi") then
			fix = fix - 1
		end
		if to:hasSkill("zzYaoDi") then
			fix = fix - 1
		end
		return fix
	end,
}
--添加技能
zzGuangMingTai:addSkill(zzYaoDi)
--翻译信息
sgs.LoadTranslationTable{
	["zzYaoDi"] = "要地",
	[":zzYaoDi"] = "<b><font color=\"blue\">锁定技</font></b>, 你与其他角色计算距离时，或其他角色与你计算距离时，始终-1。",
}
if maxVersion and maxGuangMingTai then
--[[
	技能：联络·MAX
	描述：回合结束阶段，你可以获得任意数目角色的各一张牌，然后你可以交给任意数目角色各一张牌。若如此做，你可以令一名角色回复1点体力。
]]--
zzLianLuoMAXCard = sgs.CreateSkillCard{
	name = "zzLianLuoMAXCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return not to_select:isNude()
	end,
	on_use = function(self, room, source, targets)
		for _,p in ipairs(targets) do
			local id = room:askForCardChosen(source, p, "he", "zzLianLuoMAX")
			if id > 0 then
				room:obtainCard(source, id, false)
			end
		end
		room:setPlayerFlag(source, "zzLianLuoGiveBackMAX")
		while true do
			if source:isNude() then
				break
			end
			local card = room:askForUseCard(source, "@@zzLianLuoGiveBackMAX", "@zzLianLuoGiveBackMAX")
			if not card then
				break
			end
		end
		room:setPlayerFlag(source, "zzLianLuoGiveBackMAX")
		local alives = room:getAlivePlayers()
		local to_help = sgs.SPlayerList()
		for _,p in sgs.qlist(alives) do
			room:setPlayerFlag(p, "-zzLianLuoGiveBackMAXTarget")
			if p:isWounded() then
				to_help:append(p)
			end
		end
		if to_help:isEmpty() then
			return 
		end
		local target = room:askForPlayerChosen(source, to_help, "zzLianLuoMAX", "@zzLianLuoRecoverMAX", true)
		if target then
			local recover = sgs.RecoverStruct()
			recover.who = source
			recover.recover = 1
			room:recover(target, recover)
		end
	end,
}
zzLianLuoGiveBackMAXCard = sgs.CreateSkillCard{
	name = "zzLianLuoGiveBackMAXCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return not to_select:hasFlag("zzLianLuoGiveBackMAXTarget")
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		room:obtainCard(target, self, false)
		room:setPlayerFlag(target, "zzLianLuoGiveBackMAXTarget")
	end,
}
zzLianLuoVSMAX = sgs.CreateViewAsSkill{
	name = "zzLianLuoMAX",
	n = 1,
	view_filter = function(self, selected, to_select)
		if sgs.Self:hasFlag("zzLianLuoGiveBackMAX") then
			return true
		else
			return false
		end
	end,
	view_as = function(self, cards)
		if sgs.Self:hasFlag("zzLianLuoGiveBackMAX") then
			if #cards == 1 then
				local card = zzLianLuoGiveBackMAXCard:clone()
				card:addSubcard(cards[1])
				return card
			end
		else
			return zzLianLuoMAXCard:clone()
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		if player:hasFlag("zzLianLuoGiveBackMAX") then
			return pattern == "@@zzLianLuoGiveBackMAX"
		else
			return pattern == "@@zzLianLuoMAX"
		end
	end,
}
zzLianLuoMAX = sgs.CreateTriggerSkill{
	name = "zzLianLuoMAX",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = zzLianLuoVSMAX,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local room = player:getRoom()
			room:askForUseCard(player, "@@zzLianLuoMAX", "@zzLianLuoMAX")
		end
		return false
	end,
}
--添加技能
zzGuangMingTai:addSkill(zzLianLuoMAX)
--翻译信息
sgs.LoadTranslationTable{
	["zzLianLuoMAX"] = "联络",
	[":zzLianLuoMAX"] = "回合结束阶段，你可以获得任意数目角色的各一张牌，然后你可以交给任意数目角色各一张牌。若如此做，你可以令一名角色回复1点体力。",
	["@zzLianLuoMAX"] = "您可以发动“联络”指定任意数目的角色，获得这些角色的各一张牌",
	["~zzLianLuoMAX"] = "选择一些角色（包括自己）->点击“确定”",
	["@zzLianLuoGiveBackMAX"] = "您可以继续发动“联络”交给一名其他角色一张牌",
	["@zzLianLuoRecoverMAX"] = "您发动了“联络”，可以令一名角色回复1点体力",
	["zzlianluomax"] = "联络",
	["zzlianluogivebackmax"] = "联络·回应",
}
else
--[[
	技能：联络
	描述：回合结束阶段，你可以获得你攻击范围内任意数目其他角色的各一张牌，然后你可以选择依次交给这些角色一张牌。若如此做，你失去X点体力（X为你获得牌的数目与失去牌的数目之差的一半，结果向下取整）。
]]--
zzLianLuoCard = sgs.CreateSkillCard{
	name = "zzLianLuoCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if to_select:objectName() == sgs.Self:objectName() then
			return false
		elseif to_select:isNude() then
			return false
		end
		return true
	end,
	on_use = function(self, room, source, targets)
		local to_get = sgs.IntList()
		local obtainNum = 0
		for _,p in ipairs(targets) do
			local id = room:askForCardChosen(source, p, "he", "zzLianLuo")
			if id > 0 then
				room:setPlayerFlag(p, "zzLianLuoTarget")
				to_get:append(id)
				obtainNum = obtainNum + 1
			end
		end
		for _,id in sgs.qlist(to_get) do
			room:obtainCard(source, id)
			if source:isDead() then
				return 
			end
		end
		room:setPlayerFlag(source, "zzLianLuoGiveBack")
		local giveNum = 0
		for _,p in ipairs(targets) do
			if source:isDead() or source:isNude() then
				break
			elseif p:isAlive() then
				local prompt = string.format("@zzLianLuoGiveBack:%s:", p:objectName())
				room:setPlayerFlag(p, "zzLianLuoCurrentTarget")
				if room:askForUseCard(source, "@@zzLianLuoGiveBack", prompt) then
					giveNum = giveNum + 1
				end
				room:setPlayerFlag(p, "-zzLianLuoCurrentTarget")
			end
		end
		room:setPlayerFlag(source, "-zzLianLuoGiveBack")
		for _,p in ipairs(targets) do
			room:setPlayerFlag(p, "-zzLianLuoTarget")
		end
		if source:isAlive() then
			local x = math.floor( (obtainNum - giveNum) / 2 )
			if x > 0 then
				room:loseHp(source, x)
			end
		end
	end,
}
zzLianLuoGiveBackCard = sgs.CreateSkillCard{
	name = "zzLianLuoGiveBackCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		local target = nil
		local alives = room:getAlivePlayers()
		for _,p in sgs.qlist(alives) do
			if p:hasFlag("zzLianLuoCurrentTarget") then
				target = p
				break
			end
		end
		if target then
			room:obtainCard(target, self, false)
		end
	end,
}
zzLianLuoVS = sgs.CreateViewAsSkill{
	name = "zzLianLuo",
	n = 1,
	view_filter = function(self, selected, to_select)
		if sgs.Self:hasFlag("zzLianLuoGiveBack") then
			return true
		else
			return false
		end
	end,
	view_as = function(self, cards)
		if sgs.Self:hasFlag("zzLianLuoGiveBack") then
			if #cards == 1 then
				local card = zzLianLuoGiveBackCard:clone()
				card:addSubcard(cards[1])
				return card
			end
		else
			return zzLianLuoCard:clone()
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		if player:hasFlag("zzLianLuoGiveBack") then
			return pattern == "@@zzLianLuoGiveBack"
		else
			return pattern == "@@zzLianLuo"
		end
	end,
}
zzLianLuo = sgs.CreateTriggerSkill{
	name = "zzLianLuo",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = zzLianLuoVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local room = player:getRoom()
			room:askForUseCard(player, "@@zzLianLuo", "@zzLianLuo") 
		end
		return false
	end,
}
--添加技能
zzGuangMingTai:addSkill(zzLianLuo)
--翻译信息
sgs.LoadTranslationTable{
	["zzLianLuo"] = "联络",
	[":zzLianLuo"] = "回合结束阶段，你可以获得你攻击范围内任意数目其他角色的各一张牌，然后你可以选择依次交给这些角色一张牌。若如此做，你失去X点体力（X为你获得牌的数目与失去牌的数目之差的一半，结果向下取整）。",
	["@zzLianLuoGiveBack"] = "联络：请交给 %src 一张牌（包括装备）",
	["@zzLianLuo"] = "您可以发动“联络”获得攻击范围内任意数目其他角色的各一张牌",
	["~zzLianLuo"] = "选择一些其他角色->点击“确定”",
	["zzlianluo"] = "联络",
	["zzlianluogiveback"] = "联络·回应",
}
end
if maxVersion and maxGuangMingTai then
--[[
	技能：光明（主公技）
	描述：你进入濒死状态时，可以翻开牌堆顶的X张牌，若其中有【桃】或【酒】，你回复1点体力。然后你可以选择一种花色，将这些牌中所有该花色的牌交给一名角色。（X为存活的群雄角色数）
]]--
zzGuangMing = sgs.CreateTriggerSkill{
	name = "zzGuangMing$",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Dying},
	on_trigger = function(self, event, player, data)
		local dying = data:toDying()
		local victim = dying.who
		if victim and victim:objectName() == player:objectName() then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			local quns = sgs.SPlayerList()
			for _,p in sgs.qlist(alives) do
				if p:getKingdom() == "qun" then
					quns:append(p)
				end
			end
			local x = quns:length()
			if x == 0 then
				return false
			end
			if player:askForSkillInvoke("zzGuangMing", data) then
				room:broadcastSkillInvoke("zzGuangMing") --播放配音
				room:notifySkillInvoked(player, "zzGuangMing") --显示技能发动
				local card_ids = room:getNCards(x, true)
				local move = sgs.CardsMoveStruct()
				move.to = nil
				move.to_place = sgs.Player_PlaceTable
				move.card_ids = card_ids
				move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName())
				room:moveCardsAtomic(move, true)
				local flag = false
				local spades, hearts, clubs, diamonds = sgs.IntList(), sgs.IntList(), sgs.IntList(), sgs.IntList()
				for _,id in sgs.qlist(card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if not flag then
						if card:isKindOf("Peach") or card:isKindOf("Analpetic") then
							flag = true
						end
					end
					local suit = card:getSuit()
					if suit == sgs.Card_Spade then
						spades:append(id)
					elseif suit == sgs.Card_Heart then
						hearts:append(id)
					elseif suit == sgs.Card_Club then
						clubs:append(id)
					elseif suit == sgs.Card_Diamond then
						diamonds:append(id)
					end
				end
				if flag then
					local recover = sgs.RecoverStruct()
					recover.who = player
					recover.recover = 1
					room:recover(player, recover)
				end
				local choices = {}
				if not spades:isEmpty() then
					table.insert(choices, "spade")
				end
				if not hearts:isEmpty() then
					table.insert(choices, "heart")
				end
				if not clubs:isEmpty() then
					table.insert(choices, "club")
				end
				if not diamonds:isEmpty() then
					table.insert(choices, "diamond")
				end
				table.insert(choices, "cancel")
				choices = table.concat(choices, "+")
				local ai_data = sgs.QVariant()
				ai_data:setValue(card_ids)
				local choice = room:askForChoice(player, "zzGuangMing", choices, ai_data)
				local to_give, to_throw, temp_throw = nil, nil, nil
				if choice == "spade" then
					to_give = spades
					temp_throw = {hearts, clubs, diamonds}
				elseif choice == "heart" then
					to_give = hearts
					temp_throw = {spades, clubs, diamonds}
				elseif choice == "club" then
					to_give = clubs
					temp_throw = {spades, hearts, diamonds}
				elseif choice == "diamond" then
					to_give = diamonds
					temp_throw = {spades, hearts, clubs}
				else
					to_throw = card_ids
				end
				if to_give then
					alives = room:getAlivePlayers()
					local prompt = string.format("@zzGuangMing:::%s:", choice)
					local target = room:askForPlayerChosen(player, alives, "zzGuangMing", prompt, true)
					if target then
						to_throw = sgs.IntList()
						for _,ids in ipairs(temp_throw) do
							for _,id in sgs.qlist(ids) do
								to_throw:append(id)
							end
						end
						move = sgs.CardsMoveStruct()
						move.to = target
						move.to_place = sgs.Player_PlaceHand
						move.card_ids = to_give
						move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GOTBACK, target:objectName())
						room:moveCardsAtomic(move, true)
					else
						to_throw = card_ids
					end
				end
				move = sgs.CardsMoveStruct()
				move.to = nil
				move.to_place = sgs.Player_DiscardPile
				move.card_ids = to_throw
				move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName())
				room:moveCardsAtomic(move, true)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() then
			return target:hasLordSkill("zzGuangMing")
		end
		return false
	end,
}
--添加技能
zzGuangMingTai:addSkill(zzGuangMing)
--翻译信息
sgs.LoadTranslationTable{
	["zzGuangMing"] = "光明",
	[":zzGuangMing"] = "<b><font color=\"orange\">主公技</font></b>, 你进入濒死状态时，可以翻开牌堆顶的X张牌，若其中有【桃】或【酒】，你回复1点体力。然后你可以选择一种花色，将这些牌中所有该花色的牌交给一名角色。（X为存活的群雄角色数）",
	["@zzGuangMing"] = "光明：您可以选择一名角色，令其获得这些牌中所有的 %arg 牌",
}
end
--[[****************************************************************
	编号：CASTLE - 005
	武将：战魂塔
	称号：精神动力
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
zzZhanHunTa = sgs.General(extension, "zzZhanHunTa", "wei")
--翻译信息
sgs.LoadTranslationTable{
	["zzZhanHunTa"] = "战魂塔",
	["&zzZhanHunTa"] = "战魂塔",
	["#zzZhanHunTa"] = "精神动力",
	["designer:zzZhanHunTa"] = "DGAH",
	["cv:zzZhanHunTa"] = "无",
	["illustrator:zzZhanHunTa"] = "焦国轩 - 山东潮汐塔",
	["~zzZhanHunTa"] = "战魂塔 的阵亡台词",
}
if maxVersion and maxZhanHunTa then
--[[
	技能：屹立·MAX（锁定技）
	描述：你受到一次伤害后回复1点体力；一名其他角色于其回合内对你造成伤害后，该角色计算的与你的距离+1直至当前回合结束。
]]--
zzYiLiMAX = sgs.CreateTriggerSkill{
	name = "zzYiLiMAX",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		room:broadcastSkillInvoke("zzYiLiMAX") --播放配音
		room:notifySkillInvoked(player, "zzYiLiMAX") --显示技能发动
		local recover = sgs.RecoverStruct()
		recover.who = player
		recover.recover = 1
		room:recover(player, recover)
		local source = damage.from
		if source and source:objectName() ~= player:objectName() then
			if source:getPhase() ~= sgs.Player_NotActive then
				player:gainMark("@zzSong", 1)
			end
		end
		return false
	end,
	priority = 0,
}
zzYiLiClearMAX = sgs.CreateTriggerSkill{
	name = "#zzYiLiClearMAX",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				if p:getMark("@zzSong") > 0 then
					p:loseAllMarks("@zzSong")
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
zzYiLiDistMAX = sgs.CreateDistanceSkill{
	name = "#zzYiLiDistMAX",
	correct_func = function(self, from, to)
		return to:getMark("@zzSong")
	end,
}
extension:insertRelatedSkills("zzYiLiMAX", "#zzYiLiClearMAX")
extension:insertRelatedSkills("zzYiLiMAX", "#zzYiLiDistMAX")
--添加技能
zzZhanHunTa:addSkill(zzYiLiMAX)
zzZhanHunTa:addSkill(zzYiLiClearMAX)
zzZhanHunTa:addSkill(zzYiLiDistMAX)
--翻译信息
sgs.LoadTranslationTable{
	["zzYiLiMAX"] = "屹立",
	[":zzYiLiMAX"] = "<b><font color=\"blue\">锁定技</font></b>, 你受到一次伤害后回复1点体力；<b><font color=\"blue\">锁定技</font></b>, 一名其他角色于其回合内对你造成伤害后，该角色计算的与你的距离+1直至当前回合结束。",
	["@zzSong"] = "耸",
	["#zzYiLiDistMAX"] = "屹立",
}
else
--[[
	技能：屹立（锁定技）
	描述：你受到的无来源的伤害-1；一名其他角色于其回合内对你造成伤害后，该角色计算的与你的距离+1直至当前回合结束。
]]--
zzYiLi = sgs.CreateTriggerSkill{
	name = "zzYiLi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted, sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local source = damage.from
		if event == sgs.DamageInflicted then
			if not source then
				room:broadcastSkillInvoke("zzYiLi") --播放配音
				room:notifySkillInvoked(player, "zzYiLi") --显示技能发动
				local count = damage.damage
				local msg = sgs.LogMessage()
				if count > 1 then
					msg.type = "#zzYiLiEffect"
				else
					msg.type = "#zzYiLiAvoid"
				end
				msg.from = player
				msg.arg = count
				count = count - 1
				msg.arg2 = count
				room:sendLog(msg) --发送提示信息
				damage.damage = count
				data:setValue(damage)
				return ( count == 0 )
			end
		elseif event == sgs.Damaged then
			if source and source:objectName() ~= player:objectName() then
				if source:getPhase() ~= sgs.Player_NotActive then
					player:gainMark("@zzSong", 1)
				end
			end
		end
		return false
	end,
}
zzYiLiClear = sgs.CreateTriggerSkill{
	name = "#zzYiLiClear",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				if p:getMark("@zzSong") > 0 then
					p:loseAllMarks("@zzSong")
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
zzYiLiDist = sgs.CreateDistanceSkill{
	name = "#zzYiLiDist",
	correct_func = function(self, from, to)
		return to:getMark("@zzSong")
	end,
}
extension:insertRelatedSkills("zzYiLiMAX", "#zzYiLiClear")
extension:insertRelatedSkills("zzYiLiMAX", "#zzYiLiDist")
--添加技能
zzZhanHunTa:addSkill(zzYiLi)
zzZhanHunTa:addSkill(zzYiLiClear)
zzZhanHunTa:addSkill(zzYiLiDist)
--翻译信息
sgs.LoadTranslationTable{
	["zzYiLi"] = "屹立",
	[":zzYiLi"] = "<b><font color=\"blue\">锁定技</font></b>, 你受到的无来源的伤害-1；<b><font color=\"blue\">锁定技</font></b>, 一名其他角色于其回合内对你造成伤害后，该角色计算的与你的距离+1直至当前回合结束。",
	["@zzSong"] = "耸",
}
end
--[[
	技能：鼓舞
	描述：你受到一点伤害后，你可以指定至多X名角色依次摸一张牌，然后你摸一张牌（X为你已损失的体力值）。
]]--
zzGuWuCard = sgs.CreateSkillCard{
	name = "zzGuWuCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets < sgs.Self:getLostHp()
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("zzGuWu") --播放配音
		for _,p in ipairs(targets) do
			room:drawCards(p, 1, "zzGuWu")
		end
		room:drawCards(source, 1, "zzGuWu")
	end,
}
zzGuWuVS = sgs.CreateViewAsSkill{
	name = "zzGuWu",
	n = 0,
	view_as = function(self, cards)
		return zzGuWuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@zzGuWu"
	end,
}
zzGuWu = sgs.CreateTriggerSkill{
	name = "zzGuWu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	view_as_skill = zzGuWuVS,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local count = damage.damage
		local room = player:getRoom()
		for i=1, count, 1 do
			local x = player:getLostHp()
			if x == 0 then
				return false
			end
			local prompt = string.format("@zzGuWu:::%d:", x)
			if not room:askForUseCard(player, "@@zzGuWu", prompt) then
				return false
			end
		end
		return false
	end,
}
--添加技能
zzZhanHunTa:addSkill(zzGuWu)
--翻译信息
sgs.LoadTranslationTable{
	["zzGuWu"] = "鼓舞",
	[":zzGuWu"] = "你受到一点伤害后，你可以指定至多X名角色依次摸一张牌，然后你摸一张牌（X为你已损失的体力值）。",
	["@zzGuWu"] = "您可以发动“鼓舞”令至多 %arg 名角色依次摸一张牌，然后你摸一张牌",
	["~zzGuWu"] = "选择一些将摸牌的角色（包括自己）->点击“确定”",
	["zzguwu"] = "鼓舞",
}
--[[****************************************************************
	编号：CASTLE - 006
	武将：紫云楼
	称号：仙云守护
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
zzZiYunLou = sgs.General(extension, "zzZiYunLou", "shu", 3)
--翻译信息
sgs.LoadTranslationTable{
	["zzZiYunLou"] = "紫云楼",
	["&zzZiYunLou"] = "紫云楼",
	["#zzZiYunLou"] = "仙云守护",
	["designer:zzZiYunLou"] = "DGAH",
	["cv:zzZiYunLou"] = "无",
	["illustrator:zzZiYunLou"] = "西安大唐芙蓉园紫云楼",
	["~zzZiYunLou"] = "紫云楼 的阵亡台词",
}
--[[
	技能：飘渺（锁定技）
	描述：回合开始时，你获得技能“马术”并失去技能“飞影”；回合结束后，你获得技能“飞影”并失去技能“马术”；你的手牌上限+X（X为你装备区牌的数目）
]]--
zzPiaoMiao = sgs.CreateTriggerSkill{
	name = "zzPiaoMiao",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local phase = player:getPhase()
		local room = player:getRoom()
		if phase == sgs.Player_Start then
			room:handleAcquireDetachSkills(player, "mashu|-feiying")
		elseif phase == sgs.Player_NotActive then
			room:handleAcquireDetachSkills(player, "-mashu|feiying")
		end
		return false
	end,
}
zzPiaoMiaoKeep = sgs.CreateMaxCardsSkill{
	name = "#zzPiaoMiaoKeep",
	extra_func = function(self, player)
		if player:hasSkill("zzPiaoMiao") then
			local equips = player:getEquips()
			return equips:length()
		end
		return 0
	end,
}
extension:insertRelatedSkills("zzPiaoMiao", "#zzPiaoMiaoKeep")
--添加技能
zzZiYunLou:addSkill(zzPiaoMiao)
zzZiYunLou:addSkill(zzPiaoMiaoKeep)
--翻译信息
sgs.LoadTranslationTable{
	["zzPiaoMiao"] = "飘渺",
	[":zzPiaoMiao"] = "<b><font color=\"blue\">锁定技</font></b>, 回合开始时，你获得技能“马术”并失去技能“飞影”；回合结束后，你获得技能“飞影”并失去技能“马术”；<b><font color=\"blue\">锁定技</font></b>, 你的手牌上限+X（X为你装备区牌的数目）",
}
if maxVersion and maxZiYunLou then
--[[
	技能：仙术·MAX
	描述：一名角色的出牌阶段开始时，你可以展示其一张手牌，然后根据该牌的花色执行相应的效果：
		黑桃——你可以令你攻击范围内的一名角色失去一点体力；
		红心——你可以令你攻击范围内的一名角色回复一点体力；
		草花——你可以获得你攻击范围内的一名角色区域中的一张牌；
		方块——你可以令你攻击范围内的一名角色摸两张牌。
]]--
zzXianShuMAX = sgs.CreateTriggerSkill{
	name = "zzXianShuMAX",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:isKongcheng() then
			return false
		elseif player:getPhase() == sgs.Player_Play then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:hasSkill("zzXianShuMAX") then
					if source:askForSkillInvoke("zzXianShuMAX", data) then
						room:broadcastSkillInvoke("zzXianShuMAX") --播放配音
						room:notifySkillInvoked(source, "zzXianShuMAX") --显示技能发动
						local id = room:askForCardChosen(source, player, "h", "zzXianShuMAX")
						if id > 0 then
							room:showCard(player, id)
							local card = sgs.Sanguosha:getCard(id)
							local suit = card:getSuit()
							if suit == sgs.Card_Spade then
								local victims = sgs.SPlayerList()
								for _,p in sgs.qlist(alives) do
									if inAttackRange(source, p) then
										victims:append(p)
									end
								end
								if victims:isEmpty() then
									--不可能出现这种情况
								else
									local victim = room:askForPlayerChosen(
										source, victims, "zzXianShuMAXSpade", "@zzXianShuMAX-spade", true
									)
									if victim then
										room:loseHp(victim, 1)
									end
								end
							elseif suit == sgs.Card_Heart then
								local targets = sgs.SPlayerList()
								for _,p in sgs.qlist(alives) do
									if p:isWounded() then
										if inAttackRange(source, p) then
											targets:append(p)
										end
									end
								end
								if targets:isEmpty() then
									local msg = sgs.LogMessage()
									msg.type = "#zzXianShuMAXHeart"
									msg.from = source
									msg.arg = "zzXianShuMAX"
									room:sendLog(msg) --发送提示信息
								else
									local target = room:askForPlayerChosen(
										source, targets, "zzXianShuMAXHeart", "@zzXianShuMAX-heart", true
									)
									if target then
										local recover = sgs.RecoverStruct()
										recover.who = source
										recover.recover = 1
										room:recover(target, recover)
									end
								end
							elseif suit == sgs.Card_Club then
								local targets = sgs.SPlayerList()
								for _,p in sgs.qlist(alives) do
									if not p:isAllNude() then
										if inAttackRange(source, p) then
											targets:append(p)
										end
									end
								end
								if targets:isEmpty() then
									local msg = sgs.LogMessage()
									msg.type = "#zzXianShuMAXClub"
									msg.from = source
									msg.arg = "zzXianShuMAX"
									room:sendLog(msg) --发送提示信息
								else
									local target = room:askForPlayerChosen(
										source, targets, "zzXianShuMAXClub", "@zzXianShuMAX-club", true
									)
									if target then
										local card_id = room:askForCardChosen(source, target, "hej", "zzXianShuMAX-obtain")
										if card_id > 0 then
											room:obtainCard(source, card_id)
										end
									end
								end
							elseif suit == sgs.Card_Diamond then
								local targets = sgs.SPlayerList()
								for _,p in sgs.qlist(alives) do
									if inAttackRange(source, p) then
										targets:append(p)
									end
								end
								if targets:isEmpty() then
									--不可能出现这种情况
								else
									local target = room:askForPlayerChosen(
										source, targets, "zzXianShuMAXDiamond", "@zzXianShuMAX-diamond", true
									)
									if target then
										room:drawCards(target, 2, "zzXianShuMAX")
									end
								end
							end
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
zzZiYunLou:addSkill(zzXianShuMAX)
--翻译信息
sgs.LoadTranslationTable{
	["zzXianShuMAX"] = "仙术",
	[":zzXianShuMAX"] = "一名角色的出牌阶段开始时，你可以展示其一张手牌，然后根据该牌的花色执行相应的效果：\
	<b>[黑</b><b>桃]</b>你可以令你攻击范围内的一名角色失去一点体力；\
	<b>[红</b><b>心]</b>你可以令你攻击范围内的一名角色回复一点体力；\
	<b>[草</b><b>花]</b>你可以获得你攻击范围内的一名角色区域中的一张牌；\
	<b>[方</b><b>块]</b>你可以令你攻击范围内的一名角色摸两张牌。",
	["zzXianShuMAXSpade"] = "仙术",
	["zzXianShuMAXHeart"] = "仙术",
	["#zzXianShuMAXHeart"] = "%from 发动了“%arg”，但攻击范围内没有受伤的角色，后续效果取消",
	["zzXianShuMAXClub"] = "仙术",
	["#zzXianShuMAXClub"] = "%from 发动了“%arg”，但攻击范围内没有有牌角色，后续效果取消",
	["zzXianShuMAXDiamond"] = "仙术",
	["@zzXianShuMAX-spade"] = "仙术：您可以选择攻击范围内一名角色，令其失去一点体力",
	["@zzXianShuMAX-heart"] = "仙术：您可以选择攻击范围内一名角色，令其回复一点体力",
	["@zzXianShuMAX-club"] = "仙术：您可以获得攻击范围内一名角色区域中的一张牌",
	["zzXianShuMAX-obtain"] = "仙术",
	["@zzXianShuMAX-diamond"] = "仙术：您可以选择攻击范围内的一名角色，令其摸两张牌",
}
else
--[[
	技能：仙术
	描述：你攻击范围内的一名角色的出牌阶段开始时，你可以弃一张牌并展示其一张手牌，然后根据该牌的花色执行相应的效果：
		黑桃——你可以令你攻击范围内的一名角色失去一点体力；
		红心——你可以令你攻击范围内的一名角色回复一点体力；
		草花——你可以获得你攻击范围内的一名角色区域中的一张牌；
		方块——你可以令你攻击范围内的一名角色摸两张牌。
]]--
zzXianShu = sgs.CreateTriggerSkill{
	name = "zzXianShu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:isKongcheng() then
			return false
		elseif player:getPhase() == sgs.Player_Play then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			local prompt = string.format("@zzXianShu:%s:", player:objectName())
			for _,source in sgs.qlist(alives) do
				if source:isNude() then
				elseif source:hasSkill("zzXianShu") and inAttackRange(source, player) then
					local to_use = room:askForCard(source, "..", prompt, data, "zzXianShu")
					if to_use then
						room:broadcastSkillInvoke("zzXianShu") --播放配音
						room:notifySkillInvoked(source, "zzXianShu") --显示技能发动
						local id = room:askForCardChosen(source, player, "h", "zzXianShu")
						if id > 0 then
							room:showCard(player, id)
							local card = sgs.Sanguosha:getCard(id)
							local suit = card:getSuit()
							if suit == sgs.Card_Spade then
								local victims = sgs.SPlayerList()
								for _,p in sgs.qlist(alives) do
									if inAttackRange(source, p) then
										victims:append(p)
									end
								end
								if victims:isEmpty() then
									--不可能出现这种情况
								else
									local victim = room:askForPlayerChosen(
										source, victims, "zzXianShuSpade", "@zzXianShu-spade", true
									)
									if victim then
										room:loseHp(victim, 1)
									end
								end
							elseif suit == sgs.Card_Heart then
								local targets = sgs.SPlayerList()
								for _,p in sgs.qlist(alives) do
									if p:isWounded() then
										if inAttackRange(source, p) then
											targets:append(p)
										end
									end
								end
								if targets:isEmpty() then
									local msg = sgs.LogMessage()
									msg.type = "#zzXianShuHeart"
									msg.from = source
									msg.arg = "zzXianShu"
									room:sendLog(msg) --发送提示信息
								else
									local target = room:askForPlayerChosen(
										source, targets, "zzXianShuHeart", "@zzXianShu-heart", true
									)
									if target then
										local recover = sgs.RecoverStruct()
										recover.who = source
										recover.recover = 1
										room:recover(target, recover)
									end
								end
							elseif suit == sgs.Card_Club then
								local targets = sgs.SPlayerList()
								for _,p in sgs.qlist(alives) do
									if not p:isAllNude() then
										if inAttackRange(source, p) then
											targets:append(p)
										end
									end
								end
								if targets:isEmpty() then
									local msg = sgs.LogMessage()
									msg.type = "#zzXianShuClub"
									msg.from = source
									msg.arg = "zzXianShu"
									room:sendLog(msg) --发送提示信息
								else
									local target = room:askForPlayerChosen(
										source, targets, "zzXianShuClub", "@zzXianShu-club", true
									)
									if target then
										local card_id = room:askForCardChosen(source, target, "hej", "zzXianShu-obtain")
										if card_id > 0 then
											room:obtainCard(source, card_id)
										end
									end
								end
							elseif suit == sgs.Card_Diamond then
								local targets = sgs.SPlayerList()
								for _,p in sgs.qlist(alives) do
									if inAttackRange(source, p) then
										targets:append(p)
									end
								end
								if targets:isEmpty() then
									--不可能出现这种情况
								else
									local target = room:askForPlayerChosen(
										source, targets, "zzXianShuDiamond", "@zzXianShu-diamond", true
									)
									if target then
										room:drawCards(target, 2, "zzXianShu")
									end
								end
							end
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
zzZiYunLou:addSkill(zzXianShu)
--翻译信息
sgs.LoadTranslationTable{
	["zzXianShu"] = "仙术",
	[":zzXianShu"] = "你攻击范围内的一名角色的出牌阶段开始时，你可以弃一张牌并展示其一张手牌，然后根据该牌的花色执行相应的效果：\
	<b>[黑</b><b>桃]</b>你可以令你攻击范围内的一名角色失去一点体力；\
	<b>[红</b><b>心]</b>你可以令你攻击范围内的一名角色回复一点体力；\
	<b>[草</b><b>花]</b>你可以获得你攻击范围内的一名角色区域中的一张牌；\
	<b>[方</b><b>块]</b>你可以令你攻击范围内的一名角色摸两张牌。",
	["@zzXianShu"] = "您可以弃一张牌发动“仙术”，展示 %src 的一张手牌",
	["zzXianShuSpade"] = "仙术",
	["zzXianShuHeart"] = "仙术",
	["zzXianShuClub"] = "仙术",
	["zzXianShuDiamond"] = "仙术",
	["@zzXianShu-spade"] = "仙术：您可以选择攻击范围内一名角色，令其失去一点体力",
	["@zzXianShu-heart"] = "仙术：您可以选择攻击范围内一名角色，令其回复一点体力",
	["#zzXianShuHeart"] = "%from 发动了“%arg”，但攻击范围内没有受伤的角色，后续效果取消",
	["@zzXianShu-club"] = "仙术：您可以获得攻击范围内一名角色区域中的一张牌",
	["#zzXianShuClub"] = "%from 发动了“%arg”，但攻击范围内没有有牌角色，后续效果取消",
	["zzXianShu-obtain"] = "仙术",
	["@zzXianShu-diamond"] = "仙术：您可以选择攻击范围内的一名角色，令其摸两张牌",
}
end
--[[****************************************************************
	编号：CASTLE - 007
	武将：机关阵
	称号：神秘力量
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
zzJiGuanZhen = sgs.General(extension, "zzJiGuanZhen", "wu", 3)
--翻译信息
sgs.LoadTranslationTable{
	["zzJiGuanZhen"] = "机关阵",
	["&zzJiGuanZhen"] = "机关阵",
	["#zzJiGuanZhen"] = "神秘力量",
	["designer:zzJiGuanZhen"] = "DGAH",
	["cv:zzJiGuanZhen"] = "无",
	["illustrator:zzJiGuanZhen"] = "网络资源",
	["~zzJiGuanZhen"] = "机关阵 的阵亡台词",
}
if maxVersion and maxJiGuanZhen then
--[[
	技能：秘法·MAX（锁定技）
	描述：你于回合外失去一张牌时，你摸两张牌；回合开始前，若你的判定区有牌，你额外执行一个出牌阶段。
]]--
zzMiFaMAX = sgs.CreateTriggerSkill{
	name = "zzMiFaMAX",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime, sgs.TurnStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			if player:getPhase() == sgs.Player_NotActive then
				local move = data:toMoveOneTime()
				local source = move.from
				if source and source:objectName() == player:objectName() then
					local ids = move.card_ids
					local count = 0
					for index, id in sgs.qlist(ids) do
						local place = move.from_places:at(index)
						if place == sgs.Player_PlaceHand or place == sgs.Player_PlaceEquip then
							count = count + 2
						end
					end
					if count > 0 then
						room:broadcastSkillInvoke("zzMiFaMAX") --播放配音
						room:notifySkillInvoked(player, "zzMiFaMAX") --显示技能发动
						room:drawCards(player, count, "zzMiFaMAX")
					end
				end
			end
		elseif event == sgs.TurnStart then
			local judges = player:getJudgingArea()
			if judges:isEmpty() then
				return false
			end
			room:broadcastSkillInvoke("zzMiFaMAX") --播放配音
			room:notifySkillInvoked(player, "zzMiFaMAX") --显示技能发动
			local thread = room:getThread()
			player:setPhase(sgs.Player_Play)
			room:broadcastProperty(player, "phase")
			if not thread:trigger(sgs.EventPhaseStart, room, player) then
				thread:trigger(sgs.EventPhaseProceeding, room, player)
			end
			thread:trigger(sgs.EventPhaseEnd, room, player)
			player:setPhase(sgs.Player_RoundStart)
			room:broadcastProperty(player, "phase")
		end
		return false
	end,
}
--添加技能
zzJiGuanZhen:addSkill(zzMiFaMAX)
--翻译信息
sgs.LoadTranslationTable{
	["zzMiFaMAX"] = "秘法",
	[":zzMiFaMAX"] = "<b><font color=\"blue\">锁定技</font></b>, 你于回合外失去一张牌时，你摸两张牌；<b><font color=\"blue\">锁定技</font></b>, 回合开始前，若你的判定区有牌，你额外执行一个出牌阶段。",
}
else
--[[
	技能：秘法（锁定技）
	描述：你于回合外失去一张黑色牌时，你摸一张牌（若该牌为手牌，你须先展示之）；若该牌为装备牌，改为摸两张牌。
]]--
zzMiFa = sgs.CreateTriggerSkill{
	name = "zzMiFa",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			local room = player:getRoom()
			local move = data:toMoveOneTime()
			local source = move.from
			if source and source:objectName() == player:objectName() then
				local ids = move.card_ids
				if event == sgs.BeforeCardsMove then
					for index, id in sgs.qlist(ids) do
						local card = sgs.Sanguosha:getCard(id)
						if not card:hasFlag("zzMiFaMoving") then
							if card:isBlack() then
								local place = move.from_places:at(index)
								if place == sgs.Player_PlaceHand then
									room:setCardFlag(card, "zzMiFaMoving")
									room:showCard(player, id)
									room:setCardFlag(card, "-zzMiFaMoving")
								end
							end
						end
					end
				elseif event == sgs.CardsMoveOneTime then
					local count = 0
					for index, id in sgs.qlist(ids) do
						local card = sgs.Sanguosha:getCard(id)
						if not card:hasFlag("zzMiFaMoving") then
							if card:isBlack() then
								local place = move.from_places:at(index)
								if place == sgs.Player_PlaceHand or place == sgs.Player_PlaceEquip then
									if card:isKindOf("EquipCard") then
										count = count + 2
									else
										count = count + 1
									end
								end
							end
						end
					end
					if count > 0 then
						room:broadcastSkillInvoke("zzMiFa") --播放配音
						room:notifySkillInvoked(player, "zzMiFa") --显示技能发动
						room:drawCards(player, count, "zzMiFa")
					end
				end
			end
		end
	end,
}
--添加技能
zzJiGuanZhen:addSkill(zzMiFa)
--翻译信息
sgs.LoadTranslationTable{
	["zzMiFa"] = "秘法",
	[":zzMiFa"] = "<b><font color=\"blue\">锁定技</font></b>, 你于回合外失去一张黑色牌时，你摸一张牌（若该牌为手牌，你须先展示之）；若该牌为装备牌，改为摸两张牌。",
}
end
--[[
	技能：疑云
	描述：你成为【杀】的目标时，你可以进行一次判定，若结果为方块牌，你令此【杀】的使用者代替你成为此【杀】的目标，否则你获得此判定牌；你成为一张多目标锦囊牌的目标时，你可以为此锦囊牌重新指定结算顺序并摸一张牌。
	备注：多目标锦囊牌，指GlobalEffect类的【桃园结义】和【五谷丰登】、AOE类的【南蛮入侵】和【万箭齐发】，以及【铁索连环】。
]]--
zzYiYunCard = sgs.CreateSkillCard{
	name = "zzYiYunCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return to_select:hasFlag("zzYiYunTrickTarget")
	end,
	feasible = function(self, targets)
		return #targets == sgs.Self:getMark("zzYiYunTrickTargetNum")
	end,
	about_to_use = function(self, room, use)
		local source = use.from
		local targets = use.to
		local msg = sgs.LogMessage()
		msg.type = "#zzYiYunArrange"
		msg.from = source
		msg.to = targets
		msg.arg = "zzYiYun"
		msg.arg2 = source:property("zzYiYunTrick"):toString()
		room:sendLog(msg) --发送提示信息
		local data = sgs.QVariant()
		data:setValue(use)
		local thread = room:getThread()
		thread:trigger(sgs.PreCardUsed, room, source, data)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, source:objectName(), nil, "zzYiYun", nil)
		room:moveCardTo(self, source, nil, sgs.Player_DiscardPile, reason, true)
		thread:trigger(sgs.CardUsed, room, source, data)
		thread:trigger(sgs.CardFinished, room, source, data)
	end,
	on_use = function(self, room, source, targets)
		local data = room:getTag("zzYiYunData")
		local use = data:toCardUse()
		local newTargets = sgs.SPlayerList()
		for _,target in ipairs(targets) do
			newTargets:append(target)
		end
		use.to = newTargets
		data:setValue(use)
		room:setTag("zzYiYunData", data)
		room:drawCards(source, 1, "zzYiYun")
	end,
}
zzYiYunVS = sgs.CreateViewAsSkill{
	name = "zzYiYun",
	n = 0,
	view_as = function(self, cards)
		return zzYiYunCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@zzYiYun"
	end,
}
zzYiYun = sgs.CreateTriggerSkill{
	name = "zzYiYun",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed},
	view_as_skill = zzYiYunVS,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local trick = use.card
		local room = player:getRoom()
		if trick:isKindOf("Slash") then
			local targets = use.to
			local newTargets = sgs.SPlayerList()
			for _,source in sgs.qlist(targets) do
				local flag = true
				if source:hasSkill("zzYiYun") then
					if source:askForSkillInvoke("zzYiYun", data) then
						local judge = sgs.JudgeStruct()
						judge.who = source
						judge.reason = "zzYiYun"
						judge.pattern = ".|diamond"
						judge.good = true
						room:judge(judge)
						if judge:isGood() then
							flag = false
							if player:isProhibited(player, trick) then
								local msg = sgs.LogMessage()
								msg.type = "#zzYiYunCancel"
								msg.from = source
								msg.to:append(player)
								msg.arg = "zzYiYun"
								msg.arg2 = trick:objectName()
								room:sendLog(msg) --发送提示信息
							else
								local msg = sgs.LogMessage()
								msg.type = "#zzYiYunExchange"
								msg.from = source
								msg.to:append(player)
								msg.arg = "zzYiYun"
								msg.arg2 = trick:objectName()
								room:sendLog(msg) --发送提示信息
								newTargets:append(player)
							end
						else
							room:obtainCard(source, judge.card)
						end
					end
				end
				if flag then
					newTargets:append(source)
				end
			end
			use.to = newTargets
			data:setValue(use)
			return ( newTargets:isEmpty() )
		elseif trick:isKindOf("GlobalEffect") or trick:isKindOf("AOE") or trick:isKindOf("IronChain") then
			local source_list = {}
			local targets = use.to
			for _,p in sgs.qlist(targets) do
				room:setPlayerFlag(p, "zzYiYunTrickTarget")
				if p:hasSkill("zzYiYun") then
					table.insert(source_list, p)
				end
			end
			if #source_list == 0 then
				for _,p in sgs.qlist(targets) do
					room:setPlayerFlag(p, "-zzYiYunTrickTarget")
				end
				return false
			end
			local count = targets:length()
			local prompt = string.format("@zzYiYun:::%s:", trick:objectName())
			room:setTag("zzYiYunData", data)
			for _,source in ipairs(source_list) do
				room:setPlayerProperty(source, "zzYiYunTrick", sgs.QVariant(trick:objectName()))
				room:setPlayerMark(source, "zzYiYunTrickTargetNum", count)
				room:askForUseCard(source, "@@zzYiYun", prompt)
				room:setPlayerMark(source, "zzYiYunTrickTargetNum", 0)
				room:setPlayerProperty(source, "zzYiYunTrick", sgs.QVariant())
			end
			local newData = room:getTag("zzYiYunData")
			room:removeTag("zzYiYunData")
			local newUseStruct = newData:toCardUse()
			data:setValue(newUseStruct)
			for _,p in sgs.qlist(targets) do
				room:setPlayerFlag(p, "-zzYiYunTrickTarget")
			end
		end
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
zzJiGuanZhen:addSkill(zzYiYun)
--翻译信息
sgs.LoadTranslationTable{
	["zzYiYun"] = "疑云",
	[":zzYiYun"] = "你成为【杀】的目标时，你可以进行一次判定，若结果为方块牌，你令此【杀】的使用者代替你成为此【杀】的目标，否则你获得此判定牌；你成为一张多目标锦囊牌的目标时，你可以为此锦囊牌重新指定结算顺序并摸一张牌。",
	["#zzYiYunArrange"] = "%from 发动了“%arg”，将此【%arg2】结算顺序改为 %to",
	["#zzYiYunExchange"] = "%from 发动了技能“%arg”，令使用者 %to 代替其成为了此【%arg2】的目标",
	["#zzYiYunCancel"] = "%from 发动了技能“%arg”，但由于使用者 %to 不能被指定为此【%arg2】的目标，效果改为取消之",
	["@zzYiYun"] = "您可以发动“疑云”为此【%arg】重新指定结算顺序",
	["~zzYiYun"] = "依次选择所有目标角色->点击“确定”",
}
--[[****************************************************************
	编号：CASTLE - 008
	武将：戍卫营
	称号：誓敌无畏
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
zzShuWeiYing = sgs.General(extension, "zzShuWeiYing", "qun")
--翻译信息
sgs.LoadTranslationTable{
	["zzShuWeiYing"] = "戍卫营",
	["&zzShuWeiYing"] = "戍卫营",
	["#zzShuWeiYing"] = "誓敌无畏",
	["designer:zzShuWeiYing"] = "DGAH",
	["cv:zzShuWeiYing"] = "无",
	["illustrator:zzShuWeiYing"] = "汇图网",
	["~zzShuWeiYing"] = "戍卫营 的阵亡台词",
}
--[[
	技能：忠诚（锁定技）
	描述：你受到你攻击范围内的角色或你攻击范围内的角色受到你使用的红色牌造成的伤害时，你防止此伤害并选择一项：1、伤害来源回复等量的体力；2、伤害目标失去等量的体力。
]]--
zzZhongCheng = sgs.CreateTriggerSkill{
	name = "zzZhongCheng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local card = damage.card
		if card and card:isRed() then
			local source = damage.from
			if source and source:isAlive() then
				local count = damage.damage
				local room = player:getRoom()
				if player:hasSkill("zzZhongCheng") and inAttackRange(player, source) then
					room:broadcastSkillInvoke("zzZhongCheng") --播放配音
					room:notifySkillInvoked(player, "zzZhongCheng") --显示技能发动
					local choice = room:askForChoice(player, "zzZhongCheng", "recover+losehp", data)
					if choice == "recover" then
						local msg = sgs.LogMessage()
						msg.type = "#zzZhongChengRecover"
						msg.from = player
						msg.to:append(source)
						msg.arg = "zzZhongCheng"
						msg.arg2 = count
						room:sendLog(msg) --发送提示信息
						local recover = sgs.RecoverStruct()
						recover.who = player
						recover.recover = count
						room:recover(source, recover)
					elseif choice == "losehp" then
						local msg = sgs.LogMessage()
						msg.type = "#zzZhongChengLoseHp"
						msg.from = player
						msg.to:append(player)
						msg.arg = "zzZhongCheng"
						msg.arg2 = count
						room:sendLog(msg) --发送提示信息
						room:loseHp(player, count)
					end
					return true
				elseif source:hasSkill("zzZhongCheng") and inAttackRange(source, player) then
					room:broadcastSkillInvoke("zzZhongCheng") --播放配音
					room:notifySkillInvoked(source, "zzZhongCheng") --显示技能发动
					local choice = room:askForChoice(source, "zzZhongCheng", "recover+losehp", data)
					if choice == "recover" then
						local msg = sgs.LogMessage()
						msg.type = "#zzZhongChengRecover"
						msg.from = source
						msg.to:append(source)
						msg.arg = "zzZhongCheng"
						msg.arg2 = count
						room:sendLog(msg) --发送提示信息
						local recover = sgs.RecoverStruct()
						recover.who = source
						recover.recover = count
						room:recover(source, recover)
					elseif choice == "losehp" then
						local msg = sgs.LogMessage()
						msg.type = "#zzZhongChengLoseHp"
						msg.from = source
						msg.to:append(player)
						msg.arg = "zzZhongCheng"
						msg.arg2 = count
						room:sendLog(msg) --发送提示信息
						room:loseHp(player, count)
					end
					return true
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
zzShuWeiYing:addSkill(zzZhongCheng)
--翻译信息
sgs.LoadTranslationTable{
	["zzZhongCheng"] = "忠诚",
	[":zzZhongCheng"] = "<b><font color=\"blue\">锁定技</font></b>, 你受到你攻击范围内的角色或你攻击范围内的角色受到你使用的红色牌造成的伤害时，你防止此伤害并选择一项：1、伤害来源回复等量的体力；2、伤害目标失去等量的体力。",
	["#zzZhongChengRecover"] = "%from 发动技能“%arg”防止了此 %arg2 点伤害，改为伤害来源 %to 回复等量体力",
	["#zzZhongChengLoseHp"] = "%from 发动技能“%arg”防止了此 %arg2 点伤害，改为伤害目标 %to 失去等量体力",
	["zzZhongCheng:recover"] = "伤害来源回复等量体力",
	["zzZhongCheng:losehp"] = "伤害目标失去等量体力",
}
if maxVersion and maxShuWeiYing then
--[[
	技能：热血·MAX
	描述：一名角色受到伤害后，你可以失去1点体力，令该角色或伤害来源失去X点体力（X为你已损失的体力）。
]]--
zzReXueMAX = sgs.CreateTriggerSkill{
	name = "zzReXueMAX",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		local targets = sgs.SPlayerList()
		targets:append(player)
		local source = damage.from
		if source and source:objectName() ~= player:objectName() then
			targets:append(source)
		end
		local alives = room:getAlivePlayers()
		for _,p in sgs.qlist(alives) do
			if p:hasSkill("zzReXueMAX") then
				local victim = room:askForPlayerChosen(p, targets, "zzReXueMAX", "@zzReXueMAX", true, true)
				if victim then
					room:broadcastSkillInvoke("zzReXueMAX") --播放配音
					room:loseHp(p, 1)
					local count = p:getLostHp()
					if count > 0 then
						room:loseHp(victim, count)
					end
					if victim:isDead() then
						targets:removeOne(victim)
						if targets:isEmpty() then
							break
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
zzShuWeiYing:addSkill(zzReXueMAX)
--翻译信息
sgs.LoadTranslationTable{
	["zzReXueMAX"] = "热血",
	[":zzReXueMAX"] = "一名角色受到伤害后，你可以失去1点体力，令该角色或伤害来源失去X点体力（X为你已损失的体力）。",
	["@zzReXueMAX"] = "您可以发动“热血”选择伤害事件中的一名角色，你失去1点体力，然后其失去X点体力（X为你已损失的体力值）",
}
else
--[[
	技能：热血
	描述：你攻击范围内的一名角色受到伤害后，若伤害来源存在且不为你，你可以弃置一张手牌，视为对伤害来源使用了一张火【杀】。 
]]--
zzReXue = sgs.CreateTriggerSkill{
	name = "zzReXue",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local source = damage.from
		if source then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				if p:hasSkill("zzReXue") and p:objectName() ~= source:objectName() then
					if not p:isKongcheng() then
						if inAttackRange(p, player) and p:canSlash(source, false) then
							local prompt = string.format("@zzReXue:%s:", source:objectName())
							local card = room:askForCard(p, ".", prompt, data, "zzReXue")
							if card then
								local slash = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_NoSuit, 0)
								slash:setSkillName("zzReXue")
								local use = sgs.CardUseStruct()
								use.from = p
								use.to:append(source)
								use.card = slash
								room:useCard(use, false)
								if source:isDead() then
									break
								end
							end
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
zzShuWeiYing:addSkill(zzReXue)
--翻译信息
sgs.LoadTranslationTable{
	["zzReXue"] = "热血",
	[":zzReXue"] = "你攻击范围内的一名角色受到伤害后，若伤害来源存在且不为你，你可以弃置一张手牌，视为对伤害来源使用了一张火【杀】。",
	["@zzReXue"] = "热血：您可以弃一张手牌，视为对 %src 使用了一张火【杀】",
}
end
--[[****************************************************************
	MAX版特效
]]--****************************************************************
if maxVersion then
--[[
	技能：画面效果
	描述：游戏开始时，你获得一枚“MAX”标记。
]]--
zzMaxEffect = sgs.CreateTriggerSkill{
	name = "#zzMaxEffect",
	frequency = sgs.Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		player:gainMark("@zzMaxVer", 1)
	end,
}
--添加技能
zzAnJiang:addSkill(zzMaxEffect)
if maxWanShiCheng then zzWanShiCheng:addSkill("#zzMaxEffect") end
if maxLangJiaPu then zzLangJiaPu:addSkill("#zzMaxEffect") end
if maxLingXinZhu then zzLingXinZhu:addSkill("#zzMaxEffect") end
if maxGuangMingTai then zzGuangMingTai:addSkill("#zzMaxEffect") end
if maxZhanHunTa then zzZhanHunTa:addSkill("#zzMaxEffect") end
if maxZiYunLou then zzZiYunLou:addSkill("#zzMaxEffect") end
if maxJiGuanZhen then zzJiGuanZhen:addSkill("#zzMaxEffect") end
if maxShuWeiYing then zzShuWeiYing:addSkill("#zzMaxEffect") end
--翻译信息
sgs.LoadTranslationTable{
	["@zzMaxVer"] = "MAX",
}
end
--[[****************************************************************
	MAX版专用对策
]]--****************************************************************
if maxVersion then
if maxWanShiCheng then
--[[
	技能：“坚城·MAX”专用对策
	描述：你即将造成伤害时，若目标角色拥有技能“坚城·MAX”，你可以弃置1张手牌令此伤害视为体力流失。
	拥有者：光明台
]]--
zzAntiJianChengMAX = sgs.CreateTriggerSkill{
	name = "#zzAntiJianChengMAX",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Predamage},
	on_trigger = function(self, event, player, data)
		if player:isKongcheng() then
			return false
		end
		local damage = data:toDamage()
		local target = damage.to
		if target and target:hasSkill("zzJianChengMAX") then
			local room = player:getRoom()
			local count = damage.damage
			local prompt = string.format("@zzAntiJianChengMAX:%s::%d:", target:objectName(), count)
			local card = room:askForCard(player, ".", prompt, data, "zzAntiJianChengMAX")
			if card then
				room:loseHp(target, count)
				return true
			end
		end
		return false
	end,
}
--添加技能
zzGuangMingTai:addSkill(zzAntiJianChengMAX)
--翻译信息
sgs.LoadTranslationTable{
	["zzAntiJianChengMAX"] = "“坚城·MAX”专用对策",
	["@zzAntiJianChengMAX"] = "您可以发动“坚城·MAX”专用对策，将本次对 %src 造成的 %arg 点伤害视为体力流失",
}
end
end