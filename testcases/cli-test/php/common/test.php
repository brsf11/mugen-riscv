<!DOCTYPE HTML> 
<html>
    <head>
        <style>
        .error {color: #FF0000;}
        </style>
    </head> 
    <body> 
        <?php
            $nameErr = $emailErr = $genderErr = $websiteErr = "";
            $name = $email = $gender = $comment = $website = "";

            if ($_SERVER["REQUEST_METHOD"] == "POST") {
                if (empty($_POST["name"])) {
                    $nameErr = "Name is required";
                } else {
                    $name = test_input($_POST["name"]);
                    if (!preg_match("/^[a-zA-Z ]*$/",$name)) {
                        $nameErr = "Only letters and spaces are allowed"; 
                    }
                }

                if (empty($_POST["email"])) {
                    $emailErr = "Email is required";
                } else {
                    $email = test_input($_POST["email"]);
                    if (!preg_match("/([\w\-]+\@[\w\-]+\.[\w\-]+)/",$email)) {
                        $emailErr = "Invalid email format"; 
                    }
                }

                if (empty($_POST["website"])) {
                    $website = "";
                } else {
                    $website = test_input($_POST["website"]);
                    if (!preg_match("/(?:(?:https?|ftp):\/\/|www\.)[-a-z0-9+&@#\/%?=~_|!:,.;]*[-a-z0-9+&@#\/%=~_|]/i",$website)) {
                        $websiteErr = "Invalid URL"; 
                    }
                }

                if (empty($_POST["comment"])) {
                    $comment = "";
                } else {
                    $comment = test_input($_POST["comment"]);
                }

                if (empty($_POST["gender"])) {
                    $genderErr = "Gender is a must";
                } else {
                    $gender = test_input($_POST["gender"]);
                }
            }

            function test_input($data) {
                $data = trim($data);
                $data = stripslashes($data);
                $data = htmlspecialchars($data);
                return $data;
            }
        ?>
        <h2>PHP Verification examples</h2>
        <p><span class="error">* Required fields</span></p>
        <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]);?>"> 
            Name：<input type="text" name="name">
            <span class="error">* <?php echo $nameErr;?></span>
            <br><br>
            Email：<input type="text" name="email">
            <span class="error">* <?php echo $emailErr;?></span>
            <br><br>
            Address：<input type="text" name="website">
            <span class="error"><?php echo $websiteErr;?></span>
            <br><br>
            Comment：<textarea name="comment" rows="5" cols="40"></textarea>
            <br><br>
            Gender：
            <input type="radio" name="gender" value="female">female
            <input type="radio" name="gender" value="male">male
            <span class="error">* <?php echo $genderErr;?></span>
            <br><br>
            <input type="submit" name="submit" value="submit"> 
        </form>  
        <?php
            echo "<h2>Your input：</h2>";
            echo $name;
            echo "<br>";
            echo $email;
            echo "<br>";
            echo $website;
            echo "<br>";
            echo $comment;
            echo "<br>";
            echo $gender;
        ?>          
    </body>
</html>
