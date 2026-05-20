local bind = require("lua.hyprland.binds.bind")
local utils = require("lua.utils")
local log = require("lua.log")


---@param name string
---@param key [ModKeys, Keys]
---@param opts { reset_to?: string, catchall_reset: boolean? }
---@param contents fun(add_keybind_help: fun(key: string, description: string))
local function inner(name, key, opts, contents)
  log.trace("Binding", key, "to start submap", name)
  bind(key[1], key[2], hl.dsp.submap(name))

  local action = function()
    ---@type { key: string, description: string }[]
    local keybind_help = {}

    contents(function(keybind, description)
      table.insert(keybind_help, { key = keybind, description = description })
    end)

    if not utils.table.is_empty(keybind_help) then
      hl.on("keybinds.submap", function(submap_name)
        if submap_name ~= name then return end

        local one_row_max_count = 5

        local entries = {}
        local longest_left_entry = 0
        for _, help in ipairs(keybind_help) do
          table.insert(entries, { key = help.key, desc = help.description })
          local len = #help.key + 2 + #help.description
          if len > longest_left_entry then longest_left_entry = len end
        end

        local help_text = {}
        if #entries <= one_row_max_count then
          for _, item in ipairs(entries) do
            table.insert(help_text, string.format("%s  %s", item.key, item.desc))
          end
        else
          local half = math.ceil(#entries / 2)
          for i = 1, half do
            local left, right = entries[i], entries[i + half]
            local line = string.format("%s  %s", left.key, left.desc)
            if right then
              local left_len = #left.key + 2 + #left.desc
              line = line .. string.rep(" ", longest_left_entry - left_len + 2)
                  .. string.format("%s  %s", right.key, right.desc)
            end
            table.insert(help_text, line)
          end
        end

        local text = table.concat(help_text, "\n")

        log.trace("Full help text:\n" .. text)

        local prev_font_family = Config.misc.font_family()
        Config.misc.font_family = "mono"

        local notification = hl.notification.create({
          duration = 1000,
          text = text,
        })

        notification:pause()

        local sub
        sub = hl.on("keybinds.submap", function(new_submap)
          -- if this gets fired too early - dismiss
          if new_submap == name then return end
          notification:dismiss()

          Config.misc.font_family = prev_font_family

          sub:remove()
        end)
      end)
    end

    if opts.reset_to and opts.catchall_reset then
      hl.bind("catchall", hl.dsp.submap(opts.reset_to))
    end
  end

  if opts.reset_to == nil then
    log.trace("Defining submap " .. name .. ", non reseting")
    hl.define_submap(name, action)
  else
    log.trace("Defining submap " .. name .. ", reseting")
    hl.define_submap(name, opts.reset_to, action)
  end
end

---@param name string
---@param key [ModKeys, Keys]
---@param opts { reset_to?: string, catchall_reset: boolean? }
---@param contents fun(add_keybind_help: fun(key: string, description: string))
return function(name, key, opts, contents)
  log.spanned(string.format("submap[%s]", name), function() inner(name, key, opts, contents) end)
end
