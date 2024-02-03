local mp = require 'mp'
local home = os.getenv('HOME')

mp.set_property('video', 'no')
mp.command('set msg-level "all=no"')

-- '\27[?7l'  disable line wrapping
-- '\27[?25l' hide cursor
io.write('\27[?7l\27[?25l\27[2J')
io.flush()

function reset_term()
    -- '\27[?7h'  re-enable line wrapping
    -- '\27[?25h' unhide cursor
    -- '\27[2J'   clear screen
    -- '\27[1r'   move cursor to top
    io.write('\27[?7h\27[?25h\27[2J\27[1r')
    io.flush()
end

function get_term_size()
    -- use shell command 'stty' to determine terminal size
    LINES, COLUMNS = io.popen('stty size'):read('*n', '*n')
end

function get_ascii(read_ascii)
    if read_ascii:match('%.txt$') then
        return io.open(read_ascii, 'r'):read('*all')
    end
end

function canvas()
    get_term_size()
    local metadata = mp.get_property_native('metadata')
    local plist_name = mp.get_property('path')
    local plist_pos = mp.get_property_number('playlist-pos-1')
    local plist_count = mp.get_property_number('playlist-count')
    local pause = mp.get_property_native('pause')
    local time_pos = mp.get_property_number('time-pos')
    local duration = mp.get_property_number('duration')
    if not time_pos or not duration then
        return
    end

    -- (canvas list): standard sort
    local indicator = pause and 'x' or '>'
    local timestamp = string.format('%02d:%02d / %02d:%02d',
                    math.floor(time_pos / 60), time_pos % 60,
                    math.floor(duration / 60), duration % 60)

    local blocks = {'▓', '▓', '░'}
    local colors = {'\27[31m', '\27[91m', '\27[37m'}
    local fill_width = math.floor(COLUMNS * (time_pos / duration))

    local pbar = ''
    for i = 1, COLUMNS do
        local bi = i <= fill_width and 2 or i == fill_width + 1 and 1 or 3
        pbar = pbar .. colors[bi] .. blocks[bi]
    end
    pbar = pbar .. '\27[0m'

    local plist_name = plist_name:match('.*/([^/]+)/[^/]+$') or ''
    local plist_name = '\27[31m' .. plist_name .. '\27[0m'
    local plist_counter =  string.format('%s [%d/%d]', plist_name, plist_pos, plist_count)
    local plist_padding = (' '):rep(COLUMNS - 6 - #plist_counter)

    -- (canvas list): miscellaneous section
    local title = metadata.title or 'Untitled'
    local artist = metadata.artist or 'Various Artists'

    local read_ascii = home .. '/.config/mpv/ascii_art.txt'
    local ascii_art = '\27[90m' .. (get_ascii(read_ascii) or '') .. '\27[0m'

    local tags = {
        -- '\27[30-37', '\27[90-97'   :fg
        -- '\27[40-47', '\27[100-107' :bg
        --              '\27[4m'      :ul
        '\27[4m\27[90m' .. '2005',
        '\27[4m\27[90m' .. 'cottonball',
        '\27[47m\27[30m' .. 'vienna'

    } tags = table.concat(tags, '\27[0m' .. ' ') .. '\27[0m'

    local canvas_list = {
        ascii_art, '\n\n',
        title, '\n',
        artist, '\n\n',
        indicator, ' ', timestamp,
        plist_padding, plist_counter, '\n\n',
        pbar, '\n\n',
	tags,

    } canvas_list = table.concat(canvas_list)

    -- '\27[s'   save cursor position
    -- '27[999H' move cursor to bottom
    -- '27[2J'   clear screen
    -- '27[u'    restore cursor position
    io.write('\27[s\27[999H\27[2J', canvas_list, '\27[u')
    io.flush()
end

function main()
    mp.observe_property('pause',    'bool',   canvas)
    mp.observe_property('duration', 'number', canvas)
    mp.observe_property('time-pos', 'number', canvas)
end

mp.register_event('file-loaded', main)
mp.register_event('shutdown', reset_term)
