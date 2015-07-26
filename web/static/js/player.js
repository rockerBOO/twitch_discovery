function Player() {}

Player.prototype.playerContainer = function (channel) {
  var container = document.createElement("iframe")
  container.setAttribute("id", "twitch_player")
  container.setAttribute("type", "text/html")
  container.setAttribute("src", "http://www.twitch.tv/" + channel + "/embed")
  container.setAttribute("frameborder", "0")

  return container;
}

Player.prototype.chatContainer = function (channel) {
  var container = document.createElement("iframe")
  container.setAttribute("id", "chat_embed")
  container.setAttribute("type", "text/html")
  container.setAttribute("src", "http://www.twitch.tv/" + channel + "/chat")
  container.setAttribute("frameborder", "0")
  container.setAttribute("scrolling", "no")

  return container;
}

Player.prototype.twitchPlayer = function (channel) {
  var container = this.playerContainer(channel)

  var player = document.getElementById("preview_video")

  player.appendChild(container)
}

Player.prototype.twitchChat = function (channel) {
  var container = this.chatContainer(channel)

  var chat = document.getElementById("preview_chat")

  chat.appendChild(container)
}

Player.prototype.twitchMeta = function (meta) {
  var container = document.createElement("div");

  container.innerHTML = "<h3><img src=\"/images/twitch.svg\" style=\"width: 24px; margin-top: -1px;\"> <a href=\"http://www.twitch.tv/" + meta.channel + "\">" + meta.display_name + "</a></h3>";

  document.getElementById("preview_title").innerHTML = "<a href=\"http://www.twitch.tv/" + meta.channel + "\">" + meta.title + "</a>"

  var followButton = document.getElementById("preview_follow_button")
  var metaNode = document.getElementById("channel_meta")

  followButton.setAttribute("onclick", "window.location = \"/follow/" + meta.channel + "\"")
  metaNode.appendChild(container)
}

Player.prototype.clearPreview = function() {
  document.getElementById("channel_meta").innerHTML = ""
  document.getElementById("preview_chat").innerHTML = ""
  var video = document.getElementById("preview_video")

  video.innerHTML = ""
  video.parentNode.parentNode.classList.add("preview_off")
}

module.exports = Player;
