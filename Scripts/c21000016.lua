-- Concessione S.A.F.
local s,id=GetID()
function s.initial_effect(c)
    -- Attach
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATTACH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    -- e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.attach_target)
    -- e1:SetCondition(s.attach_con)
    e1:SetOperation(s.attach_operation)
    c:RegisterEffect(e1)
    -- Negate monster effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_CHAINING)
    -- e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

function s.filter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x81c)
end

function s.attach_filter(c, e)
    return c:IsCanBeEffectTarget(e) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end

-- function s.attach_con(c, e)
--     return (Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
--             and Duel.IsExistingTarget(s.attach_filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,c, e))
-- end

function s.attach_target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    -- if chkc then return false end
    if chk==0 then
        return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingTarget(s.attach_filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,e)
    end
    -- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    -- local xyz=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
    
    -- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    -- local material=Duel.SelectTarget(tp,s.attach_filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,xyz:GetFirst(),e)

    -- e:SetLabelObject(xyz:GetFirst())

    -- Duel.SetTargetCard(material)
end

function s.attach_operation(e,tp,eg,ep,ev,re,r,rp)
    -- local xyz=Duel.GetFirstTarget()
    -- local material=e:GetLabelObject()
    -- -- if not material:IsType(TYPE_XYZ) then xyz,material=material,xyz end
    -- if material:IsRelateToEffect(e) and xyz:IsRelateToEffect(e) and xyz:IsFaceup() and material:IsCanOverlay() then
    --     -- Duel.Overlay(xyz,material)
    --     -- Duel.Overlay(material,xyz)
    -- end

    if not (Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingTarget(s.attach_filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,e)) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local xyz=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local material=Duel.SelectTarget(tp,s.attach_filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,xyz:GetFirst(),e)

    Duel.Overlay(xyz:GetFirst(),material:GetFirst())
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        rc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        rc:RegisterEffect(e2)
    end
end
