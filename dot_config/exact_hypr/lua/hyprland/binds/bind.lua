---@alias ModKeys string|string[]|nil
---@alias Keys string|string[]
---@alias Dispatcher function|HL.Dispatcher

---@param mods ModKeys # Mod keys - both have to be pressed
---@param keys Keys # Actual keys - either of them has to be pressed
---@param dispatcher Dispatcher
---@param opts? HL.BindOptions
return function(mods, keys, dispatcher, opts)
  local mods_string
  if type(mods) == "table" then mods_string = table.concat(mods, " + ") else mods_string = mods end

  local keys_table
  if type(keys) == "string" then keys_table = { keys } else keys_table = keys end


  for _, key in ipairs(keys_table) do
    local parts = {}
    if mods_string ~= nil then table.insert(parts, mods_string) end
    table.insert(parts, key)

    local full_key_string = table.concat(parts, " + ")

    Log("Binding " .. full_key_string)

    hl.bind(full_key_string, dispatcher, opts)
  end
end
