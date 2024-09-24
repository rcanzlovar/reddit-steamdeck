# Reddit Reader

This is a simple client for reading Reddit from a Steam Deck or basically anything that can 
be compiled from Godot

Currently the list of subreddits is static and all that is displayed is the title and body of the 
posts in a particular subreddit. 

On the steamdeck
A and B button go betweem subreddits. 
DPAD-L or A go to prev article
DPAD-R or D go to next article
DPAD-U or W go down half screen
DPAD-D or S go up half screen

left shoulder pad turns a control panel with buttons on and off




location of logfiles from running this on ubuntu
/home/rca/.var/app/org.godotengine.Godot/data/godot/app_userdata/Reddit client/logs

Need to do:
- add/remove subreddits. Curently hard coded. 
- add save/load of profile. Profile needs:
* list of subreddits
* last save date
* cache of subreddit data for offline browsing
* save an article
* drill down to subthreads
## loading comments:
If you want to get the URL for the post, use the "url" element. If you add ".json" (remove the slash) 
you can get a json version of the comments and run through the whole thing again 
https://www.reddit.com/r/gamedev/comments/1fh2no4/warning_evidence_p1_games_run_by_samuel_martin/
https://www.reddit.com/r/gamedev/comments/1fh2no4/warning_evidence_p1_games_run_by_samuel_martin.json























Fields on reddit post
Currently only using "title" and "selftext" 


element: approved_at_utc
element: subreddit
element: selftext
element: author_fullname
element: saved
element: mod_reason_title
element: gilded
element: clicked
element: title
element: link_flair_richtext
element: subreddit_name_prefixed
element: hidden
element: pwls
element: link_flair_css_class
element: downs
element: thumbnail_height
element: top_awarded_type
element: hide_score
element: name
element: quarantine
element: link_flair_text_color
element: upvote_ratio
element: author_flair_background_color
element: subreddit_type
element: ups
element: total_awards_received
element: media_embed
element: thumbnail_width
element: author_flair_template_id
element: is_original_content
element: user_reports
element: secure_media
element: is_reddit_media_domain
element: is_meta
element: category
element: secure_media_embed
element: link_flair_text
element: can_mod_post
element: score
element: approved_by
element: is_created_from_ads_ui
element: author_premium
element: thumbnail
element: edited
element: author_flair_css_class
element: author_flair_richtext
element: gildings
element: post_hint
element: content_categories
element: is_self
element: mod_note
element: created
element: link_flair_type
element: wls
element: removed_by_category
element: banned_by
element: author_flair_type
element: domain
element: allow_live_comments
element: selftext_html
element: likes
element: suggested_sort
element: banned_at_utc
element: view_count
element: archived
element: no_follow
element: is_crosspostable
element: pinned
element: over_18
element: preview
element: all_awardings
element: awarders
element: media_only
element: can_gild
element: spoiler
element: locked
element: author_flair_text
element: treatment_tags
element: visited
element: removed_by
element: num_reports
element: distinguished
element: subreddit_id
element: author_is_blocked
element: mod_reason_by
element: removal_reason
element: link_flair_background_color
element: id
element: is_robot_indexable
element: report_reasons
element: author
element: discussion_type
element: num_comments
element: send_replies
element: whitelist_status
element: contest_mode
element: mod_reports
element: author_patreon_flair
element: author_flair_text_color
element: permalink
element: parent_whitelist_status
element: stickied
element: url
element: subreddit_subscribers
element: created_utc
element: num_crossposts
element: media
element: is_video
