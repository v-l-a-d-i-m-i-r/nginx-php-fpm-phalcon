<?php

use Phalcon\Mvc\Micro;
use Phalcon\Logger;
use Phalcon\Logger\Adapter\Stream;
use Phalcon\Di\FactoryDefault;

$di = new FactoryDefault();
$app = new Micro();

$di->setShared('logger', function () {
  return new Stream('php://stdout');
});

$app->setDI($di);

$app->get("/", function () use ($app) {
  $app->logger->log('This is a message');

  echo "<h1>Welcome!</h1>";
});

$app->notFound(function () {
  echo "<h1>404!</h1>";
});

$app->error(function (\Exception $e) use ($app) {
  echo $e->getMessage();
});

$app->handle();