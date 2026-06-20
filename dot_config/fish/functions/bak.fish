function bak
	mv $argv[1] $argv[1].bak
end

function unbak
	mv $argv[1].bak $argv[1]
end
