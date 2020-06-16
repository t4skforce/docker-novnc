function getboolean() {
  case "${1,,}" in
    true) return 0 ;; # 0 = true
    t) return 0 ;; # 0 = true
    yes) return 0 ;; # 0 = true
    y) return 0 ;; # 0 = true
    1) return 0 ;; # 0 = true
    *) return 1 ;;
   esac
}

function homefolder() {
  if [ ! -d "$HOME/$1" ]; then
    mkdir -p "$HOME/$1" && \
    chown app:app -R "$HOME/$1"
  fi
}
