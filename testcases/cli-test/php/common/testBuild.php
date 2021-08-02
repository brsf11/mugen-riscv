<?php
    $phar = new Phar('test.phar', 0, 'test.phar');
    $phar->buildFromDirectory(dirname(__FILE__) . '/project');
    $phar->setDefaultStub('index.php', 'index.php');
?>