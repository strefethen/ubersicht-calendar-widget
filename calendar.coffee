#loosely based on https://github.com/cbeardsmore/Upcoming-iCal-Events/blob/master/Upcoming-iCal-Events.widget/main.coffee

# --------------- CUSTOMIZE ME ---------------
# these are dimensions of the widget in pixels
TOP = 58
LEFT = 24
BOTTOM = 2
WIDTH = 210

# how many pixels one-hour event occupies vertically
BLOCK_HEIGHT = 70
# --------------------------------------------

# Construct bash command using options.
# Refer to https://hasseg.org/icalBuddy/man.html
executablePath = "/usr/local/bin/icalBuddy "
baseCommand = ' eventsToday'
options = "-npn -nrd -nc -b '' -iep 'title,datetime' -ps '| : |' -po 'datetime,title' -tf '%H:%M' -df '%Y-%m-%d'"

command: executablePath + options + baseCommand

refreshFrequency: 60000

style: """
    top: #{TOP}px
    left: #{LEFT}px
    bottom: #{BOTTOM}px
    width: #{WIDTH}px
    color: black
    font-family: Helvetica
    background-color: #ffffff;
    border-width: 2px;
    border: solid;
    border-color: #555555;
    //opacity: 0.125
    z-index: -1

    div
        display: block
        color white
        font-size: 14px
        font-weight: 450
        text-align left
    #head
        font-weight: bold
        font-size 20px
    #subhead
        font-weight: bold
        font-size: 12px
        border-left: solid 4px
        border-radius: 2px
        border-color: #bbbbbb
        padding-top 6px
        padding-bottom 3px
        padding-left: 5px
        background-color: #eeeeee

        left: 50px
        width: #{WIDTH-67}px;
        color: #000000
    #line
        left: 37px;
        width: #{WIDTH-45}px;
        border: 1px solid #3e5ea3
    #hour-line
        left: 37px;
        width: #{WIDTH-45}px;
        border: 0.5px solid #bbbbbb

    #line-text
        font-size: 12px
        left: 5px
        color: #3e5ea3
        background-color: #ffffff

    #hour-text
        font-size: 12px
        left: 5px
        color: #bbbbbb

    #dot
        left: 48px;
        height: 8px;
        width: 8px;
        background-color: #3e5ea3;
        border-radius: 50%;
        display: inline-block;
"""

render: (output) -> """
"""

hours: (str) ->
    regex = /(\d+):(\d+)/
    result = regex.exec(str)
    return parseInt(result[1]) + parseInt(result[2])/60


update: (output, domEl) ->
    lines = output.split('\n')
    lines = lines.filter (line) -> line isnt ""

    bullet = lines[0][0]
    dom = $(domEl)
    dom.empty()

    today = new Date()
    current_time = today.getHours().toString().padStart(2, '0') + ":" + today.getMinutes().toString().padStart(2, '0')

    current_hour =  today.getHours() + today.getMinutes() / 60
    min_hour = current_hour

    line_regex = /^(\d+-\d+-\d+)?(?: at )?(\d+:\d+) - (\d+-\d+-\d+)?(?: at )?(\d+:\d+) : (.*)$/

    for line in lines
        start_time = line_regex.exec(line)[2]
        start_hour = @hours(start_time)
        min_hour = Math.min(min_hour, start_hour)

    min_hour = Math.floor(min_hour) - 0.5

    for line in lines
        result = line_regex.exec(line)
        start_date = result[1]
        start_time = result[2]
        end_date = result[3] or result[1]
        end_time = result[4]
        title = result[5]

        diff_hours = (@hours(end_time) - @hours(start_time))
        rel_start_hour = @hours(start_time) - min_hour

        start_pos = rel_start_hour * BLOCK_HEIGHT
        height = diff_hours * BLOCK_HEIGHT

        str = """<div id="subhead" style="position: absolute; top: #{start_pos+21}px; height: #{height-12}px;">
            #{title}
            </div> """

        dom.append(str)

    for hour in [Math.floor(min_hour+1)...25]
        rel_current_hour = hour - min_hour

        dom.append("""<hr id="hour-line" style="position: absolute; top: #{rel_current_hour * BLOCK_HEIGHT + 11}px;"></hr>""")
        dom.append("""<span id="hour-text" style="position: absolute; top: #{rel_current_hour * BLOCK_HEIGHT + 11 + 2}px;">#{hour}:00</span>""")

    rel_current_hour = current_hour - min_hour
    dom.append("""<hr id="line" style="position: absolute; top: #{rel_current_hour * BLOCK_HEIGHT + 11}px;"></hr>""")
    dom.append("""<span id="dot" style="position: absolute; top: #{rel_current_hour * BLOCK_HEIGHT + 11 + 5}px;"></span>""")
    dom.append("""<span id="line-text" style="position: absolute; top: #{rel_current_hour * BLOCK_HEIGHT + 11 + 2}px;">#{current_time}</span>""")
