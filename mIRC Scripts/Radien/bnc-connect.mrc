; type /bnc TornadoIRC to connect to first in the list
alias bnc {
  if ($1- == TornadoIRC) { server -m irc.example.com:8890 user:pass }
  if ($1- == FireFlyIRC) { server -m irc.example.com:8890 user:pass }
  if ($1- == GeekShed) { server -m irc.example.com:8890 user:pass }
  if ($1- == AllredNC) { server -m irc.example.com:8890 user:pass }
}

