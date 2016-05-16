# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

mqtt = require "mqtt"
_ = require "underscore"

log = () ->
  console.log arguments

module.exports = (robot) ->
  client = mqtt.connect "mqtt://mqtt.espert.io"

  client.on "connect", () ->
    console.log "connected"
    client.subscribe "/CMMC/+/status"

  client.on "message", (topic, msg) ->
    json_msg = JSON.parse msg.toString()
    #    log "topic = ", topic, "msg = ", msg.toString()
    #console.log "ID = ", json_msg.info.id
    data = robot.brain.get("data") or {}
    data[json_msg.info.id] = json_msg
    #data[json_msg.d.myName] = json_msg
    robot.brain.set "data", data

  #log robot.brain.get "data"


  robot.hear /เป็นไงมั่ง/i, (res) ->
    res.send "ร้อน ร้อน ร้อน! = ", robot.brain.get "TMP"

  robot.respond /open the (.*) doors/i, (res) ->
    doorType = res.match[1]
    if doorType is "pod bay"
      res.reply "I'm afraid I can't let you do that."
    else
      res.reply "Opening #{doorType} doors"

  robot.hear /^\?devices/i, (res) ->
    devices = robot.brain.get "data"
    log Object.keys(devices)

    str = "\n"
    _.each devices, (v, k) ->
      str += "#{k} => #{v.d.myName} \n"

    res.reply str

  robot.hear /^\?device (\d*)$/i, (res) ->
    console.log 57
    console.log res.match
    id = res.match[1]
    devices = robot.brain.get "data"
    device = devices[id]
    res.reply JSON.stringify device

  robot.hear /^\?device (\d*) (.+)*$/i, (res) ->
    console.log res.match
    id = res.match[1]
    devices = robot.brain.get "data"
    device = devices[id]

    exploded = res.match[2].split "."
    console.log "exploded = ", exploded

    subscript = ""
    _.each exploded, (v, k) ->
      subscript += "['#{v}']"
    estr = "out = device#{subscript}"
    console.log estr

    try
      eval estr
    catch e
      console.log "eval error", e
      res.reply e.toString()
      return

    res.reply "#{res.match[2]} = #{JSON.stringify out, null, 4}"

  robot.hear /^([-+])?(\d*)$/i, (res) ->
    user_name = "@" + res.message.user.name or ""
    signed = res.match[1]
    if signed == "+"
      str = (res.match[2] + " registered to " + user_name)
      # topic = "ESPert/"+ res.match[2].toString() +"/Status"
      topic = "ESPert/" + res.match[2] + "/Status"
      log "topic = ", topic
      client.subscribe topic
    else
      str = (res.match[2] + " removed from " + user_name)
    res.reply str
    return

# robot.enter (res) ->
#   console.log res
#   res.send "HI there "


# robot.hear /I like pie/i, (res) ->
#   res.emote "makes a freshly baked pie"
#
# lulz = ['lol', 'rofl', 'lmao']
#
# robot.respond /lulz/i, (res) ->
#   res.send res.random lulz
#
# robot.topic (res) ->
#   res.send "#{res.message.text}? That's a Paddlin'"
#
#
# enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
# leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
#
# robot.enter (res) ->
#   res.send res.random enterReplies
# robot.leave (res) ->
#   res.send res.random leaveReplies
#
# answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
#
# robot.respond /what is the answer to the ultimate question of life/, (res) ->
#   unless answer?
#     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
#     return
#   res.send "#{answer}, but what is the question?"
#
# robot.respond /you are a little slow/, (res) ->
#   setTimeout () ->
#     res.send "Who you calling 'slow'?"
#   , 60 * 1000
#
# annoyIntervalId = null
#
# robot.respond /annoy me/, (res) ->
#   if annoyIntervalId
#     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
#     return
#
#   res.send "Hey, want to hear the most annoying sound in the world?"
#   annoyIntervalId = setInterval () ->
#     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
#   , 1000
#
# robot.respond /unannoy me/, (res) ->
#   if annoyIntervalId
#     res.send "GUYS, GUYS, GUYS!"
#     clearInterval(annoyIntervalId)
#     annoyIntervalId = null
#   else
#     res.send "Not annoying you right now, am I?"
#
#
# robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
#   room   = req.params.room
#   data   = JSON.parse req.body.payload
#   secret = data.secret
#
#   robot.messageRoom room, "I have a secret: #{secret}"
#
#   res.send 'OK'
#
# robot.error (err, res) ->
#   robot.logger.error "DOES NOT COMPUTE"
#
#   if res?
#     res.reply "DOES NOT COMPUTE"
#
# robot.respond /have a soda/i, (res) ->
#   # Get number of sodas had (coerced to a number).
#   sodasHad = robot.brain.get('totalSodas') * 1 or 0
#
#   if sodasHad > 4
#     res.reply "I'm too fizzy.."
#
#   else
#     res.reply 'Sure!'
#
#     robot.brain.set 'totalSodas', sodasHad+1
#
# robot.respond /sleep it off/i, (res) ->
#   robot.brain.set 'totalSodas', 0
#   res.reply 'zzzzz'
