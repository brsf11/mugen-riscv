<?php
    require "lib/lib_a.php";
    show();
    $str = isset($_GET["str"]) ? $_GET["str"] : "hello world";
    include "template/msg.html";
?>