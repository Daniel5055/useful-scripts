#!/usr/bin/bash

# todo
# A command that will write, edit and show a todo list
# By default, I want this list to show upon logging in
# todo list is stored in home directory as .todo

# Syntax
# First argument is necessary and must be either add, list, edit, or delete

# Functions
usage ()
{
    case "$1" in
        add|help)
            echo "usage: $0 add <item>"
            ;;&
        edit|help)
            echo "       $0 edit <item_number> <item>"
            ;;&
        delete|help)
            echo "       $0 delete <item_number>"
            ;;&
        list|help)
            echo "       $0 list"
            ;;&
        help)
            echo "       $0 help"
            ;;
    esac
}

list ()
{
    # Print all except last line which contains meta data
    sed '$d' "$TODO_PATH"
}

# variable in script to be used by find item
line=0
find_item ()
{
    line=$(grep -n '^|| '"$1"')' "$TODO_PATH" | cut -d ":" -f 1)

    if [ -z  "$line" ]; then
        line=0
    fi
}

add ()
{
    if [ -n "$1" ]; then

        # If count zero then add first point, else add nth point dependent on count
        if [ "$count" -eq 0 ]; then
            sed -i '/||/a\|| 1) '"$1"'\n||' "$TODO_PATH"
        else
            find_item "$count"
            sed -i "$line"' a\||\n|| '$((count + 1))') '"$1" "$TODO_PATH"
        fi

        # Replace last line with new count
        sed -i '$d' "$TODO_PATH"
        echo $((count + 1)) >> "$TODO_PATH"

    else
        usage 'add'
        exit 1
    fi
}

edit ()
{
    if [ -n "$1" ] && [[ "$1" =~ ^[0-9]+$ ]] && [ -n "$2" ]; then
        find_item "$1"

        # If not found
        if [ "$line" -eq 0 ]; then
            echo "Item not found"
            exit 1
        else
            sed -i "$line"'c\|| '"$1"') '"$2" "$TODO_PATH"
        fi
    else
        usage 'edit'
        exit 1
    fi
}

delete ()
{
    # check that argument provided and is number
    if [ -n "$1" ] && [[ "$1" =~ ^[0-9]+$ ]]; then
        find_item "$1"

        # If not found
        if [ "$line" -eq 0 ]; then
            echo "Item not found"
            exit 1
        else
            sed -i "$line"','"$((line + 1 ))"'d' "$TODO_PATH"
        fi

        # And then renumber points :\
        next=$1
        for ((i=$1+1; i <= count; i++)); do
            find_item "$i"
            sed -i "$line"'s/'"$i"'/'"$next"'/' "$TODO_PATH"
            next=$((next + 1))
        done

        # Update count
        sed -i '$d' "$TODO_PATH"
        echo $((count - 1)) >> "$TODO_PATH"
    else
        usage 'delete'
        exit 1
    fi
}

# If the todo list does not exist
create()
{
    echo "Creating todo list"
    cat > "$TODO_PATH" << "EOF"

 _____         _         _     _     _
|_   _|       | |       | |   (_)   | |
  | | ___   __| | ___   | |    _ ___| |_
  | |/ _ \ / _` |/ _ \  | |   | / __| __|
  | | (_) | (_| | (_) | | |___| \__ \ |_
  \_/\___/ \__,_|\___/  \_____/_|___/\__|
==========================================>>
||
==========================================>>

0
EOF

}

TODO_PATH=~/.scripts/todo/todo_list
# First check if todo list doesn't exist
if [[ ! -f "$TODO_PATH" ]]; then
    create
fi

# Get total number of todo list items, which is the number at the bottom of the .todo file
count=$(tail -n 1 "$TODO_PATH")

# First check that enough arguments provided
if [ $# -ge 1 ];then
    case $1 in
        add)
            # Add item
            add "$2"
            list
            ;;
        edit)
            # Edit item
            edit "$2" "$3"
            list
            ;;
        delete)
            # Delete item
            delete "$2"
            list
            ;;
        list)
            # List items
            list
            ;;
        help|*)
            # Get Help
            usage 'help'
            ;;
    esac
fi
