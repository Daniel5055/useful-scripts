#!/usr/bin/bash

# todo
# A command that will write, edit and show a todo list
# By default, I want this list to show upon logging in
# todo list is stored in home directory as .todo

# Syntax
# First argument is necessary and must be either add, list, edit, or delete

# Command name
name="todo"
# Functions
usage ()
{
    case "$1" in
        add|help)
            echo "usage: $name add [-q] [-i insertline] \"<item>\""
            ;;&
        edit|help)
            echo "usage: $name edit [-q] <item_number> \"<item>\""
            ;;&
        delete|help)
            echo "usage: $name delete [-q] <item_number>"
            ;;&
        list|help)
            echo "usage: $name list"
            ;;&
        help)
            echo "usage: $name help"
            ;;
    esac
}

throw_error ()
{
    if [ "$#" -gt 1 ]; then
        echo "$name: $2" 1>&2
    fi
    usage "$1"
    exit 1
}

list ()
{
    # Print all except last line which contains meta data
    if [ "$#" -eq 0 ]; then
        sed '$d' "$TODO_PATH"
    else
        throw_error 'list'   
    fi
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

# For renumbering the list
renumber ()
{
    # Iterate through the list of all items
    next=1
    for l in $(grep -En '^\|\| [0-9]+)' "$TODO_PATH" | cut -d ":" -f 1); do
        sed -Ei "$l"'s/[0-9]+/'"$next"'/' "$TODO_PATH"
        next=$((next + 1))
    done

    # Finally fixed the bug... the inline option for sed should be the last option as it can take arguments
}

add ()
{
    is_insertion=0
    is_quiet=0
    # Check for options
    while getopts "i:q" o; do
        case "$o" in
            i)
                # Insert at number
                is_insertion=1
                insert_line="$OPTARG"
                ;;
            q)
                is_quiet=1
                ;;
            *)
                throw_error 'add'
                ;;
        esac
    done

    shift $((OPTIND - 1))

    # Check if item description provided and right number of arguments given
    item=""
    if [ "$#" -eq 1 ]; then
        item="$1"
    elif [ "$#" -eq 0 ]; then
        item=$(cat -)
    else
        throw_error 'add'
    fi

    # If count zero then add first point, else add nth point dependent on count
    if [ "$is_insertion" -eq 0 ]; then
        if [ "$count" -eq 0 ]; then
            sed -i '/||/a\|| 1) '"$item"'\n||' "$TODO_PATH"
        else
            find_item "$count"
            sed -i "$line"' a\||\n|| '$((count + 1))') '"$item" "$TODO_PATH"
        fi

    elif [[ "$insert_line" =~ ^[0-9]+$ ]]; then

        # Check that number is not zero and is within range 
        if [ "$insert_line" -gt 0 ] && [ "$insert_line" -le "$count" ]; then
            find_item "$insert_line"
            sed -i "$line"' i\|| '"$insert_line"') '"$item"'\n||' "$TODO_PATH"

            # Then renumber
            renumber
        else
            throw_error 'add' "line number not found"
        fi
    else
        throw_error 'add'
    fi

    # Replace last line with new count
    sed -i '$d' "$TODO_PATH"
    echo $((count + 1)) >> "$TODO_PATH"

    if [ "$is_quiet" -eq 0 ]; then
       list
    fi
}

edit ()
{
    is_quiet=0
    # Check for options
    while getopts "q" o; do
        case "$o" in
            q)
                is_quiet=1
                ;;
            *)
                throw_error 'add'
                ;;
        esac
    done

    shift $((OPTIND - 1))
    if [ "$#" -eq 2 ] && [[ "$1" =~ ^[0-9]+$ ]]; then
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

    if [ "$is_quiet" -eq 0 ]; then
       list
    fi
}

delete ()
{
    is_quiet=0
    # Check for options
    while getopts "q" o; do
        case "$o" in
            q)
                is_quiet=1
                ;;
            *)
                throw_error 'add'
                ;;
        esac
    done

    # check that argument provided and is number
    if [ "$#" -eq 1 ] && [[ "$1" =~ ^[0-9]+$ ]]; then
        find_item "$1"

        # If not found
        if [ "$line" -eq 0 ]; then
            throw_error 'delete' "Line number not found"
        else
            sed -i "$line"','"$((line + 1 ))"'d' "$TODO_PATH"
        fi

        # And then renumber points :\
        next="$1"
        for ((i=$1+1; i <= count; i++)); do
            find_item "$i"
            sed -i "$line"'s/'"$i"'/'"$next"'/' "$TODO_PATH"
            next=$((next + 1))
        done

        # Update count
        sed -i '$d' "$TODO_PATH"
        echo $((count - 1)) >> "$TODO_PATH"
    else
        throw_error 'delete'
    fi

    if [ "$is_quiet" -eq 0 ]; then
       list
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
    mode="$1"
    shift
    case "$mode" in
        add)
            # Add item
            add "${@}"
            ;;
        edit)
            # Edit item
            edit "${@}"
            ;;
        delete)
            # Delete item
            delete "${@}"
            ;;
        list)
            # List items
            list "${@}"
            ;;
        help|*)
            # Get Help
            usage 'help'
            ;;
    esac
fi
