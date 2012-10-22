\begin{code}
module OrganizationEntry (OrganizationEntry(Group, Employee), add, dump) where

data OrganizationEntry = Group {getEntries :: [OrganizationEntry], getCode :: String, getName :: String}
                       | Employee {getCode :: String, getName :: String}
                       deriving Show
add :: OrganizationEntry -> OrganizationEntry -> OrganizationEntry
add (Group entries code name) entryChild = Group (entryChild:entries) code name
add _ _ = error "method not allowed"

dump :: OrganizationEntry -> IO ()
dump (Group (e:es) c n) = do
  dump e
  dump $ Group es c n
dump (Group [] c n) = return ()
dump (Employee code name) = putStrLn $ code ++ ":" ++ name

\end{code}
// OrganizationEntry.class.php
<?php
/**
 * Componentクラスに相当する
 */
abstract class OrganizationEntry {

    private $code;
    private $name;

    public function __construct($code, $name) {
        $this->code = $code;
        $this->name = $name;
    }

    public function getCode() {
        return $this->code;
    }

    public function getName() {
        return $this->name;
    }

    /**
     * 子要素を追加する
     * ここでは抽象メソッドとして用意
     */
    public abstract function add(OrganizationEntry $entry);

    /**
     * 組織ツリーを表示する
     * サンプルでは、デフォルトの実装を用意
     */
    public function dump() {
        echo $this->code . ":" . $this->name . "<br>\n";
    }
}
?>

// Group.class.php
<?php
require_once 'OrganizationEntry.class.php';
?>
<?php
/**
 * Compositeクラスに相当する
 */
class Group extends OrganizationEntry {

    private $entries;

    public function __construct($code, $name) {
        parent::__construct($code, $name);
        $this->entries = array();
    }

    /**
     * 子要素を追加する
     */
    public function add(OrganizationEntry $entry) {
        array_push($this->entries, $entry);
    }

    /**
     * 組織ツリーを表示する
     * 自分自身と保持している子要素を表示
     */
    public function dump() {
        parent::dump();
        foreach ($this->entries as $entry) {
            $entry->dump();
        }
    }
}
?>

// Employee.class.php
<?php
require_once 'OrganizationEntry.class.php';
?>
<?php
/**
 * Leafクラスに相当する
 */
class Employee extends OrganizationEntry {

    public function __construct($code, $name) {
        parent::__construct($code, $name);
    }

    /**
     * 子要素を追加する
     * Leafクラスは子要素を持たないので、例外を発生させている
     */
    public function add(OrganizationEntry $entry) {
        throw new Exception('method not allowed');
    }
}
?>
