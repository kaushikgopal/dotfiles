function .. --description 'cd .. multiple levels up with n'
    if test (count $argv) -eq 0
        cd ..
    else
        if string match -r '^[0-9]+$' -- $argv[1]
            for i in (seq $argv[1])
                cd ..
            end
        else
            echo "✗ I don't understand !!"
            return 1
        end
    end
end
