--Aurora, la guerriera S.A.F.
local s,id,o=GetID()
function c21000008.initial_effect(c)
	--cannot direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--atk update
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c21000008.val)
	c:RegisterEffect(e3)
	
	-- extra atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	--a predefined function in the scripting framework 
	--used to check if a monster has destroyed another monster by battle.
	e4:SetCondition(aux.bdcon)
	e4:SetOperation(s.atop)
	e4:SetCountLimit(1)
	c:RegisterEffect(e4)

end

function c21000008.saf_filter(c)
	return c:IsSetCard(0x81c) -- Replace SET_CODE_ARCHETYPE with your specific archetype code
end

function c21000008.val(e,c)
	return Duel.GetMatchingGroupCount(c21000008.saf_filter,c:GetControler(),LOCATION_GRAVE,0,nil)*100
end

function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--isRelateToBattle -> verifica che il mostro sia ancora sul campo
	if c:IsRelateToBattle() then
		-- Allow the second attack
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end

