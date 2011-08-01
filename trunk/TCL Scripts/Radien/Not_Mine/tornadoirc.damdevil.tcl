###########################################################
## Topic.tcl By Danneh/GrimReaper irc.geekshed.net #hell ##
###########################################################
#
# To get bot to work you need to dcc bot and type 
#                .chanset #channel +topicness
#
# Set up the topic command character to use with the script.
set topicchar "!"

# Defaults (RTB April 18, 2011)
set topics(topic) "#DamDevil"
set topics(website) "http://damdevil.org"
set topics(brandon) "alive"
set topics(sofm) "Song Of The Moment:"
set topics(song) "Josh Turner - Why Don't We Just Dance"
set topics(url1) "http://quotes.damdevil.org"
set topics(url2) "http://twitter.com/lordachmed"
set topics(other) "Good Luck is hard to come by"
set topics(sym1) "\00312°"
###########################################################
##                 End Setup.                            ##
###########################################################

## Command help ##

# !topic <New topic here> - Update the current topic for the channel.
# !song <Song Tittle here> - Update song the channel.
# !Brandon <Brandon's status here> - Update Brandon's status for the channel.
# !URL1 <Enter first URL here> - Update the first of two URL links.
# !URL2 <Enter second URL here> - Update the second of the two URL links.
# !other <Enter any other topic subject here> - Update the other section of the topic.

###########################################################
##                      Main Script.                     ##
###########################################################

setudef flag topicness

proc dumptopic {} {
    global topics
#    return "\0034$topics(topic) \00311/\0033 $topics(other) \00311/\0037 Our website is: $topics(website) \00311/\0039 topics(sofm) $topics(song) \00311/\00312 Brandon $topics(brandon) \00311/\00312 $topics(url1) \00311/\00312 $topics(url2)"    
    return "$topics(sym1) \0037$topics(topic) $topics(sym1) \00311$topics(other) $topics(sym1) \0038Our website: $topics(website) $topics(sym1) \0030$topics(sofm) \0034$topics(song) $topics(sym1) \00315Brandon is $topics(brandon) $topics(sym1) \0037$topics(url1) \00312: \0037$topics(url2) $topics(sym1)"
}

proc simonz {nick handle uhost chan text} {
  if {[lsearch -exact [channel info $chan] +topicness] != -1} {
    if {$text == ""} {
      putserv "PRIVMSG $chan :* \002Error:\002 Correct useage is !website <text here>"
      return 0
    } else {
      global topics
      set topics(website) "$text"
      putquick "TOPIC $chan :[dumptopic]"
    }
  }
}

proc topic {nick handle uhost chan text} {
  if {[lsearch -exact [channel info $chan] +topicness] != -1} {
    if {$text == ""} {
      putserv "PRIVMSG $chan :* \002Error:\002 Correct useage is !Topic <text here>"
      return 0
    } else {
      global topics
      set topics(topic) "$text"
      putquick "TOPIC $chan :[dumptopic]"
    }
  }
}

proc song {nick handle uhost chan text} {
  if {[lsearch -exact [channel info $chan] +topicness] != -1} {
    if {$text == ""} {
      putserv "PRIVMSG $chan :* \002Error:\002 Correct useage is !song <text here>"
      return 0
    } else {
      global topics
      set topics(song) "$text"
      putquick "TOPIC $chan :[dumptopic]"
    }
  }
}

proc other {nick handle uhost chan text} {
  if {[lsearch -exact [channel info $chan] +topicness] != -1} {
    if {$text == ""} {
      putserv "PRIVMSG $chan :* \002Error:\002 Correct useage is !Other <text here>"
      return 0
    } else {
      global topics
      set topics(other) "$text"
      putquick "TOPIC $chan :[dumptopic]"
    }
  }
}

proc brandon {nick handle uhost chan text} {
  if {[lsearch -exact [channel info $chan] +topicness] != -1} {
    if {$text == ""} {
      putserv "PRIVMSG $chan :* \002Error:\002 Correct useage is !Brandon <text here>"
      return 0
    } else {
      global topics
      set topics(brandon) "$text"
      putquick "TOPIC $chan :[dumptopic]"
    }
  }
}

proc url1 {nick handle uhost chan text} {
  if {[lsearch -exact [channel info $chan] +topicness] != -1} {
    if {$text == ""} {
      putserv "PRIVMSG $chan :* \002Error:\002 Correct useage is !URL1 <text here>"
      return 0
    } else {
      global topics
      set topics(url1) "$text"
      putquick "TOPIC $chan :[dumptopic]"
    }
  }
}

proc url2 {nick handle uhost chan text} {
  if {[lsearch -exact [channel info $chan] +topicness] != -1} {
    if {$text == ""} {
      putserv "PRIVMSG $chan :* \002Error:\002 Correct useage is !URL2 <text here>"
      return 0
    } else {
      global topics
      set topics(url2) "$text"
      putquick "TOPIC $chan :[dumptopic]"
    }
  }
}

bind pub n|n ${topicchar}settopic topic
bind pub n|n ${topicchar}website webs
bind pub n|n ${topicchar}song song
bind pub n|n ${topicchar}Other other
bind pub n|n ${topicchar}Brandon brandon
bind pub n|n ${topicchar}URL1 url1
bind pub n|n ${topicchar}URL2 url2

putlog "Topic script for #radien version 1.1 By Danneh (Helped out by SubWolf) Edited by Radien"
