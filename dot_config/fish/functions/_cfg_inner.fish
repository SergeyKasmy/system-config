# takes managed dir path
function _cfg_inner
    set managed_dir $argv[1]
    set source_dir (chezmoi source-path $managed_dir)

    cd $source_dir
    ZELLIJ_RUN_CMD="chezmoi edit --apply --watch $managed_dir" zellij -l dev
    chezmoi apply -v $managed_dir
end
