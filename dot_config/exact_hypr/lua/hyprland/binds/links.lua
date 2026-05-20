---@return { url: string, description: string }
local function website(url, description)
  return {
    url = url,
    description = description,
  }
end

return {
  anime = website("https://anilist.co/home", "Anilist"),
  search = website("https://bing.com/", "Bing"),
  email = website("https://mail.google.com/", "Gmail"),
  photos = website("https://photos.google.com/", "Google Photos"),
  maps = website("https://maps.google.com/", "Google Maps"),
  steam = website("https://steamcommunity.com/my/profile", "Steam"),
  youtube = website("https://youtube.com", "Youtube"),
}
