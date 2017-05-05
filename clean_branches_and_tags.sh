#!/bin/bash

if [ "$1" == "" ]; then
    (>&2 echo "Missing parameter")
    (>&2 echo "Usage: "$0" [list|clean]")
    exit 1
fi

REMOTE=${2:-origin}

git remote show | grep -e "^"$REMOTE"$" > /dev/null
if [ $? -eq 1 ]; then
    echo "Remote '"$REMOTE"' does not exist."
    exit 1
fi

if [ "$1" == "list" ]; then
    git remote prune $REMOTE
    git fetch -p -t $REMOTE
    LIST_FILE=$(echo $0 | sed "s/\.sh$//")
    git branch -a | grep -e "remotes\/$REMOTE" | sed "s/^\s*remotes\/$REMOTE\///" | grep -v -e "^HEAD" \
        > ${LIST_FILE}.branches.lst
    git ls-remote --tags $REMOTE | sed "s/.*refs\/tags\///" | grep -v -e "}$" \
        > ${LIST_FILE}.tags.lst
    exit 0
fi

if [ "$1" == "clean" ]; then
    git remote prune $REMOTE
    git fetch -p -t $REMOTE
    CLEAN_FILE=$(echo $0 | sed "s/\.sh$/.clean/")
    if [ -e ${CLEAN_FILE}.tags.lst ]; then
        echo "Cleaning Tags ..."
        for tag in `cat ${CLEAN_FILE}.tags.lst`; do
            echo 'tag to delete '$tag
            git push --delete $REMOTE $tag
            git tag -d $tag
        done
        rm ${CLEAN_FILE}.tags.lst
    fi
    if [ -e ${CLEAN_FILE}.branches.lst ]; then
        echo "Cleaning Branches ..."
        for branch in `cat ${CLEAN_FILE}.branches.lst`; do
            echo 'branch to delete '$branch
            git push --delete $REMOTE $branch
            git branch -d $branch
        done
        rm ${CLEAN_FILE}.branches.lst
    fi
    exit 0
fi

(>&2 echo "Unknown parameter")
(>&2 echo "Usage: "$0" [list|clean]")
exit 1
