
# Sidearm Techical Assessment For Data Engineers

## The Problem

The goal is to create a data pipeline that processes a simplified, in game stream from a simulated a lacrosse game.

### Game Stream 

While the game is going on, there is a file called `gamestream.txt` located in the  `s3/gamestreams` S3 bucket. Each time an in-game event happens, it is appended to this file.
To simplify things, the game stream only reports shots on goal. Here is the format of the file each line is an event and the fields are separated by a space:

```
0 59:51 101 2 0
1 57:06 101 6 0
2 56:13 205 8 1
3 55:25 101 4 0
```

- The first column is the event ID. These are sequential. An event ID of -1 means the game is over.
- The second column is the timestamp of the event in the format `mm:ss`. This counts down to 00:00. For example the first event occured 9 seconds into the game.
- The third column is the team ID, indicating team took the shot on goal. In the simulation there are only two teams, `101` and `205`.
- the fourth colum is the jersey number of the player who took the shot.
- the final column is a `1` if the shot was a goal, `0` if it was a miss.

### Player and Team Reference Data

The player and team reference data is stored in a Microsoft SQL Server database.  The database is called `sidearmdb` . The database has two tables, `players` and `teams` with the following schemas, respectively:

```sql
CREATE TABLE teams (
    id int primary key NOT NULL,
    name VARCHAR(50) NOT NULL,
    conference VARCHAR(50) NOT NULL,
    wins INT NOT NULL,
    losses INT NOT NULL,
)

CREATE TABLE players (
    id int  primary key NOT NULL,
    name VARCHAR(50) NOT NULL,
    number varchar(3) NOT NULL,
    shots INT NOT NULL,
    goals INT NOT NULL,
    teamid INT foreign key references teams(id) NOT NULL,
)
```

The `teams` table, has two teams, `101 = syracuse` and `205 = johns hopkins`.  Each team has a conference affiliation, and a current win / loss record.

The `players` table has 10 players for each team. Each player has a name, jersey number, shots taken, goals scored, along with their team id.

## Your Challenge

As the data engineer you have two tasks:

1. Transforming the game stream and reference data into a real-time box score
2. Updating the database tables when the game is over.

### Part 1: The game stream's real-time box score

Preferrably as events occur, you should write a `boxscore.json` to the `s3/boxscores` S3 bucket. That way sidearm web developers can read the file's contents to render a webpage for live box score stats while the game is going on.

For simplicy, assume team `101` is the home team and team `205` is the away team.  

The JSON file should have the following structure (consider this an example)

```json
{
    "home": {
        "teamid" : 105,
        "conference" : "ACC",
        "wins" : 5,
        "losses" : 2,
        "score" : 3,
        "status" : "winning",
        "players": [
            {"id": 1, "name" : "sam",  "shots" : 3, "goals" : 1, "pct" : 0.33 },
            {"id": 2, "name" : "sarah",  "shots" : 0, "goals" : 0, "pct" : 0.00 },
            {"id": 3, "name" : "steve",  "shots" : 1, "goals" : 1, "pct" : 1.00 },
            ...
        ]
    },
    "away": { ... }
}
```

NOTES:

- `"status"` should be `"winning", "losing" or "tied"` based on the current `home.score` and `away.score`
- Every player on the roster (in the players table) should appear in the box score.
- Calculate the `pct` field so this does not need to happen on the client side.

### Part 2: Updating stats in the datbaase when the game is over

After the game is complete, the table data in the database should be updated, based on the final box score. Specifically:
- update the win/loss record for each team in the `teams` table
- update the shots and goals for each player in the `players` table

## Other Notes

### Setup
You will need to install docker for your operating system. You can use either [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [Rancher Desktop](https://rancherdesktop.io/)

The tech test relies on being able to execute [docker-compose](https://docs.docker.com/compose/) commands from you computer. Docker compose is installed by default with both Docker Desktop and Rancher Desktop

To start the services required to run the application:

```
$ docker-compose up
```

or for daemon mode

```
$ docker-compose up -d 
```

### Controlling the game stream

The game stream can be managed with `docker-compose` commands:

- **Stop the game stream:** `$ docker-compose stop gamestream`
- **View gamesteam activity** `$ docker-compose logs gamestream`
- **Start the game stream:** `$ docker-compose start gamestream`


NOTE: Every time you execute the `stop` command:
- the database tables are reset back to their original state.
- the live game stream located at `s3/gamestreams/gamestream.txt` restarts.
- Anything you write to `s3/boxscores` will remain.

