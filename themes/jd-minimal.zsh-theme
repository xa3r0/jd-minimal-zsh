# jd-minimal - username::host | path >>
# Success => green arrow; Failure => red arrow

# Respect user customizations via env vars. Provide safe defaults.
: "${JD_SYMBOL:=>>}"           # e.g., >> or ❯❯
: "${JD_PATH_MODE:=short}"     # short => %~ , full => %d
: "${JD_COLORS_USER:=cyan}"
: "${JD_COLORS_HOST:=yellow}"
: "${JD_COLORS_PATH:=green}"

precmd() {
  local last=$?
  local arrow="$JD_SYMBOL"
  local arrow_colored="%F{green}${arrow}%f"
  if [ $last -ne 0 ]; then
    arrow_colored="%F{red}${arrow}%f"
  fi

  # Choose the path formatter inside the function (local only valid here)
  local jd_path
  if [[ "$JD_PATH_MODE" = "full" ]]; then
    jd_path='%d'   # full path
  else
    jd_path='%~'   # ~-shortened path
  fi

  # Compose prompt
  PROMPT="%F{$JD_COLORS_USER}%n%f::%F{$JD_COLORS_HOST}%m%f | %F{$JD_COLORS_PATH}${jd_path}%f ${arrow_colored} "
  RPROMPT=''
}
