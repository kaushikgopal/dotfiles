function tss --description 'formatted tailscale status'
    tailscale status | awk '{$1=$1}1' | column -t
end
