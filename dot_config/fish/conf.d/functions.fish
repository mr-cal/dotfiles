function llm
    if test (count $argv) -ge 1
        set idx $argv[1]
    else
        set idx 1
    end
    set c "craft-llm-$idx"

    set env_args

    if string match -q "$HOME/dev*" "$PWD"
        if lxc exec "$c" -- test -d "$PWD" 2>/dev/null
            set env_args --env "CRAFT_CWD=$PWD"
        end
    end

    lxc exec --force-interactive $env_args "$c" -- su - "$USER"
end

function sb
    if test (count $argv) -ne 1
        echo "Usage: sb <brightness>"
        return 1
    end

    sudo ddcutil setvcp 10 $argv[1] --display 1; and sudo ddcutil setvcp 10 $argv[1] --display 2
end

function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
