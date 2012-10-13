\begin{code}

module Factory where

import Dao

class CreatableDao a where
  createItemDao :: a -> IO ItemDao
  createOrderDao :: a -> IO OrderDao

data Factory = DbFactory FilePath | MockFactory deriving (Show)
instance CreatableDao Factory where
  createItemDao (DbFactory filePath) = undefined
  createItemDao MockFactory = undefined
  
  createOrderDao (DbFactory filePath) = undefined
  createOrderDao MockFactory = undefined

\end{code}

// DbFactory.class.php
<?php
require_once 'DaoFactory.class.php';
require_once 'DbItemDao.class.php';
require_once 'DbOrderDao.class.php';
?>
<?php
class DbFactory implements DaoFactory {
    public function createItemDao() {
        return new DbItemDao();
    }
    public function createOrderDao() {
        return new DbOrderDao($this->createItemDao());
    }
}
?>

// MockFactory.class.php
<?php
require_once 'DaoFactory.class.php';
require_once 'MockItemDao.class.php';
require_once 'MockOrderDao.class.php';
?>
<?php
class MockFactory implements DaoFactory {
    public function createItemDao() {
        return new MockItemDao();
    }
    public function createOrderDao() {
        return new MockOrderDao();
    }
}
?>
