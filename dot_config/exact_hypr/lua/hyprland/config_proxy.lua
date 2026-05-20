local function make_config_proxy(path, depth)
  depth = depth or 0
  local proxy = {}
  setmetatable(proxy, {
    __newindex = function(_, key, value)
      local result = { [key] = value }
      for i = depth, 1, -1 do
        result = { [path[i]] = result }
      end
      hl.config(result)
    end,
    __index = function(_, key)
      local child_depth = depth + 1
      local child_path = {}
      for i = 1, depth do
        child_path[i] = path[i]
      end
      child_path[child_depth] = key
      return make_config_proxy(child_path, child_depth)
    end,
    __call = function(_)
      return hl.get_config(table.concat(path, ".", 1, depth))
    end,
  })
  return proxy
end

return function()
  return make_config_proxy({}, 0)
end
