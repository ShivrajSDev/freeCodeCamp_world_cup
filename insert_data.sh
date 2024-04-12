#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams,games;")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    # get winning team
    WINNING_TEAM=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    # if not found
    if [[ -z $WINNING_TEAM ]]
    then
      # insert winning team into teams
      WINNING_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")
      if [[ $WINNING_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams: $WINNER
      fi
      # get new winning team
      WINNING_TEAM=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    fi
    
    # get opponent
    OPPOSING_TEAM=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    # if not found
    if [[ -z $OPPOSING_TEAM ]]
    then
      # insert opposing team into teams
      OPPOSING_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")
      if [[ $OPPOSING_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams: $OPPONENT
      fi
      # get new opponent
      OPPOSING_TEAM=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi
    echo Winner: $WINNING_TEAM, Opponent: $OPPOSING_TEAM

    # insert game data into games
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES ($YEAR,'$ROUND',$WINNING_TEAM,$OPPOSING_TEAM,$WINNER_GOALS,$OPPONENT_GOALS)")
    if [[ INSERT_GAME_RESULT="INSERT 0 1" ]]
    then
      echo Inserted into games: $YEAR,$ROUND,$WINNER,$OPPONENT,$WINNER_GOALS,$OPPONENT_GOALS
    fi
  fi
done