-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
--  hs.alert.show("Hello World!")
-- end)

local hyper = {"ctrl", "alt", "cmd"}
local hyper_shift = {"ctrl", "alt", "cmd", "shift"}


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end)

-- Always paster!
hs.hotkey.bind(hyper, "v",
  function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
  end
)

hs.loadSpoon("SpoonInstall")


-- Clock {{{

local mod_aclock = spoon.SpoonInstall:andUse("AClock", {
  format = "%H",
  textFont = "Impact",
  textSize = 135,
  textColor = {hex="#1891C3"},
  width = 320,
  height = 230,
  showDuration = 10,  -- seconds
  hotkey = 'escape',
  hotkeyMods = {},
})

local function show_clock()
  -- hs.alert.show(os.date("%H:%M"))
  spoon.AClock:toggleShow()
end

hs.hotkey.bind(hyper, "C", show_clock)
-- hs.hotkey.bind(hyper, "R",
--   function()
--     hs.network.ping.ping("8.8.8.8", 1, 0.01, 1.0, "any", pingResult)
--   end
-- )

-- }}}


-- Wallpaper {{{

local function update_wallpaper()
  spoon.SpoonInstall:andUse("BingDaily", { })
  hs.alert.show("Wallpaper updated")
end

hs.hotkey.bind(hyper, "W", update_wallpaper)

-- }}}


-- WiFi {{{

local wifiMenu = hs.menubar.new()
function ssidChangedCallback()
    SSID = hs.wifi.currentNetwork()
    if SSID == nil then
        SSID = "Disconnected"
    end
    wifiMenu:setTitle("(" .. SSID .. ")" )
end
wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()
ssidChangedCallback()

-- }}}


-- Ping website {{{

function pingResult(object, message, seqnum, error)
    if message == "didFinish" then
        avg = tonumber(string.match(object:summary(), '/(%d+.%d+)/'))
        if avg == 0.0 then
            hs.alert.show("No network")
        elseif avg < 200.0 then
            hs.alert.show("Network good (" .. avg .. "ms)")
        elseif avg < 500.0 then
            hs.alert.show("Network poor(" .. avg .. "ms)")
        else
            hs.alert.show("Network bad(" .. avg .. "ms)")
        end
    end
end

hs.hotkey.bind(hyper, "p",
  function()
    hs.network.ping.ping("8.8.8.8", 1, 0.01, 1.0, "any", pingResult)
  end
)


-- }}}


-- Power supply {{{

function batteryChangedCallback()
    psuSerial = hs.battery.psuSerial()
    if psuSerial ~= 5848276 and psuSerial ~=0 and psuSerial ~= lastPsuSerial then
        hs.alert.show("That's not your power supply!")
    end
    lastPsuSerial = psuSerial
end
lastPsuSerial = 9999999
batteryWatcher = hs.battery.watcher.new(batteryChangedCallback)
batteryWatcher:start()

-- }}}


-- for Zoom {{{

micMuteStatusMenu = hs.menubar.new()
micMuteStatusLine = nil
function displayMicMuteStatus()
    local currentAudioInput = hs.audiodevice.current(true)
    local currentAudioInputObject = hs.audiodevice.findInputByUID(currentAudioInput.uid)
    muted = currentAudioInputObject:inputMuted()
    if muted then
        micMuteStatusMenu:setIcon(os.getenv("HOME") .. "/.hammerspoon/muted.png")
        micMuteStatusLineColor = {["red"]=1,["blue"]=1,["green"]=1,["alpha"]=0.0}
    else
        micMuteStatusMenu:setIcon(os.getenv("HOME") .. "/.hammerspoon/unmuted.png")
        micMuteStatusLineColor = {["red"]=1,["blue"]=0,["green"]=0,["alpha"]=0.5}
    end
    if micMuteStatusLine then
        micMuteStatusLine:delete()
    end
    max = hs.screen.primaryScreen():fullFrame()
    micMuteStatusLine = hs.drawing.rectangle(hs.geometry.rect(max.x, max.y, max.w, max.h))
    micMuteStatusLine:setStrokeColor(micMuteStatusLineColor)
    micMuteStatusLine:setFillColor(micMuteStatusLineColor)
    micMuteStatusLine:setFill(false)
    micMuteStatusLine:setStrokeWidth(20)
    micMuteStatusLine:show()
end
for i,dev in ipairs(hs.audiodevice.allInputDevices()) do
   dev:watcherCallback(displayMicMuteStatus):watcherStart()
end
function toggleMicMuteStatus()
    local currentAudioInput = hs.audiodevice.current(true)
    local currentAudioInputObject = hs.audiodevice.findInputByUID(currentAudioInput.uid)
    currentAudioInputObject:setInputMuted(not muted)
    displayMicMuteStatus()
end
displayMicMuteStatus()
hs.hotkey.bind(hyper, "m", toggleMicMuteStatus)
micMuteStatusMenu:setClickCallback(toggleMicMuteStatus)
function toggleMicMuteStatusAlert()
    if micMuteStatusAlert then
        micMuteStatusAlert = false
        micMuteStatusLine:delete()
    else
        micMuteStatusAlert = true
        displayMicMuteStatus()
    end
end

function clearScreen()
    if micMuteStatusLine then
        micMuteStatusLine:delete()
    end
end
hs.hotkey.bind(hyper_shift, "M", toggleMicMuteStatusAlert)

-- }}}


-- window management {{{
-- http://www.hammerspoon.org/docs/hs.window.layout.html

local function layoutWindows(layoutType)
  return function()
    if layoutType == 2 then
      windowLayoutObject = hs.window.layout.new({
        hs.window.filter.new(),
        "move 1 foc [50,0,100,100] 0,0 | move 1 foc [0,0,50,100] 0,0 | min"
      })
      hs.alert.show("Layout 2")
    end
    hs.window.layout.applyLayout(windowLayoutObject)
  end
end
hs.hotkey.bind(hyper, "2", layoutWindows(2))



-- }}}


-- Config reloader {{{

function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
-- hs.notify.new({
--   title="Hammerspoon",
--   informativeText="Configuration was reloaded"
-- }):send()

-- }}}


-- vim: fdm=marker
