#
# mIRC style logging
# Created by Kenny of PSdNetworks
# http://kenny.psdnetworks.co.uk/
# http://www.psdnetworks.co.uk/
# kenny@psdnetworks.co.uk
#
# Very simple operation. Channels are logged as soon as the bot joins them. No addition of channels
# to extra files or configurations is required.
#
# Configuration options:
#
#   set mirc_path
#       ^ The directory to store the log files in. This is the relative path from the bot's ~/ or
#         an absolute path.
#
#   set mirc_stripsign
#       ^ Strip the first character from the channel name?
#         Set to "0" to keep the whole name
#         Set to "1" to strip the first character
#         Examples:
#           Stripping off: "#psdnetworks" would become "#psdnetworks.log"
#           Stripping on:  "#psdnetworks" would become "psdnetworks.log"
#
#   set mirc_ext
#       ^ This is the extension to give the filenames
#         Examples:
#           set mirc_ext ".chanlog" - #mychannel would be logged to #mychannel.chanlog
#           set mirc_ext ".log"     - #mychannel would be logged to #mychannel.log
#           set mirc_ext ".abc"     - #mychannel would be logged to #mychannel.abc
#
#
set mirc_path "/home/radien/eggdrop/logs/"
set mirc_stripsign "1"
set mirc_ext ".log"
#
#
# NOTE: Channels containing the "-" character will have "-" converted to "_"
#       Example: #my-channel would be logged to something like #my_channel.log
#
# -- END OF CONFIGURATION --
#
proc mirc_privmsg {nick host handle channel text} { mirc_log "PRIVMSG" $channel $nick $host "" "$text" }
proc mirc_join {nick host handle channel} { mirc_log "JOIN" $channel $nick $host "" "" }
proc mirc_quit {nick host handle channel reason} { mirc_log "QUIT" $channel $nick $host "" "$reason" }
proc mirc_topic {nick host handle channel topic} { mirc_log "TOPIC" $channel $nick $host "" "$topic" }
proc mirc_kick {nick host handle channel target reason} { mirc_log "KICK" $channel $nick $host $target "$reason" }
proc mirc_nick {nick host handle channel newnick} { mirc_log "NICK" $channel $nick $host "" "$newnick" }
proc mirc_mode {nick host handle channel change victim} { mirc_log "MODE" $channel $nick $host $victim "$change" }
proc mirc_part {nick host handle channel partmsg} { mirc_log "PART" $channel $nick $host "" "$partmsg" }
proc mirc_action {nick host handle channel keyword text} { mirc_log "ACTION" $channel $nick $host "" "$text" }
proc mirc_stamp {min hour day month year} {
  global mirc_path mirc_stripsign mirc_ext
  foreach channel [channels] {
    set chanfile $channel
    while {"[string match *-* $chanfile]" > "0"} { regsub "\\\-" $chanfile "_" chanfile }
    if {"$mirc_stripsign" == "0"} { set mirc_filename "[string tolower $chanfile]" } else { set mirc_filename "[string range [string tolower $chanfile] 1 end]" }
    set logID [open $mirc_path$mirc_filename$mirc_ext a]
    puts $logID "Session Time: [ctime [unixtime]]"
    close $logID
  }
}
proc mirc_log {event channel nick host target details} {
  global botnick mirc_path mirc_stripsign mirc_ext
  if {"$channel" != "$botnick"} {
    set chanfile $channel
    while {"[string match *-* $chanfile]" > "0"} { regsub "\\\-" $chanfile "_" chanfile }
    set mirc_line "\[[time]\]"
    if {"$mirc_stripsign" == "0"} { set mirc_filename "[string tolower $chanfile]" } else { set mirc_filename "[string range [string tolower $chanfile] 1 end]" }
    if {"$event" == "PRIVMSG"} { set mirc_line "$mirc_line \<$nick\> $details" }
    if {"$event" == "JOIN"} { if {"$botnick" == "$nick"} {
    if {![file exists $mirc_path$mirc_filename$mirc_ext]} {
        set logID [open $mirc_path$mirc_filename$mirc_ext w]
        putlog "Starting a new logfile for $channel"
        puts $logID "Session Start: [ctime [unixtime]]"
      } else {
        set logID [open $mirc_path$mirc_filename$mirc_ext a]
        putlog "Continuing logfile for $channel"
        puts $logID "Session Time: [ctime [unixtime]]"
      }
      puts $logID "\[[time]\] *** Now talking in $channel"
      set mirc_line ""
      close $logID
    } else { set mirc_line "$mirc_line *** $nick ($host) has joined $channel" } }
    if {"$event" == "QUIT"} { set mirc_line "$mirc_line *** $nick ($host) Quit ($details)" }
    if {"$event" == "TOPIC"} { if {"$nick" == "*"} { set mirc_line "$mirc_line *** Topic is '$details'" } else { set mirc_line "$mirc_line *** $nick changes topic to '$details'" } }
    if {"$event" == "KICK"} { if {"$target" == "$botnick"} { set mirc_line "$mirc_line *** You were kicked by $nick ($details)" } else { set mirc_line "$mirc_line *** $target was kicked by $nick ($details)" } }
    if {"$event" == "NICK"} { set mirc_line "$mirc_line *** $nick is now known as $details" }
    if {"$event" == "MODE"} { set mirc_line "$mirc_line *** $nick sets mode: $details $target" }
    if {"$event" == "PART"} { set mirc_line "$mirc_line *** $nick ($host) has left $channel" }
    if {"$event" == "ACTION"} { set mirc_line "$mirc_line * $nick $details" }
    if {![file exists $mirc_path$mirc_filename$mirc_ext]} {
      set logID [open $mirc_path$mirc_filename$mirc_ext w]
      puts $logID "Session Start: [ctime [unixtime]]"
      puts $logID "\[[time]\] *** Now talking in $channel"
    } else { set logID [open $mirc_path$mirc_filename$mirc_ext a] }
    if {"$mirc_line" != ""} { puts $logID "$mirc_line" }
    close $logID
  }
}
bind pubm - * mirc_privmsg
bind join - * mirc_join
bind sign - * mirc_quit
bind topc - * mirc_topic
bind kick - * mirc_kick
bind nick - * mirc_nick
bind mode - * mirc_mode
bind part - * mirc_part
bind ctcp - "ACTION" mirc_action
bind time - "00 00 * * *" mirc_stamp
bind time - "00 06 * * *" mirc_stamp
bind time - "00 12 * * *" mirc_stamp
bind time - "00 18 * * *" mirc_stamp
putlog "fuzzled: mIRC Logger"
