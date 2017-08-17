--
-- Will create and seed one torrent file for each file or folder at the root of moviesPath
--


--
-- Options and parameters
--

moviesPath = '/movies'
torrentPath = '/torrents'
trackers = ' -t udp://tracker.coppersurfer.tk:6969 -t udp://tracker.leechers-paradise.org:6969 '
TRip = 'localhost:9091'

-- Function scandir from http://www.wellho.net/resources/ex.php4?item=u112/dlisting
function scandir(dirname)
        callit = os.tmpname()
        os.execute("ls -B1 ".. dirname .. " >"..callit)
        f = io.open(callit,"r")
        rv = f:read("*all")
        f:close()
        os.remove(callit)

        tabby = {}
        local from  = 1
        local delim_from, delim_to = string.find( rv, "\n", from  )
        while delim_from do
                table.insert( tabby, string.sub( rv, from , delim_from-1 ) )
                from  = delim_to + 1
                delim_from, delim_to = string.find( rv, "\n", from  )
                end
        -- table.insert( tabby, string.sub( rv, from  ) )
        -- Comment out eliminates blank line on end!
        return tabby
end

function os.capture(cmd, raw)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

function fileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

-- Input : only the folder name, not the whole path
function isAValidFolder(movieName)
   if movieName == nil or movieName == 'lost+found' or movieName == '.' or movieName == '..' then
      return false
   end
   if string.sub(movieName, 1, 1) == '.' then
      return false
   end
   
   return true
end

function torrentAlreadyExists(folder)
    return os.capture('transmission-remote ' .. TRip .. ' -l | grep ' .. "'" .. folder .. "' | wc -l") == '1'
end

--
-- Main
--

moviesList = scandir(moviesPath)
if moviesList == nil then
    print('ERROR: moviesPath is incorrect or empty')
    os.exit()
end

os.execute('sleep 15') --Leave some time for transmission to get up and running

for i, folder in pairs(moviesList) do
   if isAValidFolder(folder) and not torrentAlreadyExists(folder) then
      print('Creating .torrent file for : ' .. folder)
      os.execute('transmission-create ' .. trackers .. "'" .. moviesPath .. '/' .. folder .. "'")
      os.execute('transmission-remote ' .. TRip .. ' -a ' .. "'" .. folder .. "'" .. '.torrent')
   end
end
