* # of followers/# of channel views
* find by language
* mature streams
* tag streams
* follower of followers for streamers
* subset by teams
* find new videos of streamers

# Broadcast
## Meta
	broadcast_id = {broadcast, stream["_id"]}
	titles = {channel, ["4v1 4HP Clutch", "Minecon 2015 - Main Stream"]}

## Filters
	channel = {broadcast, "rockerboo"}
 	game = {broadcast, "Gunbound"} # stream"game"
  	started = {broadcast, "2011-03-19T15:42:22Z"} # stream"created_at"
	ended = {broadcast, Date.now}

# Stream
## Meta
	stream_id = {channel, "_id"}

## Metrics
	viewers = {stream, [{184729423947, 3283}, {184729423947, 3283}]} # "viewers"

## Filters
	language = {stream, "en"} # channel["broadcaster_language"]
	mature = {stream, true} # channel["mature"]
	fps = {stream, ceil "59.99995543"} # "average_fps"
	height = {stream, "720"} # "video_height"
 	game = {stream, "Gunbound"} # "game"
  	created_at = {stream, "2011-03-19T15:42:22Z"} # "created_at"

# Channel
## Meta
	channel_id = {channel, "_id"}
	name = {channel, "name"}
	display_name = {channel, "display_name"}
	status = {channel, "status"}
	url = {channel, "http://www.twitch.tv/test_channel"}

	# Images (url or nil)
	profile_banner = {channel, "http://static-cdn.jtvnw.net/jtv_user_pictures/test_channel-profile_banner-6936c61353e4aeed-480.png"}
	profile_banner_background_color = {channel, nil}
	video_banner = {channel, "http://static-cdn.jtvnw.net/jtv_user_pictures/test_channel-channel_offline_image-b314c834d210dc1a-640x360.png"}
	banner = {channel, "http://static-cdn.jtvnw.net/jtv_user_pictures/test_channel-channel_header_image-08dd874c17f39837-640x125.png"}
	logo = {channel, "http://static-cdn.jtvnw.net/jtv_user_pictures/test_channel-profile_image-94a42b3a13c31c02-300x300.jpeg"}

## Filters
	language = {channel, "en"} # "broadcaster_language"
	mature = {channel, true} # "mature"]
	fps = {channel, ceil "59.99995543"} # "average_fps"
	height = {channel, "720"} # "video_height"
 	game = {channel, "Gunbound"} # "game"
  	created_at = {channel, "2011-03-19T15:42:22Z"} # "created_at"
	partner = {channel, true} # "partner"

## Metrics
	followers = {channel, [{184729423947, 3283}, {184729423947, 3283}]}
	views = {channel, [{184729423947, 3283}, {184729423947, 3283}]}

## Teams
	team  = {channel, "N3RDFUSION"}

## Social
	follows = {channel, [user, user, ...]}

# Users
## Meta
	user_id = {user, "_id"}
	name = {user, "name"}
	display_name = {user, "display_name"}

## Filter
	# "2015-06-24T04:50:34-0500" |>
	# DateFormat.parse("{ISOz}")
	created_at = {user, "2011-03-19T15:42:22Z"}
	updated_at = {user,"2012-06-14T00:14:27Z"}

## Social
	following = {user, [channel, channel, ...]}

# Videos

## New
	Enum.each(videos, fn (video) ->
		if is_new?(video) do
			mongo_add("videos", video)
		end
	end)

	Enum.each(videos, fn (video) ->
		if is_updated?(video) do
			mongo_update("videos", video["_id"],  video)
		end
	end)

# Emoticons
## New
