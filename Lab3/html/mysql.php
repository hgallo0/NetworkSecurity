<?php
$servername = "mysql";
$username = "root";
$password = "test";
$dbname = "network";
#$keywords = isset($_GET['keywords']) ? '%'.$_GET['keywords'].'%' : '';
$keywords = isset($_GET['keywords']) ? ' '.$_GET['keywords'].' ' : '';

print "<h2>Inventory</h2>";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 

#$sql = "SELECT equip_id, type, install_date, color FROM equipment";
#$sql = "SELECT $keywords FROM equipment";
$sql = "select equip_id, type,color,install_date from equipment where equip_id = $keywords;";
$result = $conn->query($sql);


if ($result->num_rows > 0) {
    // output data of each row
    while($row = $result->fetch_assoc()) {
        echo "id: " . $row["equip_id"].  " - Type: " . $row["type"]. " " . $row["install_date"]. " " . $row["location"] . "<br>";
#      printf ("%s (%s)\n", "id: " . $row["equip_id"].  " - Type: " . $row["type"]. " " . $row["install_date"]);
    }
} else {
    echo "0 results";
}
$conn->close();
?>
