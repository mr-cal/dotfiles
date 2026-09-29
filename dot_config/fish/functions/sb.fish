function sb --description 'Set the brightness of both external monitors'
    if test (count $argv) -ne 1
        echo "Usage: sb <brightness>" >&2
        return 1
    end

    if not command -q ddcutil
        echo "sb: ddcutil is not installed" >&2
        return 1
    end

    sudo ddcutil setvcp 10 $argv[1] --display 1
    and sudo ddcutil setvcp 10 $argv[1] --display 2
end
