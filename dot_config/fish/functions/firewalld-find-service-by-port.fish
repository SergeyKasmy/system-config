function firewalld-find-service-by-port
    rg --files-with-matches "port=\"$argv[1]\"" /usr/lib/firewalld/services/ /etc/firewalld/services/
end
