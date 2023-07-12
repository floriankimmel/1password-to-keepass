vault=${args[--vault]}
keepassDatabase=${args[--keepass-database]}
keepassSecret=${args[--keepass-secret]}
keepassPassword=$(op item get --vault $vault $keepassSecret --fields label=password)

op item --vault $vault list --format json | jq -r '.[].title' | while IFS= read -r title; do
    if printf '%s\n' "$keepass" | keepassxc-cli search  $keepassDatabase "$title" 2>&1 | grep -q "No results for that search term"; then
        password=$(op item get --vault Podcast "$title" --format json | jq -r '.fields[] | select(.id == "credential" or .id == "password") | .value')
        username=$(op item get --vault Podcast "$title" --format json | jq -r '.fields[] | select(.id == "username") | .value')
        echo -e "\033[31m $title. Erstelle neuen Eintrag\033[0m"
        printf '%s\n%s' "$keepassPassword" "$password" | keepassxc-cli add $keepassDatabase --password-prompt "$title" --username $username

    else
        echo -e "\033[32m $title\033[0m"
    fi
done

