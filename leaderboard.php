<?php
$servername = "localhost";
$username = "root";
$password = "root";
$dbname = "retrosheet";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 

$sql = "select GAME_ID, AWAY_TEAM_ID, HOME_TEAM_ID from events where yearID = 2016;";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // output data of each row
    while($row = $result->fetch_assoc()) {
        echo "gameID: " . $row["gameID"]. " - away_team: " . $row["AWAY_TEAM_ID"]. " HOME_TEAM_ID" . $row["HOME_TEAM_ID"]. "<br>";
    }
} else {
    echo "0 results";
}
?>

here is some php