#!/bin/bash
#set -exu
build_dir=build

_get_metadata() {
    # TODO: Multi-line field support
    local post=$1
    local post_file=posts/$post/$post.md

    # Current metadata fields: title, date, author and description
    local fields=':date:title:author:description:'
    local field value

    while read line; do
        # End of metadata block
        [[ "$line" == ... ]] && break

        field=${line%%:*}
        value=${line#* }
        [[ $fields == *:$field:*  ]] && eval "$field='$value'"
    done < $post_file

    # Here has an aditional entry, the second field.
    echo ":$date:$post:$title:$author:$description:"
}

_build_index() {
    local metadata=()
    local sorted_metadata
    local index_file=$(mktemp)

    for post in $(cd posts && echo *); do
        metadata+=( "$(_get_metadata $post)" )
    done

    mapfile sorted_metadata <<<"$(printf '%s\n' "${metadata[@]}" | sort -r)"
    for i in "${sorted_metadata[@]}"; do
        date=$(cut -d: -f2 <<<"$i")
        post=$(cut -d: -f3 <<<"$i")
        title=$(cut -d: -f4 <<<"$i")
        author=$(cut -d: -f5 <<<"$i")
        description=$(cut -d: -f6 <<<"$i")
        printf '# [%s](/posts/%s)\n%s - %s  \n%s\n\n' "$title"       \
                                                      "$post"        \
                                                      "$date"        \
                                                      "$author"      \
                                                      "$description" >> $index_file
    done

    pandoc $index_file \
           --output $build_dir/index.html \
           --metadata title=Posts \
           --defaults defaults.yaml

    rm $index_file
}

_build_posts() {
    local post_dir
    for post in $(cd posts && echo *); do
        post_dir=$build_dir/posts/$post
        mkdir -p $post_dir
        cp posts/$post/* $post_dir/

        pandoc $post_dir/$post.md \
               --output=$post_dir/index.html \
               --defaults defaults.yaml

        rm $post_dir/$post.md
    done
}

_main() {
    _build_index
    _build_posts
}

_main "$@"
