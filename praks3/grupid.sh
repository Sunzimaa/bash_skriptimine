#!/bin/bash

# Funktsioon, et kontrollida, kas grupp eksisteerib
function group_exists {
    if getent group "$1" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Funktsioon, et kontrollida, kas kasutajanimi on sobilik
function is_valid_username {
    if [[ "$1" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        return 0
    else
        return 1
    fi
}

while true; do
    read -p "Sisesta kasutajanimi (või vajuta x, et lõpetada): " username

    # Kontrollime, kas kasutaja soovib lõpetada
    if [[ "$username" == "x" ]]; then
        echo "Skript lõpetatakse."
        break
    fi

    # Kontrollime, kas kasutajanimi on sobilik
    if ! is_valid_username "$username"; then
        echo "Viga: Kasutajanimi peab olema sobilik (ainult tähed, numbrid, punktid, allajooned ja sidekriipsud)."
        continue
    fi

    read -p "Sisesta grupi nimi (opilased/opetajad): " group

    # Kontrollime, kas grupp on olemas
    if ! group_exists "$group"; then
        echo "Viga: Grupp '$group' ei eksisteeri. Palun sisesta 'opilased' või 'opetajad'."
        continue
    fi

    # Loome kasutaja
    sudo useradd -m -s /bin/bash -g "$group" "$username"
    if [ $? -ne 0 ]; then
        echo "Viga: Kasutaja '$username' loomisel tekkis probleem."
        continue
    fi

    # Määrame parooli
    read -sp "Sisesta parool kasutajale '$username': " password
    echo
    echo "$username:$password" | sudo chpasswd

    # Seletav kirjeldus
    home_dir=$(getent passwd "$username" | cut -d: -f6)
    echo "Kasutaja '$username' on loodud."
    echo "Grupp: $group"
    echo "Kodukataloog: $home_dir"
    echo "Parool: $password"
    echo "-----------------------------"
done
