local colors = require('colors')
local settings = require('settings')

-- Equivalent to the --bar domain
sbar.bar({
  height = settings.bar_height,
  color = colors.black,
  padding_right = 2,
  padding_left = 2,
})
