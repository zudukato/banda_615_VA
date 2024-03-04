local brmAppMenu = {}
local brmUtilities = require("Reqs.brmUtilities")
local awtxConstants = require("Reqs.awtxReqConstants")
local supportAccess = false
brmAppMenu.topMenu = nil
brmAppMenu.historyIndex = {}

---Function to open a menu
---@param menuName string = name of the menu in MenusTree
---@param preIndex? number = index to start 
function brmAppMenu._openMenu(menuName, preIndex)
    if not menuName or not MenusTree[menuName] then return brmAppMenu._exitMenus() end
    preIndex = preIndex or 1
    brmAppMenu.topMenu = {}
    for _,option in ipairs(MenusTree[menuName]) do
        if not option.onlySupport or supportAccess then
            table.insert(brmAppMenu.topMenu, option)
        end
    end
    if brmAppMenu.topMenu[#brmAppMenu.topMenu].text:upper() ~= 'BACK' then
        brmAppMenu.topMenu[#brmAppMenu.topMenu+1] = {text = 'BACK'}
    end
    local text = brmUtilities.extractParam(brmAppMenu.topMenu, "text")
    local stringMenu = table.concat(text, "}")
    local index = tonumber(awtx.setupMenu.selectMenu(stringMenu,preIndex))
    table.insert(brmAppMenu.historyIndex, {name = menuName, index = index})
    brmAppMenu._evalOption(brmAppMenu.topMenu[index])
end

---Function to return to pre menu 
function brmAppMenu._backMenu()
    if brmAppMenu.historyIndex == {} then return brmAppMenu._exitMenus end
    local preMenu = table.remove(brmAppMenu.historyIndex,#brmAppMenu.historyIndex)
    if brmAppMenu.topMenu[preMenu.index].text:upper() == "BACK" then
        preMenu = table.remove(brmAppMenu.historyIndex,#brmAppMenu.historyIndex)
    end
    if not preMenu then return brmAppMenu._exitMenus() end
    return brmAppMenu._openMenu(preMenu.name, preMenu.index)
end

---Execute a function in menu
---@param func function
---@param ... any --params for the function 
function brmAppMenu._executeFunction(func, ...)
    if type(func) ~="function" then error("Func is not a function") end
    func(...)
    return brmAppMenu._backMenu()
end

---To select the action of the menu
---@param menu table
function brmAppMenu._evalOption(menu)
    menu.params = menu.params or {}
    menu.value = menu.value or menu.callThis
    menu.action= menu.text:upper() == "BACK" and "BACK" or menu.action
    local options = {
        MENU = brmAppMenu._openMenu,
        FUNC = brmAppMenu._executeFunction,
        BACK = brmAppMenu._backMenu
    }
    local selection = options[menu.action]
    if not selection then return brmAppMenu._exitMenus() end
    return selection(menu.value, unpack(menu.params))
end

---To exit of menu
function brmAppMenu._exitMenus()
    supportAccess = false
    brmAppMenu.topMenu = nil
    brmAppMenu.historyIndex = {}
    awtx.display.setMode(awtxConstants.display.MODE_SCALE)
    brmUtilities.doScroll("exit",1000)
end

function brmAppMenu.onPasswordEntered(password)
    supportAccess = false
    local menu = PersistentVars.shortCuts[password]
    if password == PersistentVars.supportPasswords then
        supportAccess = true
        brmUtilities.doScroll("Soporte",1000)
        menu ="topMenu"
    end
    if password == PersistentVars.userPassword then menu = "topMenu" end
    if not menu then return brmUtilities.doScroll("Cant",1000) end
    return brmAppMenu._openMenu(menu)
end

function brmAppMenu.onStart()
    awtx.os.registerPasswordEnteredEvent(brmAppMenu.onPasswordEntered)
end

brmAppMenu.onStart()