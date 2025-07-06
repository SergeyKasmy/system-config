function explain
    if [ (count $argv) -eq 0 ]
        read -P "Command: " input
    else
        set input $argv
    end

    aichat -r '%explain-shell%' $input
end
