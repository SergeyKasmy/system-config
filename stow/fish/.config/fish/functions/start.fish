function start
	set -q argv
	and nohup $argv >/dev/null 2>&1 &; disown
end
