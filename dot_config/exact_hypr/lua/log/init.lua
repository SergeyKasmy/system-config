local function get_target_dir()
  local xdg_cache_home = os.getenv("XDG_CACHE_HOME")

  local cache_dir
  if xdg_cache_home ~= nil then
    cache_dir = xdg_cache_home
  else
    local home = os.getenv("HOME")
    if home == nil then
      error("Neither XDG_CACHE_HOME nor HOME environment variables are set.")
    end

    cache_dir = home .. "/.cache"
  end

  return cache_dir .. "/hyprland"
end

return function()
  local target_dir = get_target_dir()

  os.execute(string.format('mkdir -p "%s"', target_dir))

  local log_path = target_dir .. "/lua.log"
  local file, err = io.open(log_path, "a+")

  if not file then
    error("Couldn't open log file: " .. err)
  end

  file:setvbuf("line")

  return file
end
