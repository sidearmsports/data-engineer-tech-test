
# Sidearm Techical Assessment For Data Engineers


## The Problem

The goal is to create a data pipeline that processes a simplified, in game stream from a simulated a lacrosse game.

### Game Stream 

While the game is going on, there is a file called `gamestream.txt` located in the  `s3/gamestreams` S3 bucket. Each time an in-game event happens, it is appended to this file.
To simplify things, thee game stream only reports shots on goal. Here is the format of the file each line is an event and the fields are separated by a space:

```
0 59:51 101 2 0
1 57:06 101 6 0
2 56:13 205 8 1
3 55:25 101 4 0
```

- The first column is the event ID. These are sequential. An event ID of -1 means the game is over.
- The second column is the timestamp of the event in the format `mm:ss`. For example the first event occured 9 seconds into the game.
- the next column is the team ID, which team took the shot on goal. In the simulation there are only two teams, 101 and 205.
- the next colum is the jersey number of the player who took the shot.
- the final column is a 1 if the shot was a goal, 0 if it was a miss.

## Player and Team Reference Data

The player and team reference data is stored in a Microsoft SQL Server database.  The database is called `sidearmdb` . The database has two tables, `players` and `teams` with the following schema:

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

The `teams` table, has two teams, `101 = syracuse` and `205 = johns hopkins`.  Each team has a conference affiliation, and  current win / loss record.
The `players` table has 10 players for each team. Each playerhas a name, jersey number, shots taken, goals scored, along with their team id.

## The Challenge to you.

### Part 1: The Game Stream's real-time box score

Preferrably as events occur, you should write a `boxscore.json` to the `s3/boxscores` S3 bucket. Sidearm web developers can read the file's contents to render a webpage for live box score for the game while the game is going on.

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



This file is a stream of events that occur during the game.  The events are separated by newlines.  Each event is separaed b a comma separated list of values.  The first value is the event type, the second is the timestamp, and the third is the player id.  The event types are:


The task (solution.py)

- write a script to run every X seconds
- watch the s3/gamestreams directory for new files
- when a new gameid.csv arrives in s3/gamestreams
- add a row to the games table, calculating the home/away scores
- create boxscore gameid.json is s3/boxscores
  structure should be:
    gameid: 1234
    home: {
        teamid: 1,
        score: 16,
        status: winning
        players: [
            {playerid: 1, shots: 10, points 15, pct: 0.67},
            {playerid: 2, shots: 5, points 1, pct: 0.20},
            ...
        ]
    },
    away: {
        teamid: 2,
        score: 6,
        status: losing
        players: [
            {playerid: 1, shots: 10, points 5, pct: 0.50},
            {playerid: 2, shots: 8, points 1, pct: 0.125},
            ...
        ]
    }

- write the boxscore.json with the same gameid as the feed in real time from the feed and the
    reference data in the database.

- do not edit any existing tables or the data therein

### TO RESTART THE GAME STREAM / RESET THE DATABASE

Every time you execute this command, the database tables are game stream is reset back to the beginning of the game. Anything you write to `s3/boxscores` will remain.

`docker-compose run gamestream`