#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Resets the index to 1
echo $($PSQL "TRUNCATE TABLE games, teams ")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")
echo $($PSQL "ALTER SEQUENCE games_opponent_id_seq RESTART WITH 1")
echo $($PSQL "ALTER SEQUENCE games_winner_id_seq RESTART WITH 1")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")

# populate the teams table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS

do
  # checks if this is a title row
  if [[ $OPPONENT != opponent ]]
  then
    # get team_name: first winner, then opponent
    TEAM_NAME=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    TEAM_NAME2=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    
    # if team_name not found in winner
    if [[ -z $TEAM_NAME ]]
    then
      # insert team
      INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      TEAM_NAME=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")

      if [[ $INSERT_TEAM_NAME == "INSERT 0 1" ]]
      then 
        echo "Inserted into teams, $OPPONENT"
      fi
    fi

    # if team_name not found in opponent  
    if [[ -z $TEAM_NAME2 ]]
    then
      # insert team
      INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      TEAM_NAME=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")

      if [[ $INSERT_TEAM_NAME == "INSERT 0 1" ]]
      then 
        echo "Inserted into teams, $WINNER"
      fi
    fi

  fi
done

# populate the games table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS

do 
  # Skip title row
  if [[ $YEAR != year ]]
  then 
    # Set winner_id and opponent_id to the team_id from the teams table
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")"
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")" 
    # Insert the results
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
    VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
    if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
    then
      echo Inserted $YEAR $ROUND Successfully!
    fi  
  fi
done
