function bak
	set name (basename $argv[1])
	mv $name $name.bak
end

function unbak
	set name (basename $argv[1])
	mv $name.bak $name
end
