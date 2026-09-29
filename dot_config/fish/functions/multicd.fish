function multicd --description 'Expand .. / ... / .... into repeated ../'
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
