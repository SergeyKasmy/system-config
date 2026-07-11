---@param name string
---@param entry RuleEntry
return function(name, entry)
  if entry.rules then
    local spec = { name = name }
    if entry.class then
      spec.match = { class = entry.class }
    end
    for k, v in pairs(entry.rules) do
      spec[k] = v
    end
    hl.window_rule(spec)
  end

  if entry.on then
    for event, callback in pairs(entry.on) do
      ---@cast event HL.EventName
      ---@cast callback fun(...)
      if entry.class then
        local class = entry.class
        hl.on(event, function(window)
          if window and window.class and window.class:match(class) then
            callback(window)
          end
        end)
      else
        hl.on(event, callback)
      end
    end
  end
end
