# supertuxkart-docker

A SuperTuxKart dedicated server in a small container, built from the official sources.
A handful of variables configure it, everything else is decided in game.

## Run

```
cp .env.example .env
docker compose up -d
docker compose logs -f
```

Open UDP port 2759 on your router or firewall, it is the only port used. The commands work
the same with Podman, just replace `docker` with `podman`.

## Settings

Secrets go in `.env`, everything else in `compose.yaml`. Apply a change with `docker compose up -d`.

| Variable | Default | Role |
|---|---|---|
| `STK_SERVER_NAME` | SuperTuxKart Server | server name |
| `STK_MOTD` | empty | message shown in the lobby |
| `STK_MODE` | lan | `wan`: listed in the public server list, needs an STK Online account. `lan`: private, players enter `IP:2759` |
| `STK_ONLINE_USERNAME`, `STK_ONLINE_PASSWORD` | empty | STK Online account used by the server in `wan` mode, in `.env` |
| `STK_PASSWORD` | empty | password players must enter, in `.env` |
| `STK_GAME_MODE` | 3 | starting mode: 3 race, 4 time trial, 6 soccer, 7 free for all, 8 capture the flag |
| `STK_DIFFICULTY` | 1 | starting difficulty: 0 beginner, 1 intermediate, 2 expert, 3 SuperTux |
| `STK_MAX_PLAYERS` | 8 | number of slots |
| `STK_OWNER_LESS` | false | `true`: nobody holds the crown, games start on their own once two players are in |
| `STK_PORT` | 2759 | UDP port, change it in `ports:` too |

Game mode and difficulty are only starting values, the server owner can change them from the
lobby. For any option not listed here, mount your own file at `/data/server_config.xml`; every
option is described in SuperTuxKart's
[NETWORKING.md](https://github.com/supertuxkart/stk-code/blob/master/NETWORKING.md).

## In game

To join: in `wan` mode, *Online, Global networking, Find server*; in `lan` mode,
*Online, Enter server address*, then `IP:2759`. Any SuperTuxKart 1.x client works.

The first player to connect gets the crown. Only they can start the game, kick a player and
change the game mode or difficulty. When they leave, the crown goes to the player who has been
connected the longest. Everyone else picks a kart, votes for the track and the number of laps,
and picks a team in soccer or capture the flag.

In the lobby chat: `/kick name` (owner only), `/spectate 1` to watch without playing,
`/listserveraddon` to list the server's add-ons, `/installaddon id` to install one locally.

## Cheatsheet

| To | Command |
|---|---|
| Start, or apply a change | `docker compose up -d` |
| Update the image | `docker compose pull && docker compose up -d` |
| Follow the logs | `docker compose logs -f` |
| Restart | `docker compose restart` |
| Stop | `docker compose down` |
| Admin console | `docker attach supertuxkart`, then `help`, `listpeers`, `kick <id>`, `kickall`, `quit`. Detach with `Ctrl-P` then `Ctrl-Q`, never `Ctrl-C` |
| Build the image yourself | `docker build -t ghcr.io/tbringuier/supertuxkart-docker .` |
| Add tracks or karts | uncomment the `./addons` volume in `compose.yaml`, put each add-on (a folder containing `track.xml` or `kart.xml`, extracted from the zip found on [online.supertuxkart.net/addons.php](https://online.supertuxkart.net/addons.php)) in `addons/tracks/<id>/` or `addons/karts/<id>/`, then `docker compose up -d` |

## Credits

The environment variable approach comes from
[Sudo-Ivan](https://github.com/Sudo-Ivan/poderized-game-servers)'s SuperTuxKart image.
SuperTuxKart is made by the [SuperTuxKart team](https://supertuxkart.net) under the GPL v3.
This repository was vibe-coded with Claude. Licensed under the WTFPL.
