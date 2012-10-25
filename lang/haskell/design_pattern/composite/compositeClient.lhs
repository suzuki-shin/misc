\begin{code}
import OrganizationEntry

group3 :: OrganizationEntry
group3 = foldl1 add [(Group [] "020" "××支店"),
                     (Employee "02001" "萩原"),
                     (Employee "02002" "田島"),
                     (Employee "02002" "白井")
                    ]
-- group3 = add (add (add (Group [] "020" "××支店") (Employee "02001" "萩原")) (Employee "02002" "田島")) (Employee "02002" "白井")

group2 :: OrganizationEntry
group2 = add (Group [] "110" "XX営業所") (Employee "11001" "川村")

group1 :: OrganizationEntry
group1 = foldl1 add [(Group [] "010" "OO支社"),
                     (Employee "01001" "支店長"),
                     (Employee "01002" "佐々木"),
                     (Employee "01003" "鈴木"),
                     (Employee "01003" "吉田"),
                     group2
                     ]
-- group1 = add (add (add (add (add (Group [] "010" "OO支社") (Employee "01001" "支店長")) (Employee "01002" "佐々木")) (Employee "01003" "鈴木")) (Employee "01003" "吉田")) group2

rootEntry :: OrganizationEntry
rootEntry = foldl1 add [(Group [] "001" "本社"),
                        (Employee "00101" "CEO"),
                        (Employee "00102" "CTO"),
                        group1,
                        group3
                        ]
-- rootEntry = add (add (add (add (Group [] "001" "本社") (Employee "00101" "CEO")) (Employee "00102" "CTO")) group1) group3


main = dump rootEntry


\end{code}
// composite_client.php
<?php
require_once 'Group.class.php';
require_once 'Employee.class.php';
?>
<?php
    /**
     * 木構造を作成
     */
    $root_entry = new Group("001", "本社");
    $root_entry->add(new Employee("00101", "CEO"));
    $root_entry->add(new Employee("00102", "CTO"));

    $group1 = new Group("010", "○○支店");
    $group1->add(new Employee("01001", "支店長"));
    $group1->add(new Employee("01002", "佐々木"));
    $group1->add(new Employee("01003", "鈴木"));
    $group1->add(new Employee("01003", "吉田"));

    $group2 = new Group("110", "△△営業所");
    $group2->add(new Employee("11001", "川村"));
    $group1->add($group2);
    $root_entry->add($group1);

    $group3 = new Group("020", "××支店");
    $group3->add(new Employee("02001", "萩原"));
    $group3->add(new Employee("02002", "田島"));
    $group3->add(new Employee("02002", "白井"));
    $root_entry->add($group3);

    /**
     * 木構造をダンプ
     */
    $root_entry->dump();
?>
