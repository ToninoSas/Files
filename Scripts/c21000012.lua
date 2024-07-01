--Puntata vincente
local s, id = GetID()

function c21000012.initial_effect(c)
	-- Activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN + CATEGORY_DAMAGE + CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c21000012.condition)
	e1:SetTarget(c21000012.target)
	e1:SetOperation(c21000012.operation)
	c:RegisterEffect(e1)
end

function c21000012.condition(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetAttacker() and Duel.GetAttacker():IsControler(1 - tp)
end

function c21000012.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
	Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, tp, 0)
	Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 0)
end

function c21000012.operation(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	-- Flip a coin
	local coin = math.random(1, 2)  -- 1 = heads, 2 = tails
	
	if coin == 1 then
		-- Cancel the attack and inflict damage equal to the ATK of the attacking monster
		local attacker = Duel.GetAttacker()
		if attacker:IsRelateToBattle() and attacker:IsControler(1 - tp) then
			local damage = attacker:GetAttack()
			if damage < 0 then damage = 0 end  -- Ensure damage is not negative
			Duel.NegateAttack()
			Duel.Damage(1 - tp, damage, REASON_EFFECT)
		end
	else
		-- Opponent gains 1000 LP
		Duel.Recover(1 - tp, 1000, REASON_EFFECT)
	end
end

