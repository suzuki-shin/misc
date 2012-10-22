\begin{code}
{-# OPTIONS -Wall #-}
module Queue (Queue(Queue), addCommand, run) where

import Command

data Queue = Queue {getCommands :: [Command], getCurrentIndex :: Int} deriving Show

addCommand :: Queue -> Command -> Queue
addCommand q com = Queue (com:(getCommands q)) (getCurrentIndex q)

run :: Queue -> IO ()
run queue = case next queue of
  Just command -> do
    execute command
    run $ Queue (getCommands queue) ((getCurrentIndex queue) + 1)
  Nothing -> return ()
  where
    next :: Queue -> Maybe Command
    next q = let commands = getCommands q
                 curIndex = getCurrentIndex q
                 commandsLen = length commands
             in case commandsLen  > curIndex of
               True -> Just (commands!!(commandsLen - curIndex - 1))
               False -> Nothing

\end{code}
// Queue.class.php
<?php
require_once 'Command.class.php';
?>
<?php
/**
 * Invokerクラスに相当する
 */
class Queue {
    private $commands;
    private $current_index;
    public function __construct() {
        $this->commands = array();
        $this->current_index = 0;
    }
    public function addCommand(Command $command) {
        $this->commands[] = $command;
    }

    public function run() {
        while (!is_null($command = $this->next())) {
            $command->execute();
        }
    }

    private function next() {
        if (count($this->commands) === 0 ||
            count($this->commands) <= $this->current_index) {
            return null;
        } else {
            return $this->commands[$this->current_index++];
        }
    }
}
?>
