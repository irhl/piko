local mp = require 'mp'
local home = os.getenv("HOME")

mp.command('set msg-level "all=no"')
mp.set_property("video", "no")

-- "\27[?7l"  disable line wrapping
-- "\27[?25l" hide cursor
io.write("\27[?7l\27[?25l")
io.flush()

function reset_term()
    -- "\27[?7h"  re-enable line wrapping
    -- "\27[?25h" unhide cursor
    -- "\27[2J"   clear screen
    -- "\27[1r"   position cursor back to top
    io.write("\27[?7h\27[?25h\27[2J\27[1r")
    io.flush()
end

function get_term_size()
    local LINES, COLUMNS = io.popen("stty size"):read("*n", "*n")
    return LINES, COLUMNS
end

function get_ascii(read_ascii)
    if read_ascii:match("%.txt$") then
        local file = io.open(read_ascii, "r")
        if file then return file:read("*all") end
    end
    return nil
end

function timestamp(seconds)
    local minutes = math.floor(seconds / 60)
    local seconds = seconds % 60
    return string.format('%02d:%02d', minutes, seconds)
end

function canvas()
    -- get everything, we'll use them later
    local LINES, COLUMNS = get_term_size()
    local metadata = mp.get_property_native("metadata")
    local plist_pos = mp.get_property_number("playlist-pos-1")
    local plist_count = mp.get_property_number("playlist-count")
    local pause = mp.get_property_native('pause')
    local time_pos = mp.get_property_number("time-pos")
    local duration = mp.get_property_number("duration")
    if not (time_pos and duration) then
        return
    end

    -- sort collection of local variables based in the canvas list
    local read_ascii = home .. "/.config/mpv/ascii_art.txt"
    local ascii_art = "\27[90m" .. (get_ascii(read_ascii) or "") .. "\27[0m"
    local pause_icon = pause and 'x' or '>'

    local artist = "\27[31m" .. (metadata.artist or "") .. "\27[0m"
    local plist_counter = artist .. string.format(" [%d/%d]", plist_pos, plist_count)
    local plist_padding = (" "):rep(COLUMNS - 6 - #plist_counter)

    local blocks = {"▓", "▓", "░"}
    local colors = {"\27[31m", "\27[91m", "\27[37m"}
    local fill_width = math.floor(COLUMNS * (time_pos / duration))

    local pbar = ""
    for i = 1, COLUMNS do
        local bi = i <= fill_width and 2 or i == fill_width + 1 and 1 or 3
        pbar = pbar .. colors[bi] .. blocks[bi]
    end
    pbar = pbar .. "\27[0m"

    local tags = {
        -- "\27[30-37", "\27[90-97"   fg: 8, 16
	-- "\27[40-47", "\27[100-107" bg: 8, 16
        "\27[47m\27[30m" .. "2005",
        "\27[47m\27[30m" .. "cottonball",
        "\27[47m\27[30m" .. "vienna"

    } tags = table.concat(tags, "\27[0m" .. " ") .. "\27[0m"

    local canvas_list = {
        -- "\27[s"   save cursor position
        -- "27[999H" move cursor to bottom
        -- "27[2J"   clear screen
        -- "27[u"    restore cursor position
        "\27[s", "\27[999H", "\27[2J",

	ascii_art, "\n\n",
        metadata.title or "", "\n",
        metadata.album or "", "\n\n",

        pause_icon, " ", timestamp(time_pos), " / ", timestamp(duration),
        plist_padding, plist_counter, "\n\n",
        pbar, "\n\n",
	tags,

	"\27[u"

    } canvas_list = table.concat(canvas_list)

    io.write(canvas_list)
    io.flush()
end

function main()
    mp.observe_property("pause", "bool", canvas)
    mp.observe_property('duration', 'number', canvas)
    mp.observe_property('time-pos', 'number', canvas)
end

mp.register_event("file-loaded", main)
mp.register_event("shutdown", reset_term)
