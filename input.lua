local inventory = { -- hello im a random comment
    items = {},
    maxSize = 10
}

function inventory:addItem(item)
    if #self.items >= self.maxSize then
        print("Inventory full! Cannot add more items.") -- ok
        return false
    end
    table.insert(self.items, item)
    print(item.name .. " was added to the inventory.")
    return true
end

function inventory:removeItem(itemName)
    for i, item in ipairs(self.items) do
        if item.name == itemName then
            table.remove(self.items, i)
            print(itemName .. " was removed from the inventory.")
            return true
        end
    end
    print(itemName .. " not found in the inventory.")
    return false
end

function inventory:useItem(itemName)
    for i, item in ipairs(self.items) do
        if item.name == itemName then
            if item.useEffect then
                item.useEffect()
            else
                print(itemName .. " has no use effect.") -- idc
            end
            return true
        end
    end
    print(itemName .. " not found in the inventory.")
    return false
end

local healthPotion = {
    name = "Health Potion",
    useEffect = function()
        print("You used a Health Potion and recovered 50 HP.")
    end
}

local manaPotion = {
    name = "Mana Potion",
    useEffect = function()
        print("You used a Mana Potion and recovered 30 MP.")
    end
}

local sword = {
    name = "Sword",
    useEffect = function()
        print("You equipped the Sword. Now you are stronger!")
    end
}

inventory:addItem(healthPotion) -- health
inventory:addItem(manaPotion) -- mana
inventory:addItem(sword) -- sword

inventory:useItem("Health Potion")
inventory:removeItem("Sword")
inventory:useItem("Sword")