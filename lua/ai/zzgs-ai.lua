--[[
	太阳神三国杀武将扩展包·重镇固守（AI部分）
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
--[[****************************************************************
	编号：CASTLE - 001
	武将：顽石城
	称号：城坚难破
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：坚城·MAX（锁定技）
	描述：你受到伤害时，防止之；回合结束时，若所有其他角色均不在你的攻击范围内，你获得1枚“困”标记并失去X点体力（X为“困”标记的数量），否则你失去所有的“困”标记。
]]--
--相关信息
local system_damageIsEffective = SmartAI.damageIsEffective
function SmartAI:damageIsEffective(to, nature, from)
	to = to or self.player
	nature = nature or sgs.DamageStruct_Normal
	from = from or self.room:getCurrent()
	if to:hasSkill("zzJianChengMAX") then
		if from:hasSkill("#zzAntiJianChengMAX") then
			if from:isKongcheng() then
				return false
			elseif self:isFriend(to, from) then
				return false
			end
		else
			return false
		end
	end
	return system_damageIsEffective(self, to, nature, from)
end
--[[
	技能：坚城（锁定技）
	描述：一名角色对你造成伤害时，须弃置一张手牌，否则此伤害-1。
]]--
--room:askForCard(source, ".", prompt, data, "zzJianCheng")
sgs.ai_skill_cardask["@zzJianCheng"] = function(self, data, pattern, target, target2, arg, arg2)
	if self.player:isKongcheng() then
		return "."
	end
	local damage = data:toDamage()
	if self:isFriend(target) then
		return "."
	end
end
--[[
	技能：合援
	描述：你于回合外获得牌时，你可以指定你攻击范围内的一名其他角色（来源除外），视为对其使用了一张【杀】。每阶段限一次。
]]--
--room:askForPlayerChosen(player, victims, "zzHeYuan", "@zzHeYuan", true, true)
sgs.ai_skill_playerchosen["zzHeYuan"] = sgs.ai_skill_playerchosen["zero_card_as_slash"]
--[[****************************************************************
	编号：CASTLE - 002
	武将：狼家堡
	称号：磐石利剑
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：固防（锁定技）
	描述：其他角色对你使用【过河拆桥】、【顺手牵羊】、【火攻】时，须弃置一张牌，否则此锦囊牌对你无效。
]]--
--room:askForCard(source, "..", prompt, data, "zzGuFang")
--[[
	技能：突围·MAX
	描述：回合开始时，若你已受伤，你可以视为使用一张【杀】；
		你的【杀】指定目标时，你可以选择一项：1、获得目标角色区域中的一张牌；2、令目标角色失去1点体力；
		锁定技，你的【杀】可以指定任意数目的角色为目标。
]]--
--room:askForUseCard(player, "@@zzTuWeiMAX", "@zzTuWeiMAX") 
sgs.ai_skill_use["@@zzTuWeiMAX"] = function(self, prompt, method)
	local slash = sgs.Sanguosha:cloneCard("slash")
	slash:setSkillName("zzTuWeiMAX")
	slash:deleteLater()
	local dummy_use = {
		isDummy = true,
		to = sgs.SPlayerList(),
	}
	self:useBasicCard(slash, dummy_use)
	if dummy_use.card then
		local targets = {}
		for _,p in sgs.qlist(dummy_use.to) do
			table.insert(targets, p:objectName())
		end
		local card_str = "#zzTuWeiMAXCard:.:->"..table.concat(targets, "+")
		return card_str
	end
	return "."
end
--room:askForChoice(player, "zzTuWeiMAX", choices, ai_data)
sgs.ai_skill_choice["zzTuWeiMAX"] = function(self, choices, data)
	local target = data:toPlayer()
	local obtain = string.find(choices, "obtain")
	if self:isFriend(target) then
		if obtain then
			if target:getArmor() and self:needToThrowArmor(target) then
				return "obtain"
			end
		end
	else
		if obtain then
			if not target:hasSkill("tuntian") then
				return "obtain"
			end
		end
		return "losehp"
	end
	return "cancel"
end
--room:askForCardChosen(player, p, "hej", "zzTuWeiMAX")
--[[
	技能：突围
	描述：你的【杀】指定目标时，你可以选择一项：1、为此【杀】额外指定一个目标；2、令目标角色须额外使用一张【闪】抵消此【杀】；3、令此【杀】命中后造成的伤害+1。若如此做，你失去1点体力并摸一张牌。
]]--
--room:askForChoice(player, "zzTuWei", choices, data)
sgs.ai_skill_choice["zzTuWei"] = function(self, choices, data)
	if self:isWeak() then
		return "cancel"
	elseif self.player:getHp() + self:getAllPeachNum() <= 1 then
		if not self:hasSkills("buqu|nosbuqu") then
			return "cancel"
		end
	end
	local use = data:toCardUse()
	local slash = use.card
	local targets = use.to
	local friends, enemies = {}, {}
	for _,p in sgs.qlist(targets) do
		if self:isFriend(p) then
			table.insert(friends, p)
		else
			table.insert(enemies, p)
		end
	end
	local withTarget = string.find(choices, "target")
	local withJink = string.find(choices, "jink")
	local withDamage = string.find(choices, "damage")
	local targetValue, jinkValue, damageValue = -1, -1, -1
	if withTarget then
		local alives = self.room:getAlivePlayers()
		local victims = sgs.SPlayerList()
		for _,p in sgs.qlist(alives) do
			if not targets:contains(p) then
				if self.player:canSlash(p, slash, false) then
					victims:append(p)
				end
			end
		end
		local callback = sgs.ai_skill_playerchosen["slash_extra_targets"]
		local extraTarget = callback(self, victims)
		if extraTarget then
			if self:isFriend(extraTarget) then
				if extraTarget:hasSkill("leiji") then
					if extraTarget:isWounded() then
						targetValue = targetValue + 4
					else
						targetValue = targetValue + 2
					end
				elseif extraTarget:hasSkill("nosleiji") then
					targetValue = targetValue + 4
				elseif self:hasSkills(sgs.masochism_skill, extraTarget) then
					targetValue = targetValue + 1
				end
			else
				targetValue = targetValue + 1
				if self:isWeak(extraTarget) then
					targetValue = targetValue + 1
					if extraTarget:getHp() + self:getAllPeachNum(extraTarget) <= 1 then
						targetValue = targetValue + 10
					end
				end
			end
		end
	end
	if withJink then
		function getValue(victim, isFriend)
			local value = 0
			local jinkNum = getCardsNum("Jink", victim, self.player)
			local hasLeiji = false
			if jinkNum > 0 then
				if victim:hasSkill("leiji") then
					hasLeiji = true
					if jinkNum == 1 then
						local recover = math.min(1, victim:getLostHp())
						value = value - 2 * recover - 2
					elseif jinkNum >= 2 then
						local recover = math.min(2, victim:getLostHp())
						value = value - 2 * recover - 4
					end
				elseif victim:hasSkill("nosleiji") then
					hasLeiji = true
					if jinkNum == 1 then
						value = value - 2
					elseif jinkNum >= 2 then
						value = value - 4
					end
				end
			end
			if jinkNum == 1 then
				value = value + 2
				if victim:getHp() + self:getAllPeachNum(victim) <= 1 then
					value = value + 10
				end
			elseif jinkNum >= 2 then
				value = value + 1
			end
			if isFriend then
				value = - value
			end
			return value
		end
		for _,friend in ipairs(friends) do
			jinkValue = jinkValue + getValue(friend, true)
		end
		for _,enemy in ipairs(enemies) do
			jinkValue = jinkValue + getValue(enemy, false)
		end
	end
	if withDamage then
		function getValue(victim, isFriend)
			local value = 0
			if self:damageIsEffective(victim, slash.nature, self.player) then
				if not victim:hasArmorEffect("silver_lion") then
					value = value + 2
					if victim:getHp() + self:getAllPeachNum(victim) <= 2 then
						value = value + 10
					end
				end
			end
			if isFriend then
				value = - value
			end
			return value
		end
		for _,friend in ipairs(friends) do
			damageValue = damageValue + getValue(friend, true)
		end
		for _,enemy in ipairs(enemies) do
			damageValue = damageValue + getValue(enemy, false)
		end
	end
	if withTarget and targetValue > jinkValue and targetValue > damageValue then
		return "target"
	elseif withJink and jinkValue > targetValue and jinkValue > damageValue then
		return "jink"
	elseif withDamage and damageValue > targetValue and damageValue > jinkValue then
		return "damage"
	end
	return "cancel"
end
--room:askForPlayerChosen(player, victims, "zzTuWei", prompt, true)
sgs.ai_skill_playerchosen["zzTuWei"] = sgs.ai_skill_playerchosen["slash_extra_targets"]
--[[****************************************************************
	编号：CASTLE - 003
	武将：灵心筑
	称号：水中的阴谋
	势力：吴
	性别：女
	体力上限：2勾玉
]]--****************************************************************
--[[
	技能：池险·MAX（锁定技）
	描述：你不能被指定为与你距离为1的角色使用的【杀】的目标；你受到的火焰伤害-1；你的手牌上限+1。
]]--
--相关信息
local system_damageIsEffective = SmartAI.damageIsEffective
function SmartAI:damageIsEffective(to, nature, from)
	to = to or self.player
	nature = nature or sgs.DamageStruct_Normal
	from = from or self.room:getCurrent()
	if nature == sgs.DamageStruct_Fire then
		if to:hasSkill("zzChiXianMAX") or to:hasSkill("zzChiXian") then
			if not from:hasSkill("jueqing") then
				local count = 1
				local JinXuanDi = self.room:findPlayerBySkillName("wuling")
				if JinXuanDi and JinXuanDi:getMark("wind") > 0 then
					count = count + 1
				end
				if count <= 1 then
					return false
				end
			end
		end
	end
	return system_damageIsEffective(self, to, nature, from)
end
--[[
	技能：池险（锁定技）
	描述：你不能被指定为与你距离为1的角色使用的【杀】的目标；你受到的火焰伤害-1；你受到的雷电伤害+1。
]]--
--[[
	技能：策应
	描述：一名与你距离为1的角色的回合结束时，你可以令其选择一项：弃置一张【杀】，或受到你造成的1点伤害。
]]--
--source:askForSkillInvoke("zzCeYing", ai_data)
sgs.ai_skill_invoke["zzCeYing"] = function(self, data)
	local target = data:toPlayer()
	if self:isFriend(target) then
		return false
	end
	if self:damageIsEffective(target, sgs.DamageStruct_Normal, self.player) then
		if self:cantbeHurt(target, self.player, 1) then
			return false
		elseif self:getDamagedEffects(target, self.player, false) then
			return false
		end
		return true
	end
	return false
end
--room:askForCard(player, "Slash", prompt, ai_data, "zzCeYing")
sgs.ai_skill_cardask["@zzCeYing"] = function(self, data, pattern, target, target2, arg, arg2)
	local source = data:toPlayer()
	if self:damageIsEffective(self.player, sgs.DamageStruct_Normal, source) then
		if self:cantbeHurt(self.player, source, 1) then
			if self:isFriend(source) then
				return nil
			else
				return "."
			end
		elseif self:getDamagedEffects(self.player, source, false) then
			if self:isWeak() then
				return nil
			end
			return "."
		end
		return nil
	end
	return "."
end
--[[
	技能：真容（觉醒技）
	描述：出牌阶段开始时，若场上人数为2，你失去技能“池险·MAX”和“策应”，增加2点体力上限并回复2点体力，获得技能“绝击”。
]]--
--[[
	技能：绝击（限定技）
	描述：出牌阶段，你可以选择一项：
		1、对一名其他角色造成X点伤害（X为其体力上限）；
		2、摸三张牌并令一名其他角色失去1点体力上限；
		3、令一名其他角色失去一项技能并弃置其装备区的所有牌。
		4、与一名其他角色拼点，没赢的一方立即阵亡。
		然后你失去所有技能。
]]--
--room:askForChoice(source, "zzJueJi", choices, ai_data)
sgs.ai_skill_choice["zzJueJi"] = function(self, choices, data)
	local target = data:toPlayer()
	local withDamage = string.find(choices, "damage")
	local withMaxHp = string.find(choices, "maxhp")
	local withSkill = string.find(choices, "skill")
	local withPindian = string.find(choices, "pindian")
	if withMaxHp and target:getMaxHp() == 1 then
		return "maxhp"
	end
	if withPindian then
		local handcards = self.player:getHandcards()
		local my_max_point = 0
		for _,card in sgs.qlist(handcards) do
			local point = card:getNumber()
			if point > my_max_point then
				my_max_point = point
			end
		end
		handcards = target:getHandcards()
		local max_point = 0
		local unknown_count = 0
		local flag = string.format("visible_%s_%s", self.player:objectName(), target:objectName())
		for _,card in sgs.qlist(handcards) do
			if card:hasFlag("visible") or card:hasFlag(flag) then
				local point = card:getNumber()
				if point > max_point then
					max_point = point
				end
			else
				unknown_count = unknown_count + 1
			end
		end
		if unknown_count == 0 and my_max_point > max_point and max_point > 0 then
			return "pindian"
		elseif my_max_point == 13 and max_point < 13 then
			return "pindian"
		end
	end
	if withDamage then
		if self:damageIsEffective(target, sgs.DamageStruct_Normal, self.player) then
			local count = target:getMaxHp()
			if target:hasArmorEffect("silver_lion") and count > 1 then
				if not self.player:hasSkill("jueqing") then
					if not self.player:hasWeapon("QinggangSword") then
						count = 1
					end
				end
			end
			if target:getHp() + self:getAllPeachNum(target) <= count then
				return "damage"
			end
			if count <= 2 then
				withDamage = false
			end
		end
	end
	if withSkill then
		local bad_skills = "benghuai|wumou|shiyong|zaoyao|chanyuan|chouhai"
		local skills = target:getVisibleSkillList()
		local only_bad = true
		for _,skill in sgs.qlist(skills) do
			if skill:inherits("SPConvertSkill") then
			elseif skill:isAttachedLordSkill() then
			elseif skill:isLordSkill() then
				if target:hasLordSkill(skill:objectName()) then
					only_bad = false
					break
				end
			else
				if not string.find(bad_skills, skill:objectName()) then
					only_bad = false
					break
				end
			end
		end
		if only_bad then
			withSkill = false
		end
	end
	if withSkill then
		return "skill"
	end
	if withMaxHp then
		return "maxhp"
	end
	if withDamage then
		return "damage"
	end
	if withPindian then
		return "pindian"
	end
	if string.find(choices, "skill") then
		return "skill"
	end
	if string.find(choices, "damage") then
		return "damage"
	end
end
--room:askForChoice(source, "zzJueJiDetachSkill", to_select, ai_data)
sgs.ai_skill_choice["zzJueJiDetachSkill"] = function(self, choices, data)
	local target = data:toPlayer()
	if target:hasSkill("chongzhen") and target:hasSkill("longdan") then
		return "longdan"
	elseif target:hasSkill("qixing") and self:hasSkills("kuangfeng|dawu", target) then
		return "qixing"
	elseif target:hasSkill("jixi") and target:hasSkill("tuntian") then
		return "tuntian"
	elseif target:hasSkill("kuangbao") and self:hasSkills("wumou|wuqian|shenfen", target) then
		return "kuangbao"
	elseif target:hasSkill("renjie") and target:hasSkill("jilve") then
		return "renjie"
	elseif target:hasSkill("paiyi") and target:getMark("quanji") then
		return "quanji"
	end
	if target:hasSkill("hunzi") and target:getMark("hunzi") == 0 then
		return "hunzi"
	elseif target:hasLordSkill("ruoyu") and target:getMark("ruoyu") == 0 then
		return "ruoyu"
	elseif target:hasSkill("qianxin") and target:getMark("qianxin") == 0 then
		return "qianxin"
	elseif target:hasSkill("qinxue") and target:getMark("qinxue") == 0 then
		return "qinxue"
	elseif target:hasSkill("zaoxian") and target:getMark("zaoxian") == 0 then
		return "zaoxian"
	elseif target:hasSkill("zhiji") and target:getMark("zhiji") == 0 then
		return "zhiji"
	elseif target:hasSkill("baiyin") and target:getMark("baiyin") == 0 then
		return "baiyin"
	elseif target:hasSkill("zili") and target:getMark("zili") == 0 then
		return "zili"
	elseif target:hasSkill("zhanshen") and target:getMark("zhanshen") == 0 then
		return "zhanshen"
	elseif target:hasSkill("danqi") and target:getMark("danqi") == 0 then
		return "danqi"
	elseif target:hasSkill("wuji") and target:getMark("wuji") == 0 then
		return "wuji"
	elseif target:hasSkill("juyi") and target:getMark("juyi") == 0 then
		return "juyi"
	elseif target:hasSkill("baoling") and target:getMark("baoling") == 0 then
		return "baoling"
	elseif target:hasSkill("fanxiang") and target:getMark("fanxiang") == 0 then
		return "fanxiang"
	elseif target:hasSkill("fengliang") and target:getMark("fengliang") == 0 then
		return "fengliang"
	elseif target:hasSkill("jiehuo") and target:getMark("jiehuo") == 0 then
		return "jiehuo"
	end
	for _,skill in ipairs(sgs.priority_skill:split("|")) do
		if string.match(choices, skill) then
			return choice
		end
	end
	for _,skill in ipairs(sgs.recover_skill:split("|")) do
		if string.match(choices, skill) then
			return choice
		end
	end
	local bad_skills = "benghuai|wumou|shiyong|zaoyao|yaowu|chanyuan|chouhai"
	local choice_table = choices:split("+")
	for _,choice in ipairs(choice_table) do
		if not string.find(bad_skills, choice) then
			return choice
		end
	end
end
--source:pindian(target, "zzJueJi")
sgs.ai_skill_pindian["zzJueJi"] = function(minusecard, self, requestor, maxcard, mincard)
	local handcards = self.player:getHandcards()
	local maxPoint, maxPointCard = 0, nil
	for _,card in sgs.qlist(handcards) do
		local point = card:getNumber()
		if point > maxPoint then
			maxPoint = point
			maxPointCard = card
		elseif point == maxPoint then
			if maxPointCard then
				if self:getKeepValue(maxPointCard) < self:getKeepValue(card) then
					maxPointCard = card
				end
			else
				maxPointCard = card
			end
		end
	end
	if maxPointCard then
		return maxPointCard
	end
	return maxcard or minusecard or mincard
end
--zzJueJiCard:Play
local jueji_skill = {
	name = "zzJueJi",
	getTurnUseCard = function(self, inclusive)
		if self.player:getMark("@zzJueJiMark") > 0 then
			return sgs.Card_Parse("#zzJueJiCard:.:")
		end
	end,
}
table.insert(sgs.ai_skills, jueji_skill)
sgs.ai_skill_use_func["#zzJueJiCard"] = function(card, use, self)
	use.card = card
	local others = self.room:getOtherPlayers(self.player)
	local target = others:first()
	if use.to then
		use.to:append(target)
	end
end
--相关信息
sgs.ai_use_value["zzJueJiCard"] = 4
sgs.ai_use_priority["zzJueJiCard"] = 9
sgs.ai_card_intention["zzJueJiCard"] = 5000
--[[****************************************************************
	编号：CASTLE - 004
	武将：光明台
	称号：指挥中心
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：要地（锁定技）
	描述：你与其他角色计算距离时，或其他角色与你计算距离时，始终-1。
]]--
--[[
	技能：联络·MAX
	描述：回合结束阶段，你可以获得任意数目角色的各一张牌，然后你可以交给任意数目角色各一张牌。若如此做，你可以令一名角色回复1点体力。
]]--
--room:askForCardChosen(source, p, "he", "zzLianLuoMAX")
--room:askForUseCard(source, "@@zzLianLuoGiveBackMAX", "@zzLianLuoGiveBackMAX")
sgs.ai_skill_use["@@zzLianLuoGiveBackMAX"] = function(self, prompt, method)
	return "."
end
--room:askForPlayerChosen(source, to_help, "zzLianLuoMAX", "@zzLianLuoRecoverMAX", true)
sgs.ai_skill_playerchosen["zzLianLuoMAX"] = function(self, targets)
	local friends = {}
	for _,p in sgs.qlist(targets) do
		if self:isFriend(p) then
			table.insert(friends, p)
		end
	end
	if #friends > 0 then
		self:sort(friends, "defense")
		for _,friend in ipairs(friends) do
			if friend:hasSkill("hunzi") and friend:getMark("hunzi") == 0 then
			else
				return friend
			end
		end
		return friends[1]
	end
end
--room:askForUseCard(player, "@@zzLianLuoMAX", "@zzLianLuoMAX")
sgs.ai_skill_use["@@zzLianLuoMAX"] = function(self, prompt, method)
	local alives = self.room:getAlivePlayers()
	local targets = {}
	for _,p in sgs.qlist(alives) do
		if not p:isNude() then
			if self:isFriend(p) then
				if p:getArmor() and self:needToThrowArmor(p) then
					table.insert(targets, p:objectName())
				end
			else
				table.insert(targets, p:objectName())
			end
		end
	end
	if #targets == 0 then
		return "."
	end
	local card_str = "#zzLianLuoMAXCard:.:->"..table.concat(targets, "+")
	return card_str
end
--[[
	技能：联络
	描述：回合结束阶段，你可以获得你攻击范围内任意数目其他角色的各一张牌，然后你可以选择依次交给这些角色一张牌。若如此做，你失去X点体力（X为你获得牌的数目与失去牌的数目之差的一半，结果向下取整）。
]]--
--room:askForCardChosen(source, p, "he", "zzLianLuo")
--room:askForUseCard(source, "@@zzLianLuoGiveBack", prompt)
sgs.ai_skill_use["@@zzLianLuoGiveBack"] = function(self, prompt, method)
	local alives = self.room:getAlivePlayers()
	local target = nil
	for _,p in sgs.qlist(alives) do
		if p:hasFlag("zzLianLuoCurrentTarget") then
			target = p
			break
		end
	end
	if target then
		local handcards = self.player:getHandcards()
		if handcards:isEmpty() then
			return "."
		end
		handcards = sgs.QList2Table(handcards)
		if self:isFriend(target) then
			self:sortByUseValue(handcards)
			return "#zzLianLuoGiveBackCard:"..handcards[1]:getEffectiveId()..":->."
		elseif self:isEnemy(target) then
			return "."
		else
			self:sortByKeepValue(handcards)
			return "#zzLianLuoGiveBackCard:"..handcards[1]:getEffectiveId()..":->."
		end
	end
	return "."
end
--room:askForUseCard(player, "@@zzLianLuo", "@zzLianLuo") 
sgs.ai_skill_use["@@zzLianLuo"] = function(self, prompt, method)
	local others = self.room:getOtherPlayers(self.player)
	local targets = {}
	for _,p in sgs.qlist(others) do
		if self.player:inMyAttackRange(p) then
			if not p:isNude() then
				table.insert(targets, p:objectName())
			end
		end
	end
	if self.player:getArmor() and self:needToThrowArmor() then
		table.insert(targets, self.player:objectName())
	end
	if #targets == 0 then
		return "."
	end
	local card_str = "#zzLianLuoCard:.:->"..table.concat(targets, "+")
	return card_str
end
--[[
	技能：光明（主公技）
	描述：你进入濒死状态时，可以翻开牌堆顶的X张牌，若其中有【桃】或【酒】，你回复1点体力。然后你可以选择一种花色，将这些牌中所有该花色的牌交给一名角色。（X为存活的群雄角色数）
]]--
--player:askForSkillInvoke("zzGuangMing", data)
sgs.ai_skill_invoke["zzGuangMing"] = true
--room:askForChoice(player, "zzGuangMing", choices, ai_data)
sgs.ai_skill_choice["zzGuangMing"] = function(self, choices, data)
	local card_ids = data:toIntList()
	local spades, hearts, clubs, diamonds = {}, {}, {}, {}
	local v_spade, v_heart, v_club, v_diamond = 0, 0, 0, 0
	for _,id in sgs.qlist(card_ids) do
		local card = sgs.Sanguosha:getCard(id)
		local suit = card:getSuit()
		if suit == sgs.Card_Spade then
			table.insert(spades, card)
			v_spade = v_spade + self:getKeepValue(card)
		elseif suit == sgs.Card_Heart then
			table.insert(hearts, card)
			v_heart = v_heart + self:getKeepValue(card)
		elseif suit == sgs.Card_Club then
			table.insert(clubs, card)
			v_club = v_club + self:getKeepValue(card)
		elseif suit == sgs.Card_Diamond then
			table.insert(diamonds, card)
			v_diamond = v_diamond + self:getKeepValue(card)
		end
	end
	v_spade = v_spade * 100 + #spades * 4
	v_heart = v_heart * 100 + #hearts * 5
	v_club = v_club * 100 + #clubs * 2.5
	v_diamond = v_diamond * 100 + #diamonds * 4.5
	local maxValue, maxSuit = v_spade, "spade"
	if v_heart > maxValue then
		maxValue, maxSuit = v_heart, "heart"
	end
	if v_club > maxValue then
		maxValue, maxSuit = v_club, "club"
	end
	if v_diamond > maxValue then
		maxValue, maxSuit = v_diamond, "diamond"
	end
	if maxValue > 0 then
		return maxSuit
	end
end
--room:askForPlayerChosen(player, alives, "zzGuangMing", prompt, true)
sgs.ai_skill_playerchosen["zzGuangMing"] = function(self, targets)
	if #self.friends_noself == 0 then
		return self.player
	elseif self:getAllPeachNum() == 0 then
		self:sort(self.friends_noself, "defense")
		return self.friends_noself[1]
	end
	return self.player
end
--[[****************************************************************
	编号：CASTLE - 005
	武将：战魂塔
	称号：精神动力
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：屹立·MAX（锁定技）
	描述：你受到一次伤害后回复1点体力；一名其他角色于其回合内对你造成伤害后，该角色计算的与你的距离+1直至当前回合结束。
]]--
--相关信息
sgs.ai_need_damaged["zzYiLiMAX"] = function(self, from, to)
	if to:hasSkill("zzYiLiMAX") then
		local hp = to:getHp()
		if hp > 1 then
			return true
		elseif hp + self:getAllPeachNum(to) > 1 then
			return true
		end
	end
end
--[[
	技能：屹立（锁定技）
	描述：你受到的无来源的伤害-1；一名其他角色于其回合内对你造成伤害后，该角色计算的与你的距离+1直至当前回合结束。
]]--
--[[
	技能：鼓舞
	描述：你受到一点伤害后，你可以指定至多X名角色依次摸一张牌，然后你摸一张牌（X为你已损失的体力值）。
]]--
--room:askForUseCard(player, "@@zzGuWu", prompt)
sgs.ai_skill_use["@@zzGuWu"] = function(self, prompt, method)
	local args = prompt:split(":")
	local x = tonumber(args[4])
	local alives = self.room:getAlivePlayers()
	local getGuWuValue = function(target)
		local value = 10
		if target:isKongcheng() and self:needKongcheng() then
			value = value - 5
			if self:isWeak(target) then
				value = value - 10
			end
		end
		if self:hasSkills(sgs.cardneed_skill, target) then
			value = value + 4
		end
		if self:getOverflow(target) >= 0 then
			value = value - 2
		else
			value = value + 1
		end
		if not self:isFriend(target) then
			value = - value
			if not self:isEnemy(target) then
				value = value * 0.1
			end
		end
		return value
	end
	local values = {}
	local targets = {}
	for _,p in sgs.qlist(alives) do
		values[p:objectName()] = getGuWuValue(p)
		table.insert(targets, p)
	end
	local compare_func = function(a, b)
		local valueA = values[a:objectName()] or 0
		local valueB = values[b:objectName()] or 0
		if valueA == valueB then
			return a:getHandcardNum() < b:getHandcardNum()
		else
			return valueA > valueB
		end
	end
	table.sort(targets, compare_func)
	local count = math.min(#targets, x)
	local names = {}
	for i=1, count, 1 do
		local p = targets[i]
		local value = values[p:objectName()] or 0
		if value > 0 then
			table.insert(names, p:objectName())
		else
			break
		end
	end
	if #names > 0 then
		local card_str = "#zzGuWuCard:.:->"..table.concat(names, "+")
		return card_str
	end
	return "."
end
--[[****************************************************************
	编号：CASTLE - 006
	武将：紫云楼
	称号：仙云守护
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：飘渺（锁定技）
	描述：回合开始时，你获得技能“马术”并失去技能“飞影”；回合结束后，你获得技能“飞影”并失去技能“马术”；你的手牌上限+X（X为你装备区牌的数目）
]]--
--[[
	技能：仙术·MAX
	描述：一名角色的出牌阶段开始时，你可以展示其一张手牌，然后根据该牌的花色执行相应的效果：
		黑桃——你可以令你攻击范围内的一名角色失去一点体力；
		红心——你可以令你攻击范围内的一名角色回复一点体力；
		草花——你可以获得你攻击范围内的一名角色区域中的一张牌；
		方块——你可以令你攻击范围内的一名角色摸两张牌。
]]--
--source:askForSkillInvoke("zzXianShuMAX", data)
sgs.ai_skill_invoke["zzXianShuMAX"] = true
--room:askForCardChosen(source, player, "h", "zzXianShuMAX")
--room:askForPlayerChosen(source, victims, "zzXianShuMAXSpade", "@zzXianShuMAX-spade", true)
sgs.ai_skill_playerchosen["zzXianShuMAXSpade"] = function(self, targets)
	local enemies, unknowns, friends = {}, {}, {}
	for _,target in sgs.qlist(targets) do
		if self:isEnemy(target) then
			table.insert(enemies, target)
		elseif self:isFriend(target) then
			table.insert(friends, target)
		else
			table.insert(unknowns, target)
		end
	end
	if #enemies > 0 then
		self:sort(enemies, "defense")
		return enemies[1]
	end
	if #unknowns > 0 then
		self:sort(unknowns, "threat")
		return unknowns[1]
	end
	if #friends > 0 then
		for _,friend in ipairs(friends) do
			if getBestHp(friend) > friend:getHp() then
				return friend
			end
		end
	end
	return nil
end
--room:askForPlayerChosen(source, targets, "zzXianShuMAXHeart", "@zzXianShuMAX-heart", true)
sgs.ai_skill_playerchosen["zzXianShuMAXHeart"] = function(self, targets)
	local friends = {}
	for _,p in sgs.qlist(targets) do
		if self:isFriend(p) then
			table.insert(friends, p)
		end
	end
	if #friends > 0 then
		self:sort(friends, "defense")
		for _,friend in ipairs(friends) do
			if friend:hasSkill("hunzi") and friend:getMark("hunzi") == 0 then
			else
				return friend
			end
		end
		return friends[1]
	end
end
--room:askForPlayerChosen(source, targets, "zzXianShuMAXClub", "@zzXianShuMAX-club", true)
sgs.ai_skill_playerchosen["zzXianShuMAXClub"] = function(self, targets)
	return self:findPlayerToDiscard("he", true, false, targets, false)
end
--room:askForCardChosen(source, target, "hej", "zzXianShuMAX-obtain")
--room:askForPlayerChosen(source, targets, "zzXianShuMAXDiamond", "@zzXianShuMAX-diamond", true)
sgs.ai_skill_playerchosen["zzXianShuMAXDiamond"] = function(self, targets)
	local friends = {}
	for _,p in sgs.qlist(targets) do
		if self:isFriend(p) then
			table.insert(friends, p)
		end
	end
	if #friends > 0 then
		self:sort(friends, "defense")
		for _,friend in ipairs(friends) do
			if not hasManjuanEffect(friend) then
				return friend
			end
		end
	end
end
--相关信息
sgs.ai_playerchosen_intention["zzXianShuMAXSpade"] = function(self, from, to)
	if getBestHp(to) > to:getHp() then
		return 
	elseif self:needToLoseHp(to) then
		return 
	end
	sgs.updateIntention(from, to, 50)
end
sgs.ai_playerchosen_intention["zzXianShuMAXHeart"] = -30
sgs.ai_choicemade_filter["cardChosen"]["zzXianShuMAX-obtain"] = sgs.ai_choicemade_filter.cardChosen.snatch
sgs.ai_playerchosen_intention["zzXianShuMAXDiamond"] = -40
--[[
	技能：仙术
	描述：你攻击范围内的一名角色的出牌阶段开始时，你可以弃一张牌并展示其一张手牌，然后根据该牌的花色执行相应的效果：
		黑桃——你可以令你攻击范围内的一名角色失去一点体力；
		红心——你可以令你攻击范围内的一名角色回复一点体力；
		草花——你可以获得你攻击范围内的一名角色区域中的一张牌；
		方块——你可以令你攻击范围内的一名角色摸两张牌。
]]--
--room:askForCard(source, "..", prompt, data, "zzXianShu")
--room:askForCardChosen(source, player, "h", "zzXianShu")
--room:askForPlayerChosen(source, victims, "zzXianShuSpade", "@zzXianShu-spade", true)
sgs.ai_skill_playerchosen["zzXianShuSpade"] = sgs.ai_skill_playerchosen["zzXianShuMAXSpade"]
--room:askForPlayerChosen(source, targets, "zzXianShuHeart", "@zzXianShu-heart", true)
sgs.ai_skill_playerchosen["zzXianShuHeart"] = sgs.ai_skill_playerchosen["zzXianShuMAXHeart"]
--room:askForPlayerChosen(source, targets, "zzXianShuClub", "@zzXianShu-club", true)
sgs.ai_skill_playerchosen["zzXianShuClub"] = sgs.ai_skill_playerchosen["zzXianShuMAXClub"]
--room:askForCardChosen(source, target, "hej", "zzXianShu-obtain")
--room:askForPlayerChosen(source, targets, "zzXianShuDiamond", "@zzXianShu-diamond", true)
sgs.ai_skill_playerchosen["zzXianShuDiamond"] = sgs.ai_skill_playerchosen["zzXianShuMAXDiamond"]
--相关信息
sgs.ai_playerchosen_intention["zzXianShuSpade"] = sgs.ai_playerchosen_intention["zzXianShuMAXSpade"]
sgs.ai_playerchosen_intention["zzXianShuHeart"] = sgs.ai_playerchosen_intention["zzXianShuMAXHeart"]
sgs.ai_choicemade_filter["cardChosen"]["zzXianShu-obtain"] = sgs.ai_choicemade_filter["cardChosen"]["zzXianShuMAX-obtain"]
sgs.ai_playerchosen_intention["zzXianShuDiamond"] = sgs.ai_playerchosen_intention["zzXianShuMAXDiamond"]
--[[****************************************************************
	编号：CASTLE - 007
	武将：机关阵
	称号：神秘力量
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：秘法·MAX（锁定技）
	描述：你于回合外失去一张牌时，你摸两张牌；回合开始前，若你的判定区有牌，你额外执行一个出牌阶段。
]]--
--[[
	技能：秘法（锁定技）
	描述：你于回合外失去一张黑色牌时，你摸一张牌（若该牌为手牌，你须先展示之）；若该牌为装备牌，改为摸两张牌。
]]--
--[[
	技能：疑云
	描述：你成为【杀】的目标时，你可以进行一次判定，若结果为方块牌，你令此【杀】的使用者代替你成为此【杀】的目标，否则你获得此判定牌；你成为一张多目标锦囊牌的目标时，你可以为此锦囊牌重新指定结算顺序并摸一张牌。
	备注：多目标锦囊牌，指GlobalEffect类的【桃园结义】和【五谷丰登】、AOE类的【南蛮入侵】和【万箭齐发】，以及【铁索连环】。
]]--
--source:askForSkillInvoke("zzYiYun", data)
sgs.ai_skill_invoke["zzYiYun"] = true
--room:askForUseCard(source, "@@zzYiYun", prompt)
sgs.ai_skill_use["@@zzYiYun"] = function(self, prompt, method)
	local data = self.room:getTag("zzYiYunData")
	local use = data:toCardUse()
	local trick = use.card
	local trickname = self.player:property("zzYiYunTrick"):toString()
	if trickname == "" or not trick then
		return "."
	end
	local friends, unknowns, enemies = {}, {}, {}
	local alives = self.room:getAlivePlayers()
	for _,p in sgs.qlist(alives) do
		if p:hasFlag("zzYiYunTrickTarget") then
			if self:isFriend(p) then
				table.insert(friends, p)
			elseif self:isEnemy(p) then
				table.insert(enemies, p)
			else
				table.insert(unknowns, p)
			end
		end
	end
	local targets = {}
	if trick:isKindOf("AOE") or trick:isKindOf("IronChain") then
		if #enemies > 0 then
			self:sort(enemies, "defense")
			for _,enemy in ipairs(enemies) do
				table.insert(targets, enemy:objectName())
			end
		end
		if #unknowns > 0 then
			self:sort(unknowns, "threat")
			for _,p in ipairs(unknowns) do
				table.insert(targets, p:objectName())
			end
		end
		if #friends > 0 then
			self:sort(friends, "defense")
			friends = sgs.reverse(friends)
			for _,friend in ipairs(friends) do
				table.insert(targets, friend:objectName())
			end
		end
	elseif trick:isKindOf("GlobalEffect") then
		if #friends > 0 then
			self:sort(friends, "defense")
			for _,friend in ipairs(friends) do
				table.insert(targets, friend:objectName())
			end
		end
		if #unknowns > 0 then
			self:sort(unknowns, "threat")
			unknowns = sgs.reverse(unknowns)
			for _,p in ipairs(unknowns) do
				table.insert(targets, p:objectName())
			end
		end
		if #enemies > 0 then
			self:sort(enemies, "defense")
			enemies = sgs.reverse(enemies)
			for _,enemy in ipairs(enemies) do
				table.insert(targets, enemy:objectName())
			end
		end
	else
		for _,p in sgs.qlist(use.to) do
			table.insert(targets, p:objectName())
		end
	end
	if #targets == 0 then
		return "."
	end
	local card_str = "#zzYiYunCard:.:->"..table.concat(targets, "+")
	return card_str
end
--相关信息
function yiyun_filter(self, player, use)
	local card = use.card
	if card and card:objectName() == "zzYiYunCard" then
		local data = self.room:getTag("zzYiYunData")
		local useTrick = data:toCardUse()
		if useTrick then
			local trick = useTrick.card
			if trick then
				local targets = use.to
				if trick:isKindOf("AOE") then
					local target = targets:first()
					sgs.updateIntention(player, target, 10)
				elseif trick:isKindOf("GlobalEffect") then
					local target = targets:first()
					if trick:isKindOf("AmazingGrace") then
						sgs.updateIntention(player, target, -50)
					end
				end
			end
		end
	end
end
table.insert(sgs.ai_choicemade_filter["cardUsed"], yiyun_filter)
--[[****************************************************************
	编号：CASTLE - 008
	武将：戍卫营
	称号：誓敌无畏
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：忠诚（锁定技）
	描述：你受到你攻击范围内的角色或你攻击范围内的角色受到你使用的红色牌造成的伤害时，你防止此伤害并选择一项：1、伤害来源回复等量的体力；2、伤害目标失去等量的体力。
]]--
--room:askForChoice(player, "zzZhongCheng", "recover+losehp", data)
--room:askForChoice(source, "zzZhongCheng", "recover+losehp", data)
sgs.ai_skill_choice["zzZhongCheng"] = function(self, choices, data)
	local damage = data:toDamage()
	local source = damage.from
	local victim = damage.to
	local count = damage.damage
	local amSource = source and source:objectName() == self.player:objectName()
	local amVictim = victim and victim:objectName() == self.player:objectName()
	if amVictim then
		if source then
			if not source:isWounded() then
				return "recover"
			elseif self:isFriend(source) then
				return "recover"
			end
		end
		if self.player:getHp() + self:getAllPeachNum() <= count then
			return "recover"
		elseif self.player:hasSkill("zhaxiang") then
			return "losehp"
		elseif getBestHp(self.player) >= self.player:getHp() + count then
			return "losehp"
		end
	end
	if amSource then
		if victim then
			if self:isFriend(victim) then
				return "recover"
			end
			if self:cantbeHurt(victim, self.player, count) then
				return "losehp"
			elseif self:hasSkills(sgs.masochism_skill, victim) then
				return "losehp"
			end
		end
		if self:isWeak() and self.player:isWounded() then
			return "recover"
		end
		if victim then
			if victim:getHp() <= count then
				return "losehp"
			elseif victim:hasSkill("zhaxiang") then
				return "recover"
			end
		end
	end
	return "losehp"
end
--[[
	技能：热血·MAX
	描述：一名角色受到伤害后，你可以失去1点体力，令该角色或伤害来源失去X点体力（X为你已损失的体力）。
]]--
--room:askForPlayerChosen(p, targets, "zzReXueMAX", "@zzReXueMAX", true, true)
sgs.ai_skill_playerchosen["zzReXueMAX"] = function(self, targets)
	local enemies = {}
	for _,p in sgs.qlist(targets) do
		if self:isEnemy(p) then
			table.insert(enemies, p) 
		end
	end
	if #enemies > 0 then
		local amWeak = false
		if self.player:getHp() + self:getAllPeachNum() <= 1 then
			amWeak = true
			local lord = getLord(self.player)
			if lord and self.player:objectName() == lord:objectName() then
				return nil
			elseif self.role == "renegade" then
				return nil
			end
		end
		local count = self.player:getLostHp() + 1
		self:sort(enemies, "threat")
		for _,enemy in ipairs(enemies) do
			if enemy:getHp() + self:getAllPeachNum(enemy) <= count then
				if enemy:isLord() and self.role == "renegade" and self.room:alivePlayerCount() > 2 then
				else
					return enemy
				end
			elseif not amWeak then
				return enemy
			end
		end
	end
end
--相关信息
sgs.ai_playerchosen_intention["zzReXueMAX"] = 200
--[[
	技能：热血
	描述：你攻击范围内的一名角色受到伤害后，若伤害来源存在且不为你，你可以弃置一张手牌，视为对伤害来源使用了一张火【杀】。 
]]--
--room:askForCard(p, ".", prompt, data, "zzReXue")
sgs.ai_skill_cardask["@zzReXue"] = function(self, data, pattern, target, target2, arg, arg2)
	if self.player:isKongcheng() then
		return "."
	elseif self:isFriend(target) then
		return "."
	end
	local slash = sgs.Sanguosha:cloneCard("fire_slash")
	if self:slashProhibit(slash, target, self.player) then
		return "."
	end
	local handcards = self.player:getHandcards()
	handcards = sgs.QList2Table(handcards)
	if self.player:getPhase() == sgs.Player_Play then
		self:sortByUseValue(handcards, true)
		local card = handcards[1]
		if self:getUseValue(card) <= self:getUseValue(slash) then
			return "$"..card:getEffectiveId()
		end
	else
		self:sortByKeepValue(handcards)
		local card = handcards[1]
		if self:getKeepValue(card) <= 4 then
			return "$"..card:getEffectiveId()
		end
	end
	return "."
end
--[[****************************************************************
	MAX版专用对策
]]--****************************************************************
--[[
	技能：“坚城·MAX”专用对策
	描述：你即将造成伤害时，若目标角色拥有技能“坚城·MAX”，你可以弃置1张手牌令此伤害视为体力流失。
	拥有者：光明台
]]--
--room:askForCard(player, ".", prompt, data, "zzAntiJianChengMAX")
sgs.ai_skill_cardask["@zzAntiJianChengMAX"] = function(self, data, pattern, target, target2, arg, arg2)
	if self.player:isKongcheng() then
		return "."
	elseif self:isFriend(target) then
		return "."
	end
end