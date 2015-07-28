function Player() {}

Player.prototype.playerContainer = function (channel) {
  var container = document.createElement("iframe")
  container.setAttribute("id", "twitch_player")
  container.setAttribute("type", "text/html")
  container.setAttribute("src", "http://www.twitch.tv/" + channel + "/embed")
  container.setAttribute("frameborder", "0")

  // var container = document.createElement("img")
  // container.setAttribute("src", "http://i.imgur.com/7wmmqX2.gif")

  return container;
}

Player.prototype.chatContainer = function (channel) {
  var container = document.createElement("iframe")
  container.setAttribute("id", "chat_embed")
  container.setAttribute("type", "text/html")
  container.setAttribute("src", "http://www.twitch.tv/" + channel + "/chat")
  container.setAttribute("frameborder", "0")
  container.setAttribute("scrolling", "no")

  // var container = document.createElement("img")
  // container.setAttribute("src", "http://i.imgur.com/7wmmqX2.gif")

  return container;
}

Player.prototype.twitchPlayer = function (channel) {
  document.getElementById("preview_video")
  .appendChild(this.playerContainer(channel))
}

Player.prototype.twitchChat = function (channel) {
  document.getElementById("preview_chat")
  .appendChild(this.chatContainer(channel))
}

Player.prototype.twitchMeta = function (meta) {
  console.log(meta)

  this.setChannelName(meta)
  this.setTitle(meta)
  this.setGame(meta)
  this.setFollowers(meta)
  this.setViewers(meta)
  this.setViews(meta)
  this.setMetaBackground(meta)
}

Player.prototype.setMetaBackground = function(meta) {
  document.getElementById("preview_meta_background_style")
  .innerHTML = "#preview_meta { "+
  "background-image: url('http://static-cdn.jtvnw.net/ttv-boxart/" + meta.game + "-272x380.jpg');" +
  " }";
}

Player.prototype.setTitle = function(meta) {
  var a = document.createElement("a")
  a.setAttribute("href", "http://www.twitch.tv/" + meta.channel)

  a.innerHTML = meta.title

  document.getElementById("preview_title")
  .appendChild(a)
}

Player.prototype.setChannelName = function(meta) {
  var a = this.channelLinkContainer(meta.channel)

  a.innerHTML = meta.display_name

  document.getElementById("preview_channel_name")
  .appendChild(a)
}

Player.prototype.setGame = function(meta) {
  var a = document.createElement("a")
  a.setAttribute("href", "/streams?game=" + meta.game)
  a.innerHTML = meta.game

  document.getElementById("preview_game")
  .appendChild(a)
}

Player.prototype.setPreviewFollower = function(channel) {
  document.getElementById("preview_follow_button")
  .setAttribute("onclick", "window.location = \"/follow/" + channel + "\"")
}

Player.prototype.setPreviewTitle = function(meta) {
  var a = this.channelLinkContainer(meta.channel)

  a.innerHTML = meta.title

  document.getElementById("preview_title")
  .appendChild(a)
}

Player.prototype.setFollowers = function(meta) {
  document.getElementById("preview_followers")
  .innerHTML = meta.followers
}

Player.prototype.setViewers = function(meta) {
  document.getElementById("preview_viewers")
  .innerHTML = meta.viewers
}

Player.prototype.setViews = function(meta) {
  document.getElementById("preview_views")
  .innerHTML = meta.views
}

Player.prototype.channelLinkContainer = function(channel) {
  var a = document.createElement("a")
  a.setAttribute("href", "http://www.twitch.tv/" + channel)

  return a
}

Player.prototype.reset_preview = function(reset_list) {
  reset_list.forEach(function (element) {
    document.getElementById(element)
    .innerHTML = ""
  })
}

Player.prototype.clearPreview = function() {
  var reset_list =
    ["preview_channel_name", "preview_game",
     "preview_title", "preview_chat"]
  this.reset_preview(reset_list)

  var video = document.getElementById("preview_video")

  video.innerHTML = ""
  video.parentNode.parentNode.classList.add("preview_off")
}

module.exports = Player;
