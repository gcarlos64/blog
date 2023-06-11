#!/bin/bash
# ------------------------------------------------------------------------------
# Copyright (C) 2023  Carlos Eduardo Gallo Filho <gcarlos@disroot.org>
# License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.
# ------------------------------------------------------------------------------

build_dir=build

_get_metadata() {
    # TODO: Multi-line field support
    local post=$1
    local post_file=posts/$post/$post.md

    # Current metadata fields: title, date, and description
    local fields=':date:title:description:'
    local field value

    while read line; do
        # End of metadata block
        [[ "$line" == ... ]] && break

        field=${line%%:*}
        value=${line#* }
        [[ $fields == *:$field:* ]] && eval "$field='$value'"
    done < $post_file

    # Here has an aditional entry, the second field.
    echo ":$date:$post:$title:$description:"
}

_build_index() {
    local metadata=()
    local sorted_metadata
    local index_file=$(mktemp)

    for post in $(cd posts && echo *); do
        metadata+=( "$(_get_metadata $post)" )
    done

    mapfile sorted_metadata <<< "$(printf '%s\n' "${metadata[@]}" | sort -r)"
    for i in "${sorted_metadata[@]}"; do
        date=$(cut -d: -f2 <<< "$i")
        post=$(cut -d: -f3 <<< "$i")
        title=$(cut -d: -f4 <<< "$i")
        description=$(cut -d: -f5 <<< "$i")
        printf '# [%s](/posts/%s)\n*%s*  \n%s\n\n' "$title"       \
                                                   "$post"        \
                                                   "$date"        \
                                                   "$description" >> $index_file
    done

    pandoc $index_file                    \
           --output $build_dir/index.html \
           --defaults defaults.yaml

    rm $index_file
}

_build_posts() {
    local post_dir
    for post in $(cd posts && echo *); do
        post_dir=$build_dir/posts/$post
        mkdir -p $post_dir
        cp posts/$post/* $post_dir/

        pandoc $post_dir/$post.md            \
               --output=$post_dir/index.html \
               --defaults defaults.yaml

        rm $post_dir/$post.md
    done
}

_build_about() {
    pandoc site/about.md                  \
           --output=$build_dir/about.html \
           --defaults defaults.yaml
}

_main() {
    rm -rf $build_dir
    mkdir -p $build_dir/posts

    _build_index
    _build_posts
    _build_about
}

_main "$@"
