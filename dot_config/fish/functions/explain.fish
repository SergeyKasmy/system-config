function explain
        if [ (count $argv) -eq 0 ]
                read  -P "Command: " input
        else
                set input $argv
        end
        
        curl -Gs "https://www.mankier.com/api/explain/?cols=$COLUMNS" --data-urlencode "q=$input"
end
