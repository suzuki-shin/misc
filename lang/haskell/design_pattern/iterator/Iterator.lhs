\begin{code}

module Iterator where

data Employee = Employee {getName :: String, getAge :: Int, getJob :: String} deriving (Show)
data Employees = Employees {getEmployees :: [Employee]} deriving (Show)



\end{code}

// Employee.class.php
<?php
class Employee {
    private $name;
    private $age;
    private $job;
    public function __construct($name, $age, $job) {
        $this->name = $name;
        $this->age = $age;
        $this->job = $job;
    }
    public function getName() {
        return $this->name;
    }
    public function getAge() {
        return $this->age;
    }
    public function getJob() {
        return $this->job;
    }
}
?>

// Employees.class.php
<?php
require_once 'Employee.class.php';
?>
<?php
class Employees implements IteratorAggregate {
    private $employees;
    public function __construct() {
        $this->employees = new ArrayObject();
    }
    public function add(Employee $employee) {
        $this->employees[] = $employee;
    }
    public function getIterator() {
        return $this->employees->getIterator();
    }
}
?>

// SalesmanIterator.class.php
<?php
require_once 'Employee.class.php';
?>
<?php
class SalesmanIterator extends FilterIterator {
    public function __construct($iterator) {
        parent::__construct($iterator);
    }

    public function accept() {
        $employee = $this->current();
        return ($employee->getJob() === 'SALESMAN');
    }
}
